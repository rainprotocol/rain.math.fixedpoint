// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalScale.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleBy is Test {
    function testScaleByReferenceImplementation(uint256 a_, int8 scaleBy_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        vm.assume(!WillOverflow.scaleByWillOverflow(a_, scaleBy_));

        assertEq(
            FixedPointDecimalScaleSlow.scaleBySlow(a_, scaleBy_, flags_),
            FixedPointDecimalScale.scaleBy(a_, scaleBy_, flags_)
        );
    }

    function testScaleBy0(uint256 a_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);

        assertEq(a_, FixedPointDecimalScale.scaleBy(a_, 0, flags_));
    }

    function testScaleByUp(uint256 a_, int8 scaleBy_, uint256 flags_) public {
        // Keep rounding flag.
        flags_ = flags_ & FLAG_ROUND_UP;
        vm.assume(scaleBy_ > 0);
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, uint8(scaleBy_)));

        assertEq(
            FixedPointDecimalScale.scaleUp(a_, uint8(scaleBy_)), FixedPointDecimalScale.scaleBy(a_, scaleBy_, flags_)
        );
    }

    function testScaleByUpOverflow(uint256 a_, int8 scaleBy_, uint256 flags_) public {
        // Keep rounding flag.
        flags_ = flags_ & FLAG_ROUND_UP;
        vm.assume(scaleBy_ > 0);
        vm.assume(WillOverflow.scaleUpWillOverflow(a_, uint8(scaleBy_)));
        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scaleBy(a_, scaleBy_, flags_);
    }

    function testScaleByUpSaturate(uint256 a_, int8 scaleBy_, uint256 flags_) public {
        // Keep rounding flag.
        flags_ = FLAG_SATURATE | (flags_ & FLAG_ROUND_UP);
        vm.assume(scaleBy_ > 0);

        assertEq(
            FixedPointDecimalScale.scaleUpSaturating(a_, uint8(scaleBy_)),
            FixedPointDecimalScale.scaleBy(a_, scaleBy_, flags_)
        );
    }

    function testScaleByDown(uint256 a_, int8 scaleBy_, uint256 flags_) public {
        // Keep saturate flag.
        flags_ = flags_ & FLAG_SATURATE;
        vm.assume(scaleBy_ < 0);

        assertEq(
            FixedPointDecimalScale.scaleBy(a_, scaleBy_, flags_),
            FixedPointDecimalScale.scaleDown(a_, stdMath.abs(scaleBy_))
        );
    }

    function testScaleByDownRoundUp(uint256 a_, int8 scaleBy_, uint256 flags_) public {
        // Keep saturate flag.
        flags_ = FLAG_ROUND_UP | (flags_ & FLAG_SATURATE);
        vm.assume(scaleBy_ < 0);

        assertEq(
            FixedPointDecimalScale.scaleBy(a_, scaleBy_, flags_),
            FixedPointDecimalScale.scaleDownRoundUp(a_, stdMath.abs(scaleBy_))
        );
    }
}
