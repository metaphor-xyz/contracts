/* solhint-disable reason-string */
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import "../CommitteeManager.sol";
import "../TestRuleset.sol";

contract CommitteeManagerTest is DSTest {
    CommitteeManager private manager;
    TestRuleset private testRuleset;

    function setUp() public {
        manager = new CommitteeManager();
        testRuleset = new TestRuleset(manager);
    }

    function testSetup() public {
        require(address(manager) != address(0), "Contract not setup properly");
    }

    function testCreateEmptyCommittee() public {
        uint256 committeeId = manager.createCommittee(
            address(0),
            "ceramic://dns08fbdfb0",
            address(0),
            bytes32(0)
        );

        require(committeeId == 0, "Committee ID should be index 0");
    }

    function testCreateCommittee() public {
        uint256 committeeId = manager.createCommittee(
            address(testRuleset),
            "ceramic://dns08fbdfb0",
            address(0),
            bytes32(0)
        );

        require(committeeId == 0, "Committee ID should be index 0");
    }

    function testChangeApprover() public {
        TestRuleset newRuleset = new TestRuleset(manager);

        uint256 committeeId = manager.createCommittee(
            address(testRuleset),
            "ceramic://dns08fbdfb0",
            address(0),
            bytes32(0)
        );

        manager.changeApprover(committeeId, address(newRuleset));

        (address owner, address ruleset, string memory metadataURI) = manager
            .getCommittee(committeeId);

        require(ruleset == address(newRuleset), "Approver not updated");
    }

    function testGetCommittee() public {
        string memory createMetadataURI = "ceramic://dns08fbdfb0";

        uint256 committeeId = manager.createCommittee(
            address(testRuleset),
            createMetadataURI,
            address(0),
            bytes32(0)
        );

        (address owner, address ruleset, string memory metadataURI) = manager
            .getCommittee(committeeId);

        require(owner == address(this), "Committee owner should be creator");
        require(
            ruleset == address(ruleset),
            "Ruleset should be set to TestRuleset"
        );
        require(
            keccak256(abi.encodePacked(metadataURI)) ==
                keccak256(abi.encodePacked(createMetadataURI)),
            "Metadata should be the same as on creation"
        );
    }

    function testCreateApprovalRequest() public {
        string memory createMetadataURI = "ceramic://dns08fbdfb0";
        string memory formSubmissionURI = "ceramic://df0dfhhw9";

        uint256 committeeId = manager.createCommittee(
            address(testRuleset),
            createMetadataURI,
            address(0),
            bytes32(0)
        );

        uint256 approvalRequestId = manager.createApprovalRequest(
            committeeId,
            formSubmissionURI
        );

        require(
            approvalRequestId == 0,
            "Approval Request ID should be index 0"
        );
    }

    function testGetApprovalRequest() public {
        string memory createMetadataURI = "ceramic://dns08fbdfb0";
        string memory createFormSubmissionURI = "ceramic://df0dfhhw9";

        uint256 committeeId = manager.createCommittee(
            address(testRuleset),
            createMetadataURI,
            address(0),
            bytes32(0)
        );

        uint256 approvalRequestId = manager.createApprovalRequest(
            committeeId,
            createFormSubmissionURI
        );

        (
            address submitter,
            string memory formSubmissionURI,
            ApprovalStatus status
        ) = manager.getApprovalRequest(committeeId, approvalRequestId);

        require(
            submitter == address(this),
            "Submitter should be request creator"
        );
        require(
            keccak256(abi.encodePacked(formSubmissionURI)) ==
                keccak256(abi.encodePacked(createFormSubmissionURI)),
            "Form submission URI should be same as on creation"
        );
    }

    function testApproveRequest() public {
        string memory createMetadataURI = "ceramic://dns08fbdfb0";
        string memory createFormSubmissionURI = "ceramic://df0dfhhw9";

        uint256 committeeId = manager.createCommittee(
            address(testRuleset),
            createMetadataURI,
            address(0),
            bytes32(0)
        );

        uint256 approvalRequestId = manager.createApprovalRequest(
            committeeId,
            createFormSubmissionURI
        );

        testRuleset.approve(committeeId, approvalRequestId);

        (
            address submitter,
            string memory formSubmissionURI,
            ApprovalStatus status
        ) = manager.getApprovalRequest(committeeId, approvalRequestId);

        require(
            status == ApprovalStatus.Approved,
            "Request status should be Approved"
        );
    }
}
