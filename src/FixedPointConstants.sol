// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev The scale of all fixed point math. This is adopting the conventions of
/// both ETH (wei) and most ERC20 tokens, so is hopefully uncontroversial.
uint256 constant FIXED_POINT_DECIMALS = 18;

/// @dev Value of "one" for fixed point math.
uint256 constant FIXED_POINT_ONE = 1e18;

/// @dev Calculations MUST round down.
uint256 constant ROUND_DOWN = 0;

/// @dev Calculations MUST round up.
uint256 constant ROUND_UP = 1;

/// @dev Can't scale by more than this many OOMs.
uint256 constant MAX_RESCALE_OOMS = 77;
