/**
 *Submitted for verification at Etherscan.io on 2022-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract helloworld {
    uint256 public n_state = 1;

    function claim(uint256 count) public {
        n_state = count + n_state;
    }
}