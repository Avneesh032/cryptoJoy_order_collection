//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./BuyOrder.sol";

contract OrderDetails is Ownable {
    BuyOrder buyOrderContract;

    constructor() Ownable(){
        
    }
// no need to keep public while deploying to mainnet
    uint256 public totalOrders;

    struct Order {
        uint256 orderId;
        uint256 price;
        address soldTo;
        uint256 timestampOrderStored;
        uint256 timestampSold;
        uint256 paymentReceivedTokenId;
    }
    // mapping(uint256=>mapping(uint256=>address)) public orderSoldByWhichToken;
    mapping(uint256 => Order) public OrderIdDetails;

    event orderStored(uint256 orderId, uint256 price, uint256 timestampOrderStored);
    event orderSold(uint256 _id,uint256 timestamp,address _soldTo, uint256 tokenId);

    modifier onlyBuyOrderContract() {
        require(msg.sender == address(buyOrderContract),"msg sender is not buy order contract");
        _;
    }

    function updateBuyOrderContractAddress(address _contractAddress) public onlyOwner{
        buyOrderContract = BuyOrder(_contractAddress);
    }

    function pushOrderDetails(uint256 _price) external onlyOwner returns (uint256) {
        uint256 orderIdToUse = totalOrders + 1;
        OrderIdDetails[orderIdToUse] = Order({
            orderId: orderIdToUse,
            price: _price,
            soldTo: address(0), 
            timestampOrderStored: block.timestamp,
            timestampSold: 0,
            paymentReceivedTokenId: 0
        });

        totalOrders++;

        emit orderStored(orderIdToUse, _price, block.timestamp);

        totalOrders += 1;

        return orderIdToUse;
    }

    function updateSoldStatus(uint256 _id, address _soldTo,uint256 _soldTimestamp,uint256 _tokenId) public onlyBuyOrderContract{
        OrderIdDetails[_id].soldTo = _soldTo;
        OrderIdDetails[_id].timestampSold = _soldTimestamp;
        OrderIdDetails[_id].paymentReceivedTokenId = _tokenId;
        emit orderSold(_id, _soldTimestamp, _soldTo, _tokenId);
    }

    function getOrderDetails(uint256 _orderId) external view returns(Order memory) {
        return OrderIdDetails[_orderId];
    }
}
