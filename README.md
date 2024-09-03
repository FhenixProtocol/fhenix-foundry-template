# Foundry Template [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/fhenixprotocol/fhenix-foundry-template
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/fhenixprotocol/fhenix-foundry-template/actions
[gha-badge]: https://github.com/fhenixprotocol/fhenix-foundry-template/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

Fhenix provides a Foundry-based template for developing Solidity smart contracts and includes sensible defaults. Links
are provided to specific topics for further exploration.

## What's Inside

- [Forge](https://github.com/foundry-rs/foundry/blob/master/forge): Tools to compile, test, fuzz, format, and deploy
  smart contracts.
- [Forge Std](https://github.com/foundry-rs/forge-std): A collection of helpful contracts and utilities for testing.
- [Prettier](https://github.com/prettier/prettier): A code formatter for non-Solidity files.
- [Solhint](https://github.com/protofire/solhint): A linter for Solidity code.
- [PermissionHelper.sol](./util/PermissionHelper.sol): Utilities for managing permissions related to FHE operations.
- [FheHelper.sol](./util/FheHelper.sol): Utilities for simulating FHE operations.

## Getting Started

To create a new repository using this template, click the
[`Use this template`](https://github.com/fhenixprotocol/fhenix-foundry-template/generate) button at the top of the page.
Alternatively, install the template manually as follows:

```sh
$ mkdir my-project
$ cd my-project
$ forge init --template fhenixprotocol/fhenix-foundry-template
$ bun install # install Solhint, Prettier, and other Node.js deps
```

If this is your first time using Foundry, refer to the
[installation](https://github.com/foundry-rs/foundry#installation) instructions for guidance.

## Features

- Simulated FHE Operations: All FHE operations, including encryption, decryption, and encrypted data handling, are
  simulated to replicate their behavior in a network environment. This approach facilitates seamless development and
  testing without requiring a fully operational FHE network.
- Permissions: The template includes utilities (PermissionHelper.sol) for creating permissions related to FHE
  operations. These utilities enable users to test and verify that contracts correctly implement access-controlled
  actions, such as viewing balances of encrypted tokens. For more about permissions, see the [Fhenix Documentation] https://docs.fhenix.zone/docs/devdocs/Writing%20Smart%20Contracts/Permissions)
  section.

## Installing Dependencies

Follow these steps to install dependencies:

1. Install the dependency using your preferred package manager, for example: `bun install dependency-name`
   - If installing from Github, use: `bun install github:username/repo-name`
2. Add a remapping for the dependency in [remappings.txt](./remappings.txt), for example:
   `dependency-name=node_modules/dependency-name`

Note that OpenZeppelin Contracts is pre-installed as an example.

## Writing Tests

To write a new test contract:

1. Start by importing `Test` from `forge-std`.
2. Inherit the test contract.

Note that: Forge Std comes with a pre-instantiated [cheatcodes](https://book.getfoundry.sh/cheatcodes/) environment,
which is accessible via the vm property. To view the logs in the terminal output, add the -vvv flag and use
[console.log](https://book.getfoundry.sh/faq?highlight=console.log#how-do-i-use-consolelog).

This template includes an example test contract [FHERC20.t.sol](./test/FHERC20.t.sol).

For contracts utilizing FHE operations, insert FHE mock operations using the `FheEnabled` contract. By inheriting the
`FheEnabled` contract in the test contract, you gain access to FHE operations. The following code demonstrates this.

```solidity
import { FheEnabled } from "./util/FheHelper.sol";

contract MyTestContract is Test, FheEnabled {
    // Your test contract code here
}
```

During test setup, `initializeFhe` the FHE environment using the initializeFhe function:

```solidity
function setUp() public {
    initializeFhe();
}
```

For a complete example, including mocked encryption, decryption, sealing and permission usage, refer to the example
**tests** provided in the tests directory.

## Permissions

The **PermissionHelper** contract provides utilities for managing permissions related to FHE operations. These utilities
enable users to test and verify that contracts correctly implement access-controlled actions, such as viewing balances
of encrypted tokens.

Consider using the following code as an example for a **PermissionHelper** contract in a test contract:

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

Note that the `PermissionHelper` contract is initialized only after we know the address of the contract being tested.
The reason is that the permission generated by the `PermissionHelper` contract is tied to the address of the contract
that is being tested.

## Differences from Real FHE Operations

FHE operations in this template simulate the behavior of a real FHE network. Instead of processing encrypted data,
operations are performed on plaintext data, which enables seamless development and testing without the need for a fully
operational FHE network. However, there are important differences between these mocked FHE operations and actual FHE
operations:

- Gas Costs – Gas costs associated with the mocked FHE operations do not accurately reflect those of real FHE
  operations. Instead, they are based on gas costs of equivalent non-FHE operations.
- Security Zones – In this mocked environment, security zones are not enforced. Thus, any user can perform operations
  between ciphertexts, which would otherwise fail in a real FHE setting.
- Ciphertext Access – The mocked FHE operations do not enforce access control restrictions on ciphertexts, which allows
  any user to access any mocked "ciphertext." On a real network, such operations could fail.
- Decrypts during Gas Estimations: When performing a decrypt (or other data revealing operations) during gas estimation
  on the Helium testnet or Localfhenix, the operation returns a default value, as the gas estimation process does not
  have access to the precise decrypted data. This can cause the transaction to fail at this stage, if the decrypted data
  is used in a way that would trigger a transaction revert (e.g., when a require statement depends on it).
- Security – The security provided by the mocked FHE operations does not represent the high level of security offered by
  real FHE operations. The mocked operations do not involve actual encryption or decryption.
- Performance – The performance of mocked FHE operations is not indicative of the real FHE operation speed. Mocked
  operations will be significantly faster due to their simplified nature.

## Usage

The following list contains the most frequently used commands.

### Build

Compile and build the contracts:

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

**Note:** Anvil does not currently support FHE operations. Stay tuned for future updates on Anvil support.

Deploy to Anvil:

```sh
$ forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545
```

For this script to work, it is necessary to have a MNEMONIC environment variable set to a valid
[BIP39 mnemonic](https://iancoleman.io/bip39/).

For instructions on how to deploy to a testnet or mainnet, refer to the
[Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting.html) tutorial.

### Format

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

**Note:** Gas usage for FHE operations will be inaccurate due to the mocked nature of these operations. To see the
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

Generate test coverage with lcov report (you have to open the `./coverage/index.html` file in your browser, to do so
simply copy paste the path):

```sh
$ bun run test:coverage:report
```

## License & Credits

- This project is licensed under MIT.
- This project is based on the [Foundry Template](https://github.com/PaulRBerg/foundry-template)

Copyright (c) 2024 Paul Razvan Berg License (MIT) https://github.com/PaulRBerg/foundry-template/blob/main/LICENSE.md
