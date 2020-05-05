pragma solidity 0.6.7;

import "./_GoldRaceDispute.sol";

contract GoldRace {

    address payable public player1 = address(0);
    address payable public player2 = address(0);
    bool public isPlayer1Turn = true;
    uint256 public betAmount = 0;
    uint256 public moveExpiration;
    
    bytes public state;
    bytes public proposedState;
    bool public isProposedStateAccepted = true;
    
    bool public isDisputeOpen = false;
    GoldRaceDispute goldRaceDispute;
    
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

        moveExpiration = now + 24 hours;
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
        
        moveExpiration = now + 24 hours;
        isPlayer1Turn = !isPlayer1Turn;
        isProposedStateAccepted = false;
    }
    
    function openDispute() public {
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
        
        isDisputeOpen = true;
        goldRaceDispute = new GoldRaceDispute();
    }
    
    function closeDispute() public {
        require(isDisputeOpen);
        
        require(isProposedStateAccepted == false);
        
        require(msg.sender == player1 || msg.sender == player2);
        
        if (goldRaceDispute.isProposedStateValid()) {
            // Current player is forced to accept the proposed state
            state = proposedState;
        } else {
            // Previous player is forced to propose another proposed state
            isPlayer1Turn = !isPlayer1Turn;
        }

        // A valid state is defined and the dispute is closed
        isProposedStateAccepted = true;
        isDisputeOpen = false;
    }
    
    function claimTimeoutVictory() public {
        require(!isDisputeOpen);
        
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

        player1 = address(0);
        player2 = address(0);
        betAmount = 0;
    }
}



