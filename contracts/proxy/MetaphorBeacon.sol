//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract MetaphorBeacon is UpgradeableBeacon {
  constructor(address implementation) UpgradeableBeacon(implementation) {
  }
}
