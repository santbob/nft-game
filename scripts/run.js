const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Karl Marx", "Che Guevara", "Ambedkar", "Periyar"], // Default characters name s
    ["https://i.pinimg.com/474x/1f/87/f2/1f87f22d3b53eb468d69b461fe2ddb74--pop-art-portraits-famous-portraits.jpg",
      "https://i.pinimg.com/736x/2a/34/9f/2a349f1517528a914cfb7323a45ac7c0.jpg",
      "https://i.pinimg.com/564x/ae/ea/fc/aeeafcae8442d4f6ea5c2934977154f6.jpg",
      "https://i.pinimg.com/736x/54/2f/bd/542fbd7ee1daae4a4df238c340ef838a.jpg"
    ], // Default characters Image URIs
    [100, 200, 300, 400], // Default characters HP Values
    [100, 50, 50, 75], // Default characters Attack Damage Values
    "Narendra Modi", // BigBoss Name
    "https://i.pinimg.com/736x/7b/c1/3a/7bc13a80127120f632e6f8c195197146.jpg", // BigBoss Image
    100, //BigBoss HP
    50 //BigBoss AttackDamage
  );
  await gameContract.deployed();
  console.log(`Game contract address: ${gameContract.address}`);

  let txn;

  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

}

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();