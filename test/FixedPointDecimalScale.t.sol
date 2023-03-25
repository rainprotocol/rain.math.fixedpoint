// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalConstants.sol";
import "../src/FixedPointDecimalScale.sol";

contract FixedPointDecimalScaleTest is Test {
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
        vm.assume(scaleDownBy_ > MAX_RESCALE_OOMS);

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleDown(a_, scaleDownBy_, rounding_);
    }

    function testScaleDown0(uint256 a_, uint256 rounding_) public {
        assertEq(a_, FixedPointDecimalScale.scaleDown(a_, 0, rounding_));
    }

    function testScaleBy0(uint256 a_, uint256 rounding_) public {
        assertEq(a_, FixedPointDecimalScale.scaleBy(a_, 0, rounding_));
    }

    function testScaleByUp(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ > 0);
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, uint8(scaleBy_)));

        assertEq(
            FixedPointDecimalScale.scaleUp(a_, uint256(uint8(scaleBy_))),
            FixedPointDecimalScale.scaleBy(a_, scaleBy_, rounding_)
        );
    }

    function testScaleByUpOverflow(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ > 0);
        vm.assume(WillOverflow.scaleUpWillOverflow(a_, uint8(scaleBy_)));
        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleBy(a_, scaleBy_, rounding_);
    }

    function testScaleByDown(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ < 0);
        vm.assume(stdMath.abs(scaleBy_) <= MAX_RESCALE_OOMS);

        assertEq(
            FixedPointDecimalScale.scaleBy(a_, scaleBy_, rounding_),
            FixedPointDecimalScale.scaleDown(a_, stdMath.abs(scaleBy_), rounding_)
        );
    }

    function testScaleByOverflow(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(stdMath.abs(scaleBy_) > MAX_RESCALE_OOMS);

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleBy(a_, scaleBy_, rounding_);
    }

    function testScaleN18(uint256 a_, uint256 rounding_) public {
        assertEq(a_, FixedPointDecimalScale.scaleN(a_, 18, rounding_));
    }

    function testScaleNLt18(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
        vm.assume(targetDecimals_ < 18);

        uint256 scaleDown_ = 18 - targetDecimals_;

        assertEq(
            FixedPointDecimalScale.scaleN(a_, targetDecimals_, rounding_),
            FixedPointDecimalScale.scaleDown(a_, scaleDown_, rounding_)
        );
    }

    function testScaleNGt18(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
        vm.assume(targetDecimals_ > 18);

        uint256 scaleUp_ = targetDecimals_ - 18;
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUp_));

        assertEq(
            FixedPointDecimalScale.scaleN(a_, targetDecimals_, rounding_), FixedPointDecimalScale.scaleUp(a_, scaleUp_)
        );
    }

    function testScaleNGt18Overflow(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
        vm.assume(targetDecimals_ > 18);

        uint256 scaleUp_ = targetDecimals_ - 18;
        vm.assume(WillOverflow.scaleUpWillOverflow(a_, scaleUp_));
        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleN(a_, targetDecimals_, rounding_);
    }

    function testScaleRatioFuzz(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 rounding_) public {
        vm.assume(!WillOverflow.scaleRatioWillOverflow(ratio_, aDecimals_, bDecimals_, rounding_));

        assertEq(
            FixedPointDecimalScale.scaleRatio(ratio_, aDecimals_, bDecimals_, rounding_),
            FixedPointDecimalScale.scaleDown(ratio_ * (10 ** (18 + bDecimals_ - aDecimals_)), 18, rounding_)
        );
    }

    // Ported from legacy tests.
    function testScaleRatioExamples() public {
        assertEq(FixedPointDecimalScale.scaleRatio(1e18, 6, 18, ROUND_DOWN), 1e30);
        assertEq(FixedPointDecimalScale.scaleRatio(1e18, 18, 6, ROUND_DOWN), 1e6);
        assertEq(FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 10, ROUND_UP), 1_00000_00000_003676);
        assertEq(FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 10, 12, ROUND_UP), 1_00000_00000_00367589_00);
        assertEq(FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 12, ROUND_UP), 1_00000_00000_00367589);
        assertEq(FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 10, ROUND_DOWN), 1_00000_00000_003675);
        assertEq(
            FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 10, 12, ROUND_DOWN), 1_00000_00000_00367589_00
        );
        assertEq(FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 12, ROUND_DOWN), 1_00000_00000_00367589);
        assertEq(FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 18, 0, ROUND_DOWN), 1);
        assertEq(
            FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 0, 18, ROUND_DOWN),
            1_00000_00000_00367589_000000_000000_000000
        );
    }

    // @todo This DOES NOT reliably overflow because the `scaleRatioWillOverflow`
    // function is too conservative. If it was accurate then this fuzz would
    // pass.
    //
    // function testScaleRatioFuzzOverflow(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 rounding_) public {
    //     vm.assume(scaleRatioWillOverflow(ratio_, aDecimals_, bDecimals_, rounding_));

    //     vm.expectRevert(stdError.arithmeticError);
    //     FixedPointScale.scaleRatio(ratio_, aDecimals_, bDecimals_, rounding_);
    // }
}
