pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GoldRace.sol";

contract TestGoldRace {
    uint public initialBalance = 1 ether;

    GoldRace goldRace;
    function beforeAll() public payable {
        goldRace = new GoldRace();
    }

    function testCreateChallenge() public payable {
        Assert.equal(goldRace.betAmount(), uint256(0), "betAmount should be equal to 0 ether");
        goldRace.createChallenge.value(1 ether)();
        Assert.equal(goldRace.betAmount(), uint256(1 ether), "betAmount should be equal to 1 ether");
    }
}
