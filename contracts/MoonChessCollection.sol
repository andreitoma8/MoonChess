// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MoonChessCollection is
    ERC1155,
    Ownable,
    ERC1155Burnable,
    ERC1155Supply
{
    using Strings for uint256;

    string public name;
    string public symbol;
    string private uriPrefix;
    string private uriSuffix = ".json";

    uint256 public price = 0.005 ether;
    uint256 public maxSupply = 1000000;

    bool private paused = false;

    constructor() ERC1155("") {
        name = "Moon Chess";
        symbol = "CHESS";
    }

    // Mint modifier
    modifier mintCompliance(uint256 id, uint256 amount) {
        require(!paused, "Minting is paused");
        require(
            amount <= 10,
            "You can not mint more than 10 NFTs per transaction"
        );
        require(totalSupply(id) + amount <= maxSupply, "Max supply reached");
        require(
            msg.value >= price * amount,
            "Value of the transaction is too low"
        );
        _;
    }

    // Batch mint modifier
    modifier mintBatchCompliance(
        uint256[] memory ids,
        uint256[] memory amounts
    ) {
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
        }
        require(msg.value >= s * price, "Value of the transaction is too low");
        _;
    }

    // Mint function where people buy
    function mint(uint256 id, uint256 amount)
        public
        payable
        mintCompliance(id, amount)
    {
        _mint(msg.sender, id, amount, "");
    }

    // Mint function in bulk where people can buy more than one type of cards
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public payable mintBatchCompliance(ids, amounts) {
        _mintBatch(to, ids, amounts, "");
    }

    // Set the URI for metadata
    function setUriPrefix(string memory newUriPrefix) public onlyOwner {
        uriPrefix = newUriPrefix;
    }

    // Set if minting is paused or not
    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
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

    // Withdraw ETH function
    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
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
