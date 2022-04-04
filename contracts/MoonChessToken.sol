// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MoonChessToken is ERC20, ERC20Burnable, Ownable {
    address private team;
    address private liquidity;
    address private marketing;
    address private presale;
    address private ecosystem;
    address private rewards;

    // Mint 100.000.000.000 Tokens on contract deployment
    constructor() ERC20("MoonChess", "MCH") {
        // _mint(team, 300000000000);
        // _mint(liquidity, 100000000000);
        // _mint(marketing, 100000000000);
        // _mint(presale, 200000000000);
        // _mint(ecosystem, 150000000000);
        // _mint(rewards, 150000000000);
        _mint(msg.sender, 1000000000000);
    }

    function mint(uint256 amount) public payable {
        require(msg.value > amount * 1);
    }
}
