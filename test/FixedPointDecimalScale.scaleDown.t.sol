// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/FixedPointDecimalScale.sol";
import "./WillOverflow.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleDown is Test {
    function testScaleDownReferenceImplementation(uint256 a_, uint8 scaleDownBy_, uint256 rounding_) public {
        vm.assume(!WillOverflow.scaleDownWillOverflow(scaleDownBy_));

        assertEq(
            FixedPointDecimalScaleSlow.scaleDownSlow(a_, scaleDownBy_, rounding_),
            FixedPointDecimalScale.scaleDown(a_, scaleDownBy_, rounding_)
        );
    }

    function testScaleDownRoundDown(uint256 a_, uint8 scaleDownBy_, uint256 rounding_) public {
        vm.assume(rounding_ != ROUND_UP);
        vm.assume(!WillOverflow.scaleDownWillOverflow(scaleDownBy_));

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;

        assertEq(c_, FixedPointDecimalScale.scaleDown(a_, scaleDownBy_, rounding_));
    }

    function testScaleDownRoundUp(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!WillOverflow.scaleDownWillOverflow(scaleDownBy_));

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;
        // If division was not clean then expect rounding up.
        if (c_ * b_ != a_) {
            c_ = c_ + 1;
        }

        assertEq(c_, FixedPointDecimalScale.scaleDown(a_, scaleDownBy_, ROUND_UP));
    }

    function testScaleDownNoRound(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!WillOverflow.scaleDownWillOverflow(scaleDownBy_));
        vm.assume(!WillOverflow.scaleDownWillRound(a_, scaleDownBy_));

        assertEq(
            FixedPointDecimalScale.scaleDown(a_, scaleDownBy_, ROUND_DOWN),
            FixedPointDecimalScale.scaleDown(a_, scaleDownBy_, ROUND_UP)
        );
    }

    function testScaleDownOverflow(uint256 a_, uint256 scaleDownBy_, uint256 rounding_) public {
        vm.assume(scaleDownBy_ >= OVERFLOW_RESCALE_OOMS);

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleDown(a_, scaleDownBy_, rounding_);
    }

    function testScaleDown0(uint256 a_, uint256 rounding_) public {
        assertEq(a_, FixedPointDecimalScale.scaleDown(a_, 0, rounding_));
    }

    function testScaleDownGas0() public {
        FixedPointDecimalScale.scaleDown(0, 13, ROUND_DOWN);
    }

    function testScaleDownGas1() public {
        FixedPointDecimalScale.scaleDown(0, 13, ROUND_UP);
    }

    function testScaleDownGas2() public {
        FixedPointDecimalScale.scaleDown(0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13, ROUND_DOWN);
    }

    function testScaleDownGas3() public {
        FixedPointDecimalScale.scaleDown(0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13, ROUND_UP);
    }

    function testScaleDownGasSlow0() public {
        FixedPointDecimalScaleSlow.scaleDownSlow(0, 13, ROUND_DOWN);
    }

    function testScaleDownGasSlow1() public {
        FixedPointDecimalScaleSlow.scaleDownSlow(0, 13, ROUND_UP);
    }

    function testScaleDownGasSlow2() public {
        FixedPointDecimalScaleSlow.scaleDownSlow(0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13, ROUND_DOWN);
    }

    function testScaleDownGasSlow3() public {
        FixedPointDecimalScaleSlow.scaleDownSlow(0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13, ROUND_UP);
    }
}