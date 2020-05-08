const GoldRace = artifacts.require("GoldRace");
const GoldRaceDispute = artifacts.require("GoldRaceDispute");

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

  it('testOpenDispute', async () => {
    const goldRaceInstance = await GoldRace.deployed();

    await goldRaceInstance.openDispute("0xd8d1bafb5c31fa4d1b1219af9981f1e4c769a81804f77536d2f8d28e49f15b7c", {from: accounts[1]});
    assert.equal(await goldRaceInstance.isDisputeOpen(), true, "isDisputeOpen should be true");

    const goldRaceDisputeAddress = await goldRaceInstance.goldRaceDispute();
    const goldRaceDisputeInstance = await GoldRaceDispute.at(goldRaceDisputeAddress);
    assert.equal(await goldRaceDisputeInstance.prosecution(), accounts[1], "accounts[1] should be prosecution");
    assert.equal(await goldRaceDisputeInstance.defence(), accounts[0], "accounts[0] should be defence");
  });

  it('testDispute', async () => {
    const goldRaceInstance = await GoldRace.deployed();
    const goldRaceDisputeAddress = await goldRaceInstance.goldRaceDispute();
    const goldRaceDisputeInstance = await GoldRaceDispute.at(goldRaceDisputeAddress);

    const prosecution = await goldRaceDisputeInstance.prosecution();
    const defence = await goldRaceDisputeInstance.defence();

    assert.equal(await goldRaceDisputeInstance.status(), 0, "Status should be 0");
    await goldRaceDisputeInstance.r2Publish("0xc9b4b12795aff539b518febdb382f6930d336e", {from: defence});

    assert.equal(await goldRaceDisputeInstance.status(), 1, "Status should be 1");
    await goldRaceDisputeInstance.reveal("0x48b0517dc17384a96f0dde4440cc4101d2d7f6", 1, {from: prosecution});

    assert.equal(await goldRaceDisputeInstance.status(), 2, "Status should be 2");

    // true, 123 -> "0x48b0517dc17384a96f0dde4440cc4101d2d7f669f62c2a4395c27d7a2e791474"
    // false, 123 -> "0x0c995408c4b5a2753bd04b90076c88cae982eb7fd8c8929c22b3deff08db3eed"
    await goldRaceDisputeInstance.commitVote("0x48b0517dc17384a96f0dde4440cc4101d2d7f669f62c2a4395c27d7a2e791474", {from: accounts[2]});
    await goldRaceDisputeInstance.commitVote("0x48b0517dc17384a96f0dde4440cc4101d2d7f669f62c2a4395c27d7a2e791474", {from: accounts[3]});
    await goldRaceDisputeInstance.commitVote("0x0c995408c4b5a2753bd04b90076c88cae982eb7fd8c8929c22b3deff08db3eed", {from: accounts[4]});

    assert.equal(await goldRaceDisputeInstance.status(), 3, "Status should be 3");
    assert.equal(await goldRaceDisputeInstance.votesCommitmentsCounter(), 3, "Votes commitments should be 3");

    await goldRaceDisputeInstance.revealVote(true, 123, {from: accounts[2]});
    await goldRaceDisputeInstance.revealVote(true, 123, {from: accounts[3]});
    await goldRaceDisputeInstance.revealVote(false, 123, {from: accounts[4]});

    assert.equal(await goldRaceDisputeInstance.status(), 4, "Status should be 4"); // VALID
  });

  it('testCloseDispute', async () => {
    const goldRaceInstance = await GoldRace.deployed();
    
    await goldRaceInstance.closeDispute();
    assert.equal(await web3.eth.getBalance(goldRaceInstance.address), 0, "balance is not 0 wei");
  });
});
