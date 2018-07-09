pragma solidity ^0.4.24;

// external = visible to other contracts and cannot be called internally
// public = visisble to this contract, contracts derived from this contract, and any other contracts
// internal = visible to this contract and derived contracts
// private = visible to this contract only

// view functions promise not to modify the state
// pure functions promise not to read from or modify the state

contract Queery {
  address private owner;
  address[] public people;
  address[5] public betters;
  uint8 public betCount;
  uint256 public betPool;
  uint256 public nonBinaryPeople;
  uint256 public queerPeople;
  uint256 public allyPeople;

  struct Person {
    string twitterID;
    string name;
    string genderIdentity;
    string sexualOrientation;
    uint256 exists;
  }

  mapping(address => Person) public personInfo;

  constructor() public {
    owner = msg.sender;
  }

  function kill() public {
    if(msg.sender == owner) selfdestruct(owner);
  }

  function sameABIPackedStrings(string a, string b) internal pure returns(bool) {
    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)); // careful with this for hash collisions
  }

  function isBetter(address personAddress) internal view returns(bool) {
    for(uint256 i = 0; i < 4; i++) {
      if(betters[i] == personAddress) return true;
    }
    return false;
  }

  function personExists(address personAddress) public view returns(bool) {
     return (personInfo[personAddress].exists > 0);
  }

  function registerPerson(
    string twitterID,
    string name,
    string genderIdentity,
    string sexualOrientation
    ) public {
      // create a new person with the input values
      personInfo[msg.sender].twitterID = twitterID;
      personInfo[msg.sender].name = name;
      personInfo[msg.sender].genderIdentity = genderIdentity;
      personInfo[msg.sender].sexualOrientation = sexualOrientation;
      personInfo[msg.sender].exists = 21;
      people.push(msg.sender);
      if(sameABIPackedStrings(genderIdentity, 'cis') == false) nonBinaryPeople++;
      if(sameABIPackedStrings(sexualOrientation, 'straight') == false) queerPeople++;
      if((sameABIPackedStrings(genderIdentity, 'cis') == true)
      && (sameABIPackedStrings(sexualOrientation, 'straight') == true)
      ) allyPeople++;
  }

  function calculateMultiplier(
    string genderIdentity,
    string sexualOrientation
    ) internal view returns(uint8) {
      uint8 multiplier = 1;
      if((sameABIPackedStrings(genderIdentity, 'cis') == false)
      && (nonBinaryPeople % 21 == 0)) multiplier++;
      if((sameABIPackedStrings(sexualOrientation, 'straight') == false)
      && (queerPeople % 21 == 0)) multiplier++;
      if((sameABIPackedStrings(genderIdentity, 'cis') == true)
      && (sameABIPackedStrings(sexualOrientation, 'straight') == true)
      && (allyPeople % 21 == 0)
      ) multiplier++;
      if(block.number % 21 == 0) multiplier++;
      return multiplier;
  }

  function payout(uint8 multiplier) private {
    // 25
    uint256 earnings = msg.value + (msg.value * multiplier);
    // 300
    uint256 maxPayout = betPool;
    uint256 winnerPayout = 0;
    uint256 leftoverPayout = 0;
    if(earnings >= maxPayout) {
      delete betPool;
      winnerPayout = maxPayout;
    } else {
      betPool -= earnings;
      leftoverPayout = betPool;
      people[people.length-1].transfer(leftoverPayout);
      winnerPayout = maxPayout - leftoverPayout;
    }
    msg.sender.transfer(winnerPayout);
  }

  function bet(
    string twitterID,
    string name,
    string genderIdentity,
    string sexualOrientation
    ) public payable {
      // must have a twitterID
      require(!sameABIPackedStrings(twitterID, ""));
      // must not be a better yet
      require(!isBetter(msg.sender));
      // must have a bet
      require(msg.value > 0);
      // register new ppl
      if(!personExists(msg.sender)) registerPerson(twitterID, name, genderIdentity, sexualOrientation);
      // add this bet to the pool of available funds to pull from
      betPool += msg.value;
      // check if we have reached max
      if(betCount >= 5) delete betCount;
      // add this person to betters list
      betters[betCount] = msg.sender;
      // increase number of bets to count this person
      betCount++;
      Person storage POI = personInfo[msg.sender];
      // if this person is the 21st better, payout
      if(betters[4] == msg.sender) payout(calculateMultiplier(POI.genderIdentity, POI.sexualOrientation));
  } // bet

  // Fallback
  function() public payable { }

} // Queery
