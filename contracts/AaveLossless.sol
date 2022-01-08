// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import '../../interfaces/ILendingPool.sol';
import '../../interfaces/IERC20.sol';
import './Lossless.sol';


contract AaveLossless is Lossless  {

    address public token;
    address public winner;
    uint256 public sponsorDeposit;
    BetSide public winningSide;
    /// Aave Lending pool to deposit tokens
    ILendingPool public lendingPool;
    enum BetSide {OPEN, HOME, DRAW, AWAY}
    
    
    
    modifier correctBet(BetSide betSide) {
        require(betSide == BetSide.HOME || betSide == BetSide.AWAY|| betSide == BetSide.DRAW, 'invalid argument for bestide');
        _;
    }
    constructor(address _token, address _lendingPoolAddress, uint256 _matchStartBlock, uint256 _matchFinishBlock) public  Lossless(_matchStartBlock,_matchFinishBlock ){
        status = MatchStatus.OPEN;
        token = _token;
        lendingPool = ILendingPool(_lendingPoolAddress);
        winningSide = BetSide.OPEN;
        winner = address(0);


    }

    function sponsor(uint256 amount) public payable isOpen() {
        require(amount > 0, 'amount must be positif');
        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(address(lendingPool), amount);
        lendingPool.deposit(token, amount, address(this),0);
        totalDeposits += amount;
        sponsorDeposit += amount;
        playerBalance[msg.sender] += amount;


    }
    function placeBet(BetSide betSide, uint256 amount) public payable isOpen() correctBet(betSide) {
        require(amount > 0, 'amount must be positif');
        if (betSide==BetSide.HOME) {
            placeHomeBet(amount);
        } else if (betSide==BetSide.AWAY) {
            placeAwayBet(amount);
        } else if (betSide==BetSide.DRAW) {
            placeDrawBet(amount);
        }
        
        // placing money in aave logique
        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(address(lendingPool), amount);
        lendingPool.deposit(token, amount, address(this),0);
        totalDeposits += amount;
        playerBalance[msg.sender] += amount;

    }
    

    function withdraw() public isPaid() {

        require(playerBalance[msg.sender]>0 , 'balance is zero');
        uint256 amount = playerBalance[msg.sender];
        playerBalance[msg.sender] = 0;
        IERC20(token).transfer(msg.sender, amount);

    }

    function setMatchWinnerAndWithdrawFromPool(BetSide _winningSide) public isFinished() onlyOwner() correctBet(_winningSide) {
        require(status == MatchStatus.OPEN, 'Cant settle this match');
        status = MatchStatus.PAID;
        winningSide = _winningSide;
        lendingPool.withdraw(token, type(uint).max, address(this));
        findWinner();
        payoutWinner(); 

    }

    function findWinner() internal {
        if(winningSide == BetSide.HOME) {
            winner = findHomeWinner();
        } else if (winningSide == BetSide.AWAY) {
            winner = findAwayWinner();
        } else if (winningSide == BetSide.DRAW) {
            winner = findDrawWinner();
        }
    }

    function payoutWinner() internal  {
        uint256 winnerPayout = IERC20(token).balanceOf(address(this)) - totalDeposits;
        playerBalance[winner] += winnerPayout;
    }
   
  


    
   
    
     
  

  

}