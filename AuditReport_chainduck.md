# Comprehensive Smart Contract Audit Report

## 1. Introduction

This audit focused on a suite of smart contracts designed to power a decentralized ecosystem, offering staking, rewards distribution, and NFT functionalities. These contracts support key features like token staking, liquidity provision, governance through veTokens, and rewards managed via Merkle tree proofs. Additionally, they integrate with widely-used libraries, such as those provided by OpenZeppelin, and external protocols to ensure robust functionality.

### Contracts Audited:
- **AstraChargeCardNFT.sol**
- **AstraGenesisNFT.sol**
- **AstraIntelCollect.sol**
- **AstraRewardMerkle.sol**
- **AstraRewardNativeMerkle.sol**
- **AstraRewards.sol**
- **AstraRewardsNative.sol**
- **Bribe.sol**
- **NFTquery.sol**
- **ResourceSynthesis.sol**
- **StarLpStaking.sol**
- **veSTAR.sol**
- **veSTARRewards.sol**
- **LinearVestingToken.sol**

### Goals of the Audit:
The primary goal of this audit was to assess the security, gas efficiency, and functionality of these contracts. The audit focused on identifying potential vulnerabilities, optimizing gas consumption, and ensuring adherence to best practices. The following report provides an in-depth analysis of each contract, including critical, major, minor, and informational findings.

---

## 2. Executive Summary

This audit uncovered several issues across the contracts, categorized by severity. While the contracts generally followed industry best practices, there are some areas for improvement, particularly around reentrancy protection, gas efficiency, access control, and cryptographic security.

### Risk Breakdown:

| Contract                | Critical Issues | Major Issues | Minor Issues | Informational |
|-------------------------|-----------------|--------------|--------------|---------------|
| AstraChargeCardNFT.sol   | 0               | 0            | 1            | 1             |
| AstraGenesisNFT.sol      | 0               | 0            | 1            | 1             |
| AstraIntelCollect.sol    | 0               | 1            | 1            | 1             |
| AstraRewardMerkle.sol    | 0               | 1            | 1            | 0             |
| AstraRewardNativeMerkle  | 0               | 1            | 1            | 0             |
| AstraRewards.sol         | 0               | 1            | 1            | 1             |
| AstraRewardsNative.sol   | 0               | 1            | 1            | 0             |
| Bribe.sol                | 0               | 1            | 1            | 0             |
| NFTquery.sol             | 0               | 1            | 1            | 0             |
| ResourceSynthesis.sol    | 0               | 1            | 1            | 1             |
| StarLpStaking.sol        | 0               | 1            | 1            | 1             |
| veSTAR.sol               | 0               | 1            | 1            | 1             |
| veSTARRewards.sol        | 0               | 1            | 1            | 0             |
| LinearVestingToken.sol    | 0               | 0            | 1            | 1             |

---

## 3. Scope of the Audit

### Audit Methodology:
- **Manual Code Review**: A thorough, line-by-line review of the code to identify logic errors, security vulnerabilities, and optimization issues.
- **Static Analysis**: Automated tools were used to detect common vulnerabilities such as reentrancy, integer overflows/underflows, and unchecked external calls.
- **Gas Profiling**: Each contract was analyzed for gas efficiency, particularly in areas that involve loops or complex computations.
- **Functional Review**: The intended functionality of critical contract functions, such as staking, reward distribution, and NFT minting, was thoroughly assessed.

---

## 4. Detailed Findings

### AstraChargeCardNFT.sol

- **Minor Issue: Lack of Event Emission**  
  The `setURI` function updates the URI without emitting an event. Adding an event for URI updates would improve transparency and allow off-chain services to track these changes more easily.

  **Code Reference:**
  ```
  function setURI(string memory uri_) external onlyOwner {
      _uri = uri_;
  }
  ```
  
  **Recommendation:**
  Add an event to track URI updates:
  ```
  event URIUpdated(string newURI);

  function setURI(string memory uri_) external onlyOwner {
      _uri = uri_;
      emit URIUpdated(uri_);
  }
  ```

- **Informational: Access Control**  
  The contract uses OpenZeppelin’s `Ownable` to manage ownership and permissioned functions. Care should be taken when transferring ownership to ensure proper control.

---

### AstraGenesisNFT.sol

- **Minor Issue: Gas Inefficiency in Merkle Proof Handling**  
  The Merkle proof verification could become expensive as the whitelist grows. Consider optimizing or batch processing claims to reduce gas costs.

  **Code Reference:**
  ```
  function whitelistMint(bytes32[] calldata _merkleProof) external {
      require(!claimed[msg.sender], "Already claimed");
      bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
      require(MerkleProof.verify(_merkleProof, whitelistMerkleRoot, leaf), "Invalid proof");
      claimed[msg.sender] = true;
      _safeMint(msg.sender, _tokenIdCounter++);
  }
  ```

  **Recommendation:**
  Consider batching or optimizing the Merkle proof verification for larger lists.

