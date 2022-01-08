// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './Lossless.sol';
import '../../interfaces/ILendingPool.sol';
import '../../interfaces/IERC20.sol';
//import "../interfaces/IWAVAX.sol";
////import "../interfaces/IBenqiUnitroller.sol";
//import "../interfaces/IBenqiAVAXDelegator.sol";
//import '../access/Ownable.sol';
//import "../lib/ReentrancyGuard.sol";


contract BenqiLossless is Lossless  {

    address public token;
    address public winner;
    BetSide public winningSide;
    /// Benqi Lending pool to deposit tokens
    //ILendingPool public lendingPool;
    enum BetSide {OPEN, HOME, AWAY}
    
    
    
  
     constructor(address _token, address _lendingPoolAddress, uint256 _matchExpiryBlock) public  Lossless(_matchExpiryBlock){
        status = MatchStatus.OPEN;
        token = _token;
        //lendingPool = ILendingPool(_lendingPoolAddress);
        winningSide = BetSide.OPEN;
        winner = address(0);


    }

    function placeBet(BetSide betSide, uint256 amount) public payable isOpen() {
        require(amount > 0, 'amount must be positif');
        require(betSide == BetSide.HOME || betSide ==BetSide.AWAY, 'invalid argument for bestide');

        if (betSide==BetSide.HOME) {
            placeHomeBet(amount);
        } else if (betSide==BetSide.AWAY) {
            placeAwayBet(amount);
        } 
        totalDeposits += amount;
        playerBalance[msg.sender] += amount;
        // placing money in benqi logique
        

    }
    

    function withdraw() public isPaid() {

        require(playerBalance[msg.sender]>0 , 'balance is zero');
        uint256 amount = playerBalance[msg.sender];
        playerBalance[msg.sender] = 0;
        //IERC20(token).transfer(msg.sender, amount);

    }

    function setMatchWinnerAndWithdrawFromPool(BetSide _winningSide) public isFinished() onlyOwner() {
        require(_winningSide == BetSide.HOME || _winningSide == BetSide.AWAY, 'Wrong input for winner');
        status = MatchStatus.PAID;
        winningSide = _winningSide;
        //lendingPool.withdraw(token, type(uint).max, address(this));
        findWinner();
        payoutWinner(); 

    }

    function findWinner() internal {
        if(winningSide == BetSide.HOME) {
            winner = findHomeWinner();
        } else if (winningSide == BetSide.AWAY) {
            winner = findAwayWinner();
        }
    }

    function payoutWinner() internal  {
        //uint256 winnerPayout = IERC20(token).balanceOf(address(this)) - totalDeposits;
        //playerBalance[winner] += winnerPayout;
    }
   
  


    
   
    
     
  

  

}