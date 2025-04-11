//SPDX-License-Identifier: UNLICENSED
pragma solidity^0.8.28;
import "./OrderDetails.sol";
import "./FetchPairPrice.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract BuyOrder is Ownable{

    // id 1 = DAI
    // id 2 = LINK
    // id 3 = BTC
    // id 4 = CBETH
    // id 5 = ETH (NATIVE)
    IERC20 public DAI = IERC20(0x7D90bB8638EED8D8D7624643927FbC9984750360);
    IERC20 public LINK =IERC20(0xa8C6dA47368DB76b8C272FF3a738F4e22B8C4917);
    IERC20 public BTC = IERC20(0x0a1f1390d85EA63851d7d458580EDa1D1Cc8545b);
    IERC20 public CBETH = IERC20(0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22);

    //Order Details will be in this contract 
    OrderDetails immutable orderDetailsContract;
    //pair prices will be fetched from this contract
    FetchPairPrice immutable priceCalculationContract;

    constructor (address _orderContract,address _priceCalculationContract) Ownable(){
        orderDetailsContract = OrderDetails(_orderContract);
        priceCalculationContract = FetchPairPrice(_priceCalculationContract);
    }
    struct Order {
        uint256 orderId;
        uint256 price;
        address soldTo;
        uint256 timestampOrderStored;
        uint256 timestampSold;
    }

    function getOrderDetails(uint256 _orderId) public view returns(OrderDetails.Order memory){
       return orderDetailsContract.getOrderDetails(_orderId);
    }

    function getTokenAddressFromId(uint256 _id) internal view returns (IERC20,uint256) {
        require(_id >0 && _id <=5,"id should be between 1-5");
        IERC20 token ;
        uint256 pairPrice;
        if(_id == 1) {
            token = DAI;
            pairPrice = uint256(priceCalculationContract.getDaiUsdPrice());
        }else if (_id ==  2){
            token = LINK;
            pairPrice = uint256(priceCalculationContract.getLinkUsdPrice());
        }else if(_id == 3) {
            token = BTC;
            pairPrice = uint256(priceCalculationContract.getBtcUsdPrice());
        }else if(_id == 4) {
            token = CBETH;
            pairPrice = uint256(priceCalculationContract.getCbethUsdPrice());
        }else {
            token = IERC20(address(0xa));
            pairPrice = uint256(priceCalculationContract.getEthUsdPrice());
        }
        return (token,pairPrice);
    }

    function addAllowance(uint256 _amt,uint256 _tokenId) internal {
        IERC20 token;
        (token,) = getTokenAddressFromId(_tokenId);
        IERC20(token).approve(address(this), _amt);
    }

    function transferToken(uint256 _tokenId, uint256 _amt) internal {
        IERC20 token;
        (token,) = getTokenAddressFromId(_tokenId);
        token.transfer(owner(),_amt);
    }

    function buyOrder(uint256 _id,uint256 _tokenId) external {
        OrderDetails.Order memory fetchedOrder = getOrderDetails(_id);
        uint256 priceInUsd = fetchedOrder.price;
        uint256 pairPrice ;
        (,pairPrice) = getTokenAddressFromId(_id); 
        uint256 priceInToken = calculatePriceInToken(priceInUsd,pairPrice);
        orderDetailsContract.updateSoldStatus(_id,msg.sender,block.timestamp,_tokenId);
        if(_tokenId == 5){
            payable(owner()).transfer(priceInToken);
        }else{
        addAllowance(priceInToken, _tokenId);
        transferToken(_tokenId, priceInToken);
        }
    }

     function calculatePriceInToken(uint256 _priceInUsd, uint256 _pairPrice) private pure returns(uint256) {
      uint256 decimal_conversion = 1e18 ;
        return (_priceInUsd * decimal_conversion) / _pairPrice ;  
    } 

}