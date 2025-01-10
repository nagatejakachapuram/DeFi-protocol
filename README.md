# Decentralized Stablecoin Protocol

## **Overview**

This protocol is a fully decentralized and algorithmic stablecoin system designed to maintain a 1:1 peg with the US Dollar. The stablecoin is exogenous, meaning it is backed by external assets like WBTC and WETH, and operates with the following principles:

- **Over-collateralization:** All issued stablecoins are backed by collateral valued greater than the stablecoin supply.
- **No Governance:** The protocol is autonomous and free from external governance.
- **Algorithmic Pegging:** Ensures price stability through smart contract-enforced mechanisms.

---

## **Key Components**

### **1. Decentralized Stablecoin (DSC)**
The stablecoin token that is minted and burned in the system.

### **2. DSCEngine**
The core contract that handles:
- Collateral deposits and withdrawals.
- Minting and burning of DSC.
- Maintaining user health factors.
- Liquidation of under-collateralized accounts.

### **3. Price Oracles**
Chainlink price feeds provide accurate and up-to-date USD prices for collateral tokens.

---

## **Features**

### **Collateral Management**
- Users can deposit supported collateral tokens (e.g., WBTC, WETH).
- Collateral value is determined based on Chainlink price feeds.
- Withdrawal and redemption are subject to health factor checks.

### **Minting DSC**
- Users can mint DSC against their deposited collateral.
- The protocol enforces over-collateralization and maintains a minimum health factor.

### **Burning DSC**
- Users can burn DSC to increase their health factor or unlock collateral.

### **Liquidation**
- Accounts with a health factor below 1 are subject to liquidation.
- Liquidators can seize collateral in exchange for burning DSC.

### **Health Factor**
A metric to assess the solvency of an account. Defined as:
```
Health Factor = (Collateral Value Adjusted for Liquidation Threshold) / Debt Value
```

---

## **Contract Architecture**

### **1. DecentralizedStableCoin.sol**
- Implements the ERC20 standard for the DSC token.
- Supports minting and burning by the DSCEngine.

### **2. DSCEngine.sol**
- Manages collateral deposits, withdrawals, minting, and liquidation.
- Tracks user balances and ensures over-collateralization.
- Integrates with Chainlink price feeds for real-time asset valuation.

---

## **Workflow**

### **Deposit and Mint**
1. User deposits collateral (e.g., WETH, WBTC).
2. The protocol calculates the collateral’s USD value.
3. User mints DSC up to the maximum allowed based on their health factor.

### **Burn and Redeem**
1. User burns DSC to reduce debt.
2. Collateral is unlocked proportionally based on the new health factor.

### **Liquidation**
1. Accounts with health factor < 1 are eligible for liquidation.
2. Liquidators burn DSC to seize collateral at a discounted rate.

---

## **Deployment Instructions**

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd stablecoin-protocol
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Deploy contracts:
   ```bash
   npx hardhat deploy
   ```

4. Verify contracts on Etherscan:
   ```bash
   npx hardhat verify <contract-address> --network <network-name>
   ```

---

## **Testing**
Run the test suite to ensure the protocol functions as intended:
```bash
npx hardhat test
```

---

## **Future Improvements**
1. Add support for additional collateral types.
2. Implement governance for protocol upgrades.
3. Introduce dynamic liquidation thresholds based on market conditions.

---

## **License**
This project is licensed under the MIT License.

---

## **Acknowledgements**
- **OpenZeppelin**: For secure smart contract libraries.
- **Chainlink**: For reliable price oracles.

---

## **Contact**
For questions or contributions, reach out at nagatejakachapuram@gmail.com or open an issue in the repository.

