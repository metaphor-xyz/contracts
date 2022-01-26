//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import "../ApprovalImplementation.sol";
import "../TestRuleset.sol";

contract ApprovalTest is DSTest {
  ApprovalImplementation approval;
  TestRuleset testRuleset;

  function setUp() public {
    approval = new ApprovalImplementation();
    testRuleset = new TestRuleset(approval);
  }

  function testSetup() public {
    require(address(approval) != address(0), "Contract not setup properly");
  }

  function testCreateEmptyCommittee() public {
    uint256 committeeId = approval.createCommittee(address(0), "ceramic://dns08fbdfb0", address(0), bytes32(0));

    require(committeeId == 0, "Committee ID should be index 0");
  }

  function testCreateCommittee() public {

    uint256 committeeId = approval.createCommittee(address(testRuleset), "ceramic://dns08fbdfb0",
                                                   address(0), bytes32(0));

    require(committeeId == 0, "Committee ID should be index 0");
  }

  function testGetCommittee() public {
    string memory createMetadataURI = "ceramic://dns08fbdfb0";

    uint256 committeeId = approval.createCommittee(address(testRuleset), createMetadataURI, address(0), bytes32(0));

    (address owner, address ruleset, string memory metadataURI) = approval.getCommittee(committeeId);

    require(owner == address(this), "Committee owner should be creator");
    require(ruleset == address(ruleset), "Ruleset should be set to TestRuleset");
    require(keccak256(abi.encodePacked(metadataURI)) == keccak256(abi.encodePacked(createMetadataURI)),
            "Metadata should be the same as on creation");
  }

  function testCreateApprovalRequest() public {
    string memory createMetadataURI = "ceramic://dns08fbdfb0";
    string memory formSubmissionURI = "ceramic://df0dfhhw9";

    uint256 committeeId = approval.createCommittee(address(testRuleset), createMetadataURI, address(0), bytes32(0));

    uint256 approvalRequestId = approval.createApprovalRequest(committeeId, formSubmissionURI);

    require (approvalRequestId == 0, "Approval Request ID should be index 0");
  }

  function testGetApprovalRequest() public {
    string memory createMetadataURI = "ceramic://dns08fbdfb0";
    string memory createFormSubmissionURI = "ceramic://df0dfhhw9";

    uint256 committeeId = approval.createCommittee(address(testRuleset), createMetadataURI, address(0), bytes32(0));

    uint256 approvalRequestId = approval.createApprovalRequest(committeeId, createFormSubmissionURI);

    (address submitter, string memory formSubmissionURI, ApprovalStatus status) =
      approval.getApprovalRequest(committeeId, approvalRequestId);

    require(submitter == address(this), "Submitter should be request creator");
    require(keccak256(abi.encodePacked(formSubmissionURI)) ==
            keccak256(abi.encodePacked(createFormSubmissionURI)),
      "Form submission URI should be same as on creation");
  }

  function testApproveRequest() public {
    string memory createMetadataURI = "ceramic://dns08fbdfb0";
    string memory createFormSubmissionURI = "ceramic://df0dfhhw9";

    uint256 committeeId = approval.createCommittee(address(testRuleset), createMetadataURI, address(0), bytes32(0));

    uint256 approvalRequestId = approval.createApprovalRequest(committeeId, createFormSubmissionURI);

    testRuleset.approve(committeeId, approvalRequestId);

    (address submitter, string memory formSubmissionURI, ApprovalStatus status) =
      approval.getApprovalRequest(committeeId, approvalRequestId);

    require(status == ApprovalStatus.Approved, "Request status should be Approved");
  }
}
