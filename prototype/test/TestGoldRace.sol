pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GoldRace.sol";

contract TestGoldRace {
    uint public initialBalance = 1 wei;

    GoldRace goldRace;
    function beforeAll() public payable {
        goldRace = new GoldRace();
    }

    function testCreateChallenge() public payable {
        Assert.equal(goldRace.betAmount(), uint256(0), "betAmount should be equal to 0");
        goldRace.createChallenge.value(1 wei)();
        Assert.equal(goldRace.betAmount(), uint256(1), "betAmount should be equal to 1");
    }
}
