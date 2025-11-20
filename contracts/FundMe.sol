// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// import "@chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"

// Evitar problemas de overflows en versiones de solidy 6 o menor.
// import "@chainlink/contracts/src/v0.8/vendor/SafeMathChainlink.sol";

contract FundMe {
    // Evitar problemas de overflows en versiones de solidy 6 o menor.
    // using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;

    address[] public funders;

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable {
        // Minimo $50
        uint256 minimumUsd = 50 * 10 ** 18;
        require(
            getConversionRate(msg.value) >= minimumUsd,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 10000000000);
    }

    function getConversionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 100000000000000;
        return ethAmountInUsd;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public payable onlyOwner {
        // only owner
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 funderIdx; funderIdx < funders.length; funderIdx++) {
            address funder = funders[funderIdx];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
    }
}
