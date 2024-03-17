// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

error InvalidCampaign();

contract PersaProtocol {
    uint256 public numberOfCampaigns = 0;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 amount;
        uint256 amountCollected;
        uint256 duration;
        string image;
    }

    struct Donation {
        address user;
        uint256 campaignId;
        uint256 amount;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Donation[]) public campaignDonations; // Mapping from campaign ID to list of donations
    mapping(address => Donation[]) public userDonations; // Mapping from user address to list of donations

    modifier validCampaignId(uint256 _id) {
        if (_id < numberOfCampaigns - 1) revert InvalidCampaign();
        _;
    }

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _amount,
        uint256 _duration,
        string memory _image
    ) public returns (uint256) {
        require(
            _duration > block.timestamp,
            "Campaign duration must be in the future"
        );

        Campaign storage campaign = campaigns[numberOfCampaigns];

        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.amount = _amount;
        campaign.duration = _duration;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable validCampaignId(_id) {
        uint256 amount = msg.value;

        require(amount > 0, "Amount should be greater than 0");

        Campaign storage campaign = campaigns[_id];

        require(
            campaign.amountCollected + amount < campaign.amount,
            "Donated amount exceeds the required amount"
        );

        (bool sent, ) = campaign.owner.call{value: msg.value}("");
        require(sent, "Failed to donate to a campaign");
        campaign.amountCollected = campaign.amountCollected + amount;

        // Update donation mappings
        userDonations[msg.sender].push(
            Donation({user: msg.sender, amount: amount, campaignId: _id})
        );
        campaignDonations[_id].push(
            Donation({user: msg.sender, amount: amount, campaignId: _id})
        );
    }

    function getDonatorsOfCampaign(
        uint256 _id
    ) public view validCampaignId(_id) returns (Donation[] memory) {
        return campaignDonations[_id];
    }

    function getDonationsOfUser() public view returns (Donation[] memory) {
        return userDonations[msg.sender];
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    // TODO --- Implement stop campaign
    // function stopCampaign() {}

    // TODO --- Implement extend campaign
    // functions extendCampaign(){}
}
