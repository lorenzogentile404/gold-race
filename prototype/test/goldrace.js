const GoldRace = artifacts.require("GoldRace");

contract('GoldRaceTest', (accounts) => {

  it('testCreateChallenge', async () => {
    const goldRaceInstance = await GoldRace.deployed();

    // Player 1 creates challenge
    assert.equal(await web3.eth.getBalance(goldRaceInstance.address), 0, "balance is not 0 wei");
    await goldRaceInstance.createChallenge({from: accounts[0], value: 1});
    assert.equal(await web3.eth.getBalance(goldRaceInstance.address), 1, "balance is not 1 wei");
  });

  it('testAcceptChallenge', async () => {
    const goldRaceInstance = await GoldRace.deployed();

    // Player 2 accepts challenge
    assert.equal(await goldRaceInstance.player1(), accounts[0], "player1 is not accounts[0]");
    await goldRaceInstance.acceptChallenge({from: accounts[1], gas: 3000000, value: 1});
    assert.equal(await web3.eth.getBalance(goldRaceInstance.address), 2, "balance is not 2 wei");
    assert.equal(await goldRaceInstance.player2(), accounts[1], "player2 is not accounts[1]");
    assert.equal(await goldRaceInstance.isPlayer1Turn(), true, "player1 is not the first player to play");
  });

  it('testSequenceOfMoves', async () => {
    const goldRaceInstance = await GoldRace.deployed();

    assert.equal(await goldRaceInstance.isProposedStateAccepted(), true, "Unexepected isProposedStateAccepted value");

    // First move
    await goldRaceInstance.move("0x01", {from: accounts[0]});
    assert.equal(await goldRaceInstance.proposedState(), "0x01", "State should be 0x01");

    // Second move
    assert.equal(await goldRaceInstance.isPlayer1Turn(), false, "Unexepected isPlayer1Turn value");
    assert.equal(await goldRaceInstance.isProposedStateAccepted(), false, "Unexepected isProposedStateAccepted value");
    await goldRaceInstance.acceptState({from: accounts[1]});
    assert.equal(await goldRaceInstance.isProposedStateAccepted(), true, "Unexepected isProposedStateAccepted value");
    await goldRaceInstance.move("0x02", {from: accounts[1]});
    assert.equal(await goldRaceInstance.proposedState(), "0x02", "State should be 0x02");

    // Third move
    assert.equal(await goldRaceInstance.isPlayer1Turn(), true, "Unexepected isPlayer1Turn value");
    assert.equal(await goldRaceInstance.isProposedStateAccepted(), false, "Unexepected isProposedStateAccepted value");
    await goldRaceInstance.acceptState({from: accounts[0]});
    assert.equal(await goldRaceInstance.isProposedStateAccepted(), true, "Unexepected isProposedStateAccepted value");
    await goldRaceInstance.move("0x03", {from: accounts[0]});
    assert.equal(await goldRaceInstance.proposedState(), "0x03", "State should be 0x03");
  });
});
