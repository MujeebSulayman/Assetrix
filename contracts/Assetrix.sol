// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract RealEstateCampaign is Ownable, Pausable, ReentrancyGuard {
    struct Campaign {
        string name;
        address payable owner;
        uint256 fundingGoal;
        uint256 deadline;
        uint256 totalRaised;
        bool fundsReleased;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed owner,
        string name,
        uint256 fundingGoal,
        uint256 deadline
    );
    event ContributionReceived(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );
    event FundsReleased(uint256 indexed campaignId, uint256 amount);
    event RefundIssued(uint256 indexed campaignId, address indexed investor, uint256 amount);

    modifier campaignExists(uint256 _campaignId) {
        require(_campaignId < campaignCount, "Campaign does not exist");
        _;
    }

    modifier beforeDeadline(uint256 _campaignId) {
        require(block.timestamp < campaigns[_campaignId].deadline, "Deadline passed");
        _;
    }

    modifier afterDeadline(uint256 _campaignId) {
        require(block.timestamp >= campaigns[_campaignId].deadline, "Deadline not reached");
        _;
    }

    function createCampaign(
        string calldata _name,
        uint256 _goal,
        uint256 _deadline
    ) external {
        require(_deadline > block.timestamp, "Deadline must be in the future");
        require(_goal > 0, "Funding goal must be greater than 0");

        campaigns[campaignCount] = Campaign({
            name: _name,
            owner: payable(msg.sender),
            fundingGoal: _goal,
            deadline: _deadline,
            totalRaised: 0,
            fundsReleased: false
        });

        emit CampaignCreated(campaignCount, msg.sender, _name, _goal, _deadline);
        campaignCount++;
    }

    function contribute(uint256 _campaignId)
        external
        payable
        whenNotPaused
        campaignExists(_campaignId)
        beforeDeadline(_campaignId)
    {
        require(msg.value > 0, "Contribution must be greater than 0");

        Campaign storage campaign = campaigns[_campaignId];
        campaign.totalRaised += msg.value;
        contributions[_campaignId][msg.sender] += msg.value;

        emit ContributionReceived(_campaignId, msg.sender, msg.value);
    }

    function releaseFunds(uint256 _campaignId)
        external
        campaignExists(_campaignId)
        afterDeadline(_campaignId)
        nonReentrant
    {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.owner, "Only campaign owner can release funds");
        require(!campaign.fundsReleased, "Funds already released");
        require(campaign.totalRaised >= campaign.fundingGoal, "Funding goal not reached");

        campaign.fundsReleased = true;
        uint256 amount = campaign.totalRaised;
        campaign.owner.transfer(amount);

        emit FundsReleased(_campaignId, amount);
    }

    function claimRefund(uint256 _campaignId)
        external
        campaignExists(_campaignId)
        afterDeadline(_campaignId)
        nonReentrant
    {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.totalRaised < campaign.fundingGoal, "Funding goal was met");

        uint256 contributed = contributions[_campaignId][msg.sender];
        require(contributed > 0, "No contribution to refund");

        contributions[_campaignId][msg.sender] = 0;
        payable(msg.sender).transfer(contributed);

        emit RefundIssued(_campaignId, msg.sender, contributed);
    }

    // BONUS: Admin controls
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
