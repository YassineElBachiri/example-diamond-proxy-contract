// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;


import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { LibERC1155 } from  "../libraries/LibERC1155.sol";

contract ERC1155Facet is IERC1155, ERC165 {
   
    using Address for address;
   

    // constructor() {
    //     // Register the supported interfaces
    //     _registerInterface(type(IERC1155).interfaceId);
    //     _registerInterface(type(IERC1155MetadataURI).interfaceId);
    // }

    // function supportsInterface(bytes4 interfaceId) public view override(IERC165, ERC165) returns (bool) {
    //     return interfaceId == type(IERC1155).interfaceId || interfaceId == type(IERC1155MetadataURI).interfaceId;
    // }

    function balanceOf(address account, uint256 id) public view  returns (uint256) {
        return LibERC1155.balanceOf(account, id);
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view  returns (uint256[] memory) {
        return LibERC1155.balanceOfBatch(accounts, ids);
    }

    function setApprovalForAll(address operator, bool approved) public  {
        LibERC1155.setApprovalForAll(operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view  returns (bool) {
        return LibERC1155.isApprovedForAll(account, operator);
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public  {
        LibERC1155.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public  {
        LibERC1155.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function uri(uint256 tokenId) public view  returns (string memory) {
        return LibERC1155.tokenURI(tokenId);
    }

    // Additional functions and events as needed for your ERC11555 implementation
    // ...
}