//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Approval.sol";

contract ApprovalImplementation is Approval {
    function createCommittee(address ruleset, string memory metadataURI,
      address approvalActionAddress, bytes32 approvalActionSelector)
        external override returns (uint256)
    {
        // TODO: check that address is a ruleSet contract

        uint256 committeeId = nextCommitteeId++;
        Committee storage committee = committees[committeeId];
        committee.owner = msg.sender;
        committee.ruleset = IRuleset(ruleset);
        committee.metadataURI = metadataURI;
        committee.approvalActionAddress = approvalActionAddress;
        committee.approvalActionSelector = approvalActionSelector;

        return committeeId;
    }

    function getCommittee(uint256 committeeId) virtual public view override
      returns (address owner, address ruleset, string memory metadataURI)
    {
      Committee storage committee = committees[committeeId];

      return (
        committee.owner,
        address(committee.ruleset),
        committee.metadataURI
      );
    }

    function getApprovalRequest(uint256 committeeId, uint256 approvalRequestId)
        public
        view
        override
        returns (
            address submitter,
            string memory formSubmissionURI,
            ApprovalStatus
        )
    {
        ApprovalRequest storage request = committees[committeeId].approvalRequests[
            approvalRequestId
        ];

        return (
            request.submitter,
            request.formSubmissionURI,
            request.status
        );
    }

    function createApprovalRequest(
        uint256 committeeId,
        string memory formSubmissionURI
    ) external override returns (uint256) {
        Committee storage committee = committees[committeeId];
        uint256 approvalRequestId = committee.nextApprovalRequestId++;
        committee.approvalRequests[approvalRequestId] = ApprovalRequest({
            submitter: msg.sender,
            formSubmissionURI: formSubmissionURI,
            status: ApprovalStatus.Submitted
        });

        emit RequestCreated(committeeId, approvalRequestId);

        return approvalRequestId;
    }

    function changeApprovalStatus(uint256 committeeId, uint256 approvalRequestId,
                                  ApprovalStatus status) virtual external override {
      Committee storage committee = committees[committeeId];
      ApprovalRequest storage request = committee.approvalRequests[approvalRequestId];

      require(address(committee.ruleset) == msg.sender,
              "ApprovalStatus can only be changed by the committee's Ruleset contract");

      request.status = status;

      emit RequestStatusChanged(committeeId, approvalRequestId);

      // If approved and an action is set, perform that action
      if (status == ApprovalStatus.Approved && committee.approvalActionAddress != address(0)) {
      }
    }
}

contract ApprovalImplementationTest {
  ApprovalImplementation approval;

  function setUp() public {
    approval = new ApprovalImplementation();
  }

  function testSetup() public {
    require(address(approval) != address(0), "Contract not setup properly");
  }

  function testCreateEmptyCommittee() public {
    uint256 committeeId = approval.createCommittee(address(0), "ceramic://dns08fbdfb0", address(0), bytes32(0));

    require(committeeId == 0, "Committee ID should be index 0");
  }

  function testGetCommittee() public {
    string memory createMetadataURI = "ceramic://dns08fbdfb0";

    uint256 committeeId = approval.createCommittee(address(0), createMetadataURI, address(0), bytes32(0));

    (address owner, address ruleset, string memory metadataURI) = approval.getCommittee(committeeId);

    require(owner == address(this), "Committee owner should be creator");
    require(ruleset == address(0), "Ruleset should be unset");
    require(keccak256(abi.encodePacked(metadataURI)) == keccak256(abi.encodePacked(createMetadataURI)),
            "Metadata should be the same as on creation");
  }

  function testCreateApprovalRequest() public {
    string memory createMetadataURI = "ceramic://dns08fbdfb0";
    string memory formSubmissionURI = "ceramic://df0dfhhw9";

    uint256 committeeId = approval.createCommittee(address(0), createMetadataURI, address(0), bytes32(0));

    uint256 approvalRequestId = approval.createApprovalRequest(committeeId, formSubmissionURI);

    require (approvalRequestId == 0, "Approval Request ID should be index 0");
  }

  function testGetApprovalRequest() public {
    string memory createMetadataURI = "ceramic://dns08fbdfb0";
    string memory createFormSubmissionURI = "ceramic://df0dfhhw9";

    uint256 committeeId = approval.createCommittee(address(0), createMetadataURI, address(0), bytes32(0));

    uint256 approvalRequestId = approval.createApprovalRequest(committeeId, createFormSubmissionURI);

    (address submitter, string memory formSubmissionURI, ApprovalStatus status) =
      approval.getApprovalRequest(committeeId, approvalRequestId);

    require(submitter == address(this), "Submitter should be request creator");
    require(keccak256(abi.encodePacked(formSubmissionURI)) ==
            keccak256(abi.encodePacked(createFormSubmissionURI)),
      "Form submission URI should be same as on creation");
  }
}
