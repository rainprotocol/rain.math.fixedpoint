// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibFixedPointScale.sol";

contract LibFixedPointScaleTest is Test {
    function scaleUp(uint256 a_, uint256 scaleBy_) internal returns (uint256) {
        return a_ * (10 ** scaleBy_);
    }

    function testScaleDownRoundDown(uint256 a_, uint256 scaleDownBy_, uint256 rounding_) public {
        vm.assume(rounding_ != ROUND_UP);
        vm.assume(scaleDownBy_ <= MAX_RESCALE_OOMS);

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;

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

    function testScaleDown0(uint256 a_, uint256 rounding_) public {
        assertEq(a_, LibFixedPointScale.scaleDown(a_, 0, rounding_));
    }

    function testScaleBy0(uint256 a_, uint256 rounding_) public {
        assertEq(a_, LibFixedPointScale.scaleBy(a_, 0, rounding_));
    }

    function testScaleByUp(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ > 0);
        vm.assume(uint8(scaleBy_) <= MAX_RESCALE_OOMS);

        unchecked {
            uint256 b_ = 10 ** uint8(scaleBy_);
            uint256 c_ = a_ * b_;
            vm.assume(c_ / b_ == a_);
        }

        assertEq(
            scaleUp(a_, uint256(uint8(scaleBy_))),
            LibFixedPointScale.scaleBy(a_, scaleBy_, rounding_)
        );
    }

    function testScaleByDown(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ < 0);
        vm.assume(stdMath.abs(scaleBy_) <= MAX_RESCALE_OOMS);

        assertEq(
            LibFixedPointScale.scaleBy(a_, scaleBy_, rounding_),
            LibFixedPointScale.scaleDown(a_, stdMath.abs(scaleBy_), rounding_)
        );
    }

    function testScaleByOverflow(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(stdMath.abs(scaleBy_) > MAX_RESCALE_OOMS);

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointScale.scaleBy(a_, scaleBy_, rounding_);
    }
}
