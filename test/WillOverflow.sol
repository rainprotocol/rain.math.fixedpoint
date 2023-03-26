// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../src/FixedPointDecimalConstants.sol";

library WillOverflow {
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
        if (scaleBy_ > 0) {
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
            if (bDecimals_ - aDecimals_ > uint8(type(int8).max)) {
                return true;
            }

            if (FLAG_SATURATE & flags_ == 0) {
                return scaleUpWillOverflow(ratio_, bDecimals_ - aDecimals_);
            }
        }

        if (aDecimals_ > bDecimals_) {
            if (aDecimals_ - bDecimals_ > 128) {
                return true;
            }
        }

        return false;
    }
}
