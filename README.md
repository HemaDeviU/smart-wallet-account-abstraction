## Smart Wallet Account Abstraction

This project aims to create a smart wallet factory such that 

1) It lets the user create a new smart contract wallet and specify the owners of that wallet - multisignature wallets

2) It also displays a list of Smart Contract Wallets for which the user's EOA is the owner

3) It lets an owner of a smart contract wallet initiate a transaction

4) It lets other owners sign the transaction

5) After all the owners have signed, it lets any one of the owners send the transaction to finally be executed

7) The user's smart accounts are upgradeable by implementing the UUPS Upgradeable Proxy pattern in our contracts.


### Requirements
- #### Foundry

To get started with Foundry, run the following commands:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
git clone https://github.com/HemaDeviU/smart-wallet-account-abstraction
cdsmart-wallet-account-abstraction
forge build
```

### Usage
- #### For local Deployment

1.  Start a local node
```make anvil```
2.  Deploy
```make deploy```

- #### For testnet deployment

1. Setup environment variables
You'll want to set your SEPOLIA_RPC_URL and PRIVATE_KEY as environment variables. You can add them to a .env file.

- PRIVATE_KEY: The private key of your account (like from metamask) which has testnet ETH.
- SEPOLIA_RPC_URL: This is url of the sepolia testnet node you're working with. You can get setup with one for free from Alchemy.
- ETHERSCAN_API_KEY: To verify the contract,get the api key from etherscan account.

2. Deploy
make deploy ARGS="--network sepolia"






