pragma solidity 0.6.7;

import "remix_tests.sol";
import "remix_accounts.sol";
import "./_GoldRace.sol";

// https://medium.com/remix-ide/solidity-unit-testing-using-remix-tests-part-2-50a9f486ab5d

contract GoldRaceTest {

    GoldRace goldRace;
    function beforeAll() public {
        goldRace = new GoldRace();
    }
    
    /// #sender: account-0
    /// #value: 10
    function checkCreateGame() public payable {
        Assert.equal(msg.sender, TestsAccounts.getAccount(0), "player1 should be equal to account-0");
        Assert.equal(goldRace.betAmount(), uint256(0), "betAmount should be equal to 0");
        goldRace.createChallenge.value(msg.value)();
        Assert.equal(goldRace.betAmount(), uint256(10), "betAmount should be equal to 10");
    }
}
