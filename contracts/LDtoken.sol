//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ERC20.sol";
import "hardhat/console.sol";

contract LDToken is ERC20 {
	constructor() ERC20(
		"LDToken",
		"LD",
		5,
		1000000,
		payable(0xFaDe01512d3F258353F9b8628f4927BD7bf876BD)
	){}

	receive() external payable {}
}
