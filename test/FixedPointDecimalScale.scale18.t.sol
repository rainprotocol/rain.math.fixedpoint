// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalScale.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScale18 is Test {
    function testScale18ReferenceImplementation(uint256 a_,uint256 decimals_, uint256 rounding_) public {
        vm.assume(!WillOverflow.scale18WillOverflow(a_, decimals_));

        assertEq(
            FixedPointDecimalScaleSlow.scale18Slow(a_, decimals_, rounding_),
            FixedPointDecimalScale.scale18(a_, decimals_, rounding_)
        );
    }

    function testScale1818(uint256 a_, uint256 rounding_) public {
        assertEq(a_, FixedPointDecimalScale.scale18(a_, 18, rounding_));
    }

    function testScale18Lt(uint256 a_, uint256 decimals_, uint256 rounding_) public {
        vm.assume(decimals_ < 18);

        uint256 scaleUp_ = 18 - decimals_;
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUp_));

        assertEq(
            FixedPointDecimalScale.scaleUp(a_, scaleUp_), FixedPointDecimalScale.scale18(a_, decimals_, rounding_)
        );
    }

    function testScale18LtOverflow(uint256 a_, uint8 aDecimals_, uint256 rounding_) public {
        vm.assume(aDecimals_ < 18);

        uint256 scaleUp_ = 18 - aDecimals_;
        vm.assume(WillOverflow.scaleUpWillOverflow(a_, scaleUp_));

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scale18(a_, aDecimals_, rounding_);
    }

    function testScale18Gt(uint256 a_, uint8 aDecimals_, uint256 rounding_) public {
        vm.assume(aDecimals_ > 18);

        uint256 scaleDown_ = aDecimals_ - 18;
        vm.assume(!WillOverflow.scaleDownWillOverflow(scaleDown_));

        assertEq(
            FixedPointDecimalScale.scaleDown(a_, scaleDown_, rounding_),
            FixedPointDecimalScale.scale18(a_, aDecimals_, rounding_)
        );
    }

    function testScale18GtOverflow(uint256 a_, uint8 aDecimals_, uint256 rounding_) public {
        vm.assume(aDecimals_ > 18);

        uint256 scaleDown_ = aDecimals_ - 18;
        vm.assume(WillOverflow.scaleDownWillOverflow(scaleDown_));
        vm.expectRevert(stdError.arithmeticError);

        FixedPointDecimalScale.scale18(a_, aDecimals_, rounding_);
    }
}
