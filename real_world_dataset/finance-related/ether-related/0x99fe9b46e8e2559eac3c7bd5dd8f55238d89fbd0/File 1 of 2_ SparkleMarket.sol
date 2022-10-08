//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

interface IERC721M {
    function marketTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function getApproved(uint tokenId) external view returns (address approved);
}

contract SparkleMarket {

    IERC721M public nftContract;

    uint256 constant NEVER_EXPIRE = 0;
    address constant ANYBODY = address(0);
    uint64 constant THE_PAST = 1;

    struct Listing {
        uint256 price;
        address from;
        address to;
        uint64 expireTime;
    }

    mapping(uint256 => Listing) private listings;

    event CreateListing(
        uint256 indexed tokenID,
        uint256 price,
        address indexed from,
        address indexed to,
        uint64 expireTime
    );

    event CancelListing(address indexed from, uint256 indexed tokenID);

    event Sale(
        uint256 indexed tokenID,
        uint256 price,
        address indexed from,
        address indexed to
    );

    constructor(address _nftContract) {
        nftContract = IERC721M(_nftContract);
    }

    function _list(uint256 tokenId, uint256 price, address to, uint64 expireTime) internal {
        _requireOwnerOrAllowed(tokenId, msg.sender);
        require(expireTime > block.timestamp || expireTime == NEVER_EXPIRE, "Gotta let the listing have a valid expiration time!");
        listings[tokenId] = Listing({price: price, from: nftContract.ownerOf(tokenId), to: to, expireTime: expireTime });
        emit CreateListing(tokenId, price, msg.sender, to, expireTime);
    }

    function listInWei(uint256 tokenId, uint256 priceInWeiNotEth, address to, uint64 expireTime) external {
        _list(tokenId, priceInWeiNotEth, to, expireTime);
    }

    function listBatchInWei(
        uint256[] calldata tokenIdList,
        uint256[] calldata priceListInWeiNotEth,
        address[] calldata toList,
        uint64[] calldata expireTimeList) external {
        for (uint i = 0; i < tokenIdList.length; i++) {
            _list(tokenIdList[i], priceListInWeiNotEth[i], toList[i], expireTimeList[i]);
        }
    }

    function _requireOwnerOrAllowed(uint256 tokenId, address theAddress) internal view {
        address tokenOwner = nftContract.ownerOf(tokenId);
        require(tokenOwner == theAddress
            || nftContract.isApprovedForAll(tokenOwner, theAddress)
            || nftContract.getApproved(tokenId) == theAddress,
            "Address is not owner or approved");
    }

    function cancelListing(uint256[] calldata tokenIdList) external {
        for (uint i = 0; i < tokenIdList.length; i++) {
            uint256 tokenId = tokenIdList[i];
            _requireOwnerOrAllowed(tokenId, msg.sender);
            listings[tokenId].expireTime = THE_PAST;
            emit CancelListing(msg.sender, tokenId);
        }
    }

    function buy(uint256 tokenId) external payable {
        Listing memory l = listings[tokenId];
        require(l.from != address(0) &&
                (l.price != 0 ||
                l.to != address(0)),
                "Cannot buy an uninitialized listing");
        require(l.expireTime > block.timestamp
            || l.expireTime == NEVER_EXPIRE,
            "Listing must still be valid to be sold");
        require(l.price == msg.value, "must send correct money to pay purchase price");
        require(l.from == nftContract.ownerOf(tokenId), "Owner must still own for listing to be valid");
        if (l.to != ANYBODY)
          require(l.to == msg.sender, "if private sale, buyer must match target address the seller wants to sell to");

        listings[tokenId].expireTime = THE_PAST;
        address payable from = payable(nftContract.ownerOf(tokenId));
        nftContract.marketTransferFrom(from, msg.sender, tokenId);
        from.transfer(msg.value);
        emit Sale(tokenId, msg.value, from, msg.sender);
    }

    function buyBatch(uint256[] calldata tokenIdList) external payable {
        uint sum = 0;
        for(uint i = 0; i < tokenIdList.length; i++) {
            uint tokenId = tokenIdList[i];
            Listing memory l = listings[tokenId];
            require(l.expireTime != 0 ||
                    l.price != 0 ||
                    l.to != address(0),
                    "Cannot buy an uninitialized listing");
            require(l.expireTime > block.timestamp
                || l.expireTime == NEVER_EXPIRE,
                "Listing must still be valid to be sold");
            require(l.from == nftContract.ownerOf(tokenId), "Owner must still own for listing to be valid");
            if (l.to != ANYBODY)
              require(l.to == msg.sender, "if private sale, buyer must match target address the seller wants to sell to");
            sum += l.price;
        }

        require(sum == msg.value, "must send correct money to pay purchase price");

        for(uint i = 0; i < tokenIdList.length; i++) {
            uint tokenId = tokenIdList[i];
            listings[tokenId].expireTime = THE_PAST;
            address payable from = payable(nftContract.ownerOf(tokenId));
            nftContract.marketTransferFrom(from, msg.sender, tokenId);
            from.transfer(listings[tokenId].price);
        }

    }

    function getListing(uint256 tokenId) external view returns (Listing memory) {
        return listings[tokenId];
    }

    function isForSale(uint256 tokenId) external view returns (bool) {
        if ( listings[tokenId].from != nftContract.ownerOf(tokenId) )
            return false;
        if ( listings[tokenId].expireTime > block.timestamp)
            return true;
        bool listingInitialized = (listings[tokenId].price != 0 || listings[tokenId].to != ANYBODY);
        if (listings[tokenId].expireTime == NEVER_EXPIRE && listingInitialized)
            return true;
        return false;
    }

}
