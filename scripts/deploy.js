const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Karl Marx", "Che Guevara", "Ambedkar", "Periyar"], // Default characters name s
    ["QmW4qoZc3YRJcJSm9p8cLyEC53BdmPKbFb5AcDV7NpbTV3",
      "QmNuxqDodmTXMMV7gAM946dXro8ARFvfTTWaX5wHXNFJ7M",
      "QmZk5aTGZtX2t8VqawPM8aDchrS633B4ACNsw6ADo2tY3k",
      "QmTe3pNk6EJuTdGjsEjN7gxGLM6e5QGrkaPYs1apppAtUT"
    ], // Default characters Image URIs
    [100, 200, 300, 400], // Default characters HP Values
    [100, 50, 50, 75], // Default characters Attack Damage Values
    "Narendra Modi", // BigBoss Name
    "QmZ6PrLPVw83ZWw81h1LBTFCqjWzQbVhoibpUYnzqf9kq3", // BigBoss Image
    100, //BigBoss HP
    50 //BigBoss AttackDamage
  );
  await gameContract.deployed();
  console.log(`Game contract address: ${gameContract.address}`);

  // let txn;

  // txn = await gameContract.mintCharacterNFT(2);
  // await txn.wait();

  // txn = await gameContract.attackBoss();
  // await txn.wait();

  // txn = await gameContract.attackBoss();
  // await txn.wait();

  console.log("Done!");
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