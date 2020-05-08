pragma solidity >=0.4.21 <0.7.0;

contract GoldRaceDispute {
    
    bool public hasDisputeBeenResolved = false;
    
    // Parties of the dispute
    address public prosecution;
    address public defence;
    
    // Variable necessary to generate random committee address prefix
    bytes32 public c1;
    bytes19 public r1;
    bytes19 public r2;
    bytes19 public randomCommitteeAddressPrefix;
    uint8 prefixThreshold = 15; // This can go from 1 to 19
    event RandomCommitteeAnnouncement(uint8 byteNumber, byte value);
    event Comparison(byte v1, byte v2);
    
    constructor() public {
        //prosecution = _player1;
        //defence = _player2;
        c1 = 0xd8d1bafb5c31fa4d1b1219af9981f1e4c769a81804f77536d2f8d28e49f15b7c; // This will come from prosecution
        // Open to "0x48b0517dc17384a96f0dde4440cc4101d2d7f6", 1 
        
        // Default value for testing
        r2 = 0xc9b4b12795aff539b518febdb382f6930d336e;
    }
    
    // e.g., 0xc9b4b12795aff539b518febdb382f6930d336e
    function r2Publish(bytes19 _r2) public {
        //require(msg.sender == defence);
        r2 = _r2;
    }
    
    function reveal(bytes19 _r, uint256 _n) public {
        //require(msg.sender == prosecution);
        require(c1 == keccak256(abi.encodePacked(_r, _n)));
        r1 = _r;
        randomCommitteeAddressPrefix = bytes19(r1 ^ r2);
        announceRandomCommittee();
    }
    
    function announceRandomCommittee () internal {
        uint8 byteNumber = 0;
        for (byteNumber = 0; byteNumber < prefixThreshold; byteNumber++) {
            emit RandomCommitteeAnnouncement(byteNumber, randomCommitteeAddressPrefix[byteNumber]);
        }
    }
    
    function isMemberOfRandomCommitte(address _candidateAddress) internal returns(bool) {
        uint8 byteNumber = 0;
        bytes20 candidateAddressBytes = bytes20(_candidateAddress);
        byte candidateValue;
        byte randomCommitteValue;
        uint matchCounter = 0;
        for (byteNumber = 0; byteNumber < prefixThreshold; byteNumber++) {
            candidateValue = candidateAddressBytes[byteNumber];
            randomCommitteValue = randomCommitteeAddressPrefix[byteNumber];
            emit Comparison(candidateValue, randomCommitteValue);
            if (candidateValue == randomCommitteValue) {
                matchCounter += 1;
            }
        }
        return matchCounter == prefixThreshold;
    }
    
    function vote() public returns(bool) {
        // require(isMemberOfRandomCommitte(msg.sender));
        return true;
    } 
    
    function isProposedStateValid() public pure returns(bool) {
        // TODO
        return false;
    }

    function computeCommitment(bytes19 r, uint256 n) pure public returns(bytes32) {
        return keccak256(abi.encodePacked(r, n));
    }
}

