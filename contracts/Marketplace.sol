// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Marketplace {

  mapping(uint => uint) values;
  IERC721 achievements;
  IERC20 currency;

  constructor(address achievementContract, address currencyContract) {
    achievements = IERC721(achievementContract);
    currency = IERC20(currencyContract);
  }

  function publish(uint token_id, uint value) public {
    require(values[token_id] == 0);
    require(value >= 1);
    require(achievements.getApproved(token_id) == address(this));

    values[token_id] = value;
  }

  function buy(uint token_id) public {
    require(values[token_id] != 0);
    require(currency.allowance(msg.sender, address(this)) >= values[token_id]);
    require(achievements.getApproved(token_id) == address(this));

    currency.transferFrom(msg.sender, achievements.ownerOf(token_id), values[token_id]);
    achievements.safeTransferFrom(achievements.ownerOf(token_id), msg.sender, token_id);
    values[token_id] = 0;
  }

}