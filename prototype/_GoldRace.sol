pragma solidity 0.6.7;

contract GoldRace {

    address payable public player1;
    address payable public player2;
    bool public player1Turn = true;
    uint256 public betAmount = 0;
    uint256 public moveExpiration;
    
    bytes32 public state;
    
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
    
    // Example move: "0x67fad3bfa1e0321bd021ca805ce14876e50acac8ca8532eda8cbf924da565160"
    function acceptStateAndMove(bytes32 _state) public {
        require(player1 != address(0));
        require(player2 != address(0));
        require(now < moveExpiration);
        if (player1Turn) {
            require(msg.sender == player1);
        } else {
            require(msg.sender == player2);
        }
        
        state = _state;
        
        moveExpiration = now + 24 hours;
        player1Turn = !player1Turn;
    }
    
    function openDispute() public view {
        require(player1 != address(0));
        require(player2 != address(0));
        require(now < moveExpiration);
        if (player1Turn) {
            require(msg.sender == player1);
        } else {
            require(msg.sender == player2);
        }
        
        // Dispute logic
    }

    function claimTimeoutVictory() public {
        require(player1 != address(0));
        require(player2 != address(0));
        require(now >= moveExpiration);
        if (player1Turn) {
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

