//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

enum ApprovalStatus {
    Submitted,
    Approved,
    Denied
}

error Unauthorized();

interface IApprovalAction {
    function onApproval(uint256 committeeId, uint256 requestId) external;
}

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
        IApprovalAction approvalAction;
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
        address approvalAction
    ) external returns (uint256) {
        uint256 committeeId = nextCommitteeId++;
        Committee storage _committee = committees[committeeId];
        _committee.owner = msg.sender;
        _committee.approver = approver;
        _committee.metadataURI = metadataURI;
        _committee.approvalAction = IApprovalAction(approvalAction);

        emit CommitteeCreated(committeeId);

        return committeeId;
    }

    function changeApprover(uint256 committeeId, address approver) external {
        Committee storage _committee = committees[committeeId];

        if (_committee.owner != msg.sender) {
            revert Unauthorized();
        }

        _committee.approver = approver;

        emit CommitteeCreated(committeeId);
    }

    function committee(uint256 committeeId)
        public
        view
        virtual
        returns (
            address owner,
            address approver,
            string memory metadataURI
        )
    {
        Committee storage _committee = committees[committeeId];

        return (
            _committee.owner,
            address(_committee.approver),
            _committee.metadataURI
        );
    }

    function request(uint256 committeeId, uint256 approvalRequestId)
        public
        view
        returns (
            address submitter,
            string memory formSubmissionURI,
            ApprovalStatus
        )
    {
        ApprovalRequest storage _request = committees[committeeId]
            .approvalRequests[approvalRequestId];

        return (
            _request.submitter,
            _request.formSubmissionURI,
            _request.status
        );
    }

    function createApprovalRequest(
        uint256 committeeId,
        string memory formSubmissionURI
    ) external returns (uint256) {
        Committee storage _committee = committees[committeeId];
        uint256 approvalRequestId = _committee.nextApprovalRequestId++;
        _committee.approvalRequests[approvalRequestId] = ApprovalRequest({
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
    ) external {
        Committee storage _committee = committees[committeeId];
        ApprovalRequest storage _request = _committee.approvalRequests[
            approvalRequestId
        ];

        if (address(_committee.approver) != msg.sender) {
            revert Unauthorized();
        }

        _request.status = status;

        emit RequestStatusChanged(committeeId, approvalRequestId);

        // If approved and an action is set, perform that action
        if (
            status == ApprovalStatus.Approved &&
            address(_committee.approvalAction) != address(0)
        ) {
            _committee.approvalAction.onApproval(
                committeeId,
                approvalRequestId
            );
        }
    }
}
