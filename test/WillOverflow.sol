// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../src/FixedPointDecimalConstants.sol";

library WillOverflow {
    /// Relevant logic taken direct from Open Zeppelin.
    function mulDivWillOverflow(uint256 x, uint256 y, uint256 denominator) internal pure returns (bool) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly ("memory-safe") {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }
        return !(denominator > prod1);
    }

    function scaleUpWillOverflow(uint256 a_, uint256 scaleBy_) internal pure returns (bool) {
        unchecked {
            if (a_ == 0) {
                return false;
            }
            if (scaleBy_ >= OVERFLOW_RESCALE_OOMS) {
                return true;
            }
            uint256 b_ = 10 ** scaleBy_;
            uint256 c_ = a_ * b_;
            return c_ / b_ != a_;
        }
    }

    function scaleDownWillRound(uint256 a_, uint256 scaleDownBy_) internal pure returns (bool) {
        if (scaleDownBy_ >= OVERFLOW_RESCALE_OOMS) {
            return a_ != 0;
        }
        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;
        return c_ * b_ != a_;
    }

    function scale18WillOverflow(uint256 a_, uint256 decimals_, uint256 flags_) internal pure returns (bool) {
        if (decimals_ < FIXED_POINT_DECIMALS && (FLAG_SATURATE & flags_ == 0)) {
            return scaleUpWillOverflow(a_, FIXED_POINT_DECIMALS - decimals_);
        } else {
            return false;
        }
    }

    function scaleNWillOverflow(uint256 a_, uint256 decimals_, uint256 flags_) internal pure returns (bool) {
        if (decimals_ > FIXED_POINT_DECIMALS && (FLAG_SATURATE & flags_ == 0)) {
            return scaleUpWillOverflow(a_, decimals_ - FIXED_POINT_DECIMALS);
        } else {
            return false;
        }
    }

    function scaleByWillOverflow(uint256 a_, int8 scaleBy_, uint256 flags_) internal pure returns (bool) {
        // If we're scaling up and not saturating check the overflow.
        if (scaleBy_ > 0 && (FLAG_SATURATE & flags_ == 0)) {
            return scaleUpWillOverflow(a_, uint8(scaleBy_));
        } else {
            return false;
        }
    }

    function scaleRatioWillOverflow(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 flags_)
        internal
        pure
        returns (bool)
    {
        if (bDecimals_ > aDecimals_) {
            if (FLAG_SATURATE & flags_ == 0) {
                return scaleUpWillOverflow(ratio_, bDecimals_ - aDecimals_);
            }
        }

        return false;
    }
}
