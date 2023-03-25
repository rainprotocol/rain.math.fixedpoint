// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalScale.sol";
import "./FixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScale18 is Test {
    function testScale18ReferenceImplementation(uint256 a_, uint256 decimals_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        vm.assume(!WillOverflow.scale18WillOverflow(a_, decimals_));

        assertEq(
            FixedPointDecimalScaleSlow.scale18Slow(a_, decimals_, flags_),
            FixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }

    function testScale1818(uint256 a_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        assertEq(a_, FixedPointDecimalScale.scale18(a_, 18, flags_));
    }

    function testScale18Lt(uint256 a_, uint256 decimals_, uint256 flags_) public {
        // Only keep rounding flags.
        flags_ = flags_ & FLAG_ROUND_UP;
        vm.assume(decimals_ < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = FIXED_POINT_DECIMALS - decimals_;
        vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(FixedPointDecimalScale.scaleUp(a_, scaleUpBy_), FixedPointDecimalScale.scale18(a_, decimals_, flags_));
        assertEq(
            FixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_),
            FixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }

    function testScale18LtOverflow(uint256 a_, uint8 decimals_, uint256 flags_) public {
        // Only keep rounding flags.
        flags_ = flags_ & FLAG_ROUND_UP;
        vm.assume(decimals_ < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = FIXED_POINT_DECIMALS - decimals_;
        vm.assume(WillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        vm.expectRevert(stdError.arithmeticError);
        FixedPointDecimalScale.scale18(a_, decimals_, flags_);
    }

    function testScale18LtSaturate(uint256 a_, uint256 decimals_, uint256 flags_) public {
        // Keep rounding flags.
        flags_ = FLAG_SATURATE | (flags_ & FLAG_ROUND_UP);
        vm.assume(decimals_ < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = FIXED_POINT_DECIMALS - decimals_;

        assertEq(
            FixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_),
            FixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }

    function testScale18Gt(uint256 a_, uint8 decimals_, uint256 flags_) public {
        // Keep saturate flags.
        flags_ = flags_ & FLAG_SATURATE;
        vm.assume(decimals_ > FIXED_POINT_DECIMALS);

        uint256 scaleDownBy_ = decimals_ - FIXED_POINT_DECIMALS;

        assertEq(
            FixedPointDecimalScale.scaleDown(a_, scaleDownBy_), FixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }

    function testScale18GtRoundUp(uint256 a_, uint8 decimals_, uint256 flags_) public {
        // Keep saturate flags.
        flags_ = FLAG_ROUND_UP | (flags_ & FLAG_SATURATE);
        vm.assume(decimals_ > FIXED_POINT_DECIMALS);

        uint256 scaleDownBy_ = decimals_ - FIXED_POINT_DECIMALS;

        assertEq(
            FixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_),
            FixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }
}
