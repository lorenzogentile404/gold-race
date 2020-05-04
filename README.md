# GOLD RACE: **G**ame with **O**ff-chain **L**ogic and **D**ispute **R**esolution r**A**ndom **C**ommitt**E**e

On-chain verification of a game logic may be a very expensive operation. A workaround is requiring players to mutually validate the moves off-chain.
As far as players agree on the next state of the game, no additional logic is required.
However, in case of a dispute, a resolution mechanism is necessary.

A naive solution may consist of providing to third-parties an incentive to vote honestly regarding the validity of the next proposed state, in a fashion similar to Decentralized Oracles such as [Augur](https://www.augur.net/).
However,  giving the opportunity to vote for anybody makes the mechanism vulnerable to attacks by players, who may be interested to vote in a way that is profitable for them.

GOLD RACE is a protocol that aims to mitigate this risk by randomly computing a committee who is eligible to vote regarding the validity of the next proposed state.
