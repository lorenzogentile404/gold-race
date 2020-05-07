pragma solidity >=0.4.21 <0.7.0;

//https://www.stat.berkeley.edu/~stark/Java/Html/sha256Rand.htm
//https://people.csail.mit.edu/rivest/sampler.py

contract PRNGKECCAK256 {

    uint256 seed;
    uint256 currentSampleNumber = 1; 
    
    event PRNEvent(bytes32 h, uint256 n);
    
    constructor (uint256 _seed) public {
        seed = _seed;
    }
    
    function getPRN(uint256 _maxValue) public returns(uint256) {
        bytes32 h = keccak256(abi.encodePacked(seed, currentSampleNumber));
        currentSampleNumber += 1;
        uint256 n = uint(h) % _maxValue + 1;
        emit PRNEvent(h, n);
        return n;
    }
}

