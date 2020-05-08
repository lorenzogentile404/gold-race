pragma solidity >=0.4.21 <0.7.0;

import "./GoldRaceDispute.sol";

contract GoldRace {

    address payable public player1 = address(0);
    address payable public player2 = address(0);
    bool public isPlayer1Turn = true;
    uint256 public betAmount = 0;
    uint256 public moveExpiration;
    uint constant public timePerMove = 30 minutes;
    
    bytes public state = "";
    bytes public proposedState = "";
    bool public isProposedStateAccepted = true;
    
    bool public isDisputeOpen = false;
    GoldRaceDispute public goldRaceDispute;
    
    function createChallenge() public payable {
        require(!isDisputeOpen);
        
        require(player1 == address(0));
        require(player2 == address(0));
        
        require(msg.value > 0);
        
        player1 = msg.sender;
        betAmount = msg.value;
    }
    
    function cancelChallenge() public {
        require(!isDisputeOpen);
        
        require(player1 != address(0));
        require(player2 == address(0));
        
        require(msg.sender == player1);

        msg.sender.transfer(address(this).balance);
        
        player1 = address(0);
        betAmount = 0;
    }
    
    function acceptChallenge() public payable {
        require(!isDisputeOpen);
        
        require(player1 != address(0));
        require(player2 == address(0));
        
        require(msg.sender != player1);
        require(msg.value == betAmount);

        player2 = msg.sender;

        moveExpiration = now + timePerMove;
    }
    
    function acceptState() public {
        require(!isDisputeOpen);
        
        require(isProposedStateAccepted == false);
        
        require(now < moveExpiration);
        
        require(player1 != address(0));
        require(player2 != address(0));
        if (isPlayer1Turn) {
            require(msg.sender == player1);
        } else {
            require(msg.sender == player2);
        }
        
        state = proposedState;
        isProposedStateAccepted = true;
    }
    
    // Example move: "0x67fa"
    function move(bytes memory _proposedState) public {
        /* Note that _proposedState can include also a winning state
        e.g., in the case of chess Qh5# indicates that the Queen goes 
        to h5 and it is checkmate. */
        require(!isDisputeOpen);
        
        require(isProposedStateAccepted == true);
        
        require(now < moveExpiration);
        
        require(player1 != address(0));
        require(player2 != address(0));
        if (isPlayer1Turn) {
            require(msg.sender == player1);
        } else {
            require(msg.sender == player2);
        }
        
        proposedState = _proposedState;
        
        moveExpiration = now + timePerMove;
        isPlayer1Turn = !isPlayer1Turn;
        isProposedStateAccepted = false;
    }
    
    function openDispute(bytes32 _c1) public {
        require(!isDisputeOpen);
        
        require(isProposedStateAccepted == false);
        
        require(now < moveExpiration);
        
        require(player1 != address(0));
        require(player2 != address(0));
        // For te
        if (isPlayer1Turn) {
            require(msg.sender == player1);
            goldRaceDispute = new GoldRaceDispute(player1, player2, _c1);
        } else {
            require(msg.sender == player2);
            goldRaceDispute = new GoldRaceDispute(player2, player1, _c1);
        }
        isDisputeOpen = true;
    }
    
    function closeDispute() public {
        require(isDisputeOpen && goldRaceDispute.isDisputeEnded());
        
        require(isProposedStateAccepted == false);
        
        require(msg.sender == player1 || msg.sender == player2);
        
        // Here isPlayer1Turn indicates the player who opened the dispute.
        
        if (!goldRaceDispute.isProposedStateValid()) {
            /* The proposed state is not accepted
            In case game continued, previous player should propose another move. */
            isPlayer1Turn = !isPlayer1Turn;
        }
        
        // Here isPlayer1Turn indicates the player who lost the dispute.
        
        uint rewardForWinner = address(this).balance; // * percentage
 
        if (isPlayer1Turn) {
                player2.transfer(rewardForWinner);
        } else {
                player1.transfer(rewardForWinner);      
        }
        
        // Here rewardForRandomCommitte should be distributed.
        // uint rewardForRandomCommitte = address(this).balance * (1 - percentage);
        // goldRaceDispute.getMajorityToReward();
            
        restart();
    }
    
    function claimVictory() public {
        require(!isDisputeOpen);
        
        /* Note that a timeout may be related to the following events:
        A) Adversary left or resigns the game at some point;
        B) Adversary implicitily accepts a winning state by doing nothing. 
        Do something may result in a dispute that he or she would lose anyway. */
        require(now >= moveExpiration);
        
        require(player1 != address(0));
        require(player2 != address(0));
        if (isPlayer1Turn) {
            require(msg.sender == player2);
            player2.transfer(address(this).balance);
        } else {
            require(msg.sender == player1);
            player1.transfer(address(this).balance);      
        }

        restart();
    }
    
    function restart() internal {
        player1 = address(0);
        player2 = address(0);
        isPlayer1Turn = true;
        betAmount = 0;
        state = "";
        proposedState = "";
        isProposedStateAccepted = true;
        isDisputeOpen = false;
    }
}
