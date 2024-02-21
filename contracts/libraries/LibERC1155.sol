//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

library LibERC1155 {
    using Address for address;

    // each facet gets their own struct to store state into
    bytes32 constant ERC1155_STORAGE_POSITION = keccak256("facet.erc1155.diamond.storage");


    //State Variables
    struct Storage {
        mapping(uint256 => mapping(address => uint256)) _balances;
        mapping(address => mapping(address => bool)) _operatorApprovals;
        mapping(uint256 => string) _tokenURIs;
        mapping(uint256 => uint256) _totalSupply;
    }

    // Access ERC1155 storage via:
    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = ERC1155_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    // Function to set the URI for a token
    function setTokenURI(uint256 tokenId, string memory uri) internal {
        Storage storage ds = getStorage();
        ds._tokenURIs[tokenId] = uri;
    }

    // Function to get the URI for a token
    function tokenURI(uint256 tokenId) internal view returns (string memory) {
        Storage storage ds = getStorage();
        return ds._tokenURIs[tokenId];
    }

    // Function to get the balance of an account's tokens
    function balanceOf(address account, uint256 id) internal view returns (uint256) {
        Storage storage ds = getStorage();
        return ds._balances[id][account];
    }

    // Function to get the balance of multiple token types
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) internal view returns (uint256[] memory) {
        require(accounts.length == ids.length, "LibERC1155: accounts and ids length mismatch");


        uint256[] memory balances = new uint256[](accounts.length);
        for (uint256 i =   0; i < accounts.length; ++i) {
            balances[i] = balanceOf(accounts[i], ids[i]);
        }

        return balances;
    }

    // Function to set the approval for an operator
    function setApprovalForAll(address operator, bool approved) internal {
        Storage storage ds = getStorage();
        ds._operatorApprovals[msg.sender][operator] = approved;
    }

    // Function to check if an operator is approved for an account
    function isApprovedForAll(address account, address operator) internal view returns (bool) {
        Storage storage ds = getStorage();
        return ds._operatorApprovals[account][operator];
    }

    // Function to transfer tokens from one account to another
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) internal {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "LibERC1155: caller is not owner nor approved");
        require(to != address(0), "LibERC1155: transfer to the zero address");


        Storage storage ds = getStorage();
        ds._balances[id][from] -= amount;
        ds._balances[id][to] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);


        _checkOnERC1155Received(from, to, id, amount, data);
    }

    // Function to transfer multiple tokens from one account to another
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "LibERC1155: caller is not owner nor approved");
        require(to != address(0), "LibERC1155: transfer to the zero address");
        require(ids.length == amounts.length, "LibERC1155: ids and amounts length mismatch");


        Storage storage ds = getStorage();
        for (uint256 i =   0; i < ids.length; ++i) {
            ds._balances[ids[i]][from] -= amounts[i];
            ds._balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);


        _checkOnERC1155BatchReceived(from, to, ids, amounts, data);
    }

    // Internal function to check if the recipient is a contract and if so, call the onERC1155Received function
    function _checkOnERC1155Received(address from, address to, uint256 id, uint256 amount, bytes memory data) internal {
        if (to.isContract()) {
            require(IERC1155Receiver(to).onERC1155Received(msg.sender, from, id, amount, data) == IERC1155Receiver.onERC1155Received.selector, "LibERC1155: ERC1155Receiver rejected tokens");
        }
    }

    // Internal function to check if the recipient is a contract and if so, call the onERC1155BatchReceived function
    function _checkOnERC1155BatchReceived(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
        if (to.isContract()) {
            require(IERC1155Receiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) == IERC1155Receiver.onERC1155BatchReceived.selector, "LibERC1155: ERC1155Receiver rejected tokens");
        }
    }

    // Event emitted when tokens are transferred
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);


    // Event emitted when multiple tokens are transferred
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

   



    // // Function to set the URI for a token
    // function setTokenURI(uint256 tokenId, string memory uri) internal {
    //     _tokenURIs[tokenId] = uri;
    // }

    // // Function to get the URI for a token
    // function tokenURI(uint256 tokenId) internal view returns (string memory) {
    //     return _tokenURIs[tokenId];
    // }

    // // Function to get the balance of an account's tokens
    // function balanceOf(address account, uint256 id) internal view returns (uint256) {
    //     return _balances[id][account];
    // }

    // // Function to get the balance of multiple token types
    // function balanceOfBatch(address[] memory accounts, uint256[] memory ids) internal view returns (uint256[] memory) {
    //     require(accounts.length == ids.length, "LibERC1155: accounts and ids length mismatch");

    //     uint256[] memory balances = new uint256[](accounts.length);
    //     for (uint256 i =  0; i < accounts.length; ++i) {
    //         balances[i] = balanceOf(accounts[i], ids[i]);
    //     }

    //     return balances;
    // }

    // // Function to set the approval for an operator
    // function setApprovalForAll(address operator, bool approved) internal {
    //     _operatorApprovals[msg.sender][operator] = approved;
    // }

    // // Function to check if an operator is approved for an account
    // function isApprovedForAll(address account, address operator) internal view returns (bool) {
    //     return _operatorApprovals[account][operator];
    // }

    // // Function to transfer tokens from one account to another
    // function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) internal {
    //     require(from == msg.sender || isApprovedForAll(from, msg.sender), "LibERC1155: caller is not owner nor approved");
    //     require(to != address(0), "LibERC1155: transfer to the zero address");

    //     _balances[id][from] -= amount;
    //     _balances[id][to] += amount;

    //     emit TransferSingle(msg.sender, from, to, id, amount);

    //     _checkOnERC1155Received(from, to, id, amount, data);
    // }

    // // Function to transfer multiple tokens from one account to another
    // function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
    //     require(from == msg.sender || isApprovedForAll(from, msg.sender), "LibERC1155: caller is not owner nor approved");
    //     require(to != address(0), "LibERC1155: transfer to the zero address");
    //     require(ids.length == amounts.length, "LibERC1155: ids and amounts length mismatch");

    //     for (uint256 i =  0; i < ids.length; ++i) {
    //         _balances[ids[i]][from] -= amounts[i];
    //         _balances[ids[i]][to] += amounts[i];
    //     }

    //     emit TransferBatch(msg.sender, from, to, ids, amounts);

    //     _checkOnERC1155BatchReceived(from, to, ids, amounts, data);
    // }

    // // Internal function to check if the recipient is a contract and if so, call the onERC1155Received function
    // function _checkOnERC1155Received(address from, address to, uint256 id, uint256 amount, bytes memory data) internal {
    //     if (to.isContract()) {
    //         require(IERC1155Receiver(to).onERC1155Received(msg.sender, from, id, amount, data) == IERC1155Receiver.onERC1155Received.selector, "LibERC1155: ERC1155Receiver rejected tokens");
    //     }
    // }

    // // Internal function to check if the recipient is a contract and if so, call the onERC1155BatchReceived function
    // function _checkOnERC1155BatchReceived(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
    //     if (to.isContract()) {
    //         require(IERC1155Receiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) == IERC1155Receiver.onERC1155BatchReceived.selector, "LibERC1155: ERC1155Receiver rejected tokens");
    //     }
    // }

    // // Event emitted when tokens are transferred
    // event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    // // Event emitted when multiple tokens are transferred
    // event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
}