// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IMoonChessToken.sol";

contract MoonChessCollection is
    ERC1155,
    Ownable,
    ERC1155Burnable,
    ERC1155Supply
{
    using Strings for uint256;

    IMoonChessToken token;

    string public name;
    string public symbol;
    string private uriPrefix;
    string private uriSuffix = ".json";

    uint256 public price = 10 ether;
    uint256 public maxSupply = 1000000;
    uint256 private collectionsReleased = 4;

    bool private paused = false;

    constructor(IMoonChessToken _token) ERC1155("") {
        name = "Moon Chess";
        symbol = "CHESS";
        token = _token;
    }

    // Mint function where people buy
    function mint(uint256 id, uint256 amount) external {
        require(!paused, "Minting is paused");
        require(
            amount <= 10,
            "You can not mint more than 10 NFTs per transaction"
        );
        require(totalSupply(id) + amount <= maxSupply, "Max supply reached");
        token.transferFrom(msg.sender, address(this), price * amount);
        require(id <= collectionsReleased, "TokenId nonexistent");
        _mint(msg.sender, id, amount, "");
    }

    // Mint function in bulk where people can buy more than one type of cards
    function mintBatch(uint256[] memory ids, uint256[] memory amounts)
        external
    {
        require(!paused, "Minting is paused");
        uint256 s;
        for (uint256 i = 0; i < ids.length; i++) {
            require(
                totalSupply(ids[i]) + amounts[i] <= maxSupply,
                "Total supply reached."
            );
            require(
                amounts[i] <= 10,
                "You can not mint more than 10 NFTs per transaction"
            );
            s += amounts[i];
            require(ids[i] <= collectionsReleased, "TokenId nonexistent");
        }
        token.transferFrom(msg.sender, address(this), price * s);
        _mintBatch(msg.sender, ids, amounts, "");
    }

    // Set the URI for metadata
    function setUriPrefix(string memory newUriPrefix) public onlyOwner {
        uriPrefix = newUriPrefix;
    }

    // Set if minting is paused or not
    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }

    // Set the number of diefrent cards available to mint
    function setCollectionsReleased(uint256 _collectionsReleased)
        public
        onlyOwner
    {
        collectionsReleased = _collectionsReleased;
    }

    // Set the price
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    // Function that returns the URI for the token ID
    function uri(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            bytes(uriPrefix).length > 0
                ? string(
                    abi.encodePacked(uriPrefix, _tokenId.toString(), uriSuffix)
                )
                : "";
    }

    // Withdraw MCH function
    function withdraw(uint256 _amount) public onlyOwner {
        token.transfer(owner(), _amount);
    }

    // View function for frontend
    function frontEndTotalSupply() external view returns (uint256[] memory) {
        uint256[] memory supplies;
        for (uint256 i = 1; i <= collectionsReleased; ++i) {
            supplies[i] = totalSupply(i);
        }
        uint256 s;
        for (uint256 i = 1; i <= collectionsReleased; ++i) {
            s += supplies[i];
        }
        supplies[0] = s;
        return supplies;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    receive() external payable {}
}
