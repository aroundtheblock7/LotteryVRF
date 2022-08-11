# LotteryVRF

### In this project we create a lottery using Chainlinks Verifiably Random Feature that allows users to receive a true random lottery number. We also use ChainLink Keepers to fully automate the lottery so that after enough users have entered (1 in this case), enough time "intervals" have passed (block.timestamps), and there is enough funds in the lottery contract, the Keepers will automatically execute and "upkeep" the contract thererby choosing a winner to the lottery and paying out the winner. 

### In the photos below we can see.. screen shots of the contract deployed successfuly via hardhat to rinkeby network, the VRF Consumer Base site registered with the deployed contract address as the "consumer", the Keepers site funded and registered with a history of "upkeeps", as well as Transaction confirmations on etherscan that shows the user has entered the Lottery. We can also see the internal transactions on etherscan that are used by the VRFCoordinator and the Keepers. This contract can also be run locally on hardhat with via the Mock contract set up. Deploy scripts and Helper-Hardhat--Config.js file were both used to fully automate the deployment process. 

<img width="1194" alt="Screen Shot 2022-08-10 at 9 04 18 PM" src="https://user-images.githubusercontent.com/81759076/184052138-671f4aaa-a4ef-4441-a0e0-27fcad5daaa3.png">
<img width="1615" alt="Screen Shot 2022-08-10 at 9 03 18 PM" src="https://user-images.githubusercontent.com/81759076/184052135-4b8007ac-3c3c-4638-af0c-b3f6604c81fd.png">
<img width="1497" alt="Screen Shot 2022-08-10 at 9 00 32 PM" src="https://user-images.githubusercontent.com/81759076/184052128-7345c95c-d2bf-42fa-887c-a12ae2dc4af2.png">
<img width="1514" alt="Screen Shot 2022-08-10 at 9 04 43 PM" src="https://user-images.githubusercontent.com/81759076/184052174-4a3dcd1d-ad77-48d6-ba21-a0661d86ce49.png">
<img width="1530" alt="Screen Shot 2022-08-10 at 9 05 12 PM" src="https://user-images.githubusercontent.com/81759076/184052176-6fa23c3c-baae-40ea-b0c9-bb42ac77da31.png">
