pragma solidity 0.4.20;

// external = visible to other contracts and cannot be called internally
// public = visisble to this contract, contracts derived from this contract, and any other contracts
// internal = visible to this contract and derived contracts
// private = visible to this contract only

contract Queery {
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

  function Queery(uint256 _minimumBet) public {
    owner = msg.sender;
    if(_minimumBet != 0) minimumBet = _minimumBet;
  }

  function kill() public {
    if(msg.sender == owner) selfdestruct(owner);
  }

  function checkPersonExists(address person) public constant returns(bool) {
    for(uint256 i = 0; i < people.length; i++) {
      if(people[i] == person) return true;
    }
    return false;
  }

  function bet(uint256 numberSelected) public payable {
    require(!checkPersonExists(msg.sender));
    require(numberSelected >= 1 && numberSelected <= 10);
    require(msg.value >= minimumBet);

    personInfo[msg.sender].amountBet = msg.value;
    personInfo[msg.sender].numberSelected = numberSelected;
    numberOfBets++;
    people.push(msg.sender);
    totalBet += msg.value;

    if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
  }

  function generateNumberWinner() public {
    uint256 numberGenerated = block.number % 10 + 1;
    distributePrizes(numberGenerated);
  }

  function distributePrizes(uint256 numberWinner) public {
    address[maxAmountOfBets] memory winners;
    uint256 count = 0;
    for(uint256 i = 0; i < people.length; i++){
       address personAddress = people[i];
       if(personInfo[personAddress].numberSelected == numberWinner){
          winners[count] = personAddress;
          count++;
       }
       delete personInfo[personAddress]; // Delete all the players
    }
    people.length = 0; // Delete all the players array
    uint256 winnerEtherAmount = totalBet / winners.length; // How much each winner gets
    for(uint256 j = 0; j < count; j++){
       if(winners[j] != address(0)) // Check that the address in this fixed array is not empty
       winners[j].transfer(winnerEtherAmount);
    }
   }

  function proclaim(
    string name,
    string genderIdentity,
    string sexualOrientation,
    ) public payable {
      require(!checkPersonExists(msg.sender));
      require(name != "");
      require(msg.value >= minimumBet);

      // TODO: if person exists allow them to bet and win but don't add to the counts
      // dont push them to people
      // use numberOfBets
      personInfo[msg.sender].name = name;
      personInfo[msg.sender].genderIdentity = genderIdentity;
      personInfo[msg.sender].sexualOrientation = sexualOrientation;
      // personInfo[msg.sender].amountBet = msg.value;

      totalPeople++;
      people.push(msg.sender);

      uint256 private reward = 0;

      if(totalPeople % 21 == 0) {
        reward++;
        if(genderIdentity != 'cis') {
          nonBinaryPeople++;
          if(nonBinaryPeople % 21 == 0) reward++;
        }
        if(sexualOrientation != 'straight') {
          queerPeople++;
          if(queerPeople % 21 == 0) reward++;
        }
        if(genderIdentity == 'cis' && sexualOrientation == 'straight') {
          allyPeople++;
          if(allyPeople % 21 == 0) reward++;
        }
        if (block.number % 21 == 0) reward++;
        // payout
        uint256 payout = msg.value + (msg.value * reward);
        if (payout >= totalBet) {
          msg.sender.transfer(totalBet);
        } else {
          msg.sender.transfer(payout);
          distributeLeftoverPayout(payout);
        }
        totalBet = 0;
      } else {
        totalBet += msg.value;
      }
  } // proclaim

  function distributeLeftoverPayout(uint256 winnerPayout) public {
    uint256 leftoverPayout = totalBet - winnerPayout;
    if(leftoverPayout > 0) {
      uint256 receiverPayout = (totalBet - winnerPayout) / 20;
      for(uint256 i = people.length-2; i > people.length-22; i--) {
        if(people[i] != address(0)) people[i].transfer(receiverPayout);
      }
    }
  }

  // This will allow you to save the ether you send to the contract. Otherwise it would be rejected.
  function() public payable { }

}
