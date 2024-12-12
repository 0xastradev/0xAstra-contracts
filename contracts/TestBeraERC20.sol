import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestBeraERC20 is ERC20 {
    constructor() ERC20("STAR", "STAR") {
        _mint(msg.sender, 100000000000000000000000000000000000000);
    }

   function mint(address to, uint256 amount) public {
    _mint(to, amount);
   }
}
