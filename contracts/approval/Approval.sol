//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

abstract contract Approval {
    enum Status {
        Submitted,
        Approved,
        Denied
    }

    struct Applicant {
        address addr;
        string applicationUri;
        Status status;
        string justification;
    }

    struct Member {
        address addr;
        string applicationUri;
    }

    struct Committee {
        uint256 id;
        string infoUri;
        mapping(address => Applicant) applicants;
        address[] applicantAddrs;
        mapping(address => Member) members;
        address[] memberAddrs;
        address admittanceRuleset;
    }

    event ApplicantApplied(address applicant, uint256 committeeId);
    event ApplicantDenied(address applicant, uint256 committeeId);
    event ApplicantApproved(address applicant, uint256 committeeId);

    mapping(uint256 => Committee) public committees;
    uint256[] public committeeIds;
    uint256 public nextCommitteeId = 0;

    function createCommittee(string memory infoJson, address admittanceRuleset) virtual external;

    function listCommittees() virtual public view returns (uint256[] memory);

    function listApplicants(uint256 committeeId) virtual public view returns (address[] memory);

    function getApplicant(uint256 committeeId, address applicantAddr) virtual public view
      returns (string memory, Status, string memory);

    function listMembers(uint256 committeeId) virtual public view returns (address[] memory);

    function getMember(uint256 committeeId, address memberAddr) virtual public view returns (string memory);

    function upvoteApplicant(uint256 committeeId, address applicantAddr) virtual external;

    function applyToCommittee(uint256 committeeId, string memory applicationJson) virtual external;
}
