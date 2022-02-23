//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "../approval/CommitteeManager.sol";

contract DeployBeacon {
    address private _beaconAddress;

    constructor() {
        CommitteeManager manager = new CommitteeManager();
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(manager));
        BeaconProxy proxy = new BeaconProxy{salt: "beacon-committeemanager"}(
            address(beacon),
            ""
        );
        _beaconAddress = address(proxy);
    }

    function deployedBeacon() external view returns (address) {
        return _beaconAddress;
    }
}
