pragma solidity 0.4.24;

// external = visible to other contracts and cannot be called internally
// public = visisble to this contract, contracts derived from this contract, and any other contracts
// internal = visible to this contract and derived contracts
// private = visible to this contract only

// view functions promise not to modify the state
// pure functions promise not to read from or modify the state

contract Example {
  address private owner;
  uint256 internal minimumBet;
  uint256 internal totalBet;
  uint256 internal numberOfBets;
  uint256 internal maxAmountOfBets = 20;
  address[] public people;
  uint256 public totalPeople;
  uint256 public nonBinaryPeople;
  uint256 public queerPeople;
  uint256 public allyPeople;

  struct Person {
    string name;
    string genderIdentity;
    string sexualOrientation;
    uint256 amountBet;
    uint256 numberSelected;
  }

  mapping(address => Person) public personInfo;

  constructor(uint256 _minimumBet) public {
    owner = msg.sender;
    if(_minimumBet != 0) minimumBet = _minimumBet;
  }

  function kill() public {
    if(msg.sender == owner) selfdestruct(owner);
  }

  function personExists(address person) public view returns(bool) {
    // a person exists if their amountBet is greater than 0
    return (personInfo[person].amountBet > 0);
  }

  function sameABIPackedStrings(string a, string b) public pure returns(bool) {
    // careful with this for hash collisions
    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }

  // EXAMPLE
  function bet(uint256 numberSelected) public payable {
    require(!personExists(msg.sender));
    require(numberSelected >= 1 && numberSelected <= 10);
    require(msg.value >= minimumBet);

    personInfo[msg.sender].amountBet = msg.value;
    personInfo[msg.sender].numberSelected = numberSelected;
    numberOfBets++;
    people.push(msg.sender);
    totalBet += msg.value;

    if(numberOfBets == maxAmountOfBets) generateNumberWinner();
  }
  function generateNumberWinner() public {
    uint256 numberGenerated = block.number % 10 + 1;
    distributePrizes(numberGenerated);
  }
  function distributePrizes(uint256 numberWinner) private {
    address[20] memory winners;
    uint256 count = 0;
    for(uint256 i = 0; i < people.length; i++){
      address personAddress = people[i];
      if(personInfo[personAddress].numberSelected == numberWinner){
        winners[count] = personAddress;
        count++;
      }
      delete personInfo[personAddress];
    }
    people.length = 0;
    uint256 winnerEtherAmount = totalBet / winners.length;
    for(uint256 j = 0; j < count; j++){
      if(winners[j] != address(0))
      winners[j].transfer(winnerEtherAmount);
    }
  }
  // END EXAMPLE

  // Fallback
  function() public payable { }

}
