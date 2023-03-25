// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalScale.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUp is Test {
    // Special case for scale = 0 is that input = output.
    function testScaleUp0(uint256 a_) public {
        assertEq(a_, FixedPointDecimalScale.scaleUp(a_, 0));
    }

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

    // Special case for scale = 0 is that input = output.
    function testScaleUpSaturating0(uint256 a_) public {
        assertEq(a_, FixedPointDecimalScale.scaleUpSaturating(a_, 0));
    }

    function testScaleUpSaturating(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(scaleUpBy_ < OVERFLOW_RESCALE_OOMS);

        assertEq(
            FixedPointDecimalScaleSlow.scaleUpSaturatingSlow(a_, scaleUpBy_),
            FixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_)
        );
    }

    function testScaleUpSaturatingParity(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(
            FixedPointDecimalScale.scaleUp(a_, scaleUpBy_), FixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_)
        );
    }

    function testScaleUpGas0() public {
        FixedPointDecimalScale.scaleUp(123, 5);
    }

    function testScaleUpGas1() public {
        FixedPointDecimalScale.scaleUp(0, 7);
    }

    function testScaleUpSaturatingGas0() public {
        FixedPointDecimalScale.scaleUpSaturating(123, 5);
    }

    function testScaleUpSaturatingGas1() public {
        FixedPointDecimalScale.scaleUpSaturating(0, 7);
    }

    // This hits saturation
    function testScaleUpSaturatingGas2() public {
        FixedPointDecimalScale.scaleUpSaturating(
            11579208924889540434846052544353396039762338070540290210999787421892, 11
        );
    }

    function testScaleUpSlowGas0() public {
        FixedPointDecimalScaleSlow.scaleUpSlow(123, 5);
    }

    function testScaleUpSlowGas1() public {
        FixedPointDecimalScaleSlow.scaleUpSlow(0, 7);
    }

    function testScaleUpSaturatingSlowGas0() public {
        FixedPointDecimalScaleSlow.scaleUpSaturatingSlow(123, 5);
    }

    function testScaleUpSaturatingSlowGas1() public {
        FixedPointDecimalScaleSlow.scaleUpSaturatingSlow(0, 7);
    }

    // This hits saturation
    function testScaleUpSaturatingSlowGas2() public {
        FixedPointDecimalScaleSlow.scaleUpSaturatingSlow(
            11579208924889540434846052544353396039762338070540290210999787421892, 11
        );
    }
}
