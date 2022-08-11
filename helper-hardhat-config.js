const { ethers } = require("hardhat")

//Note all these below are being derived from our constructor. These are the inputs needed upon deployment.
const networkConfig = {
    4: {
        name: "rinkeby",
        vrfCoordinatorV2: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        entranceFee: ethers.utils.parseEther("0.01"),
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        subscriptionId: "10222",
        callbackGasLimit: "600000", // 600,000
        interval: "30",
    },
    //We don't need to put the vrfCoordinator below because we are using our mock on hardhat
    //For gasLane we can put the same as above or any filler as we'll be using the mock so it won't matter
    31337: {
        name: "hardhat",
        entranceFee: ethers.utils.parseEther("0.01"),
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        subscriptionId: "0",
        callbackGasLimit: "600000", // 600,000
        interval: "30",
    },
}
const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}
