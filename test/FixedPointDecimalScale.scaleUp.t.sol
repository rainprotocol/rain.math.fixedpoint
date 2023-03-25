// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalScale.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUp is Test {
    // Special case for scale = 0 is that input = output.
    function testScaleUpBy0(uint256 a_) public {
        assertEq(a_, FixedPointDecimalScale.scaleUp(a_, 0));
    }

    function testScaleUp0(uint256 scaleUpBy_) public {
        // scaling up 0 will never overflow.
        assertEq(0, FixedPointDecimalScale.scaleUp(0, scaleUpBy_));
    }

    function testScaleUp(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(FixedPointDecimalScaleSlow.scaleUpSlow(a_, scaleUpBy_), FixedPointDecimalScale.scaleUp(a_, scaleUpBy_));
    }

    function testScaleUpOverflow(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleUp(a_, scaleUpBy_);
    }

    function testScaleUpOverflowBoundary(uint256 a_) public {
        vm.assume(a_ > 0);
        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleUp(a_, OVERFLOW_RESCALE_OOMS);
    }

    function testScaleUpSaturatingParity(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(
            FixedPointDecimalScale.scaleUp(a_, scaleUpBy_), FixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_)
        );
    }

    function testScaleUpGas0() public pure {
        FixedPointDecimalScale.scaleUp(123, 5);
    }

    function testScaleUpGas1() public pure {
        FixedPointDecimalScale.scaleUp(0, 7);
    }

    function testScaleUpSlowGas0() public pure {
        FixedPointDecimalScaleSlow.scaleUpSlow(123, 5);
    }

    function testScaleUpSlowGas1() public pure {
        FixedPointDecimalScaleSlow.scaleUpSlow(0, 7);
    }
}
