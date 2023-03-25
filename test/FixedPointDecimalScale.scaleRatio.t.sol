// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/FixedPointDecimalScale.sol";
import "../src/FixedPointDecimalConstants.sol";

contract FixedPointDecimalScaleScaleRatioTest is Test {
    // function testScaleRatioFuzz(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 rounding_) public {
    //     vm.assume(!WillOverflow.scaleRatioWillOverflow(ratio_, aDecimals_, bDecimals_, rounding_));

    //     assertEq(
    //         FixedPointDecimalScale.scaleRatio(ratio_, aDecimals_, bDecimals_, rounding_),
    //         FixedPointDecimalScale.scaleDown(ratio_ * (10 ** (18 + bDecimals_ - aDecimals_)), 18, rounding_)
    //     );
    // }

    // Ported from legacy tests.
    function testScaleRatioExamples() public {
        assertEq(FixedPointDecimalScale.scaleRatio(1e18, 6, 18, FLAG_SATURATE), 1e30);
        assertEq(FixedPointDecimalScale.scaleRatio(1e18, 18, 6, FLAG_SATURATE), 1e6);
        assertEq(
            FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 10, FLAG_SATURATE | FLAG_ROUND_UP),
            1_00000_00000_003676
        );
        assertEq(
            FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 10, 12, FLAG_SATURATE | FLAG_ROUND_UP),
            1_00000_00000_00367589_00
        );
        assertEq(
            FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 12, FLAG_SATURATE | FLAG_ROUND_UP),
            1_00000_00000_00367589
        );
        assertEq(FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 10, FLAG_SATURATE), 1_00000_00000_003675);
        assertEq(
            FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 10, 12, FLAG_SATURATE), 1_00000_00000_00367589_00
        );
        assertEq(
            FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 12, FLAG_SATURATE), 1_00000_00000_00367589
        );
        assertEq(FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 18, 0, FLAG_SATURATE), 1);
        assertEq(
            FixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 0, 18, FLAG_SATURATE),
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
