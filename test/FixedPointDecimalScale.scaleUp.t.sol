// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalScale.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUp is Test {
    function testScaleUp(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(FixedPointDecimalScaleSlow.scaleUpSlow(a_, scaleUpBy_), FixedPointDecimalScale.scaleUp(a_, scaleUpBy_));
    }

    function testScaleUpOverflow(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleUp(a_, scaleUpBy_);

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleUp(a_, OVERFLOW_RESCALE_OOMS);
    }

    function testScaleUpGas0() public {
        FixedPointDecimalScale.scaleUp(123, 5);
    }

    function testScaleUpGas1() public {
        FixedPointDecimalScale.scaleUp(0, 7);
    }

    function testScaleUpSlowGas0() public {
        FixedPointDecimalScaleSlow.scaleUpSlow(123, 5);
    }

    function testScaleUpSlowGas1() public {
        FixedPointDecimalScaleSlow.scaleUpSlow(0, 7);
    }
}
