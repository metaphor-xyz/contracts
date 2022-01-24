//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract MetaphorProxy is BeaconProxy {
  constructor(address beacon) BeaconProxy(beacon, "") {
  }
}
