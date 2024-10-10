// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "@era-contracts/libraries/SystemContractsCaller.sol";
import {Create2Factory} from "@era-contracts/Create2Factory.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../src/AAFactory.sol";
import "../src/TwoUserMultisig.sol";

contract DeployMultisig is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Owners for the multisig account
        // Can be random
        address owner1 = vm.envAddress("OWNER_1");
        address owner2 = vm.envAddress("OWNER_2");

        // Read artifact file and get the bytecode hash
        string memory artifact = vm.readFile(
            "zkout/TwoUserMultisig.sol/TwoUserMultisig.json"
        );
        bytes32 multisigBytecodeHash = vm.parseJsonBytes32(artifact, ".hash");
        console.log("Bytecode hash: ");
        console.logBytes32(multisigBytecodeHash);
        bytes32 salt = "1234";

        vm.startBroadcast(deployerPrivateKey);
        AAFactory factory = new AAFactory(multisigBytecodeHash);
        console.log("Factory deployed at: ", address(factory));

        factory.deployAccount(salt, owner1, owner2);
        string memory factoryArtifact = vm.readFile(
            "zkout/AAFactory.sol/AAFactory.json"
        );
        bytes32 factoryBytecodeHash = vm.parseJsonBytes32(
            factoryArtifact,
            ".hash"
        );
        Create2Factory create2Factory = new Create2Factory();
        address multisigAddress = create2Factory.create2(
            salt,
            factoryBytecodeHash,
            abi.encode(owner1, owner2)
        );
        console.log("Multisig deployed at: ", multisigAddress);

        vm.stopBroadcast();
    }
}
