//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

enum ApprovalStatus {
    Submitted,
    Approved,
    Denied
}

error Unauthorized();

contract CommitteeManager {
    struct ApprovalRequest {
        ApprovalStatus status;
        address submitter;
        string formSubmissionURI;
    }

    struct Committee {
        address owner;
        address approver;
        mapping(uint256 => ApprovalRequest) approvalRequests;
        string metadataURI;
        uint256 nextApprovalRequestId;
        // todo(carlos): are we doing this right
        address approvalActionAddress;
        bytes32 approvalActionSelector;
    }

    event CommitteeCreated(uint256 indexed committeeId);
    event CommitteeUpdated(uint256 indexed committeeId);
    event RequestCreated(
        uint256 indexed committeeId,
        uint256 indexed approvalRequestId
    );
    event RequestStatusChanged(
        uint256 indexed committeeId,
        uint256 indexed approvalRequestId
    );

    uint256 public nextCommitteeId = 0;
    mapping(uint256 => Committee) public committees;

    function createCommittee(
        address approver,
        string memory metadataURI,
        address approvalActionAddress,
        bytes32 approvalActionSelector
    ) external returns (uint256) {
        uint256 committeeId = nextCommitteeId++;
        Committee storage committee = committees[committeeId];
        committee.owner = msg.sender;
        committee.approver = approver;
        committee.metadataURI = metadataURI;
        committee.approvalActionAddress = approvalActionAddress;
        committee.approvalActionSelector = approvalActionSelector;

        emit CommitteeCreated(committeeId);

        return committeeId;
    }

    function changeApprover(uint256 committeeId, address approver) external {
        Committee storage committee = committees[committeeId];

        if (committee.owner != msg.sender) {
            revert Unauthorized();
        }

        committee.approver = approver;

        emit CommitteeCreated(committeeId);
    }

    function getCommittee(uint256 committeeId)
        public
        view
        virtual
        returns (
            address owner,
            address approver,
            string memory metadataURI
        )
    {
        Committee storage committee = committees[committeeId];

        return (
            committee.owner,
            address(committee.approver),
            committee.metadataURI
        );
    }

    function getApprovalRequest(uint256 committeeId, uint256 approvalRequestId)
        public
        view
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
    ) external returns (uint256) {
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
    ) external virtual {
        Committee storage committee = committees[committeeId];
        ApprovalRequest storage request = committee.approvalRequests[
            approvalRequestId
        ];

        if (address(committee.approver) != msg.sender) {
            revert Unauthorized();
        }

        request.status = status;

        emit RequestStatusChanged(committeeId, approvalRequestId);

        // If approved and an action is set, perform that action
        // if (
        //     status == ApprovalStatus.Approved &&
        //     committee.approvalActionAddress != address(0)
        // ) {}
    }
}
