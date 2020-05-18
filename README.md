# GOLD RACE: **G**ame with **O**ff-chain **L**ogic and **D**ispute **R**esolution r**A**ndom **C**ommitt**E**e

On-chain verification of a game logic may be a very expensive operation. A workaround is requiring players to mutually validate the moves off-chain. As far as players agree on the next state of the game, no additional logic is required. However, in case of a dispute, a resolution mechanism is necessary.

A naive solution may consist in providing to third-parties an incentive to vote honestly regarding the validity of the next proposed state, in a fashion similar to decentralized oracles. However, giving the opportunity to vote to anybody makes the mechanism vulnerable to attacks by players, who may be interested in voting in a way that is profitable for them.

GOLD RACE is a protocol that aims to mitigate this risk by randomly computing a committee who is eligible to vote regarding the validity of the next proposed state.

## Contents of the repository

- ```/prototype/contracts```: contains a Solidity prototypal implementation of the main components of the protocol.

In particular, the contract ```GoldRace.sol``` implements the game logic: players can create a challenge, make a bet, propose their moves, accept them or, eventually, open a dispute.

On the other hand, the contract ```GoldRaceDispute.sol``` implements the dispute logic: players can generate a random committee of an arbitrary size by running a coin tossing protocol, members of the random committee can vote to define a valid state and the majority is rewarded.

Moreover, if one of the players leave the game or the dispute when he or she is expected to execute an action, the other player is legitimized to claim the victory after a certain time. For the purposes of simplifying the prototype, it is assumed that the members of the random committee always cooperate to conclude the voting phase.

- ```/prototype/test```: containts unit and integration tests written in Solidity and Javascript.

## How to test?

Get [Ganache](https://www.trufflesuite.com/ganache) and [Truffle](https://www.trufflesuite.com/truffle), that allow to build an Ethereum testing blockchain running on your computer.

Then run Ganache and follow the guided procedure.

```console
user@host:~$ ./ganache-2.4.0-linux-x86_64.AppImage 
12:47:11.971 › Checking for update
listen to truffle
```

Finally, run the tests as follows.

```console
user@host:~$ cd gold-race/prototype/
user@host:~/gold-race/prototype$ truffle test
Using network 'development'.


Compiling your contracts...
===========================
> Compiling ./test/TestGoldRace.sol
> Artifacts written to /tmp/test-120411-11899-1sw0ao1.ujf1g
> Compiled successfully using:
   - solc: 0.5.0+commit.1d4f565a.Emscripten.clang



  TestGoldRace
    ✓ testCreateChallenge (162ms)

  Contract: GoldRaceTest
    ✓ testCreateChallenge (65ms)
    ✓ testAcceptChallenge (111ms)
    ✓ testSequenceOfMoves (621ms)
    ✓ testOpenDispute (194ms)
    ✓ testDispute (974ms)
    ✓ testCloseDispute (136ms)


  7 passing (12s)
```
