//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Approval.sol";

contract ApprovalImplementation is Approval {
    function createCommittee(
        address ruleset,
        string memory metadataURI,
        address approvalActionAddress,
        bytes32 approvalActionSelector
    ) external override returns (uint256) {
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

    function getCommittee(uint256 committeeId)
        public
        view
        virtual
        override
        returns (
            address owner,
            address ruleset,
            string memory metadataURI
        )
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
        ApprovalRequest storage request = committees[committeeId]
            .approvalRequests[approvalRequestId];

        return (request.submitter, request.formSubmissionURI, request.status);
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

    function changeStatus(
        uint256 committeeId,
        uint256 approvalRequestId,
        ApprovalStatus status
    ) external virtual override {
        Committee storage committee = committees[committeeId];
        ApprovalRequest storage request = committee.approvalRequests[
            approvalRequestId
        ];

        require(
            address(committee.ruleset) == msg.sender,
            "Not committee controller"
        );

        request.status = status;

        emit RequestStatusChanged(committeeId, approvalRequestId);

        // If approved and an action is set, perform that action
        // if (
        //     status == ApprovalStatus.Approved &&
        //     committee.approvalActionAddress != address(0)
        // ) {}
    }
}
