// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./Bannable.sol";

contract FCToken is ERC20, ERC20Snapshot, Ownable, Pausable, Bannable {
    constructor() ERC20("Fantastic City Token", "FCT") {
        _mint(msg.sender, 5000000 * 10 ** decimals());
    }
    
    function transfer(address recipient, uint256 amount) public virtual whenNotBanned whenNotPaused override returns (bool) {
        return super.transfer(recipient, amount);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount)
        public
        virtual
        whenNotBanned
        whenNotPaused
        override
        returns(bool)
    {
        return super.transferFrom(sender, recipient, amount);
    }
    
    function approve(address spender, uint256 amount) public virtual whenNotBanned whenNotPaused override returns(bool) {
        return super.approve(spender, amount);
    }

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}