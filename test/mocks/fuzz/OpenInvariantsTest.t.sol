// SPDX-License-Identifier: MIT

// Have our invariants aka our properties that should always hold

// what are our Invariants?

// 1. Total supply of dsc should be always less than collateral
// 2. Getter view functions never revert <- evergreen invaraint

pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract InvariantsTest is Test, StdInvariant {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralisedStableCoin dsc;
    HelperConfig config;

    function setUp() external {
        deployer = new DeployDSC();
        (dsce.dsce, config) = deployer.run();
        targetContract(address(dsce));
    }
}
