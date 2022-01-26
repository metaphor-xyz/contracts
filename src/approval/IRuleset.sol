//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IRuleset {
    function getMembers() external view returns (address[] memory members);

    function getName() external view returns (string memory name);

    function getDescription() external view returns (string memory description);
}
