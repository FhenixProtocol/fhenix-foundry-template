# Foundry Template [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/fhenixprotocol/fhenix-foundry-template
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/fhenixprotocol/fhenix-foundry-template/actions
[gha-badge]: https://github.com/fhenixprotocol/fhenix-foundry-template/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

A Foundry-based template for developing Solidity smart contracts, with sensible defaults.

## What's Inside

- [Forge](https://github.com/foundry-rs/foundry/blob/master/forge): compile, test, fuzz, format, and deploy smart
  contracts
- [Forge Std](https://github.com/foundry-rs/forge-std): collection of helpful contracts and utilities for testing
- [Prettier](https://github.com/prettier/prettier): code formatter for non-Solidity files
- [Solhint](https://github.com/protofire/solhint): linter for Solidity code
- [PermissionHelper.sol](./util/PermissionHelper.sol): utilities for managing permissions related to FHE operations
- [FheHelper.sol](./util/FheHelper.sol): utilities for mocking FHE operations

## Getting Started

Click the [`Use this template`](https://github.com/fhenixprotocol/fhenix-foundry-template/generate) button at the top of
the page to create a new repository with this repo as the initial state.

Or, if you prefer to install the template manually:

```sh
$ mkdir my-project
$ cd my-project
$ forge init --template fhenixprotocol/fhenix-foundry-template
$ bun install # install Solhint, Prettier, and other Node.js deps
```

If this is your first time with Foundry, check out the
[installation](https://github.com/foundry-rs/foundry#installation) instructions.

## Features

- Mock FHE Operations: All FHE operations, including encryption, decryption, and encrypted data handling, are mocked to
  simulate their behavior in a network environment. This allows for seamless development and testing without requiring a
  fully operational FHE network.

- Permissions: The template provides utilities (PermissionHelper.sol) for creating permissions related to FHE
  operations, allowing users to test that their contracts correctly implement access controlled actions such as viewing
  balances of encrypted tokens. To read more about permissions, check out the
  [Fhenix Documentation](https://docs.fhenix.zone/docs/devdocs/Writing%20Smart%20Contracts/Permissions) section.

## Installing Dependencies

This is how to install dependencies:

1. Install the dependency using your preferred package manager, e.g. `bun install dependency-name`
   - Use this syntax to install from GitHub: `bun install github:username/repo-name`
2. Add a remapping for the dependency in [remappings.txt](./remappings.txt), e.g.
   `dependency-name=node_modules/dependency-name`

Note that OpenZeppelin Contracts is pre-installed, so you can follow that as an example.

## Writing Tests

To write a new test contract, you start by importing `Test` from `forge-std`, and then you inherit it in your test
contract. Forge Std comes with a pre-instantiated [cheatcodes](https://book.getfoundry.sh/cheatcodes/) environment
accessible via the `vm` property. If you would like to view the logs in the terminal output, you can add the `-vvv` flag
and use [console.log](https://book.getfoundry.sh/faq?highlight=console.log#how-do-i-use-consolelog).

This template comes with an example test contract [FHERC20.t.sol](./test/FHERC20.t.sol)

For contracts that wish to use FHE operations, you need to inject the FHE mock operations using the `FheEnabled`
contract.

Simply inherit the `FheEnabled` contract in your test contract, and you will have access to the FHE operations.

```solidity
import { FheEnabled } from "./util/FheHelper.sol";

contract MyTestContract is Test, FheEnabled {
    // Your test contract code here
}
```

Next, during the test setup, you need to initialize the FHE environment using the `initializeFhe` function.

```solidity
function setUp() public {
    initializeFhe();
}
```

For a full example, including mocked encryption, decryption, sealing and permission usage refer to the example tests
provided in the tests directory.

## Permissions

The PermissionHelper contract provides utilities for managing permissions related to FHE operations. This allows users
to test that their contracts correctly implement access controlled actions such as viewing balances of encrypted tokens.

Here's an example of how to use the PermissionHelper contract in a test contract:

```solidity
import { Test } from "forge-std/src/Test.sol";

import { ContractWeAreTesting } from "./src/ContractWeAreTesting.sol";
import { PermissionHelper } from "./util/PermissionHelper.sol";

contract MyContract is Test {
    ContractWeAreTesting private contractToTest;
    PermissionHelper private permitHelper;

    function setUp() public {
        // The contract we are testing must be deployed first
        contractToTest = new ContractWeAreTesting();

        // The PermissionHelper contract must be deployed with the address of the contract we are testing
        // otherwise the permission generated will not match the address of the contract being tested
        permitHelper = new PermissionHelper(address(contractToTest));
    }

    function testOnlyOwnerCanViewBalance() public {
        // Owner key and address
        uint256 ownerPrivateKey = 0xA11CE;
        address owner = vm.addr(ownerPrivateKey);

        // Generate a permission for the owner using the permitHelper and the private key
        Permission memory permission = permitHelper.generatePermission(ownerPrivateKey);

        // Call function with permission
        uint256 result = permissions.someFunctionWithOnlyPermitted(owner, permission);
    }
}
```

Note how the `PermissionHelper` contract is initialized only once we know the address of the contract being tested -
this is because the permission generated by the `PermissionHelper` contract is tied to the address of the contract being
tested.

## Differences from Real FHE Operations

The FHE operations in this template are mocked to simulate the behavior of a real FHE network. This means that the
operations are not actually performed on encrypted data, but rather on plaintext data. This allows for seamless
development and testing without requiring a fully operational FHE network.

However, there are some key differences between the mocked FHE operations and real FHE operations:

- Gas Costs - The gas costs for the mocked FHE operations are not representative of the gas costs for real FHE
  operations. The gas costs for the mocked operations are based on the gas costs for the equivalent non-FHE operations.
- Security Zones - The mocked FHE operations do not enforce security zones, so any user can perform operations between
  ciphertexts which would otherwise fail.
- Ciphertext Access - The mocked FHE operations do not enforce access control on ciphertexts, so any user can access any
  mocked "ciphertext". On a real network such an operation could fail.
- Decrypts during gas estimations - On Helium testnet or in Localfhenix when performing a decryption (or other revealing
  operation) during gas estimation, the operation will return a default value, because the gas estimation does not have
  access to the decrypted data. This can cause a transaction to fail during this phase if the decrypted data is used in
  a way that would cause the transaction to revert (e.g. performing a require on it).
- Security - The security of the mocked FHE operations is not representative of the security of real FHE operations. The
  mocked operations do not provide any encryption/decryption.
- Performance - The performance of the mocked FHE operations is not representative of the performance of real FHE
  operations and will be much faster due to their nature.

## Usage

This is a list of the most frequently needed commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

### Deploy

**Note:** Anvil does not currently support FHE operations. Stay tuned for future updates for Anvil support.

Deploy to Anvil:

```sh
$ forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545
```

For this script to work, you need to have a `MNEMONIC` environment variable set to a valid
[BIP39 mnemonic](https://iancoleman.io/bip39/).

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting.html) tutorial.

### Format

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

**Note:** Gas usage for FHE operations will be inaccurate due to the mocked nature of the operations. To see the
gas-per-operation for FHE operations, refer to the
[Gas Costs](https://docs.fhenix.zone/docs/devdocs/Writing%20Smart%20Contracts/Gas-and-Benchmarks) section in our
documentation.

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ bun run lint
```

### Test

Run the tests:

```sh
$ forge test
```

Generate test coverage and output result to the terminal:

```sh
$ bun run test:coverage
```

Generate test coverage with lcov report (you'll have to open the `./coverage/index.html` file in your browser, to do so
simply copy paste the path):

```sh
$ bun run test:coverage:report
```

## License & Credits

- This project is licensed under MIT.
- This project is based on the [Foundry Template](https://github.com/PaulRBerg/foundry-template)

  Copyright (c) 2024 Paul Razvan Berg License (MIT) https://github.com/PaulRBerg/foundry-template/blob/main/LICENSE.md