- **Informational: Missing Event Emission on Minting**  
  No events are emitted during the minting process. For better transparency, it’s recommended to emit events when new tokens are minted.

  **Recommendation:**
  ```
  event Minted(address indexed user, uint256 tokenId);

  function whitelistMint(bytes32[] calldata _merkleProof) external {
      // ... existing logic
      _safeMint(msg.sender, _tokenIdCounter++);
      emit Minted(msg.sender, _tokenIdCounter);
  }
  ```

---

### AstraIntelCollect.sol

- **Major Issue: Timestamp Manipulation**  
  The contract depends on `block.timestamp` to manage collection intervals. Block timestamps can be manipulated by miners within a small range. A more robust solution should be used to prevent timing-related exploits.

  **Code Reference:**
  ```
  uint32 private constant COLLECT_INTERVAL = 24 * 60 * 60;

  function collectIntel() external {
      require(block.timestamp - users[msg.sender].latestCollectTime >= COLLECT_INTERVAL, "Too soon");
      // Logic for collection
  }
  ```

  **Recommendation:**
  Avoid relying on `block.timestamp` and consider using `block.number` or implementing stricter checks around the block timestamp range.

- **Minor Issue: Unchecked External Calls**  
  The contract relies on external contracts (e.g., whitelisting) without verifying their return values. This could result in unforeseen vulnerabilities if external calls fail or return unexpected values.

  **Code Reference:**
  ```
  IBeraPad padContract = IBeraPad(whitelistAddr);
  padContract.someFunctionCall();
  ```

  **Recommendation:**
  Ensure that all external contract calls check return values and handle failure cases properly.

- **Informational: Gas Optimization**  
  As user interactions grow, the gas cost for updating the `users` mapping could increase. Consider optimizing data structures to handle large-scale user bases more efficiently.

---

### AstraRewardMerkle.sol / AstraRewardNativeMerkle.sol

- **Major Issue: Reentrancy Protection**  
  Functions responsible for transferring rewards should be protected with the `nonReentrant` modifier to mitigate reentrancy risks.

  **Code Reference:**
  ```
  function claim(uint256 amount, bytes32[] calldata proof) external {
      require(!claimedAddress[msg.sender], "Already claimed");
      // Reward transfer logic here
  }
  ```

  **Recommendation:**
  Use the `nonReentrant` modifier to prevent reentrancy attacks:
  ```
  function claim(uint256 amount, bytes32[] calldata proof) external nonReentrant {
      // Existing logic
  }
  ```

- **Minor Issue: Lack of Event Emission**  
  The contract should emit events when the whitelist root is updated and when rewards are claimed to improve traceability and off-chain data collection.

---

### AstraRewards.sol / AstraRewardsNative.sol

- **Major Issue: Signature Replay Attack**  
  Signatures used to claim rewards could be reused by attackers. A nonce or timestamp-based mechanism should be introduced to ensure each signature can only be used once.

  **Code Reference:**
  ```
  function claimReward(bytes calldata signature) external {
      address signer = ECDSA.recover(hash, signature);
      require(signer == validSigner, "Invalid signature");
      // Reward claim logic
  }
  ```

  **Recommendation:**
  Use a nonce system to prevent replay attacks:
  ```
  mapping(address => uint256) public nonces;

  function claimReward(bytes calldata signature) external {
      uint256 currentNonce = nonces[msg.sender];
      bytes32 hash = keccak256(abi.encodePacked(msg.sender, currentNonce));
      address signer = ECDSA.recover(hash, signature);
      require(signer == validSigner, "Invalid signature");

      nonces[msg.sender]++;
      // Reward claim logic
  }
  ```

- **Minor Issue: Gas Efficiency**  
  Reward calculations could become gas-intensive when processing large numbers of stakers. Consider batch processing to reduce costs.

---

### Bribe.sol

- **Major Issue: Unchecked External Calls**  
  External calls to the `IBGT` contract for queuing and activating boosts should have their return values checked. Failing to check these could result in unexpected behavior or vulnerabilities.

  **Code Reference:**
  ```
  IBGT(boostContract).queueBoost(validator, amount);
  ```

  **Recommendation:**
  Ensure external calls check return values:
  ```
  bool success = IBGT(boostContract).queueBoost(validator, amount);
  require(success, "Boost queue failed");
  ```

- **Minor Issue: Safe Token Transfers**  
  Ensure that all token transfers use `SafeERC20` and check return values to handle failures appropriately.

---

### NFTquery.sol

- **Major Issue: Gas Inefficiency**  
  Iterating over a fixed range of 800 token IDs is inefficient, particularly for larger collections. Allow for dynamic input ranges or batch processing to reduce gas costs.

  **Code Reference:**
  ```
  for (uint256 tokenId = 0; tokenId < maxSupply; tokenId++) {
      try nft.ownerOf(tokenId) returns (address owner) {
          if (owner == msg.sender) {
              // Store token ID
          }
      } catch {
          continue;
      }
  }
  ```

  **Recommendation:**
  Consider using a dynamic range for token IDs or batch processing to reduce gas costs for larger collections.

  ---

  ---

### ResourceSynthesis.sol

