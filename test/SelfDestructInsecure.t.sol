// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {Attack, EtherGame} from "src/SelfDestructInsecure.sol";

contract SelfDestructInsecure is Test {
    using stdStorage for StdStorage;

    Attack attack;
    EtherGame etherGame;

    function setUp() external {
        etherGame = new EtherGame();
        attack = new Attack(etherGame);
    }

    // VM Cheatcodes can be found in ./lib/forge-std/src/Vm.sol
    // Or at
    function testSelfDestruct() external {
        //          Attack.attack
        // - EtherGame.deposit
        // - EtherGame.withdraw
        // - Attack fallback (receives 1 Ether)
        // - EtherGame.withdraw
        // - Attack.fallback (receives 1 Ether)
        // - EtherGame.withdraw
        // - Attack fallback (receives 1 Ether)
        etherGame.deposit{value: 1 ether}();
        hoax(address(0x2), 7 ether);
        attack.attack{value: 6 ether}();
        vm.stopPrank();
        // assertEq(etherGame.getBalance(), 0);
    }
}
