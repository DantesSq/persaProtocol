import { assert } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { PersaProtocol, PersaProtocol__factory } from "../typechain-types";
import { Address } from "hardhat-deploy/dist/types";

describe("PersaProtocol", function () {
  let persaProtocol__factory: PersaProtocol__factory;
  let persaProtocol: PersaProtocol;
  let deployer: Address;

  this.beforeEach("Setting up the contract..", async () => {
    // Deploying PersaProtocol contract
    console.log("setting up the contract");
    const { deployer: contractDeployer } = await getNamedAccounts();
    deployer = contractDeployer;
    console.log(`Deployer: ${deployer}`);

    persaProtocol__factory = await ethers.getContractFactory("PersaProtocol");
    persaProtocol = await persaProtocol__factory.deploy();
  });

  it("Campaigns should not exist", async () => {
    const campains = await persaProtocol.getCampaigns();
    assert.equal(campains.length, 0);
  });

  it("Owner constructor equals deployer", async () => {
    const owner = await persaProtocol.i_owner();
    assert.equal(owner, deployer);
  });

  it("Creating new campaign", async () => {
    const title = "";
    const description = "";
    const amount = ethers.parseUnits("0.5", 18); // parse amount to WEI
    const duration = Math.floor(Date.now() / 1000) + 3600;
    const image =
      "https://publish.purewow.net/wp-content/uploads/sites/2/2022/04/fluffy-cat-breeds-cat.jpg?fit=728%2C524"; // string to img how to handle it?
    const isPrivate = false; // because false

    const tx = await persaProtocol.createCampaign(
      title,
      description,
      amount,
      duration,
      image
    );

    // Wait for the transaction to be mined
    await tx.wait();

    // Check the return value of createCampaign
    const createdCampaignId = await persaProtocol.numberOfCampaigns();
    assert.equal(Number(createdCampaignId) - 1, 0, "Campaign ID should be 0");

    // Check the state changes
    const campaigns = await persaProtocol.getCampaigns();
    assert.equal(campaigns.length, 1, "Number of campaigns should be 1");

    const createdCampaign = campaigns[0];
    assert.equal(
      createdCampaign.owner,
      deployer,
      "Owner address should match deployer address"
    );
    assert.equal(createdCampaign.title, title, "Title should match");
    assert.equal(
      createdCampaign.description,
      description,
      "Description should match"
    );
    assert.equal(createdCampaign.amount, amount, "Amount should match");
    assert.equal(
      Number(createdCampaign.duration),
      duration,
      "Duration should match"
    );
    assert.equal(createdCampaign.image, image, "Image URL should match");
  });

  it("Donating to campaign", async () => {
    // Create a campaign
    const title = "Test Campaign";
    const description = "This is a test campaign";
    const amount = ethers.parseUnits("1", 18);
    const duration = Math.floor(Date.now() / 1000) + 3600; // Current time + 1 hour
    const image = "https://example.com/image.jpg";
    const isPrivate = false;

    await persaProtocol.createCampaign(
      title,
      description,
      amount,
      duration,
      image
    );

    // Get the campaign ID
    const campaignId = Number(await persaProtocol.numberOfCampaigns()) - 1;

    // Donate to a campaign
    const donationAmount = ethers.parseUnits("0.5", 18);

    await persaProtocol.donateToCampaign(campaignId, {
      value: donationAmount,
    });

    // Check if the donation was successful
    const campaign = await persaProtocol.campaigns(campaignId);
    assert.equal(
      campaign.amountCollected,
      donationAmount,
      "Campaign amount collected should match donation amount"
    );

    // Check if we were added to donators
    const donators = await persaProtocol.getDonatorsOfCampaign(campaignId);
    console.log("donators, ", donators);
    assert.equal(donators[0][0], deployer, "Donator should match deployer");
  });
});
