# Lossless Betting - contracts



## The Contracts

The repo contain 3 main contracts 

### Lossless.sol
This contract implement is a boilerplate for lossless betting contracts for football 1X2.
Contract has an owner to settle the bet, to be replaced by Chainlink.

**Process** 
  1. Owner creates contract, sets `matchStartBlock` and `matchFinishBlock` : Players can place bets before `matchStartBlock` 
  and owner can settle the game after `matchFinishBlock.
  1. Before matchStartBlock player can pick a side ( Home, Draw, Away), choose an amount and place a bet.
  2. After placing a bet the player win points proportional to the `amount` and `blocks remaining before matchStartBlock`.
  3. The chance of winning for the player is proportional to his points.
  4. The money deposited for bets is then lent to a protocol and earns yield : Lending logic should be implemented in the contract that inherits this one.
  5. After game is finished and owner sets winning team, contract pick randomly a winner who bet on the right side.
  6. Winner wins the yield generated, and other players are refunded.
  

  
**Params** 
  1. `matchStartBlock` : Block at which game is supposed to start.
  2. `matchFinishBlock` : Block after which game should have ended.
 

### AaveLossless.sol
This contract implement is a lossless betting contracts for football 1X2 that use Aave to generate yield. Contract has an owner to settle the bet, to be replaced by Chainlink

**Process**
  1. Contract inherits from `Lossless.sol`.
  2. Owner creates contract, sets `token` and `lendingpool` : token for betting and lending pool to use..
  3. Contract can also be sponsored : someone deposit without participating in betting.
  4. Players can place bets before `matchStartBlock`.
  5. Betting money is then deposited into Aave to earn yield.
  6. Owner can settle the game after `matchFinishBlock`, a winner is then randomly picked he wins the yield generated.

**Anyone can**
  1. Sponsor the contract.
  2. Place bets before `matchStartBlock` .

  
**Admin/Owner can**
  1. Set winning team after `matchFinishBlock`.

**Params**
  2. `token` : ERC20 token address used for betting.
  3. `lendingPool` : Aave lending pool address.
  4. `winner` :Winning player address.
  5. `sponsorDeposit` : Amount deposited by sponsors to the contract.
  

### BenqiLossless.sol
Similar to `AaveLossless.sol`, not implemented yet


 
## Tests
All tests/scripts are written with `brownie`.  
 
Local testing using mainnet-fork.
No unit test yet, deployed contract on mainnet-fork and tested the`AaveLossless.sol`  process with a script end to end using the `weth` token. Worked fine.


    
## Compononets used
1. Node JS  (everything was tested under `v14.18.1`) 
2. Brownie  - ( the version used is `v1.17.2`) 
2. Ganache CLI ( the version used is `v6.12.2` )   

## Remark
Contracts are written in solidity `v0.6.x`and SafeMath have not been implemented yet.

