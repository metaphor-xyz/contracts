//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IRuleset {
  function getMembers() view external returns (address[] memory members);
  function getName() view external returns (string memory name);
  function getDescription() view external returns (string memory description);
}
