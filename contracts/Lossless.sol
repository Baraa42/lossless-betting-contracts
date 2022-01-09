// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './access/Ownable.sol';

/** @title Lossless
 *  @dev This contract implement is a boilerplate for lossless betting contracts for football 1X2.
 * Contract has an owner to settle the bet, to be replaced by Chainlink.
 * Process : - Owner creates contract, sets matchStartBlock and matchFinishBlock : Players can place bets before matchStartBlock 
 * and owner can settle the game after matchFinishBlock.
 *           - Before matchStartBlock player can pick a side ( Home, Draw, Away), choose an amount and place a bet.
 *           - After placing a bet the player win points proportional to the 'amount' and 'blocks remaining before matchStartBlock'.
 *           - The chance of winning for the player is proportional to his points. 
 *           - The money deposited for bets is then lent to a protocol and earns yield.     
 *           - After game is finished and owner sets winning team, contract pick randomly a winner who bet on the right side.
 *           - Winner wins the yield generated, and other players are refunded.
 */

contract Lossless is Ownable  {

    MatchStatus public status;
    /// block at which game is supposed to start
    uint256 public matchStartBlock;
    /// block after which game should have ended
    uint256 public matchFinishBlock;
    /// total amount deposited in the contract
    uint256 public totalDeposits;
    /// total points earned by players betting home
    uint256 public homePointsTrackers;
    /// total points earned by players betting draw
    uint256 public drawPointsTrackers;
    /// total points earned by players betting away
    uint256 public awayPointsTrackers;
    /// number of home bets
    uint256 public homeBets;
    /// number of draw bets
    uint256 public drawBets;
    /// number of away bets
    uint256 public awayBets;
    /// tracks total points earned by player betting home after bet number i, used for computing winner
    uint256 [] public homePointsAfterBet;
    /// tracks total points earned by player betting draw after bet number i, used for computing winner
    uint256 [] public drawPointsAfterBet;
    /// tracks total points earned by player betting away after bet number i, used for computing winner
    uint256 [] public awayPointsAfterBet;
    /// tracks which playerr placed home bet number i
    mapping(uint => address) public homeBetPlacer;
    /// tracks which playerr placed draw bet number i
    mapping(uint => address) public drawBetPlacer;
    /// tracks which playerr placed away bet number i
    mapping(uint => address) public awayBetPlacer;
    /// tracks players deposits
    mapping(address => uint) public playerBalance;
    /// tracks players home points
    mapping(address => uint) public playerHomePoints;
    /// tracks players draw points
    mapping(address => uint) public playerDrawPoints;
    /// tracks players away points
    mapping(address => uint) public playerAwayPoints;
    enum MatchStatus {OPEN, PAID}

    
     /**
     * @dev Throws if called after game started
     */
    modifier isOpen() {
        require(status == MatchStatus.OPEN, 'Match not open');
        require(block.number < matchStartBlock, 'Cant place bet now');
        _;
    }

     /**
     * @dev Throws if called before game is Finished 
     */

    modifier isFinished() {
        require(block.number > matchFinishBlock  , 'Game is finished');
        _;
    }

     /**
     * @dev Throws if called after game is Paid
     */
    modifier isPaid() {
        require(status == MatchStatus.PAID, 'Match not paid');
        _;
    }

    
    /**
     * @dev Initialize the contract settings : matchStartBlock and matchFinishBlock.
     */
     constructor(uint256 _matchStartBlock, uint256 _matchFinishBlock) public {
        status = MatchStatus.OPEN;
        matchStartBlock = _matchStartBlock; 
        matchFinishBlock = _matchFinishBlock;

    }

    /**
     * @dev Places home bet.
     */
    function placeHomeBet(uint256 amount) internal {
        uint256 currentBlock = block.number;
        uint256 points = amount *  (matchStartBlock - currentBlock);
        playerHomePoints[msg.sender] += points;
        homePointsTrackers += points;
        homePointsAfterBet.push(homePointsTrackers);
        homeBetPlacer[homeBets] = msg.sender;
        homeBets += 1;
        
    }

    /**
     * @dev Places draw bet.
     */
    function placeDrawBet(uint256 amount) internal {
        uint256 currentBlock = block.number;
        uint256 points = amount *  (matchStartBlock - currentBlock);
        playerDrawPoints[msg.sender] += points;
        drawPointsTrackers += points;
        drawPointsAfterBet.push(drawPointsTrackers);
        drawBetPlacer[homeBets] = msg.sender;
        drawBets += 1;
        
    }

    /**
     * @dev Places away bet.
     */
    function placeAwayBet(uint256 amount) internal {
        uint256 currentBlock = block.number;
        uint256 points = amount * (matchStartBlock - currentBlock);
        playerAwayPoints[msg.sender] += points;
        awayPointsTrackers += points;
        awayPointsAfterBet.push(awayPointsTrackers) ;
        awayBetPlacer[awayBets] = msg.sender;
        awayBets += 1;
        
    }



    /**
     * @dev Find home winner.
     */
    function findHomeWinner() internal returns(address) {
        uint256 random = random();
        random = random % homePointsTrackers;

        if(random < homePointsAfterBet[0]) {
            return homeBetPlacer[0];
        }

        uint hi = homePointsAfterBet.length-1;
        uint lo = 0;

        while(lo <= hi) {
            uint256 mid = lo + (hi-lo)/2;
            if(random < homePointsAfterBet[mid]){
                hi = mid-1 ;
            } else if (random >homePointsAfterBet[mid]) {
                lo = mid + 1;
            } else {
                return homeBetPlacer[mid+1];
            }
        }
        return homeBetPlacer[lo];

    }

    /**
     * @dev Find Draw winner.
     */
    function findDrawWinner() internal returns(address) {
        uint256 random = random();
        random = random % drawPointsTrackers;

        if(random < drawPointsAfterBet[0]) {
            return drawBetPlacer[0];
        }

        uint hi = drawPointsAfterBet.length-1;
        uint lo = 0;

        while(lo <= hi) {
            uint256 mid = lo + (hi-lo)/2;
            if(random < drawPointsAfterBet[mid]){
                hi = mid-1 ;
            } else if (random >drawPointsAfterBet[mid]) {
                lo = mid + 1;
            } else {
                return drawBetPlacer[mid+1];
            }
        }
        return drawBetPlacer[lo];

    }

    /**
     * @dev Find away winner.
     */
    function findAwayWinner() internal returns(address) {
        uint256 random = random();
        random = random % awayPointsTrackers;

        if(random < awayPointsAfterBet[0]) {
            return awayBetPlacer[0];
        }

        uint hi = awayPointsAfterBet.length-1;
        uint lo = 0;

        while(lo <= hi) {
            uint256 mid = lo + (hi-lo)/2;
            if(random < awayPointsAfterBet[mid]){
                hi = mid-1 ;
            } else if (random >awayPointsAfterBet[mid]) {
                lo = mid + 1;
            } else {
                return awayBetPlacer[mid+1];
            }
        }
        return awayBetPlacer[lo];

    }
  

    /**
     * @dev Generate random number to compute the winner, to be replaced with Chainlink VRF.
     */
    function random() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp ,totalDeposits, matchStartBlock, matchFinishBlock )));
    }

    
  


}