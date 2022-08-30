// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {Attack, EtherStore} from "src/ReentrancyInsecure.sol";

contract ReentrancyInsecure is Test {
    using stdStorage for StdStorage;

    Attack attack;
    EtherStore etherStore;

    function setUp() external {
        etherStore = new EtherStore();
        attack = new Attack(address(etherStore));
    }

    // VM Cheatcodes can be found in ./lib/forge-std/src/Vm.sol
    // Or at https://github.com/foundry-rs/forge-std
    function testSetEtherStore() external {
        //          Attack.attack
        // - EtherStore.deposit
        // - EtherStore.withdraw
        // - Attack fallback (receives 1 Ether)
        // - EtherStore.withdraw
        // - Attack.fallback (receives 1 Ether)
        // - EtherStore.withdraw
        // - Attack fallback (receives 1 Ether)
        etherStore.deposit{value: 2 ether}();
        hoax(address(0x2), 3 ether);
        attack.attack{value: 1 ether}();
        vm.stopPrank();
        assertEq(etherStore.getBalance(), 0);
    }
}
