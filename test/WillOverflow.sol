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

    function scaleDownWillOverflow(uint256 scaleDownBy_) internal pure returns (bool) {
        return scaleDownBy_ >= OVERFLOW_RESCALE_OOMS;
    }

    function scaleDownWillRound(uint256 a_, uint256 scaleDownBy_) internal pure returns (bool) {
        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;
        return c_ * b_ != a_;
    }

    function scaleRatioWillOverflow(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 rounding_)
        internal
        returns (bool)
    {
        if (18 + uint256(bDecimals_) < aDecimals_) {
            return true;
        }

        if (scaleUpWillOverflow(ratio_, 18 + uint256(bDecimals_) - uint256(aDecimals_))) {
            return true;
        }

        // I think this is more a limit of the fuzz test than the underlying.
        // @todo relax this constraint somehow.
        if (scaleDownWillOverflow(bDecimals_)) {
            return true;
        }

        int8 diff_ = int8(bDecimals_) - int8(aDecimals_);
        if (diff_ == 0) {
            return false;
        } else if (diff_ > 0) {
            return scaleUpWillOverflow(ratio_, uint8(diff_));
        } else {
            // Don't have forge stdMath.abs in a library, need to convert the
            // negative diff ourselves bitwise.
            return scaleDownWillOverflow(uint8(~diff_) + 1);
        }
    }
}
