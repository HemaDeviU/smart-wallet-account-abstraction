// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.21;

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./Wallet.sol";

contract WalletFactory {
    Wallet public immutable walletImplementation;

    constructor(IEntryPoint _entryPoint) {
        walletImplementation = new Wallet(_entryPoint, address(this));
    }

    function createAccount(address[] owners,uint256 salt) public returns (Wallet) {
        address addr = getAddress(owners, salt);
        uint256 codeSize = addr.code.length;
        if (codeSize > 0) {
            return Wallet(payable(addr));
        }
        return Wallet(payable(new ERC1967Proxy{salt : bytes32(salt)}(address(walletImplementation),abi.encodeCall(Wallet.initialize, (owners)))));
    }

    
    function getAddress(address[] owners,uint256 salt) public view returns (address) {
        return Create2.computeAddress(bytes32(salt), keccak256(abi.encodePacked(type(ERC1967Proxy).creationCode,abi.encode(address(walletImplementation),abi.encodeCall(Wallet.initialize, (owners))))));
    }
}