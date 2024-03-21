//SPDX-License-Identifier:MIT
pragma solidity ^0.8.21;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {BaseAccount} from "@account-abstraction/core/BaseAccount.sol";
import "@account-abstraction/core/Helpers.sol";
import {TokenCallbackHandler} from "@account-abstraction/callback/TokenCallbackHandler.sol";

contract Wallet is BaseAccount, TokenCallbackHandler, UUPSUpgradeable, Initializable {
    address[] public owners;
    IEntryPoint private immutable _entryPoint;
    event WalletInitialized(IEntryPoint indexed entryPoint, address[] indexed owners);

    modifier onlyEntryPointOrFactory() {
        require(msg.sender == address(_entryPoint) || msg.sender == walletFactory ,"error");
        _;
    }
     modifier onlyEntryPointOrOwner()  {
        require(msg.sender == address(entryPoint()) || msg.sender == owners, "account: not Owner or EntryPoint");
    }
    modifier onlyOwners{
        bool isOwner = false;
        for(uint256 i=0;i<owners.length;i++)
        {
        if(msg.sender == owners[i])
            {
            isOwner=true;
            break;
            }
            require(isOwner || msg.sender==address(this),"onlyowners");
        _;
        }
    }
    constructor(IEntryPoint anEntryPoint, address ourWalletFactory) {
        _entryPoint = anEntryPoint;
        walletFactory = ourWalletFactory;
    }
   function initialize(address[] memory initialOwners) public virtual initializer {
        _initialize(intialOwners);
    }
    function execute(address dest, uint256 value, bytes calldata func) external onlyEntryPointOrFactory{
        _call(dest, value, func);
    }

    function executeBatch(address[] calldata dest, uint256[] calldata value, bytes[] calldata func) external _requireFromEntryPointOrOwner{
        require(dest.length == func.length && (value.length == 0 || value.length == func.length), "wrong array lengths");
        if (value.length == 0) {
            for (uint256 i = 0; i < dest.length; i++) {
                _call(dest[i], 0, func[i]);
            }
        } else {
            for (uint256 i = 0; i < dest.length; i++) {
                _call(dest[i], value[i], func[i]);
            }
        }
    }
   

    function _initialize(address[] memory initialOwners) internal virtual {
        require(initialOnwers.length >0, "noowners");
        owners = initialOwners;
        emit WalletInitialize(_entryPoint, owner);
    }


    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)internal override virtual returns (uint256 validationData) {
        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        for(uint256 i =0; i<owners.length;i++){
        if (owners[i] != ECDSA.recover(hash, userOp.signature[i]))
           { 
            return SIG_VALIDATION_FAILED;
           }
        }
        return SIG_VALIDATION_SUCCESS;
    }

    function _call(address target, uint256 value, bytes memory data) internal {
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
    function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }
    function getDeposit() public view returns (uint256) {
        return entryPoint().balanceOf(address(this));
    }

    function addDeposit() public payable {
        entryPoint().depositTo{value: msg.value}(address(this));
    }

    function withdrawDepositTo(address payable withdrawAddress, uint256 amount) public onlyOwner {
        entryPoint().withdrawTo(withdrawAddress, amount);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyOwners(newImplementation){}
    
    receive() external payable {}
}