// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

import "./FixedPointDecimalConstants.sol";

library FixedPointDecimalArithmeticOpenZeppelin {
    using Math for uint256;

    /// Fixed point multiplication in 18 decimal fixed point.
    /// Both `a` and `b` MUST be 18 decimal fixed point values.
    /// Implemented in terms of Open Zeppelin `Math` library.
    /// @param a First term.
    /// @param b Second term.
    /// @param rounding Rounding direction as per Open Zeppelin `Math`.
    /// @return `a` multiplied by `b` in 18 fixed point decimals.
    function fixedPointMul(uint256 a, uint256 b, Math.Rounding rounding) internal pure returns (uint256) {
        return a.mulDiv(b, FIXED_POINT_ONE, rounding);
    }

    /// Fixed point division in 18 decimal fixed point.
    /// Both `a` and `b` MUST be 18 decimal fixed point values.
    /// Implemented in terms of Open Zeppelin `Math` library.
    /// @param a First term.
    /// @param b Second term.
    /// @param rounding Rounding direction as per Open Zeppelin `Math`.
    /// @return `a` divided by `b` in 18 fixed point decimals.
    function fixedPointDiv(uint256 a, uint256 b, Math.Rounding rounding) internal pure returns (uint256) {
        return a.mulDiv(FIXED_POINT_ONE, b, rounding);
    }
}
