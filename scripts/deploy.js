async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Approval = await ethers.getContractFactory("ApprovalImplementation");
  const approval = await Approval.deploy();

  const UpgradeableBeacon = await ethers.getContractFactory("MetaphorBeacon");
  const upgradeableBeacon = await UpgradeableBeacon.deploy(approval.address);

  const BeaconProxy = await ethers.getContractFactory("MetaphorProxy");
  const beaconProxy = await BeaconProxy.deploy(upgradeableBeacon.address, []);


  console.log("Approval address:", approval.address);
  console.log("Proxy address:", beaconProxy.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
