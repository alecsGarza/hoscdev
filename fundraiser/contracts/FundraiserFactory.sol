pragma solidity >=0.7.0 <0.8.11;

import "./Fundraiser.sol";

contract FundraiserFactory {
  uint256 constant maxLimit = 20;

  Fundraiser[] private xfundraisers;
  event FundraiserCreated(Fundraiser indexed fundraiser, address indexed owner);

   function fundraisersCount() public view returns(uint256) {
       return xfundraisers.length;
   }

   function createFundraiser(
        string memory name,
        string memory url,
        string memory imageURL,
        string memory description,
        address payable beneficiary
    )
        public
    {
        Fundraiser fundraiser = new Fundraiser(
            name,
            url,
            imageURL,
            description,
            beneficiary,
            msg.sender
        );
        xfundraisers.push(fundraiser);
        emit FundraiserCreated(fundraiser, msg.sender);
    }

    function fundraisers(uint256 limit, uint256 offset) public view returns(Fundraiser[] memory coll) {
        require(offset <= fundraisersCount(), "offset out of bounds");
        uint256 size = fundraisersCount() - offset; 

        size = size < limit ? size : limit;
        size = size < maxLimit ? size : maxLimit;
        coll = new Fundraiser[](size);

        for(uint256 i = 0; i < size; i++) {
          coll[i] = xfundraisers[offset+i];
        }

        return coll;
    }

}