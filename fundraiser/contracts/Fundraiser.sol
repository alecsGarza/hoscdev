pragma solidity >=0.7.0 <0.8.11;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol"; 

contract Fundraiser is Ownable{
  using SafeMath for uint256;

  struct Donation {
    uint256 value;
    uint256 date;
  }
  mapping(address => Donation[]) private donations;
  
  event DonationReceived(address indexed donor, uint256 value);
  event Withdraw(uint256 amount);

  string public name;
  string public url;
  string public imageURL;
  string public description;
  
  address payable public beneficiary;
  address public custodian;

  uint256 public totalDonations;
  uint256 public donationsCount;

  constructor(
    string memory xname,
    string memory xurl,
    string memory ximageURL,
    string memory xdescription,
    address payable xbeneficiary,
    address xcustodian
  )
    public
  {
    name = xname;
    url = xurl;
    imageURL = ximageURL;
    description = xdescription;
    beneficiary = xbeneficiary;
    transferOwnership(xcustodian);
    totalDonations = 0; 
  }

  function setBeneficiary(address payable xbeneficiary) public onlyOwner {
    beneficiary = payable(xbeneficiary);
  }

  function myDonationsCount() public view returns(uint256) {
    return donations[msg.sender].length;
  }

  function donate() public payable {
    Donation memory donation = Donation({
        value: msg.value,
        date: block.timestamp
    });
    donations[msg.sender].push(donation);

    totalDonations = totalDonations + msg.value;
    donationsCount++;
    emit DonationReceived(msg.sender, msg.value);
  }

  function myDonations() public view returns(
    uint256[] memory values,
    uint256[] memory dates
  )
  {
    uint256 count = myDonationsCount();
    values = new uint256[](count);
    dates = new uint256[](count);

    for (uint256 i = 0; i < count; i++) {
        Donation storage donation = donations[msg.sender][i];
        values[i] = donation.value;
        dates[i] = donation.date;
    }

    return (values, dates);
  }

  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    beneficiary.transfer(balance);
    emit Withdraw(balance);
  }

  fallback() external payable {
    totalDonations = totalDonations.add(msg.value);
    donationsCount++;
  }

}