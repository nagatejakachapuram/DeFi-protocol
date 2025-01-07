// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
    mapping(address token => address priceFeed) private s_priceFeeds; // tokenToPricefeed
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

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

    function mintDSC() external {}

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
