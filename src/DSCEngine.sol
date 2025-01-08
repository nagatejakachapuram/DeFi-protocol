// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title DSCEngine
 * @author Nagateja
 *
 * The system is designed to be a minimal, and have the tokens maintain 1 token == 1 $ peg
 * This stable coin has properties:
 *  - Exogenous
 *  - Dollar pegged
 *  - Algorithmic
 *
 *  It is similar to DAI if DAI has no governance, no fees and was only backed by WETH AND WBTC.
 *
 *  Our DSC system should be always "Overcollateralzed". At no point, should the value of all collateral <= the $ backed value of the DSC.
 *
 *  @notice This contract is the core of the DSC system, it handles all the logic for minig and redeeming DSC, as well as depositing & withdrawing collateral.
 *  @notice This contract is VERY losely based on the MAKERDAO DSS (DAI) system.
 */
contract DSCEngine is ReentrancyGuard {
    ////////////////////////////
    //     Errors             //
    ///////////////////////////
    error DSCEngine_NeedMoreThanZero();
    error DSCEngine_tokenAddressAndPriceFeedMustBeSameLength();
    error DSCEngine_tokenNotAllowed();
    error DSCEngine_transferFailed();

    ////////////////////////////
    //     State Variables    //
    ///////////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    mapping(address token => address priceFeed) private s_priceFeeds; // tokenToPricefeed
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;
    address[] private s_collateralTokens;

    address weth;
    address wbtc;

    DecentralizedStableCoin private immutable i_dsc;

    ////////////////////////////
    //     Events             //
    ///////////////////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    /////////////////////////////
    //     Modifiers         ///
    ///////////////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine_NeedMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine_tokenNotAllowed();
        }
        _;
    }

    ////////////////////////////
    //      Functions         //
    ////////////////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        // USD price Feeds
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine_tokenAddressAndPriceFeedMustBeSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    function depositCollateralAndMintDSC() external {}

    /**
     *
     * @param tokenCollateralAddress The address of the token need to be deposited as collateral.
     * @param amountCollateral The amount of collateral.
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine_transferFailed();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function mintDSC(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMinted[msg.sender] += amountDscToMint;
        // If they minted too much ($150 DSC, $100 ETH)
        revertfHealthFatorIsBroken(msg.sender);
    }

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}


    //////////////////////////////////////
    //    Private & Internal Functions  //
    /////////////////////////////////////

    function _getAccountInformation(address user) private view returns(uint256 totalDscMinted, uint256 collateralValueInUsd){
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /**
     * 
     * Returns how close to liquidation a user is
     * If a user goes below 1, then they get liquidated.
     */

    function _healthFactor(address user) private view returns(uint256) {
        // Total collateral value > total DSC minted
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);

    }

    function _revertfHealthFatorIsBroken(address user) internal view {
        // 1. Check health factor (do they have enough collateral)
        // 2. Revert if they don't


    }


    //////////////////////////////////////
    //    Public & Internal Functions  //
    /////////////////////////////////////

    function getAccountCollateralValue(address user) public view returns(uint256 totalCollateralValueInUsd){
        // loop through each collateral token, get the amount they deposited, and map it to
        // price, to get the USD value.
        for (uint256 i = 0; i < s_collateralTokens.length; i++){
            address token = s_collateralTokens[i];
            uint256  amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // 1 ETH = $1000
        // The retunred value from CL will be 1000  1e18
        return (uint256(price) * ADDITIONAL_FEED_PRECISION * amount) / PRECISION; // (1000 * 1e8 * (1e10)) * 1000 * 1e18


    }
}
