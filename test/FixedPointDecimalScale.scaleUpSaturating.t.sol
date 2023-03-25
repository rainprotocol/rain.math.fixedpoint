// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalScale.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUpSaturating is Test {
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

    function testScaleUpSaturatingGas0() public pure {
        FixedPointDecimalScale.scaleUpSaturating(123, 5);
    }

    function testScaleUpSaturatingGas1() public pure {
        FixedPointDecimalScale.scaleUpSaturating(0, 7);
    }

    // This hits saturation
    function testScaleUpSaturatingGas2() public pure {
        FixedPointDecimalScale.scaleUpSaturating(
            11579208924889540434846052544353396039762338070540290210999787421892, 11
        );
    }

    function testScaleUpSaturatingSlowGas0() public pure {
        FixedPointDecimalScaleSlow.scaleUpSaturatingSlow(123, 5);
    }

    function testScaleUpSaturatingSlowGas1() public pure {
        FixedPointDecimalScaleSlow.scaleUpSaturatingSlow(0, 7);
    }

    // This hits saturation
    function testScaleUpSaturatingSlowGas2() public pure {
        FixedPointDecimalScaleSlow.scaleUpSaturatingSlow(
            11579208924889540434846052544353396039762338070540290210999787421892, 11
        );
    }
}
