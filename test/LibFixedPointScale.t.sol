// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibFixedPointScale.sol";

contract LibFixedPointScaleTest is Test {
    function testScaleDownRoundDown(uint256 a_, uint256 scaleDownBy_, uint256 rounding_) public {
        vm.assume(rounding_ != ROUND_UP);
        vm.assume(scaleDownBy_ <= MAX_RESCALE_OOMS);

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_  = a_ / b_;

        assertEq(c_, LibFixedPointScale.scaleDown(a_, scaleDownBy_, rounding_));
    }

    function testScaleDownRoundUp(uint256 a_, uint256 scaleDownBy_) public {
        vm.assume(scaleDownBy_ <= MAX_RESCALE_OOMS);

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;
        // If division was not clean then expect rounding up.
        if (c_ * b_ != a_) {
            c_ = c_ + 1;
        }

        assertEq(c_, LibFixedPointScale.scaleDown(a_, scaleDownBy_, ROUND_UP));
    }

    function testScaleDownOverflow(uint256 a_, uint256 scaleDownBy_, uint256 rounding_) public {
        vm.assume(scaleDownBy_ > MAX_RESCALE_OOMS);

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointScale.scaleDown(a_, scaleDownBy_, rounding_);
    }
}
