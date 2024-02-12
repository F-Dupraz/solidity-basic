// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Currency is ERC20("Achievment Currency", "ACC"), Ownable {
 
  function MyEmit(uint cuantity, address destination) public onlyOwner {
    _mint(destination, cuantity);
  }

}
