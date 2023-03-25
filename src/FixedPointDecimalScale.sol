// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "./FixedPointDecimalConstants.sol";

/// @title FixedPointDecimalScale
/// @notice Tools to scale unsigned values to/from 18 decimal fixed point
/// representation.
///
/// Overflows error and underflows are rounded up or down explicitly.
///
/// The max uint256 as decimal is roughly 1e77 so scaling values comparable to
/// 1e18 is unlikely to ever overflow in most contexts. For a typical use case
/// involving tokens, the entire supply of a token rescaled up a full 18 decimals
/// would still put it "only" in the region of ~1e40 which has a full 30 orders
/// of magnitude buffer before running into saturation issues. However, there's
/// no theoretical reason that a token or any other use case couldn't use large
/// numbers or extremely precise decimals that would push this library to
/// overflow point, so it MUST be treated with caution around the edge cases.
///
/// Scaling down ANY fixed point decimal also reduces the precision which can
/// lead to  dust or in the worst case trapped funds if subsequent subtraction
/// overflows a rounded-down number. Consider using saturating subtraction for
/// safety against previously downscaled values, and whether trapped dust is a
/// significant issue. If you need to retain full/arbitrary precision in the case
/// of downscaling DO NOT use this library.
///
/// All rescaling and/or division operations in this library require a rounding
/// flag. This allows and forces the caller to specify where dust sits due to
/// rounding. For example the caller could round up when taking tokens from
/// `msg.sender` and round down when returning them, ensuring that any dust in
/// the round trip accumulates in the contract rather than opening an exploit or
/// reverting and trapping all funds. This is exactly how the ERC4626 vault spec
/// handles dust and is a good reference point in general. Typically the contract
/// holding tokens and non-interactive participants should be favoured by
/// rounding calculations rather than active participants. This is because we
/// assume that an active participant, e.g. `msg.sender`, knowns something we
/// don't and is carefully crafting an attack, so we are most conservative and
/// suspicious of their inputs and actions.
library FixedPointDecimalScale {
    /// Scales `a_` up by a specified number of decimals.
    /// @param a_ The number to scale up.
    /// @param scaleUpBy_ Number of orders of magnitude to scale `b_` up by.
    /// Errors if overflows.
    /// @return b_ `a_` scaled up by `scaleUpBy_`.
    function scaleUp(uint256 a_, uint256 scaleUpBy_) internal pure returns (uint256 b_) {
        // Checked power is expensive so don't do that.
        unchecked {
            b_ = 10 ** scaleUpBy_;
        }
        b_ = a_ * b_;

        // We know exactly when 10 ** X overflows so replay the checked version
        // to get the standard Solidity overflow behaviour. The branching logic
        // here is still ~230 gas cheaper than unconditionally running the
        // overflow checks. We're optimising for standardisation rather than gas
        // in the unhappy revert case.
        if (scaleUpBy_ >= OVERFLOW_RESCALE_OOMS) {
            10 ** scaleUpBy_;
        }
    }

    /// Identical to `scaleUp` but saturates instead of reverting on overflow.
    /// Note that if `scaleUpBy_` exceeds `OVERFLOW_RESCALE_OOMS` then this WILL
    /// still overflow.
    /// @param a_ As per `scaleUp`.
    /// @param scaleUpBy_ As per `scaleUp`.
    /// @return c_ As per `scaleUp` but saturates as `type(uint256).max` on
    /// overflow.
    function scaleUpSaturating(uint256 a_, uint256 scaleUpBy_) internal pure returns (uint256 c_) {
        // Adapted from saturatingMath.
        // Inlining everything here saves ~250-300+ gas relative to slow.
        unchecked {
            uint256 b_ = 10 ** scaleUpBy_;
            c_ = a_ * b_;
            // Checking b_ here allows us to skip an "is zero" check because even
            // 10 ** 0 = 1, so we have a positive lower bound on b_.
            c_ = c_ / b_ != a_ ? type(uint256).max : c_;
        }

        // Same overflow replay `scaleUp`
        if (scaleUpBy_ >= OVERFLOW_RESCALE_OOMS) {
            10 ** scaleUpBy_;
        }
    }

    /// Scales `a_` down by a specified number of decimals, rounding in the
    /// specified direction. Used internally by several other functions in this
    /// lib.
    /// @param a_ The number to scale down.
    /// @param scaleDownBy_ Number of orders of magnitude to scale `a_` down by.
    /// Overflows if greater than 77.
    /// @param rounding_ Rounding direction. Unknown values are treated as
    /// rounding DOWN.
    /// @return `a_` scaled down by `scaleDownBy_` and rounded.
    function scaleDown(uint256 a_, uint256 scaleDownBy_, uint256 rounding_) internal pure returns (uint256) {
        uint256 b_ = 10 ** scaleDownBy_;
        uint256 scaled_ = a_ / b_;
        // Intentionally doing a divide before multiply here to detect the need
        // to round up.
        //slither-disable-next-line divide-before-multiply
        if (rounding_ == ROUND_UP && a_ != scaled_ * b_) {
            scaled_ += 1;
        }
        return scaled_;
    }

    /// Scale a fixed point decimal of some scale factor to 18 decimals.
    /// @param a_ Some fixed point decimal value.
    /// @param aDecimals_ The number of fixed decimals of `a_`.
    /// @param rounding_ Rounding direction.
    /// @return `a_` scaled to 18 decimals.
    function scale18(uint256 a_, uint256 aDecimals_, uint256 rounding_) internal pure returns (uint256) {
        uint256 decimals_;
        if (FIXED_POINT_DECIMALS > aDecimals_) {
            unchecked {
                decimals_ = FIXED_POINT_DECIMALS - aDecimals_;
            }
            a_ = scaleUp(a_, decimals_);
        } else if (FIXED_POINT_DECIMALS < aDecimals_) {
            unchecked {
                decimals_ = aDecimals_ - FIXED_POINT_DECIMALS;
            }
            a_ = scaleDown(a_, decimals_, rounding_);
        }
        return a_;
    }

    /// Scale an 18 decimal fixed point value to some other scale.
    /// @param a_ An 18 decimal fixed point number.
    /// @param targetDecimals_ The new scale of `a_`.
    /// @param rounding_ Rounding direction.
    /// @return `a_` rescaled from 18 to `targetDecimals_`.
    function scaleN(uint256 a_, uint256 targetDecimals_, uint256 rounding_) internal pure returns (uint256) {
        uint256 decimals_;
        if (targetDecimals_ == FIXED_POINT_DECIMALS) {
            return a_;
        } else if (FIXED_POINT_DECIMALS > targetDecimals_) {
            unchecked {
                decimals_ = FIXED_POINT_DECIMALS - targetDecimals_;
            }
            return scaleDown(a_, decimals_, rounding_);
        } else {
            unchecked {
                decimals_ = targetDecimals_ - FIXED_POINT_DECIMALS;
            }
            return scaleUp(a_, decimals_);
        }
    }

    /// Scale an 18 decimal fixed point ratio of a_:b_ according to the decimals
    /// of a and b that each MAY NOT be 18.
    /// i.e. a subsequent call to `a_.fixedPointMul(ratio_)` would yield the
    /// value that it would have as though `a_` and `b_` were both 18 decimals
    /// and we hadn't rescaled the ratio.
    /// @param ratio_ The ratio to be scaled.
    /// @param aDecimals_ The decimals of the ratio numerator.
    /// @param bDecimals_ The decimals of the ratio denominator.
    /// @param rounding_ Rounding direction.
    function scaleRatio(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 rounding_)
        internal
        pure
        returns (uint256)
    {
        return scaleBy(ratio_, int8(bDecimals_) - int8(aDecimals_), rounding_);
    }

    /// Scale a fixed point up or down by `scaleBy_` orders of magnitude.
    /// Notably `scaleBy` is a SIGNED integer so scaling down by negative OOMS
    /// is supported.
    /// @param a_ Some integer of any scale.
    /// @param scaleBy_ OOMs to scale `a_` up or down by. This is a SIGNED int8
    /// which means it can be negative, and also means that sign extension MUST
    /// be considered if changing it to another type.
    /// @param rounding_ Rounding direction.
    /// @return `a_` rescaled according to `scaleBy_`.
    function scaleBy(uint256 a_, int8 scaleBy_, uint256 rounding_) internal pure returns (uint256) {
        if (scaleBy_ == 0) {
            return a_;
        } else if (scaleBy_ > 0) {
            return scaleUp(a_, uint8(scaleBy_));
        } else {
            uint256 scaleDownBy_;
            unchecked {
                scaleDownBy_ = uint8(-1 * scaleBy_);
            }
            return scaleDown(a_, scaleDownBy_, rounding_);
        }
    }
}
