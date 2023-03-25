// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./LibWillOverflow.sol";
import "../src/LibFixedPointScale.sol";

contract LibFixedPointScaleTestScale18 is Test {

    function testScale1818(uint256 a_, uint256 rounding_) public {
        assertEq(a_, LibFixedPointScale.scale18(a_, 18, rounding_));
    }

    function testScale18Lt(uint256 a_, uint256 aDecimals_, uint256 rounding_) public {
        vm.assume(aDecimals_ < 18);

        uint256 scaleUp_ = 18 - aDecimals_;
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a_, scaleUp_));

        assertEq(LibFixedPointScale.scaleUp(a_, scaleUp_), LibFixedPointScale.scale18(a_, aDecimals_, rounding_));
    }

    function testScale18LtOverflow(uint256 a_, uint8 aDecimals_, uint256 rounding_) public {
        vm.assume(aDecimals_ < 18);

        uint256 scaleUp_ = 18 - aDecimals_;
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a_, scaleUp_));

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointScale.scale18(a_, aDecimals_, rounding_);
    }

    function testScale18Gt(uint256 a_, uint8 aDecimals_, uint256 rounding_) public {
        vm.assume(aDecimals_ > 18);

        uint256 scaleDown_ = aDecimals_ - 18;
        vm.assume(!LibWillOverflow.scaleDownWillOverflow(scaleDown_));

        assertEq(
            LibFixedPointScale.scaleDown(a_, scaleDown_, rounding_),
            LibFixedPointScale.scale18(a_, aDecimals_, rounding_)
        );
    }

    function testScale18GtOverflow(uint256 a_, uint8 aDecimals_, uint256 rounding_) public {
        vm.assume(aDecimals_ > 18);

        uint256 scaleDown_ = aDecimals_ - 18;
        vm.assume(LibWillOverflow.scaleDownWillOverflow(scaleDown_));
        vm.expectRevert(stdError.arithmeticError);

        LibFixedPointScale.scale18(a_, aDecimals_, rounding_);
    }
}