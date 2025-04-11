//SPDX-License-Identifier: UNLICENSED
pragma solidity^0.8.28;
import {AggregatorV3Interface} from "lib/foundry-chainlink-toolkit/src/interfaces/feeds/AggregatorV3Interface.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
contract FetchPairPrice {
    AggregatorV3Interface constant  BTC_USD = AggregatorV3Interface(0x0FB99723Aee6f420beAD13e6bBB79b7E6F034298);
    AggregatorV3Interface constant  CBETH_USD = AggregatorV3Interface(0x3c65e28D357a37589e1C7C86044a9f44dDC17134);
    AggregatorV3Interface constant  DAI_USD = AggregatorV3Interface(0xD1092a65338d049DB68D7Be6bD89d17a0929945e);
    AggregatorV3Interface constant  ETH_USD = AggregatorV3Interface(0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1);
    AggregatorV3Interface constant  LINK_USD = AggregatorV3Interface(0xb113F5A928BCfF189C998ab20d753a47F9dE5A61);


    function getBtcUsdPrice () external view returns (int256) {
        (,int256 answer,,,) =  BTC_USD.latestRoundData();
        return answer;
    }

    function getCbethUsdPrice () external view returns (int256) {
        (,int256 answer,,,) =  CBETH_USD.latestRoundData();
        return answer;
    }

    function getDaiUsdPrice () external view returns (int256) {
        (,int256 answer,,,) =  DAI_USD.latestRoundData();
        return answer;
    }

    function getEthUsdPrice () external view returns (int256) {
        (,int256 answer,,,) =  ETH_USD.latestRoundData();
        return answer;
    }

    function getLinkUsdPrice () external view returns (int256) {
        (,int256 answer,,,) =  LINK_USD.latestRoundData();
        return answer;
    }

    function getDecimal(AggregatorV3Interface _pair) internal view returns(uint256){
        return _pair.decimals();
    }

   

}