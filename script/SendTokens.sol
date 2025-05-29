pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/interfaces/IStakingHelper.sol";
import {ISuperToken} from "@superfluid-finance/contracts/interfaces/superfluid/ISuperfluid.sol";
import "forge-std/console.sol";

contract SendTokens is Script {

function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    
    vm.startBroadcast(deployerPrivateKey);
    // get the deployer's address
    address deployer = vm.addr(deployerPrivateKey);
    console.log("Deployer's address:", deployer);
    address tokenAddress = 0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58;
    console.log("Token address:", tokenAddress);
    ISuperToken token = ISuperToken(tokenAddress); // should be STREME supertoken
    console.log("Token address:", address(token));
    
    IStakingHelper receiver = IStakingHelper(0x39464d829f8432E8eCd7FEDab6abe4E264D02E0C);

    console.log("Token balance:", token.balanceOf(deployer));
    console.log("Receiver address:", address(receiver));


    token.send(address(receiver), token.balanceOf(deployer), bytes("0x"));

    vm.stopBroadcast();
}

}