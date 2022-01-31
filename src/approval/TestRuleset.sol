//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CommitteeManager.sol";

contract TestRuleset is Ownable {
    CommitteeManager public manager;

    constructor(CommitteeManager _manager) Ownable() {
        manager = _manager;
    }

    function approve(uint256 committeeId, uint256 approvalRequestId)
        external
        onlyOwner
    {
        require(address(manager) != address(0), "Approval contract not set");

        manager.changeStatus(
            committeeId,
            approvalRequestId,
            ApprovalStatus.Approved
        );
    }

    function setApprovalContract(address managerAddress) external onlyOwner {
        manager = CommitteeManager(managerAddress);
    }
}
