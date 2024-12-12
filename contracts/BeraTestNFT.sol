import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BeraTestNFT is ERC721Enumerable, Ownable {
    string private baseURI;

    constructor() ERC721("BeraMakerNFT", "BTNFT") Ownable(msg.sender) {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
      baseURI = baseURI_;
    }
}
