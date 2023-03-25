// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../src/FixedPointConstants.sol";

/// @title LibFixedPointScaleSlow
/// @notice Slow but more obviously correct versions of all functions in
/// LibFixedPointScale.
///
/// Generally the functions here are slower because they include more jumps
/// because they are DRY. However, scaling values can easily be on a hot gas path
/// so we MAY inline a lot of the logic which makes them WETter. The slow and
/// fast version MAY be identical.
library LibFixedPointScaleSlow {
    function scaleUpSlow(uint256 a_, uint256 scaleUpBy_) internal pure returns (uint256) {
        return a_ * (10 ** scaleUpBy_);
    }

    function scaleDownSlow(uint256 a_, uint256 scaleDownBy_, uint256 rounding_) internal pure returns (uint256) {
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

    function scale18Slow(uint256 a_, uint256 decimals_, uint256 rounding_) internal pure returns (uint256) {
        if (FIXED_POINT_DECIMALS == decimals_) {
            return a_;
        }

        if (FIXED_POINT_DECIMALS > decimals_) {
            scaleUpSlow(a_, FIXED_POINT_DECIMALS - decimals_);
        }

        if (decimals_ > FIXED_POINT_DECIMALS) {
            scaleDownSlow(a_, decimals_ - FIXED_POINT_DECIMALS, rounding_);
        }
    }
}