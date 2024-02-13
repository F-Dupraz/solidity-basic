// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0 < 0.9.0;

import "./Achievment.sol";
import "./Currency.sol";

contract TicTacToe {

    struct Match {
        address player_1;
        address player_2;
        address winner;
        uint[3][3] moves;
        address last_move;
    }

    Match[] matches;
    mapping(address => uint) gamesWon;
    Achievment achievment;
    Currency currency;

    constructor(address achievmentContract, address achievmentCurrency) {
        achievment = Achievment(achievmentContract);
        currency = Currency(achievmentCurrency);
    }

    function startMatch(address my_player_1, address my_player_2) public returns(uint) {
        require(my_player_1 != my_player_2, "Players cannot be the same!");
        uint match_id = matches.length;
        Match memory new_match;
        new_match.player_1 = my_player_1;
        new_match.player_2 = my_player_2;
        matches.push(new_match);
        return match_id;
    }

    function play(uint match_id, uint horizontal, uint vertical) public {
        Match memory my_match = matches[match_id];
        require(msg.sender == my_match.player_1 || msg.sender == my_match.player_2, "You are not a player!");
        require(horizontal >= 0 && horizontal < 3);
        require(vertical >= 0 && vertical < 3);
        require(my_match.moves[horizontal][vertical] == 0);
        require(msg.sender != my_match.last_move);
        require(!isFinished(my_match));

        saveMove(match_id, horizontal, vertical);
        my_match = matches[match_id];

        uint winner = getWinner(my_match);
        saveWinner(winner, match_id);

        matches[match_id].last_move = msg.sender;
    }

    function saveWinner(uint winner, uint match_id) private {
        if(winner != 0) {
            if(winner == 1) matches[match_id].winner = matches[match_id].player_1;
            else matches[match_id].winner = matches[match_id].player_2;

            gamesWon[matches[match_id].winner]++;
            if(gamesWon[matches[match_id].winner] == 5) {
                achievment.MyEmit(matches[match_id].winner);
            }

            bool spaceAvaiable;
            for(uint i = 0; i < 3; i++) {
                for(uint j = 0; j < 3; j++) {
                    if(matches[match_id].moves[i][j] == 0) spaceAvaiable = true;
                }
            }
            if(spaceAvaiable) achievment.MyEmit(matches[match_id].winner);

            if(achievment.balanceOf(matches[match_id].winner) > 0) {
                currency.MyEmit(2, matches[match_id].winner);
            } else {
                currency.MyEmit(1, matches[match_id].winner);
            }
        }
    }

    function saveMove(uint match_id, uint h, uint v) private {
        if(msg.sender == matches[match_id].player_1) matches[match_id].moves[h][v] = 1;
        else matches[match_id].moves[h][v] = 2;
    }

    function chekLine(uint[3][3] memory my_moves, uint x1, uint y1, uint x2, uint y2, uint x3, uint y3) private pure returns(uint) {
        if((my_moves[x1][y1] == my_moves[x2][y2]) && (my_moves[x2][y2] == my_moves[x3][y3])) return my_moves[x1][x2];
        else return 0;
    }

    function getWinner(Match memory my_match) private pure returns(uint) {
        uint winner = chekLine(my_match.moves, 0, 0, 1, 1, 2, 2);
        if(winner == 0) winner = chekLine(my_match.moves, 0, 2, 1, 1, 2, 0);
        if(winner == 0) winner = chekLine(my_match.moves, 0, 0, 0, 1, 0, 2);
        if(winner == 0) winner = chekLine(my_match.moves, 1, 0, 1, 1, 1, 2);
        if(winner == 0) winner = chekLine(my_match.moves, 2, 0, 2, 1, 2, 2);
        if(winner == 0) winner = chekLine(my_match.moves, 0, 0, 1, 0, 2, 0);
        if(winner == 0) winner = chekLine(my_match.moves, 0, 1, 1, 1, 2, 1);
        if(winner == 0) winner = chekLine(my_match.moves, 0, 2, 1, 2, 2, 2);

        return winner;
    }

    function isFinished(Match memory my_match) private pure returns(bool) {
        if(my_match.winner != address(0)) return true;

        for(uint i = 0; i < 3; i++) {
            for(uint j = 0; j < 3; j++) {
                if(my_match.moves[i][j] == 0) return false;
            }
        }

        return true;
    }
}
