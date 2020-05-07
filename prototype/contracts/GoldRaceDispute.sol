pragma solidity >=0.4.21 <0.7.0;

import "./PRNGKECCAK256.sol";

contract GoldRaceDispute {
    
    bool public hasDisputeBeenResolved = false;
    
    // Parties of the dispute
    address public prosecution;
    address public defence;
    
    // Variable necessary to generate random seed
    bytes32 public c1;
    bytes32 public r1;
    bytes32 public r2;
    uint256 public seed;
    
    PRNGKECCAK256 prng;
    
    constructor() public {
        //prosecution = _player1;
        //defence = _player2;
        c1 = 0x5026c1c20b7eb1bb979586796fcba65745acad62cd702cb7cfc19934f3982f38; // This will come from prosecution
        // Open to "0x48b0517dc17384a96f0dde4440cc4101d2d7f669f62c2a4395c27d7a2e791474", 1 
        
        // Default value for testing
        r2 = 0x1029517dc17384a96f0dde4440cc4101d2d7f669f62c2a4395c27d7a2e795689;
    }
    
    // e.g., 0x1029517dc17384a96f0dde4440cc4101d2d7f669f62c2a4395c27d7a2e795689
    function r2Publish(bytes32 _r2) public {
        //require(msg.sender == defence);
        r2 = _r2;
    }
    
    function reveal(bytes32 _r, uint256 _n) public returns(bool){
        //require(msg.sender == prosecution);
        require(c1 == keccak256(abi.encodePacked(_r, _n)));
        r1 = _r;
        seed = uint(r1 ^ r2);
        prng = new PRNGKECCAK256(seed);
        return true;
    }
    
    function isProposedStateValid() public pure returns(bool) {
        // TODO
        return false;
    }


    // Helper functions
    function test() public returns(uint256[2] memory) {
            return [prng.getPRN(19), prng.getPRN(19)];
    }
    
    //function computeCommitment(bytes32 r, uint256 n) pure public returns(bytes32) {
    //    return keccak256(abi.encodePacked(r, n));
    //}
}


