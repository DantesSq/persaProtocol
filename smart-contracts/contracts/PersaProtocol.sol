// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract PersaProtocol {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 amount;
        uint256 amountCollected;
        uint256 duration;
        string image;
        address[] donators;
        uint256[] donations;
        bool isPrivate;
        address[] allowedAddresses;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _amount,
        uint256 _duration,
        string memory _image,
        bool _isPrivate
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.amount = _amount;
        campaign.duration = _duration;
        campaign.image = _image;
        campaign.isPrivate = _isPrivate;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];
        (bool sent, ) = campaign.owner.call{value: msg.value}("");
        require(sent, "Failed to donate to a campaign");
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);
    }

    function getDonators(
        uint256 _id
    ) public view returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}
