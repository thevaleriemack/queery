pragma solidity 0.4.20;

// external = visible to other contracts and cannot be called internally
// public = visisble to this contract, contracts derived from this contract, and any other contracts
// internal = visible to this contract and derived contracts
// private = visible to this contract only

contract Queery {
  address private owner;
  uint256 internal minimumBet;
  unint256 internal totalBet;
  uint256 internal numberOfBets;
  uint256 internal maxAmountOfBets = 20;
  address[] public people;
  uint256 public allyPeople;
  uint256 public nonBinaryPeople;
  uint256 public queerPeople;

  struct Person {
    string name;
    string sexualOrientation;
    string genderIdentity;
    uint256 index; // in people
    uint256 amountBet;
    uint256 numberSelected;
  }

  mapping (address => Person) public personInfo;

  function Queery(uint256 _minimumBet) public {
    owner = msg.sender;
    if (_minimumBet != 0 minimumBet = _minimumBet;
  }

  function kill() public {
    if (msg.sender == owner) selfdestruct(owner);
  }

  function reward() public payable {
    // every 12th person casts to 21 people who came before them
  }
}
