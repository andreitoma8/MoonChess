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

    uint256 public price = 0.01 ether;
    uint256 public maxSupply = 1000000000;

    bool private paused = true;

    constructor() ERC1155("") {
        name = "Moon Chess";
        symbol = "CHESS";
    }

    modifier mintCompliance(uint256 id, uint256 amount) {
        require(
            amount < 10,
            "You can not mint more than 10 NFTs per transaction"
        );
        require(totalSupply(id) < maxSupply, "Max supply reached");
        require(!paused, "Minting is paused");
        _;
    }

    function mint(uint256 id, uint256 amount)
        public
        payable
        mintCompliance(id, amount)
    {
        require(
            msg.value >= price * amount,
            "Value of the transaction is too low"
        );
        _mint(msg.sender, id, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function setUriPrefix(string memory newUriPrefix) public onlyOwner {
        uriPrefix = newUriPrefix;
    }

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
}
