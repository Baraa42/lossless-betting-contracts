// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import '../../interfaces/ILendingPool.sol';
import '../../interfaces/IERC20.sol';
import './Lossless.sol';



/** @title AaveLossless
 *  @dev This contract implement is a lossless betting contracts for football 1X2 that use Aave to generate yield
 * Contract has an owner to settle the bet, to be replaced by Chainlink.
 * Process : - Owner creates contract, sets token and lendingpool : token for betting and lending pool to use.
 *           - Contract can also be sponsored : someone deposit without participating in betting.
 */
contract AaveLossless is Lossless  {

    /// token used to bet
    address public token;
    /// player winning the lottery after game is settled
    address public winner;
    /// amount of deposit by sponsors
    uint256 public sponsorDeposit;
    /// team winning
    BetSide public winningSide;
    /// Aave Lending pool to deposit tokens
    ILendingPool public lendingPool;
    enum BetSide {OPEN, HOME, DRAW, AWAY}
    
    event BetPlaced(address player, BetSide betside, uint256 amount);
    event Winner(address _winner);
    
     /**
     * @dev Throws if betside is not valid
     */
    modifier correctBet(BetSide betSide) {
        require(betSide == BetSide.HOME || betSide == BetSide.AWAY|| betSide == BetSide.DRAW, 'invalid argument for bestide');
        _;
    }

    /**
     * @dev Initialize the contract settings : matchStartBlock, matchFinishBlock, token and lending pool.
     */
    constructor(address _token, address _lendingPoolAddress, uint256 _matchStartBlock, uint256 _matchFinishBlock)
    public  
    Lossless(_matchStartBlock, _matchFinishBlock ){
        status = MatchStatus.OPEN;
        token = _token;
        lendingPool = ILendingPool(_lendingPoolAddress);
        winningSide = BetSide.OPEN;
        winner = address(0);
    }

    /**
     * @dev Sponsor the contract, funds received will be used to generate yield.
     */
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

    /**
     * @dev Places the bet.
     */
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
        emit BetPlaced(msg.sender, betSide, amount);

    }
    
    /**
     * @dev Withdraw balance after game is over.
     */
    function withdraw() public isPaid() {

        require(playerBalance[msg.sender]>0 , 'balance is zero');
        uint256 amount = playerBalance[msg.sender];
        playerBalance[msg.sender] = 0;
        IERC20(token).transfer(msg.sender, amount);

    }

    /**
     * @dev can be called by owner to settle game and withdraw from the pool : To be replaced by chainlink.
     */
    function setMatchWinnerAndWithdrawFromPool(BetSide _winningSide) public isFinished() onlyOwner() correctBet(_winningSide) {
        require(status == MatchStatus.OPEN, 'Cant settle this match');
        status = MatchStatus.PAID;
        winningSide = _winningSide;
        lendingPool.withdraw(token, type(uint).max, address(this));
        findWinner();
        payoutWinner(); 
        emit Winner(_winner);

    }

    /**
     * @dev Internal function to find the winnner of the lottery.
     */
    function findWinner() internal {
        if(winningSide == BetSide.HOME) {
            winner = findHomeWinner();
        } else if (winningSide == BetSide.AWAY) {
            winner = findAwayWinner();
        } else if (winningSide == BetSide.DRAW) {
            winner = findDrawWinner();
        }
    }

    /**
     * @dev Internal function to update the balance of the winnner of the lottery.
     */
    function payoutWinner() internal  {
        uint256 winnerPayout = IERC20(token).balanceOf(address(this)) - totalDeposits;
        playerBalance[winner] += winnerPayout;
    }
   
  


    
   
    
     
  

  

}