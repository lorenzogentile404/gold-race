const PRNGKECCAK256 = artifacts.require("PRNGKECCAK256");
const GoldRaceDispute = artifacts.require("GoldRaceDispute");
const GoldRace = artifacts.require("GoldRace");

module.exports = function(deployer) {
  deployer.deploy(PRNGKECCAK256, 1); // GoldRaceDispute should interact with its own instance of PRNGKECCAK256 -> FIX
  deployer.link(PRNGKECCAK256, GoldRaceDispute);
  deployer.deploy(GoldRaceDispute);
  deployer.link(GoldRaceDispute, GoldRace);
  deployer.deploy(GoldRace);
};
