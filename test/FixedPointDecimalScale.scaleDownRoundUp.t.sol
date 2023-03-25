// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/FixedPointDecimalScale.sol";
import "./WillOverflow.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleDown is Test {
    function testScaleDownReferenceImplementation(uint256 a_, uint8 scaleDownBy_) public {
        assertEq(
            FixedPointDecimalScaleSlow.scaleDownRoundUpSlow(a_, scaleDownBy_),
            FixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_)
        );
    }

    function testScaleDownRoundUpNoRound(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!WillOverflow.scaleDownWillRound(a_, scaleDownBy_));

        assertEq(
            FixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_),
            FixedPointDecimalScale.scaleDown(a_, scaleDownBy_)
        );
    }

    function testScaleDownRoundUpOverflow0(uint256 scaleDownBy_) public {
        vm.assume(scaleDownBy_ >= OVERFLOW_RESCALE_OOMS);

        assertEq(0, FixedPointDecimalScale.scaleDownRoundUp(0, scaleDownBy_));
    }

    function testScaleDownRoundUpOverflow(uint256 a_, uint256 scaleDownBy_) public {
        vm.assume(a_ > 0);
        vm.assume(scaleDownBy_ >= OVERFLOW_RESCALE_OOMS);

        assertEq(1, FixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_));
    }

    function testScaleDownRoundUpGas1() public pure {
        FixedPointDecimalScale.scaleDownRoundUp(0, 13);
    }

    function testScaleDownRoundUpGas3() public pure {
        FixedPointDecimalScale.scaleDownRoundUp(0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13);
    }

    function testScaleDownRoundUpGasSlow1() public pure {
        FixedPointDecimalScaleSlow.scaleDownRoundUpSlow(0, 13);
    }

    function testScaleDownRoundUpGasSlow3() public pure {
        FixedPointDecimalScaleSlow.scaleDownRoundUpSlow(
            0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13
        );
    }
}
