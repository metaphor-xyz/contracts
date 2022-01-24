//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IRuleset.sol";

enum ApprovalStatus {
    Submitted,
    Approved,
    Denied
}

abstract contract Approval {
    struct ApprovalRequest {
        ApprovalStatus status;
        address submitter;
        string formSubmissionURI;
    }

    struct Committee {
        address owner;
        mapping(uint256 => ApprovalRequest) approvalRequests;
        IRuleset ruleset;
        string metadataURI;
        uint256 nextApprovalRequestId;
        // todo(carlos): are we doing this right
        address approvalActionAddress;
        bytes32 approvalActionSelector;
    }

    event RequestCreated(uint256 indexed committeeId, uint256 indexed approvalRequestId);
    event RequestStatusChanged(uint256 indexed committeeId, uint256 indexed approvalRequestId);

    uint256 public nextCommitteeId = 0;
    mapping(uint256 => Committee) public committees;

    function createCommittee(address rulesetAddress, string calldata metadataURI, 
      address approvalActionAddress, bytes32 approvalActionSelector) virtual external returns (uint256 committeeId);

    function getCommittee(uint256 committeeId) virtual public view
      returns (address owner, address ruleset, string memory metadataURI);

    function getApprovalRequest(uint256 committeeId, uint256 approvalRequestId) virtual public view
      returns (address submitter, string memory formSubmissionURI, ApprovalStatus);

    function createApprovalRequest(uint256 committeeId, string calldata formSubmissionURI)
      virtual external returns (uint256 approvalRequestId);

    // todo(carlos): MUST RESTRICT TO ruleset addr
    function changeApprovalStatus(uint256 committeeId, uint256 approvalRequestId,
      ApprovalStatus status) virtual external;
}
