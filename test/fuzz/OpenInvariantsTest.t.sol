// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test,console} from "lib/forge-std/src/Test.sol";
import {StdInvariant} from "lib/forge-std/src/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";


contract OpenInvarianttest is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin public dsc;
    HelperConfig config;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc,dsce,config) = deployer.run();
        (,,(weth),(wbtc),) = config.activeNetworkConfig();
        targetContract(address(dsce));
    }

    function invariant_protocolMustHaveMoreValueThatTotalSupplyDollars() public view {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
        uint256 totalBtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(weth,totalWethDeposited);
        uint256 wbtcValue = dsce.getUsdValue(wbtc,totalBtcDeposited);

        assert(wethValue+wbtcValue >= totalSupply);
    }
}