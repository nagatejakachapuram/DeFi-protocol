// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.4/interfaces/AggregatorV3Interface.sol";

/*
    * @title OracleLib
    * @author Kachapuram Nagateja
    * @notice This Library is used to check the chainlink oracle for the stale data
    * If a price is stale, the function will revert, and render the DSCEngine unusable- this is
    * We want the DSCEngine to freeze if price becomes stable
    * 
    * So if the chainlink network explodes then u have lot of money locked in the protocol.
    */

library OracleLib {
    error OracleLib_stalePrice();

    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed)
        public
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        (uint80 roundID, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            priceFeed.latestRoundData();

        uint256 secondsSince = block.timestamp - updatedAt;
        if (secondsSince > TIMEOUT) revert OracleLib_stalePrice();
        return (roundID, answer, startedAt, updatedAt, answeredInRound);
    }
}
