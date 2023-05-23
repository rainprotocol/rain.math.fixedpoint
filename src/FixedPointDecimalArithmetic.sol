// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library FixedPointDecimalArithmeticOpenZeppelin {
    /// Fixed point multiplication in native scale decimals.
    /// Both `a_` and `b_` MUST be `DECIMALS` fixed point decimals.
    /// @param a_ First term.
    /// @param b_ Second term.
    /// @param rounding_ Rounding direction as per Open Zeppelin Math.
    /// @return `a_` multiplied by `b_` to `DECIMALS` fixed point decimals.
    function fixedPointMul(
        uint256 a_,
        uint256 b_,
        Math.Rounding rounding_
    ) internal pure returns (uint256) {
        return a_.mulDiv(b_, FIXED_POINT_ONE, rounding_);
    }

    /// Fixed point division in native scale decimals.
    /// Both `a_` and `b_` MUST be `DECIMALS` fixed point decimals.
    /// @param a_ First term.
    /// @param b_ Second term.
    /// @param rounding_ Rounding direction as per Open Zeppelin Math.
    /// @return `a_` divided by `b_` to `DECIMALS` fixed point decimals.
    function fixedPointDiv(
        uint256 a_,
        uint256 b_,
        Math.Rounding rounding_
    ) internal pure returns (uint256) {
        return a_.mulDiv(FIXED_POINT_ONE, b_, rounding_);
    }
}