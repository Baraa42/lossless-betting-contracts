// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './access/Ownable.sol';


contract Lossless is Ownable  {

    MatchStatus public status;
    uint256 public matchStartBlock;
    uint256 public matchFinishBlock;
    uint256 public totalDeposits;
    uint256 public homePointsTrackers;
    uint256 public drawPointsTrackers;
    uint256 public awayPointsTrackers;
    uint256 public homeBets;
    uint256 public awayBets;
    uint256 public drawBets;
    uint256 [] public homePointsAfterBet;
    uint256 [] public drawPointsAfterBet;
    uint256 [] public awayPointsAfterBet;
    mapping(uint => address) public homeBetPlacer;
    mapping(uint => address) public drawBetPlacer;
    mapping(uint => address) public awayBetPlacer;
    mapping(address => uint) public playerBalance;
    mapping(address => uint) public playerHomePoints;
    mapping(address => uint) public playerDrawPoints;
    mapping(address => uint) public playerAwayPoints;
    enum MatchStatus {OPEN, PAID}

    
    
    modifier isOpen() {
        require(status == MatchStatus.OPEN, 'Match not open');
        require(block.number < matchStartBlock, 'Cant place bet now');
        _;
    }

    modifier isRunning() {
        require(block.number < matchFinishBlock && block.number > matchStartBlock  , 'Game is running');
        _;
    }

    modifier isFinished() {
        require(block.number > matchFinishBlock  , 'Game is finished');
        _;
    }

    modifier isPaid() {
        require(status == MatchStatus.PAID, 'Match not paid');
        _;
    }

    
    
     constructor(uint256 _matchStartBlock, uint256 _matchFinishBlock) public {
        status = MatchStatus.OPEN;
        matchStartBlock = _matchStartBlock; 
        matchFinishBlock = _matchFinishBlock;

    }

    
    function placeHomeBet(uint256 amount) internal {
        uint256 currentBlock = block.number;
        uint256 points = amount *  (matchStartBlock - currentBlock);
        playerHomePoints[msg.sender] += points;
        homePointsTrackers += points;
        homePointsAfterBet.push(homePointsTrackers);
        homeBetPlacer[homeBets] = msg.sender;
        homeBets += 1;
        
    }

    function placeDrawBet(uint256 amount) internal {
        uint256 currentBlock = block.number;
        uint256 points = amount *  (matchStartBlock - currentBlock);
        playerDrawPoints[msg.sender] += points;
        drawPointsTrackers += points;
        drawPointsAfterBet.push(drawPointsTrackers);
        drawBetPlacer[homeBets] = msg.sender;
        drawBets += 1;
        
    }

    function placeAwayBet(uint256 amount) internal {
        uint256 currentBlock = block.number;
        uint256 points = amount * (matchStartBlock - currentBlock);
        playerAwayPoints[msg.sender] += points;
        awayPointsTrackers += points;
        awayPointsAfterBet.push(awayPointsTrackers) ;
        awayBetPlacer[awayBets] = msg.sender;
        awayBets += 1;
        
    }


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
  
   
    function random() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp ,totalDeposits, matchStartBlock, matchFinishBlock )));
    }

    
  


}