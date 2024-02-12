// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Achievment is ERC721("Achievment Token", "ACT"), Ownable {

  uint lastIndex;

  function MyEmit(address destination) public onlyOwner returns(uint) {
    uint index = lastIndex;
    lastIndex++;
    _safeMint(destination, index);
    return index;
  }

}
