// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../src/FixedPointDecimalConstants.sol";

library WillOverflow {
    function scaleUpWillOverflow(uint256 a_, uint256 scaleBy_) internal pure returns (bool) {
        unchecked {
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

    function scale18WillOverflow(uint256 a_, uint256 decimals_) internal pure returns (bool) {
        if (decimals_ < FIXED_POINT_DECIMALS) {
            return scaleUpWillOverflow(a_, FIXED_POINT_DECIMALS - decimals_);
        } else {
            return false;
        }
    }

    function scaleRatioWillOverflow(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_) internal pure returns (bool) {
        if (18 + uint256(bDecimals_) < aDecimals_) {
            return true;
        }

        if (scaleUpWillOverflow(ratio_, 18 + uint256(bDecimals_) - uint256(aDecimals_))) {
            return true;
        }

        int8 diff_ = int8(bDecimals_) - int8(aDecimals_);
        if (diff_ > 0) {
            return scaleUpWillOverflow(ratio_, uint8(diff_));
        } else {
            return false;
        }
    }
}
