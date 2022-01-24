//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Approval.sol";

contract ApprovalImplementation is Approval {
    function createCommittee(string memory infoJson, address admittanceRuleset)
        external override
    {
        // TODO: check that address is a ruleSet contract

        // TODO: write infoJson to Ceramic
        string memory infoUri = infoJson;

        uint256 committeeId = nextCommitteeId++;
        Committee storage committee = committees[committeeId];
        committee.id = committeeId;
        committee.infoUri = infoUri;
        committee.admittanceRuleset = admittanceRuleset;
        committee.memberAddrs.push(msg.sender);
        Member storage member = committee.members[msg.sender];
        member.addr = msg.sender;
        member.applicationUri = "Owner didn't apply!";
        committeeIds.push(committeeId);
    }

    function listCommittees() public view override returns (uint256[] memory) {
        uint256[] memory localCommitteeIds = committeeIds;
        return localCommitteeIds;
    }

    function listApplicants(uint256 committeeId)
        public
        view
        override
        returns (address[] memory)
    {
        bool isMember = false;
        for (
            uint256 i = 0;
            i < committees[committeeId].memberAddrs.length;
            i++
        ) {
            if (committees[committeeId].memberAddrs[i] == msg.sender) {
                isMember = true;
            }
        }
        require(isMember, "Non-members cannot read list of applicants.");

        address[] memory applicants = committees[committeeId].applicantAddrs;
        return applicants;
    }

    function getApplicant(uint256 committeeId, address applicantAddr)
        public
        view
        override
        returns (
            string memory,
            Status,
            string memory
        )
    {
        bool isMember = false;
        for (
            uint256 i = 0;
            i < committees[committeeId].memberAddrs.length;
            i++
        ) {
            if (committees[committeeId].memberAddrs[i] == msg.sender) {
                isMember = true;
            }
        }
        require(isMember, "Non-members cannot read list of applicants.");

        Applicant storage applicant = committees[committeeId].applicants[
            applicantAddr
        ];
        return (
            applicant.applicationUri,
            applicant.status,
            applicant.justification
        );
    }

    function listMembers(uint256 committeeId)
        public
        view
        override
        returns (address[] memory)
    {
        bool isMember = false;
        for (
            uint256 i = 0;
            i < committees[committeeId].memberAddrs.length;
            i++
        ) {
            if (committees[committeeId].memberAddrs[i] == msg.sender) {
                isMember = true;
            }
        }
        require(isMember, "Non-members cannot read list of applicants.");

        address[] memory members = committees[committeeId].memberAddrs;
        return members;
    }

    function getMember(uint256 committeeId, address memberAddr)
        public
        view
        override
        returns (string memory)
    {
        bool isMember = false;
        for (
            uint256 i = 0;
            i < committees[committeeId].memberAddrs.length;
            i++
        ) {
            if (committees[committeeId].memberAddrs[i] == msg.sender) {
                isMember = true;
            }
        }
        require(isMember, "Non-members cannot read list of applicants.");

        Member storage member = committees[committeeId].members[memberAddr];
        return member.applicationUri;
    }

    function upvoteApplicant(uint256 committeeId, address applicantAddr)
        external override
    {
        bool isMember = false;
        for (
            uint256 i = 0;
            i < committees[committeeId].memberAddrs.length;
            i++
        ) {
            if (committees[committeeId].memberAddrs[i] == msg.sender) {
                isMember = true;
            }
        }
        require(isMember, "Non-members cannot read list of applicants.");

        require(
            committees[committeeId].applicants[applicantAddr].addr !=
                address(0),
            "Applicant has not applied."
        );
        require(
            committees[committeeId].applicants[applicantAddr].status ==
                Status.Submitted,
            "Applicant decision has already been made."
        );

        // TODO: send upvote for applicant to ruleset
        // for now, any upvote automatically adds a member
        Applicant storage applicant = committees[committeeId].applicants[
            applicantAddr
        ];
        applicant.status = Status.Approved;
        applicant.justification = "This person IS super cool!";

        committees[committeeId].members[applicantAddr] = Member({
            addr: applicantAddr,
            applicationUri: applicant.applicationUri
        });
        committees[committeeId].memberAddrs.push(applicantAddr);
    }

    function applyToCommittee(
        uint256 committeeId,
        string memory applicationJson
    ) external override {
        require(
            committees[committeeId].applicants[msg.sender].addr == address(0),
            "Applicant has already applied."
        );
        require(
            committees[committeeId].members[msg.sender].addr == address(0),
            "Applicant is already a member."
        );
        require(
            committees[committeeId].applicants[msg.sender].status !=
                Status.Denied,
            "Applicant has already been denied."
        );

        // TODO: encrypt applicationJson
        string memory encryptedApplicationJson = applicationJson;

        // TODO: write encryptedApplicationJson to Ceramic
        string memory applicationUri = encryptedApplicationJson;

        committees[committeeId].applicants[msg.sender] = Applicant({
            addr: msg.sender,
            applicationUri: applicationUri,
            status: Status.Submitted,
            justification: ""
        });
        committees[committeeId].applicantAddrs.push(msg.sender);
    }
}