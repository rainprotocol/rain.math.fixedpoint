// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/FixedPointDecimalScale.sol";
import "./WillOverflow.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleDown is Test {
    function testScaleDownReferenceImplementation(uint256 a_, uint8 scaleDownBy_) public {
        assertEq(
            FixedPointDecimalScaleSlow.scaleDownSlow(a_, scaleDownBy_),
            FixedPointDecimalScale.scaleDown(a_, scaleDownBy_)
        );
    }

    function testScaleDownNoRound(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!WillOverflow.scaleDownWillRound(a_, scaleDownBy_));

        assertEq(
            FixedPointDecimalScale.scaleDown(a_, scaleDownBy_),
            FixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_)
        );
    }

    function testScaleDownOverflow(uint256 a_, uint256 scaleDownBy_) public {
        vm.assume(scaleDownBy_ >= OVERFLOW_RESCALE_OOMS);

        assertEq(0, FixedPointDecimalScale.scaleDown(a_, scaleDownBy_));
    }

    function testScaleDown0(uint256 a_) public {
        assertEq(a_, FixedPointDecimalScale.scaleDown(a_, 0));
    }

    function testScaleDownGas0() public {
        FixedPointDecimalScale.scaleDown(0, 13);
    }

    function testScaleDownGas2() public {
        FixedPointDecimalScale.scaleDown(0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13);
    }

    function testScaleDownGasSlow0() public {
        FixedPointDecimalScaleSlow.scaleDownSlow(0, 13);
    }

    function testScaleDownGasSlow2() public {
        FixedPointDecimalScaleSlow.scaleDownSlow(0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13);
    }
}
