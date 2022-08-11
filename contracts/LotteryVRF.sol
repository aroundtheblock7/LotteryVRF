// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

//Goals for our lotttery contract...
//We want users to be able to enter the lottery (paying some fee to enter)
//Users can pick a random number (verifiably random)
//Winner to be selected every X minutes or at some frequency we decide on
//We want everything to be completely automated, not requiring manual maintenance
//Must use a chainlink oracle = Randomness (automated execution) Chainlink keepers

error Raffle_NotEnoughETHEntered();
error Raffle_TransferFailed();
error Raffle_NotOpen();
error Raffle_UpkeepNotNeeded(
    uint256 currentBalance,
    uint256 numPlayers,
    uint256 raffleState
);

/** @title A sample Lottery Contract
 *  @author AroundTheBlock7
 *  @notice This contract is for creating an untamperable decentralized smart contract
 *  @dev This implements Chainlink VRF v2 and Chainlink Keepers
 */

contract LotteryVRF is VRFConsumerBaseV2, KeeperCompatibleInterface {
    enum RaffleState {
        OPEN, //0
        CALCULATING //1
    }

    //State Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint256 public immutable i_entranceFee;
    address payable[] public s_players;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    //Lottery variables
    address private s_recentWinner;
    RaffleState private s_raffleState;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval;

    event LotteryEnter(address indexed player);
    event RequestedLotteryWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_entranceFee = entranceFee;
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        i_interval = interval;
    }

    function enterLottery() public payable {
        //require (msg.value > i_entranceFee, "Not enough ETH!") Instead of this, we can use the if and revert which is cheaper
        if (msg.value < i_entranceFee) {
            revert Raffle_NotEnoughETHEntered();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle_NotOpen();
        }
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }

    //This is the function that the Chainlink Keeper Nodes call. It is run offchain! 
    //They look for the `upkeepNeeded' to return true.
    //The following should be true in order to return true....
    //1.) Our time interval should have passed
    //2.) The lottery should have at least 1 player and have some ETH
    //3.) Our subscription is funded with LINK
    //4.) The lottery should be in an "open" state.
    //The input bytes memory checkData allows us to input any data we want. We wont need for this so we can take out checkData
    //We also don't need performData in the return statement which woulc allow us to do other stuff. We want bool upkeepNeeded!
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool isOpen = (RaffleState.OPEN == s_raffleState);
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasPlayers = (s_players.length > 0);
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasPlayers && hasBalance);
        return (upkeepNeeded, "0x0");
    }

    //This function interacts interacts VRFConsumerBaseV2 Contract/Oracle.
    //If checkUpKeep returns true, than the node automatically calls performUpkeep here.
    //When this is executed by the node it returns a random number & triggers the fulfillRandomWords 
    //Initally we called this function "requestRandomWinner", but after we incorporated keepers and wrote...
    //...the "checkUpkeep" function we renamed this function to performUpkeep and gave it proper inputs (bytes calldata performData)
    function performUpkeep(bytes calldata /* performData */) external override {
        //Remember upkeepNeeded and performData were the 2 things returned to us in checkUpkeep function above
        //We pass in upkeepNeeded here but we do not need performData so leave that out
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle_UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        //We want to make sure we set the RaffleState to calculating so to avoid new entries while we pick a winner
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );

        emit RequestedLotteryWinner(requestId);
    }

    //This function is filled by the VRFCoordinator via the VRFCoordinatorV2Interface.
    //This is automatically called after the requestRandomWinner/performUpkeep function is triggered. The VRFCoordinator fills the request here.
    function fulfillRandomWords(
        uint256,
        /*requestId */
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        //After we pick the winner we want to set the RaffleState to open again and reset the players array!
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0); //resets the array
        //We also want to reset the timestamp here so to keep things running smooth with the interval and picking next winner
        s_lastTimeStamp = block.timestamp;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        //require(success, etc.) chepaer way to do it...
        if (!success) {
            revert Raffle_TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    //When retreiving constant variables in storage we can use "pure" instead of "view" for visibility
    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }

    function getLatestTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    //Again, can use "pure" instead of "view" when returning constants
    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }
}
