# Assetrix Smart Contract Assessment

## 🎯 Objective

This contract implements a crowdfunding-style escrow system for real estate projects. It allows developers to create fundraising campaigns, receive contributions in ETH, and conditionally access funds depending on whether the funding goal is met before the deadline.

---

## 🏗️ Key Features

### ✅ Campaign Creation
- Developers can create campaigns by providing a name, funding goal (in ETH), and deadline (timestamp).
- Each campaign is uniquely identified and tracked.

### ✅ Investor Contributions
- Anyone can contribute ETH to a campaign before the deadline.
- Contributions are recorded per user and locked in escrow.

### ✅ Escrow Logic
- Funds are held securely until the deadline.
- If the funding goal is **met**, only the campaign owner can release funds to themselves.
- If the funding goal is **not met**, contributors can individually claim refunds.

### ✅ Security Measures
- Uses OpenZeppelin's `Ownable`, `Pausable`, and `ReentrancyGuard` contracts:
  - `Ownable` restricts admin actions like pausing.
  - `Pausable` allows emergency pause of contributions.
  - `ReentrancyGuard` protects against reentrancy in withdrawals/refunds.
- Follows `checks-effects-interactions` pattern for fund handling.

### ✅ Events for Transparency
- `CampaignCreated`
- `ContributionReceived`
- `FundsReleased`
- `RefundIssued`

---

## 🛠️ Design Decisions

- **ETH-only** was used for simplicity, but the contract is modular and can be upgraded to support ERC20 tokens (e.g., USDC) for stablecoin-based funding.
- Funds are **only released manually** by the campaign owner (once eligible), giving flexibility for post-campaign compliance.
- Refunds are pull-based: users must actively claim, avoiding unintended gas consumption.

---

## 🚨 Assumptions

- All timestamps are based on `block.timestamp`, assuming an honest miner majority.
- Campaign owners are trusted to register only valid real estate campaigns; legal validation is assumed off-chain.

---

## 📂 File Structure
  assetrix/
  
│
├── contracts/
│   └── Assetrix.sol                  # Main smart contract
│
├── ARCHITECTURE.md                   # Architecture decisions
│
│
├── README.md                         # Design decisions and usage
                      
              

---

## 📚 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

Mujeeb Sulayman  
Blockchain Developer 
