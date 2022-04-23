// SPDX-License-Identifier: MIT
// Creator: andreitoma8
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MoonChessToken is
    ERC20,
    ERC20Burnable,
    ERC20Permit,
    ERC20Votes,
    Ownable
{
    address private team;
    address private liquidity;
    address private marketing;
    address private presale;
    address private ecosystem;
    address private rewards;

    // Mint 100.000.000.000 Tokens on contract deployment
    constructor() ERC20("MoonChess", "MCH") ERC20Permit("MoonChess") {
        // _mint(team, 300000000000);
        // _mint(liquidity, 100000000000);
        // _mint(marketing, 100000000000);
        // _mint(presale, 200000000000);
        // _mint(ecosystem, 150000000000);
        // _mint(rewards, 150000000000);
        _mint(msg.sender, 1000000000000 * 10**18);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
