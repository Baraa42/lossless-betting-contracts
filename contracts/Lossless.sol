// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './access/Ownable.sol';


contract Lossless is Ownable  {

    MatchStatus public status;
    uint256 public matchExpiryBlock;
    uint256 public totalDeposits;
    uint256 public homePointsTrackers;
    uint256 public awayPointsTrackers;
    uint256 public homeBets;
    uint256 public awayBets;
    uint256 [] public homePointsAfterBet;
    uint256 [] public awayPointsAfterBet;
    mapping(uint => address) homeBetPlacer;
    mapping(uint => address) awayBetPlacer;
    mapping(address => uint) playerBalance;
    mapping(address => uint) playerHomePoints;
    mapping(address => uint) playerAwayPoints;
    enum MatchStatus {OPEN, RUNNING, FINISHED, PAID}

    
    event OrderExpired( );
    
    modifier isOpen() {
        require(status == MatchStatus.OPEN, 'Match not open');
        require(block.number < matchExpiryBlock, 'Cant place bet now');
        _;
    }

    modifier isFinished() {
        require(status == MatchStatus.FINISHED, 'Match not finished');
        _;
    }

    modifier isPaid() {
        require(status == MatchStatus.PAID, 'Match not paid');
        _;
    }
    
     constructor(uint256 _matchExpiryBlock) public {
        status = MatchStatus.OPEN;
        matchExpiryBlock = _matchExpiryBlock; // to use later

    }

    
    function placeHomeBet(uint256 amount) internal {
        uint256 currentBlock = block.number;
        uint256 points = amount *  (matchExpiryBlock - currentBlock);
        playerHomePoints[msg.sender] += points;
        homePointsTrackers += points;
        homePointsAfterBet[homeBets] = homePointsTrackers;
        homeBetPlacer[homeBets] = msg.sender;
        homeBets += 1;
        
    }

    function placeAwayBet(uint256 amount) internal {
        uint256 currentBlock = block.number;
        uint256 points = amount * (matchExpiryBlock - currentBlock);
        playerAwayPoints[msg.sender] += points;
        awayPointsTrackers += points;
        awayPointsAfterBet[awayBets] = awayPointsTrackers;
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
        uint lo = 1;

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

    function findAwayWinner() internal returns(address) {
        uint256 random = random();
        random = random % awayPointsTrackers;

        if(random < awayPointsAfterBet[0]) {
            return awayBetPlacer[0];
        }

        uint hi = awayPointsAfterBet.length-1;
        uint lo = 1;

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
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp ,totalDeposits )));
    }

    
  


}