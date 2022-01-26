//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRuleset.sol";
import "./Approval.sol";

contract TestRuleset is IRuleset, Ownable {
    string public name = "TestRuleset";
    string public description = "This is a test ruleset";
    Approval public approvalContract;

    constructor(Approval approval) Ownable() {
        approvalContract = approval;
    }

    function getMembers() external view returns (address[] memory members) {
        address[] memory empty = new address[](0);

        return empty;
    }

    function getName() external view returns (string memory) {
        return name;
    }

    function getDescription() external view returns (string memory) {
        return description;
    }

    function approve(uint256 committeeId, uint256 approvalRequestId)
        external
        onlyOwner
    {
        require(
            address(approvalContract) != address(0),
            "Approval contract not set"
        );

        approvalContract.changeStatus(
            committeeId,
            approvalRequestId,
            ApprovalStatus.Approved
        );
    }

    function setApprovalContract(address approvalAddress) external onlyOwner {
        approvalContract = Approval(approvalAddress);
    }
}
