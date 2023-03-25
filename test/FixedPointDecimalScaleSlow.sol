// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.math.saturating/SaturatingMath.sol";
import "../src/FixedPointDecimalConstants.sol";

/// @title FixedPointDecimalScaleSlow
/// @notice Slow but more obviously correct versions of all functions in
/// FixedPointScale.
///
/// Generally the functions here are slower because they include more jumps
/// because they are DRY. However, scaling values can easily be on a hot gas path
/// so we MAY inline a lot of the logic which makes them WETter. The slow and
/// fast version MAY be identical.
library FixedPointDecimalScaleSlow {
    function scaleUpSlow(uint256 a_, uint256 scaleUpBy_) internal pure returns (uint256) {
        return a_ * (10 ** scaleUpBy_);
    }

    function scaleUpSaturatingSlow(uint256 a_, uint256 scaleUpBy_) internal pure returns (uint256) {
        return SaturatingMath.saturatingMul(a_, 10 ** scaleUpBy_);
    }

    function scaleDownSlow(uint256 a_, uint256 scaleDownBy_) internal pure returns (uint256) {
        if (scaleDownBy_ >= OVERFLOW_RESCALE_OOMS) {
            return 0;
        }
        return a_ / (10 ** scaleDownBy_);
    }

    function scaleDownRoundUpSlow(uint256 a_, uint256 scaleDownBy_) internal pure returns (uint256) {
        if (scaleDownBy_ >= OVERFLOW_RESCALE_OOMS) {
            if (a_ == 0) {
                return 0;
            } else {
                return 1;
            }
        }
        uint256 b_ = (10 ** scaleDownBy_);
        uint256 c_ = a_ / b_;
        if (c_ * b_ != a_) {
            c_ += 1;
        }
        return c_;
    }

    function scale18Slow(uint256 a_, uint256 decimals_, uint256 flags_) internal pure returns (uint256) {
        if (FIXED_POINT_DECIMALS > decimals_) {
            uint256 scaleUpBy_ = FIXED_POINT_DECIMALS - decimals_;
            if (flags_ & FLAG_SATURATE != 0) {
                return scaleUpSaturatingSlow(a_, scaleUpBy_);
            } else {
                return scaleUpSlow(a_, scaleUpBy_);
            }
        }

        if (decimals_ > FIXED_POINT_DECIMALS) {
            uint256 scaleDownBy_ = decimals_ - FIXED_POINT_DECIMALS;
            if (flags_ & FLAG_ROUND_UP != 0) {
                return scaleDownRoundUpSlow(a_, scaleDownBy_);
            } else {
                return scaleDownSlow(a_, scaleDownBy_);
            }
        }

        return a_;
    }
}
