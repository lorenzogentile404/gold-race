pragma solidity >=0.4.21 <0.7.0;

contract GoldRaceDispute {

    // Parties of the dispute
    address public prosecution;
    address public defence;

    // Status of the dispute
    enum Status {R2PUBLISH, REVEAL, COMMITVOTE, REVEALVOTE, VALID, NOTVALID}
    Status public status = Status.R2PUBLISH;

    // Timeout of the dispute
    uint256 public disputeExpiration;
    uint256 public timePerDispute = 30 minutes;

    // Variables necessary to generate random committee address prefix
    bytes32 public c1;
    bytes19 public r1;
    bytes19 public r2;
    bytes19 public randomCommitteeAddressPrefix;
    event RandomCommitteeAnnouncement(uint8 byteNumber, byte value);
    event Comparison(byte v1, byte v2);

    // Variables representing the votes
    struct VoteCommitment {
        bytes32 c;
        bool exists;
        bool revealed;
    }
    mapping(address => VoteCommitment) votesCommitments;
    mapping(address => bool) votes;
    address payable[] public approvingMembers;
    address payable[] public contraryMembers;
    uint256 public votesCommitmentsCounter = 0;

    // Define size of the random committee
    uint8 public prefixThreshold;

    // Number of required members of the random committee voting
    // It represents the maximum possible size of majority to reward
    uint256 public votesThreshold;

    constructor(address _prosecution, address _defence, bytes32 _c1, uint8 _prefixThreshold, uint256 _votesThreshold) public {
        prosecution = _prosecution;
        defence = _defence;
        c1 = _c1; // This comes from prosecution
        prefixThreshold = _prefixThreshold;
        votesThreshold = _votesThreshold;
        // e.g. "0xd8d1bafb5c31fa4d1b1219af9981f1e4c769a81804f77536d2f8d28e49f15b7c"
        // Open to "0x48b0517dc17384a96f0dde4440cc4101d2d7f6", 1
        disputeExpiration = now + timePerDispute;
    }

    // e.g., "0xc9b4b12795aff539b518febdb382f6930d336e"
    function r2Publish(bytes19 _r2) public {
        require(msg.sender == defence);
        require(status == Status.R2PUBLISH);
        require(now < disputeExpiration);

        r2 = _r2;
        status = Status.REVEAL;
    }

    function reveal(bytes19 _r, uint256 _n) public {
        require(msg.sender == prosecution);
        require(status == Status.REVEAL);
        require(c1 == keccak256(abi.encodePacked(_r, _n)));
        require(now < disputeExpiration);

        r1 = _r;
        randomCommitteeAddressPrefix = bytes19(r1 ^ r2);
        announceRandomCommittee();
        status = Status.COMMITVOTE;
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

    function commitVote(bytes32 _c) public {
        // require(isMemberOfRandomCommitte(msg.sender)); This check is turned off for testing purposes
        require(msg.sender != prosecution && msg.sender != defence);
        require(status == Status.COMMITVOTE);
        require(!votesCommitments[msg.sender].exists); // This prevents commiting a vote more than once
        require(now < disputeExpiration);

        votesCommitments[msg.sender] = VoteCommitment(_c, true, false);
        votesCommitmentsCounter += 1;
        if (votesCommitmentsCounter == votesThreshold) {
            status = Status.REVEALVOTE;
        }
    }

    function revealVote(bool _r, uint256 _n) public {
        require(status == Status.REVEALVOTE);
        require(votesCommitments[msg.sender].exists);
        require(votesCommitments[msg.sender].c == keccak256(abi.encodePacked(_r, _n)));
        require(!votesCommitments[msg.sender].revealed); // This prevents counting a vote more than once
        require(now < disputeExpiration);

        votesCommitments[msg.sender].revealed = true;

        if (_r) {
            approvingMembers.push(msg.sender);
        } else {
            contraryMembers.push(msg.sender);
        }

        uint256 validCounter = approvingMembers.length;
        uint256 notValidCounter = contraryMembers.length;

        if (validCounter + notValidCounter == votesThreshold) {
            if (validCounter > notValidCounter) {
                status = Status.VALID;
            } else if (validCounter <= notValidCounter) {
                // In case of a tie it is assumed the proposed state is not valid
                status = Status.NOTVALID;
            }
        }
    }

    function isDisputeEnded() public view returns(bool) {
        return status == Status.VALID || status == Status.NOTVALID;
    }

    function isProposedStateValid() public view returns(bool) {
        return status == Status.VALID;
    }

    function claimDisputeVictory() public {
        require(now >= disputeExpiration);

        if (status == Status.R2PUBLISH) {
            // Defence loses by timeout
            require(msg.sender == prosecution);
            status = Status.NOTVALID;
        } else if (status == Status.REVEAL) {
            // Prosecution loses by timeout
            require(msg.sender == defence);
            status = Status.VALID;
        }
    }

    function getMajorityToReward() public view returns(address payable[] memory) {
        if (status == Status.VALID) {
            return approvingMembers;
        } else if (status == Status.NOTVALID) {
            return contraryMembers;
        }
    }

    /*
    // Helper functions
    function computeCommitment(bytes19 _r, uint256 _n) pure public returns(bytes32) {
        return keccak256(abi.encodePacked(_r, _n));
    }

    // true, 123 -> "0x48b0517dc17384a96f0dde4440cc4101d2d7f669f62c2a4395c27d7a2e791474"
    // false, 123 -> "0x0c995408c4b5a2753bd04b90076c88cae982eb7fd8c8929c22b3deff08db3eed"
    function computeBitCommitment(bool _r, uint256 _n) pure public returns(bytes32) {
        return keccak256(abi.encodePacked(_r, _n));
    }
    */
}
