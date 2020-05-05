pragma solidity 0.6.7;

contract GoldRace {

    address payable public player1 = address(0);
    address payable public player2 = address(0);
    bool public isPlayer1Turn = true;
    uint256 public betAmount = 0;
    uint256 public moveExpiration;
    
    bytes public state;
    bytes public proposedState;
    
    function createChallenge() public payable {
        require(player1 == address(0));
        require(player2 == address(0));
        require(msg.value > 0);
        
        player1 = msg.sender;
        betAmount = msg.value;
    }
    
    function cancelChallenge() public {
        require(player1 != address(0));
        require(player2 == address(0));
        require(msg.sender == player1);

        msg.sender.transfer(address(this).balance);
        
        player1 = address(0);
        betAmount = 0;
    }
    
    function acceptChallenge() public payable {
        require(player1 != address(0));
        require(player2 == address(0));
        require(msg.sender != player1);
        require(msg.value == betAmount);

        player2 = msg.sender;

        moveExpiration = now + 24 hours;
    }
    
    // Example move: "0x67fa"
    function acceptStateAndMove(bytes memory _proposedState) public {
        require(player1 != address(0));
        require(player2 != address(0));
        require(now < moveExpiration);
        if (isPlayer1Turn) {
            require(msg.sender == player1);
        } else {
            require(msg.sender == player2);
        }
        
        state = proposedState;
        proposedState = _proposedState;
        
        moveExpiration = now + 24 hours;
        isPlayer1Turn = !isPlayer1Turn;
    }
    
    function openDispute() public view {
        require(player1 != address(0));
        require(player2 != address(0));
        require(now < moveExpiration);
        if (isPlayer1Turn) {
            require(msg.sender == player1);
        } else {
            require(msg.sender == player2);
        }
        
        // Dispute logic (if proposedState is valid, it becomes state)
    }

    function claimTimeoutVictory() public {
        require(player1 != address(0));
        require(player2 != address(0));
        require(now >= moveExpiration);
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


