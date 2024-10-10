// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "@era-contracts/libraries/SystemContractsCaller.sol";
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
        bytes32 bytecodeHash = vm.parseJsonBytes32(artifact, ".hash");
        bytes32 salt = bytes32(
            uint256(
                uint160(address(0x0000000000000000000000000000000000000001))
            )
        );

        vm.startBroadcast(deployerPrivateKey);
        AAFactory factory = new AAFactory(bytecodeHash);

        address multisig = factory.deployAccount(salt, owner1, owner2);

        console.log("Multisig deployed at: ", multisig);

        vm.stopBroadcast();
    }
}
