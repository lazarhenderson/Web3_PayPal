const hre = require("hardhat");

async function main() {
  const PayPal = await hre.ethers.getContractFactory("PayPal");
  const paypal = await PayPal.deploy();

  await paypal.deployed();

  console.log("PayPal contract address: ", paypal.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
