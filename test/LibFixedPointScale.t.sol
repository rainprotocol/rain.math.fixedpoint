// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibFixedPointScale.sol";

contract LibFixedPointScaleTest is Test {
    function testScaleDownRoundDown(uint256 a_, uint256 scaleDownBy_, uint256 rounding_) {
        vm.pauseGasMetering();
        vm.assume(rounding_ != ROUND_UP);

        vm.resumeGasMetering();
        uint256 actual_ = LibFixedPointScale.scaleDown(a_, scaleDownBy_, rounding_);
        vm.pauseGasMetering();
    }
}