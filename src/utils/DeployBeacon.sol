//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract DeployBeacon {
    address private _beaconAddress;

    function deploy(address beacon, bytes32 salt) external {
        BeaconProxy proxy = new BeaconProxy{salt: salt}(beacon, "");
        _beaconAddress = address(proxy);
    }

    function deployedBeacon() external view returns (address) {
        return _beaconAddress;
    }
}
