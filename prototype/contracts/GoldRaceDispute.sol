pragma solidity >=0.4.21 <0.7.0;

contract GoldRaceDispute {
    
    bool public hasDisputeBeenResolved = false;
    
    // Parties of the dispute
    address public prosecution;
    address public defence;
    
    // Variable necessary to generate random committee address prefix
    bytes32 public c1;
    bytes32 public r1;
    bytes32 public r2;
    bytes20 public randomCommitteeAddressPrefix;
    uint8 prefixThreshold = 15;
    event RandomCommitteeAnnouncement(uint8 byteNumber, byte value);
    event Comparison(byte v1, byte v2);
    
    constructor() public {
        //prosecution = _player1;
        //defence = _player2;
        c1 = 0x5026c1c20b7eb1bb979586796fcba65745acad62cd702cb7cfc19934f3982f38; // This will come from prosecution
        // Open to "0x48b0517dc17384a96f0dde4440cc4101d2d7f669f62c2a4395c27d7a2e791474", 1 
        
        // Default value for testing
        r2 = 0xc9b4b12795aff539b518febdb382f6930d336eff7dff036a8bbb585ef06b6a2f;
    }
    
    // e.g., 0xc9b4b12795aff539b518febdb382f6930d336eff7dff036a8bbb585ef06b6a2f
    function r2Publish(bytes32 _r2) public {
        //require(msg.sender == defence);
        r2 = _r2;
    }
    
    function reveal(bytes32 _r, uint256 _n) public {
        //require(msg.sender == prosecution);
        require(c1 == keccak256(abi.encodePacked(_r, _n)));
        r1 = _r;
        randomCommitteeAddressPrefix = bytes20(r1 ^ r2);
        announceRandomCommittee();
    }
    
    function announceRandomCommittee () internal {
        uint8 byteNumber = 0;
        for (byteNumber = 0; byteNumber < prefixThreshold; byteNumber++) {
            emit RandomCommitteeAnnouncement(byteNumber, randomCommitteeAddressPrefix[byteNumber]);
        }
    }
    
    function isMemberOfRandomCommitte() public returns(bool) { //address _candidateAddress) internal returns(bool) {
        address _candidateAddress = msg.sender;
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
    
    function vote() public {
        //require(isMemberOfRandomCommitte(msg.sender));
    } 
    
    function isProposedStateValid() public pure returns(bool) {
        // TODO
        return false;
    }

    //function computeCommitment(bytes32 r, uint256 n) pure public returns(bytes32) {
    //    return keccak256(abi.encodePacked(r, n));
    //}
}
