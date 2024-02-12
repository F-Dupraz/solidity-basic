// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace {

  mapping(uint => uint) values;
  mapping(uint => address) bidder;
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
    bidder[token_id] = msg.sender;
  }

  function finish(uint token_id) public onlyOwner {
    require(values[token_id] > 0);
    require(currency.allowance(bidder[token_id], address(this)) > values[token_id]);
    require(achievements.getApproved(token_id) == address(this));

    currency.transferFrom(bidder[token_id], achievements.ownerOf(token_id), values[token_id]);
    achievements.safeTransferFrom(achievements.ownerOf(token_id), bidder[token_id], token_id);
    values[token_id] = 0;
  }

  function offer(uint token_id, uint cuantity) public {
    require(values[token_id] > 0);
    require(cuantity > values[token_id]);
    require(currency.allowance(msg.sender, address(this)) >= values[token_id]);

    bidder[token_id] = msg.sender;
    values[token_id] = cuantity;
  }

}