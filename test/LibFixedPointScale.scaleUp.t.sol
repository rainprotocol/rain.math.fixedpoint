// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./LibWillOverflow.sol";
import "../src/LibFixedPointScale.sol";
import "./LibFixedPointScaleSlow.sol";

contract LibFixedPointScaleTestScaleUp is Test {
    function testScaleUp(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(LibFixedPointScaleSlow.scaleUpSlow(a_, scaleUpBy_), LibFixedPointScale.scaleUp(a_, scaleUpBy_));
    }

    function testScaleUpOverflow(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointScale.scaleUp(a_, scaleUpBy_);
    }
}