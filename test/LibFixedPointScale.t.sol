// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibFixedPointScale.sol";

contract LibFixedPointScaleTest is Test {
    function scaleUp(uint256 a_, uint256 scaleBy_) internal returns (uint256) {
        return a_ * (10 ** scaleBy_);
    }

    function scaleUpWillOverflow(uint256 a_, uint256 scaleBy_) internal returns (bool) {
        unchecked {
            if (scaleBy_ > MAX_RESCALE_OOMS) {
                return true;
            }
            uint256 b_ = 10 ** scaleBy_;
            uint256 c_ = a_ * b_;
            return c_ / b_ != a_;
        }
    }

    function scaleDownWillOverflow(uint256 a_, uint256 scaleDownBy_) internal returns (bool) {
        return scaleDownBy_ > MAX_RESCALE_OOMS;
    }

    function scaleDownWillRound(uint256 a_, uint256 scaleDownBy_) internal returns (bool) {
        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;
        return c_ * b_ != a_;
    }

    function testScaleDownRoundDown(uint256 a_, uint8 scaleDownBy_, uint256 rounding_) public {
        vm.assume(rounding_ != ROUND_UP);
        vm.assume(!scaleDownWillOverflow(a_, scaleDownBy_));

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;

        assertEq(c_, LibFixedPointScale.scaleDown(a_, scaleDownBy_, rounding_));
    }

    function testScaleDownRoundUp(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!scaleDownWillOverflow(a_, scaleDownBy_));

        uint256 b_ = 10 ** scaleDownBy_;
        uint256 c_ = a_ / b_;
        // If division was not clean then expect rounding up.
        if (c_ * b_ != a_) {
            c_ = c_ + 1;
        }

        assertEq(c_, LibFixedPointScale.scaleDown(a_, scaleDownBy_, ROUND_UP));
    }

    function testScaleDownNoRound(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!scaleDownWillOverflow(a_, scaleDownBy_));
        vm.assume(!scaleDownWillRound(a_, scaleDownBy_));

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
        vm.assume(!scaleUpWillOverflow(a_, uint8(scaleBy_)));

        assertEq(
            scaleUp(a_, uint256(uint8(scaleBy_))),
            LibFixedPointScale.scaleBy(a_, scaleBy_, rounding_)
        );
    }

    function testScaleByUpOverflow(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
        vm.assume(scaleBy_ > 0);
        vm.assume(scaleUpWillOverflow(a_, uint8(scaleBy_)));
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
        assertEq(
            a_,
            LibFixedPointScale.scaleN(a_, 18, rounding_)
        );
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
        vm.assume(!scaleUpWillOverflow(a_, scaleUp_));

        assertEq(
            LibFixedPointScale.scaleN(a_, targetDecimals_, rounding_),
            scaleUp(a_, scaleUp_)
        );
    }
}
