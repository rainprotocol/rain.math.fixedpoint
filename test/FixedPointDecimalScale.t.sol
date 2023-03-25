// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./WillOverflow.sol";
import "../src/FixedPointDecimalConstants.sol";
import "../src/FixedPointDecimalScale.sol";

contract FixedPointDecimalScaleTest is Test {
// function testScaleBy0(uint256 a_, uint256 rounding_) public {
//     assertEq(a_, FixedPointDecimalScale.scaleBy(a_, 0, rounding_));
// }

// function testScaleByUp(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
//     vm.assume(scaleBy_ > 0);
//     vm.assume(!WillOverflow.scaleUpWillOverflow(a_, uint8(scaleBy_)));

//     assertEq(
//         FixedPointDecimalScale.scaleUp(a_, uint256(uint8(scaleBy_))),
//         FixedPointDecimalScale.scaleBy(a_, scaleBy_, rounding_)
//     );
// }

// function testScaleByUpOverflow(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
//     vm.assume(scaleBy_ > 0);
//     vm.assume(WillOverflow.scaleUpWillOverflow(a_, uint8(scaleBy_)));
//     vm.expectRevert(stdError.arithmeticError);
//     FixedPointDecimalScale.scaleBy(a_, scaleBy_, rounding_);
// }

// function testScaleByDown(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
//     vm.assume(scaleBy_ < 0);
//     vm.assume(stdMath.abs(scaleBy_) < OVERFLOW_RESCALE_OOMS);

//     assertEq(
//         FixedPointDecimalScale.scaleBy(a_, scaleBy_, rounding_),
//         FixedPointDecimalScale.scaleDown(a_, stdMath.abs(scaleBy_), rounding_)
//     );
// }

// function testScaleByOverflow(uint256 a_, int8 scaleBy_, uint256 rounding_) public {
//     vm.assume(stdMath.abs(scaleBy_) >= OVERFLOW_RESCALE_OOMS);

//     vm.expectRevert(stdError.arithmeticError);
//     FixedPointDecimalScale.scaleBy(a_, scaleBy_, rounding_);
// }

// function testScaleN18(uint256 a_, uint256 rounding_) public {
//     assertEq(a_, FixedPointDecimalScale.scaleN(a_, 18, rounding_));
// }

// function testScaleNLt18(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
//     vm.assume(targetDecimals_ < 18);

//     uint256 scaleDown_ = 18 - targetDecimals_;

//     assertEq(
//         FixedPointDecimalScale.scaleN(a_, targetDecimals_, rounding_),
//         FixedPointDecimalScale.scaleDown(a_, scaleDown_, rounding_)
//     );
// }

// function testScaleNGt18(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
//     vm.assume(targetDecimals_ > 18);

//     uint256 scaleUp_ = targetDecimals_ - 18;
//     vm.assume(!WillOverflow.scaleUpWillOverflow(a_, scaleUp_));

//     assertEq(
//         FixedPointDecimalScale.scaleN(a_, targetDecimals_, rounding_), FixedPointDecimalScale.scaleUp(a_, scaleUp_)
//     );
// }

// function testScaleNGt18Overflow(uint256 a_, uint8 targetDecimals_, uint256 rounding_) public {
//     vm.assume(targetDecimals_ > 18);

//     uint256 scaleUp_ = targetDecimals_ - 18;
//     vm.assume(WillOverflow.scaleUpWillOverflow(a_, scaleUp_));
//     vm.expectRevert(stdError.arithmeticError);
//     FixedPointDecimalScale.scaleN(a_, targetDecimals_, rounding_);
// }
}
