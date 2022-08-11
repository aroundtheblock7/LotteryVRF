const { getNamedAccounts, deployments, network, ethers } = require("hardhat")
const { ModifierDefinition } = require("prettier-plugin-solidity/src/nodes");
const { developmentChains } = require("../helper-hardhat-config")

//It costs 0.25 Link per request. This is listed as the "premium" under Rinkeby for the VRF Coordinator
const BASE_FEE = ethers.utils.parseEther("0.25");
const GAS_PRICE_LINK = 1e9 // This is the link per gas. It is equivalent to 1000000000 

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const args = [BASE_FEE, GAS_PRICE_LINK]

    if (developmentChains.includes(network.name)) {
        log("Local network detected! Deploying mocks...")
        //deploy a mock vrfCoordinator...
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: args,
        })
        log("Mocks Deployed!")
        log("--------------------------------------------")
    }
}
module.exports.tags = ["all", "mocks"]