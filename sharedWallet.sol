//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

    //only the owner can approve or change address allowances
contract sharedWallet is Ownable {
    using SafeMath for uint;

    event deposit(address indexed _from, uint _amount);
    event approval(address indexed _forWho, address indexed _byWhom, uint _oldAmount, uint _newAmount);
    event transfer(address indexed _to, uint _amount);

    //maps approved addresses and amounts
    mapping (address => mapping(bool => uint)) public approved;

    //anyone can deposit funds to this smart contract
    function depositFunds() payable public {
        emit deposit(msg.sender, msg.value);
    }
    //return the total remaining balance in this contract
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    //owner can approve an address and add an allowance
    function approveAddress(address payable _to, uint _amount) public onlyOwner {
        emit approval(_to, msg.sender, approved[_to][true], _amount);
        approved[_to][true] = _amount;
    }

    //owner can transfer any amount of funds in this contract
    function transferAnyAmount(address payable _to, uint _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient contract funds");
        _to.transfer(_amount);
    }

    //Anyone with an approved address and allowance can transfer any amount of their allowance
    function transferAllowanceAmount(address payable _to, uint _amount) public {
        require(_amount <= approved[msg.sender][true], "Amount is greater than allowance");
        approved[msg.sender][true]=approved[msg.sender][true].sub(_amount);
        emit transfer(_to, _amount);
        _to.transfer(_amount);
    }

    //the owner can change the allowance amount
    function changeAllowance(address payable _to, uint _amount) public onlyOwner{
        approved[_to][true] = _amount;
    }

    //return the remaining allowance of an address
    function getAllowanceAmount(address _address) public view returns(uint) {
        return approved[_address][true];
    }

    function renounceOwnership() public view override onlyOwner {
        revert("can't renounceOwnership here"); //not possible with this smart contract
    }

    receive() external payable {
        emit deposit(msg.sender, msg.value);
    }
}