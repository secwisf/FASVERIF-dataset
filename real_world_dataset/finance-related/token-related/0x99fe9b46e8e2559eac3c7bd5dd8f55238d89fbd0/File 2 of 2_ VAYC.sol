// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// This file is forked from Solmate v6,
/// We stand on the shoulders of giants
/// Unnecessary functions have been deleted, mint, safeMint and burn
/// Added our own mint functions, tweaked ownerOf to support our weirdness

import "./SparkleMarket.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function setOwnerOf(uint256 id, address newOwner) external view returns (address owner);
}

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)
/// @dev Note that balanceOf does not revert if passed the zero address, in defiance of the ERC.
contract VAYC {
    /*///////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*///////////////////////////////////////////////////////////////
                          METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string private constant NOT_LIVE = "Sale not live";
    string private constant INCORRECT_PRICE = "Gotta pay right money";
    string private constant MINTED_OUT = "Max supply reached";
    string public name;

    string public symbol;

    address private admin;
    uint16 public totalSupply;
    uint16 public counter = 0;
    uint16 public constant  MAX_SUPPLY =  10000; // only first 10000 were minted

    IERC721 private MAYC = IERC721(0x60E4d786628Fea6478F785A6d7e704777c86a7c6);
    IERC721 private BAYC = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
    IERC721 private BAKC = IERC721(0xba30E5F9Bb24caa003E9f2f0497Ad287FDF95623);
    //function setMAYC(address _mayc) public {MAYC = IERC721(_mayc);} //helper for unit testing
    //IERC721 private MAYC = IERC721(0x6A8e25D0168B98e240d28a803e71ada93973F856);
    //IERC721 private BAYC = IERC721(0x6A8e25D0168B98e240d28a803e71ada93973F856);
    //IERC721 private BAKC = IERC721(address(0xdead));

    SparkleMarket public market;
    uint256 public constant COST_MAYC =   0.042069 ether;
    uint256 public constant COST_PUBLIC = 0.069420 ether;
    uint8 constant MAX_MINT = 10;

   enum SaleStatus {
       Paused,
       Presale,
       Whitelist,
       Public
    }
    SaleStatus public saleMode;


    /*///////////////////////////////////////////////////////////////
                            ERC721 STORAGE                        
    //////////////////////////////////////////////////////////////*/

    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) private preOf;

    mapping(uint256 => address) private publicOf;

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*///////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function ownerOf(uint256 id) public view returns (address) {
        if (preOf[id] != address(0))
            return preOf[id];
        else
            return publicOf[id];
    }

    function approve(address spender, uint256 id) external {
        address owner = ownerOf(id);

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public {
        require(from == ownerOf(id), "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || msg.sender == getApproved[id] || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            balanceOf[from]--;

            balanceOf[to]++;
        }

        if (preOf[id] != address(0))
            preOf[id] = to;
        else
            publicOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*///////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f;   // ERC165 Interface ID for ERC721Metadata
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "must be admin");
        _;
    }

    /*///////////////////////////////////////////////////////////////
                       VAYC SPECIFIC LOGIC
    //////////////////////////////////////////////////////////////*/
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        admin = msg.sender;
        market = new SparkleMarket(address(this));
    }

    function saleToPause() external onlyAdmin {
        saleMode = SaleStatus.Paused;
    }

    function saleToPre() external onlyAdmin {
        saleMode = SaleStatus.Presale;
    }

    function saleToWhitelist() external onlyAdmin {
        saleMode = SaleStatus.Whitelist;
    }

    function saleToPublic() external onlyAdmin {
        saleMode = SaleStatus.Public;
    }

    function withdraw() external onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }

    function mintPre(uint[] calldata tokenIds) external payable {
        require(saleMode == SaleStatus.Presale, NOT_LIVE);
        require(msg.value == COST_MAYC*tokenIds.length, INCORRECT_PRICE);
        require(totalSupply + tokenIds.length < MAX_SUPPLY, MINTED_OUT);
        for (uint i = 0; i < tokenIds.length; i++) {
            require(msg.sender == MAYC.ownerOf(tokenIds[i]), "Missing required token");
            require(tokenIds[i] < MAX_SUPPLY, "TokenId too high");
        }
        for (uint i = 0; i < tokenIds.length; i++) {
            require(ownerOf(tokenIds[i]) == address(0), "ALREADY_MINTED");

            // Counter overflow is incredibly unrealistic.
            unchecked {
                balanceOf[msg.sender]++;
            }

            preOf[tokenIds[i]] = msg.sender;
            emit Transfer(address(0), msg.sender, tokenIds[i]);
        }
        unchecked{
            totalSupply = totalSupply + (uint16(tokenIds.length));
        }
    }

    function mintWL(uint16 num, uint tokenId) external payable {
        require(saleMode == SaleStatus.Whitelist, NOT_LIVE);
        bool baycFan =
            (msg.sender == MAYC.ownerOf(tokenId)) ||
            (msg.sender == BAYC.ownerOf(tokenId)) ||
            (msg.sender == BAKC.ownerOf(tokenId));
        require(baycFan, "Not whitelisted");
        require(msg.value == COST_MAYC * num, INCORRECT_PRICE);
        _mintY(num);
    }

    function mintPublic(uint16 num) external payable {
        require(saleMode == SaleStatus.Public, NOT_LIVE);
        require(msg.value == COST_PUBLIC * num, INCORRECT_PRICE);
        _mintY(num);
    }

    function _mintY(uint16 num) internal {
        require(num <= MAX_MINT, "Max 10 per TX");
        require(totalSupply + num < MAX_SUPPLY, MINTED_OUT);
        require(msg.sender.code.length == 0, "Hack harder bot master"); // bypassable, but raises level of effort
        uint id = counter;
        uint num_already_minted = 0;
        while(num_already_minted < num){
            if (preOf[id] == address(0)) {
                publicOf[id] = msg.sender;
                emit Transfer(address(0), msg.sender, id);
                num_already_minted += 1;
            }
            id += 1;
        }
        unchecked {
            balanceOf[msg.sender] += num;
            counter = uint16(id);
            totalSupply = totalSupply + num;
        }
    }

    // This function is here as a fallback in case we get undesirable gas consumption due to the
    // structure of the preOf array. if it does, the owner can pause the contract, mint the offending
    // token id and push public supply up to what it needs to be to get over O(n) SREAD operations in
    // the MAYC Array.
    // We may use it for promotions & giveaways.
    // One can monitor the deployment address for suspicious activity if you do not trust the devs.
    function mintAdmin(uint id, uint16 supplyOverwrite) external onlyAdmin {
        unchecked {
            publicOf[id] = msg.sender;
            counter = supplyOverwrite;
            balanceOf[msg.sender] += 1;
            totalSupply += 1;
        }
        emit Transfer(address(0), msg.sender, id);
    }

    function uintToString(uint256 value) internal pure returns (string memory) {
        // stolen from OpenZeppelin Strings library
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        if(ownerOf(id) == address(0))
            return "";
        return string(abi.encodePacked(string(abi.encodePacked("ipfs://QmUupQShChuEV9r6qEKGLpd51qWj4zGtMzkpsCDTuUutJQ/", uintToString(id))), ".json")); // TODO CHANGE MEEEEEE
    }

    function marketTransferFrom(address from, address to, uint256 id) external {
        require(msg.sender == address(market), "INVALID_CALLER");
        require(to != address(0), "INVALID_RECIPIENT");
        unchecked {
            balanceOf[from]--;

            balanceOf[to]++;
        }

        if (preOf[id] != address(0))
            preOf[id] = to;
        else
            publicOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );

    }

}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)
interface ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4);
}
