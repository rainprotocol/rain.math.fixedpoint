// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalScale.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleN is Test {
    function testScaleNReferenceImplementation(uint256 a_, uint256 decimals_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        vm.assume(!WillOverflow.scaleNWillOverflow(a_, decimals_));

        assertEq(
            FixedPointDecimalScaleSlow.scaleNSlow(a_, decimals_, flags_),
            FixedPointDecimalScale.scaleN(a_, decimals_, flags_)
        );
    }

    function testScaleN18(uint256 a_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        assertEq(a_, FixedPointDecimalScale.scale18(a_, FIXED_POINT_DECIMALS, flags_));
    }

    function testScaleNLt18(uint256 a_, uint8 targetDecimals_, uint256 flags_) public {
        // Only keep saturating flags.
        flags_ = flags_ & FLAG_SATURATE;
        vm.assume(targetDecimals_ < FIXED_POINT_DECIMALS);

        uint256 scaleDownBy_ = FIXED_POINT_DECIMALS - targetDecimals_;

        assertEq(
            FixedPointDecimalScale.scaleN(a_, targetDecimals_, flags_),
            FixedPointDecimalScale.scaleDown(a_, scaleDownBy_)
        );
    }

    function testScaleNLt18RoundUp(uint256 a_, uint8 targetDecimals_, uint256 flags_) public {
        // Keep saturating flags.
        flags_ = FLAG_ROUND_UP | flags_ & FLAG_SATURATE;
        vm.assume(targetDecimals_ < FIXED_POINT_DECIMALS);

        uint256 scaleDownBy_ = FIXED_POINT_DECIMALS - targetDecimals_;

        assertEq(
            FixedPointDecimalScale.scaleN(a_, targetDecimals_, flags_),
            FixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_)
        );
    }

    function testScaleNGt18(uint256 a_, uint8 targetDecimals_, uint256 flags_) public {
        // Keep rounding flag
        flags_ = flags_ & FLAG_ROUND_UP;
        vm.assume(targetDecimals_ > FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = targetDecimals_ - FIXED_POINT_DECIMALS;
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(
            FixedPointDecimalScale.scaleN(a_, targetDecimals_, flags_),
            FixedPointDecimalScale.scaleUp(a_, scaleUpBy_)
        );
    }

    function testScaleNGt18Overflow(uint256 a_, uint8 targetDecimals_, uint256 flags_) public {
        // Keep rounding flag
        flags_ = flags_ & FLAG_ROUND_UP;
        vm.assume(targetDecimals_ > FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = targetDecimals_ - FIXED_POINT_DECIMALS;
        vm.assume(WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleN(a_, targetDecimals_, flags_);
    }

    function testScaleNGt18Saturate(uint256 a_, uint8 targetDecimals_, uint256 flags_) public {
        // Keep rounding flag
        flags_ = FLAG_SATURATE | flags_ & FLAG_ROUND_UP;
        vm.assume(targetDecimals_ > FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = targetDecimals_ - FIXED_POINT_DECIMALS;

        assertEq(
            FixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_),
            FixedPointDecimalScale.scaleN(a_, targetDecimals_, flags_)
        );
    }

}
