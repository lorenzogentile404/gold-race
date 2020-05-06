const GoldRaceDispute = artifacts.require("GoldRaceDispute");
const GoldRace = artifacts.require("GoldRace");

module.exports = function(deployer) {
  deployer.deploy(GoldRaceDispute);
  deployer.link(GoldRaceDispute, GoldRace);
  deployer.deploy(GoldRace);
};
