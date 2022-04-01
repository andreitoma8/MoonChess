// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/IMoonChessToken.sol";

contract MoonChessGame is ERC1155Holder, Ownable {
    IMoonChessToken public token;
    IERC1155 public collection;

    bool private paused = true;

    // Event that sends data on ERC20 Token Deposit
    event TokenDeposit(address indexed account, uint256 indexed amount);
    // Event that sends data on ERC1155 Collectible Deposit
    event CollectionDeposit(
        address indexed account,
        uint256[] indexed ids,
        uint256[] indexed amount
    );

    // Set the address of the Token and the Collection
    constructor(address _token, address _collection) {
        token = IMoonChessToken(_token);
        collection = IERC1155(_collection);
    }

    // Function users call to deposit tokens into the game
    function depositToken(uint256 _amount) public pausable {
        token.transferFrom(msg.sender, address(this), _amount);
        emit TokenDeposit(msg.sender, _amount);
    }

    // Function users call to deposit collectables into the game
    function depositCollection(uint256[] memory _ids, uint256[] memory _amount)
        public
        pausable
    {
        collection.safeBatchTransferFrom(
            msg.sender,
            address(this),
            _ids,
            _amount,
            ""
        );
        emit CollectionDeposit(msg.sender, _ids, _amount);
    }

    // Function called by the game to send the withdrawed MCH token back to the user wallet
    function sendTokens(
        address _user,
        uint256 _withdrawAmount,
        uint256 _burnAmount
    ) public onlyOwner {
        token.transfer(_user, _withdrawAmount);
        token.burn(_burnAmount);
    }

    function sendCollectibles(
        address _user,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) public onlyOwner {
        collection.safeBatchTransferFrom(
            address(this),
            _user,
            _ids,
            _amounts,
            ""
        );
    }

    // Utils

    modifier pausable() {
        require(!paused, "Deposits are paused");
        _;
    }

    // Failsafe function to pause deposits
    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }
}
