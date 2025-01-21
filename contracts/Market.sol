// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Market is ReentrancyGuard {
    address payable public immutable feeAccount;
    uint256 public immutable feePercentage;
    uint256 public itemCount;

    constructor(address _feeAccount, uint256 _feePercentage) {
        feeAccount = payable(_feeAccount);
        feePercentage = _feePercentage;
        itemCount = 0;
    }

    struct Item {
        uint256 itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable owner;
        bool sold;
    }
    mapping(uint256 => Item) public items;

    event Offered(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address owner
    );

    event Bought(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address owner,
        address buyer
    );

    function getTokenCount() external view returns (uint256) {
        return itemCount;
    }

    function listItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "Can't list an nft for free");
        itemCount++;
        _nft.transferFrom(msg.sender, address(this), _tokenId);

        //track item
        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );

        emit Offered(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            address(msg.sender)
        );
    }

    function payOwner(uint256 _itemId) internal {
        uint256 actualPrice = getPrice(_itemId);
        uint256 listedPrice = items[_itemId].price;
        address payable owner = items[_itemId].owner;
        owner.transfer(listedPrice);
        uint256 contractValue = actualPrice - listedPrice;
        feeAccount.transfer(contractValue);
    }

    function getPrice(uint256 _itemId) public view returns (uint256) {
        uint256 listedPrice = items[_itemId].price;
        uint256 actualPrice = listedPrice +
            ((listedPrice * feePercentage) / 100);
        return actualPrice;
    }

    function buyNft(uint256 _itemId) external payable nonReentrant {
        uint256 actualPrice = getPrice(_itemId);
        require(msg.value >= actualPrice, "Did not send enough funds to buy");

        Item storage item = items[_itemId];
        require(!item.sold, "Item already sold");

        item.nft.transferFrom(address(this), address(msg.sender), _itemId);
        item.sold = true;

        payOwner(_itemId);

        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.owner,
            address(msg.sender)
        );
    }
}
