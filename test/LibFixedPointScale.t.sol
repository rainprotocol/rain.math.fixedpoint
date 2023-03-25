// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./LibWillOverflow.sol";
import "../src/FixedPointConstants.sol";
import "../src/LibFixedPointScale.sol";

contract LibFixedPointScaleTest is Test {



    function testScaleDownRoundDown(uint256 a_, uint8 scaleDownBy_, uint256 rounding_) public {
        vm.assume(rounding_ != ROUND_UP);
        vm.assume(!LibWillOverflow.scaleDownWillOverflow(scaleDownBy_));

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;

        assertEq(c_, LibFixedPointScale.scaleDown(a_, scaleDownBy_, rounding_));
    }

    function testScaleDownRoundUp(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!LibWillOverflow.scaleDownWillOverflow(scaleDownBy_));

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;
        // If division was not clean then expect rounding up.
        if (c_ * b_ != a_) {
            c_ = c_ + 1;
        }

        assertEq(c_, LibFixedPointScale.scaleDown(a_, scaleDownBy_, ROUND_UP));
    }

    function testScaleDownNoRound(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!LibWillOverflow.scaleDownWillOverflow(scaleDownBy_));
        vm.assume(!LibWillOverflow.scaleDownWillRound(a_, scaleDownBy_));

        assertEq(
            LibFixedPointScale.scaleDown(a_, scaleDownBy_, ROUND_DOWN),
            LibFixedPointScale.scaleDown(a_, scaleDownBy_, ROUND_UP)
        );
    }

    function testScaleDownOverflow(uint256 a_, uint256 scaleDownBy_, uint256 rounding_) public {
        vm.assume(scaleDownBy_ > MAX_RESCALE_OOMS);

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointScale.scaleDown(a_, scaleDownBy_, rounding_);
    }

    function testScaleDown0(uint256 a_, uint256 rounding_) public {
        assertEq(a_, LibFixedPointScale.scaleDown(a_, 0, rounding_));
    }

    function testScaleBy0(uint256 a_, uint256 rounding_) public {
        assertEq(a_, LibFixedPointScale.scaleBy(a_, 0, rounding_));
    }

    function testScaleByUp(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ > 0);
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a_, uint8(scaleBy_)));

        assertEq(
            LibFixedPointScale.scaleUp(a_, uint256(uint8(scaleBy_))),
            LibFixedPointScale.scaleBy(a_, scaleBy_, rounding_)
        );
    }

    function testScaleByUpOverflow(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ > 0);
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a_, uint8(scaleBy_)));
        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointScale.scaleBy(a_, scaleBy_, rounding_);
    }

    function testScaleByDown(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ < 0);
        vm.assume(stdMath.abs(scaleBy_) <= MAX_RESCALE_OOMS);

        assertEq(
            LibFixedPointScale.scaleBy(a_, scaleBy_, rounding_),
            LibFixedPointScale.scaleDown(a_, stdMath.abs(scaleBy_), rounding_)
        );
    }

    function testScaleByOverflow(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(stdMath.abs(scaleBy_) > MAX_RESCALE_OOMS);

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointScale.scaleBy(a_, scaleBy_, rounding_);
    }

    function testScaleN18(uint256 a_, uint256 rounding_) public {
        assertEq(a_, LibFixedPointScale.scaleN(a_, 18, rounding_));
    }

    function testScaleNLt18(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
        vm.assume(targetDecimals_ < 18);

        uint256 scaleDown_ = 18 - targetDecimals_;

        assertEq(
            LibFixedPointScale.scaleN(a_, targetDecimals_, rounding_),
            LibFixedPointScale.scaleDown(a_, scaleDown_, rounding_)
        );
    }

    function testScaleNGt18(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
        vm.assume(targetDecimals_ > 18);

        uint256 scaleUp_ = targetDecimals_ - 18;
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a_, scaleUp_));

        assertEq(LibFixedPointScale.scaleN(a_, targetDecimals_, rounding_), LibFixedPointScale.scaleUp(a_, scaleUp_));
    }

    function testScaleNGt18Overflow(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
        vm.assume(targetDecimals_ > 18);

        uint256 scaleUp_ = targetDecimals_ - 18;
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a_, scaleUp_));
        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointScale.scaleN(a_, targetDecimals_, rounding_);
    }

    function testScaleRatioFuzz(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 rounding_) public {
        vm.assume(!LibWillOverflow.scaleRatioWillOverflow(ratio_, aDecimals_, bDecimals_, rounding_));

        assertEq(
            LibFixedPointScale.scaleRatio(ratio_, aDecimals_, bDecimals_, rounding_),
            LibFixedPointScale.scaleDown(ratio_ * (10 ** (18 + bDecimals_ - aDecimals_)), 18, rounding_)
        );
    }

    // Ported from legacy tests.
    function testScaleRatioExamples() public {
        assertEq(LibFixedPointScale.scaleRatio(1e18, 6, 18, ROUND_DOWN), 1e30);
        assertEq(LibFixedPointScale.scaleRatio(1e18, 18, 6, ROUND_DOWN), 1e6);
        assertEq(LibFixedPointScale.scaleRatio(1_00000_00000_00367589, 12, 10, ROUND_UP), 1_00000_00000_003676);
        assertEq(LibFixedPointScale.scaleRatio(1_00000_00000_00367589, 10, 12, ROUND_UP), 1_00000_00000_00367589_00);
        assertEq(LibFixedPointScale.scaleRatio(1_00000_00000_00367589, 12, 12, ROUND_UP), 1_00000_00000_00367589);
        assertEq(LibFixedPointScale.scaleRatio(1_00000_00000_00367589, 12, 10, ROUND_DOWN), 1_00000_00000_003675);
        assertEq(LibFixedPointScale.scaleRatio(1_00000_00000_00367589, 10, 12, ROUND_DOWN), 1_00000_00000_00367589_00);
        assertEq(LibFixedPointScale.scaleRatio(1_00000_00000_00367589, 12, 12, ROUND_DOWN), 1_00000_00000_00367589);
        assertEq(LibFixedPointScale.scaleRatio(1_00000_00000_00367589, 18, 0, ROUND_DOWN), 1);
        assertEq(LibFixedPointScale.scaleRatio(1_00000_00000_00367589, 0, 18, ROUND_DOWN), 1_00000_00000_00367589_000000_000000_000000);
    }

    // @todo This DOES NOT reliably overflow because the `scaleRatioWillOverflow`
    // function is too conservative. If it was accurate then this fuzz would
    // pass.
    //
    // function testScaleRatioFuzzOverflow(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 rounding_) public {
    //     vm.assume(scaleRatioWillOverflow(ratio_, aDecimals_, bDecimals_, rounding_));

    //     vm.expectRevert(stdError.arithmeticError);
    //     LibFixedPointScale.scaleRatio(ratio_, aDecimals_, bDecimals_, rounding_);
    // }
}
