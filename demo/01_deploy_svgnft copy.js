const fs = require("fs");
let { networkConfig } = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	const chainId = await getChainId();

	log("----------------------------------------");

	const SVGNFT = await deploy("self_updating_NFT", {
		from: deployer,
		log: true,
	});

	log(`You have deployed the NFT contract to ${SVGNFT.address}\n`);
	let filepath = "./img/test.svg";
	let svg = fs.readFileSync(filepath, { encoding: "utf8" });

	const svgNFTContract = await hre.ethers.getContractFactory(
		"self_updating_NFT"
	);
	const accounts = await hre.ethers.getSigners();
	const signer = accounts[0];

	const svgNFT = new hre.ethers.Contract(
		SVGNFT.address,
		svgNFTContract.interface,
		signer
	);
	const networkName = networkConfig[chainId]["name"];
	log(
		`Verify with: \n npx hardhat verify --network ${networkName} ${svgNFT.address}\n`
	);

	let transactionResponse = await svgNFT.create();
	let receipt = await transactionResponse.wait(1);

	log(`NFT minted!\n`);
	log(`You can view the tokenUri here: ${await svgNFT.tokenURI(0)}\n`);

	let transferTransaction = svgNFT.transferFrom(signer, accounts[1], 0);
	console.log(await transferTransaction);
};
