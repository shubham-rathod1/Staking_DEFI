const hre = require('hardhat');

async function main() {
  // We get the contract to deploy
  const DaiToken = await hre.ethers.getContractFactory('DaiToken');
  const daitoken = await DaiToken.deploy();
  await daitoken.deployed();
  console.log('dai at ', daitoken.address);

  const StakerToken = await hre.ethers.getContractFactory('StakerToken');
  const stakertoken = await StakerToken.deploy();
  await stakertoken.deployed();
  console.log('Staker deployed to:', stakertoken.address);

  const TokenFarm = await hre.ethers.getContractFactory('TokenFarm');
  const tokenFarm = await TokenFarm.deploy(
    stakertoken.address,
    daitoken.address
  );
  await tokenFarm.deployed();
  console.log('tokenfarm deployed to:', tokenFarm.address);

  await stakertoken.transfer(tokenFarm.address, '1000000000000000000000000');
  await daitoken.transfer("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", '1000000000000000000000000');

//dai at  0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
// Staker deployed to: 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
// tokenfarm deployed to: 0x0165878A594ca255338adfa4d48449f69242Eb8F

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