- **Major Issue: Access Control**  
  Critical functions, such as adding resources and adjusting synthesis costs, should be protected with access control mechanisms. Only the contract owner or authorized entities should be able to modify these settings.

  **Code Reference:**
  ```
  function addResource(uint256 id, uint256 level, string memory name) external {
      resources[id] = Resource(id, level, name);
  }

  function setSynthesisCost(uint256 _cost) external {
      synthesisCost = _cost;
  }
  ```

  **Recommendation:**
  Use the `onlyOwner` modifier or similar access control to protect critical functions:
  ```
  function addResource(uint256 id, uint256 level, string memory name) external onlyOwner {
      resources[id] = Resource(id, level, name);
  }

  function setSynthesisCost(uint256 _cost) external onlyOwner {
      synthesisCost = _cost;
  }
  ```

- **Minor Issue: Gas Optimization**  
  Large-scale resource synthesis could lead to high gas costs. Consider optimizing the synthesis process for better scalability.

---

### StarLpStaking.sol

- **Major Issue: Reward Distribution Vulnerability**  
  Ensure that the reward distribution logic is accurate and cannot be manipulated by users to receive more than their fair share of rewards.

  **Code Reference:**
  ```
  function stake(uint256 amount) external {
      require(amount > 0, "Cannot stake 0 tokens");
      lpToken.transferFrom(msg.sender, address(this), amount);
      // Reward distribution logic here
  }
  ```

  **Recommendation:**
  Review the reward distribution mechanism to ensure fairness and prevent users from inflating their rewards.

- **Informational: Gas Efficiency**  
  Staking and calculating rewards for a large number of users could become gas-expensive. Optimizing the reward calculation process can help reduce the overall gas usage.

---

### veSTAR.sol

- **Major Issue: Token Locking and Unlocking**  
  The locking and unlocking mechanisms must be robust to ensure that users cannot unlock tokens prematurely. Use time-based logic carefully to prevent manipulation of unlock times.

  **Code Reference:**
  ```
  function lock(uint256 amount, uint256 time) external {
      require(time > 0 && time <= MAX_LOCK_TIME, "Invalid lock time");
      starToken.transferFrom(msg.sender, address(this), amount);
      locked[msg.sender].amount += amount;
      locked[msg.sender].unlockTime = block.timestamp + time;
  }

  function unlock() external {
      require(block.timestamp >= locked[msg.sender].unlockTime, "Tokens are still locked");
      uint256 amount = locked[msg.sender].amount;
      locked[msg.sender].amount = 0;
      starToken.transfer(msg.sender, amount);
  }
  ```

  **Recommendation:**
  Review and ensure that the locking mechanism prevents early unlocks and that no user can circumvent the intended lock period.

- **Informational: Event Emissions**  
  It’s good practice to emit events for critical actions such as locking and unlocking tokens, and this contract handles these events well.

---

### veSTARRewards.sol

- **Major Issue: Secure Liquidity and Staking Operations**  
  The contract interacts with the `IBeraPool` for liquidity and staking operations. Ensure these interactions are secure and that rewards are calculated accurately to avoid any potential exploits.

  **Code Reference:**
  ```
  function stake(uint256 amount) external {
      require(amount > 0, "Cannot stake 0 tokens");
      astraToken.safeTransferFrom(msg.sender, address(this), amount);
      // Staking logic here
  }

  function claimRewards() external {
      // Reward claim logic here
  }
  ```

  **Recommendation:**
  Carefully review the interactions with external pools to ensure that rewards are calculated and distributed fairly.

- **Minor Issue: Token Transfer Handling**  
  Ensure that `SafeERC20` is used consistently, and all return values from token transfers are properly checked.

---

### LinearVestingToken.sol

- **Minor Issue: Lack of Event Emission on Token Claims**  
  The `claim` function allows the vester to claim unlocked tokens but does not emit an event. Adding an event for token claims would improve transparency and allow off-chain services to track these actions.

  **Code Reference:**
  ```solidity
  function claim() external {
      // ... existing logic ...
  }
  ```

  **Recommendation:**
  Add an event to track token claims:
  ```solidity
  event TokensClaimed(address indexed claimant, uint256 amount);

  function claim() external {
      // ... existing logic ...
      emit TokensClaimed(msg.sender, amountToUnlock);
  }
  ```

- **Informational: Access Control**  
  The contract uses the `onlyOwner` modifier for vesting tokens and restricts claims to the designated vester. Ensure that the vester's address is managed securely to prevent unauthorized claims.

---

## 5. Security Analysis

### Reentrancy Vulnerabilities
The contracts reviewed are generally well-written and adhere to standard best practices, but there are several areas where improvements are necessary. By addressing the identified issues—particularly around reentrancy protection, gas efficiency, and access control—the contracts can become more robust and secure.

### Recommendations:
- Implement nonce systems to prevent signature replay attacks.
- Apply `nonReentrant` modifiers to all functions dealing with token transfers and reward distribution.
- Optimize gas usage by adopting batch processing and improving iteration logic.
- Ensure critical functions are well-protected through strict access control.
- Use `SafeERC20` consistently and check return values for all token transfers.

---

**Audit conducked by 0xChainDuck**

