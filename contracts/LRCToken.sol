// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LRCToken {

    using SafeMath for uint;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint _totalSupply;
    address public owner;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Approval(
        address indexed tokenOwner, 
        address indexed spender,
        uint tokens
    );
    event Transfer(
        address indexed from,
        address indexed  to,
        uint tokens
    );

    constructor() {
        symbol = "LRC";
        name = "Liquid King Coin";
        decimals = 2;
        _totalSupply = 1000000000;
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
    }

    // Total token supply
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    // Get owner token balance
    function balanceOf(address tokenOwner) public view returns(uint) {
        return balances[tokenOwner];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    // Transfer tokens to another account
    function transfer(address to, uint tokens) public returns(bool) {
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], tokens);
        balances[to] = SafeMath.add(balances[to], tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;
    } 

    // Approve delegates to withdraw token
    function approve(address spender, uint tokens) public returns(bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    // Get total number of tokens approved for withdrawal
    function allowance(address tokenOwner, address spender) public view returns(uint) {
        return allowed[tokenOwner][spender];
    }

    // Mint token
    function mint(address tokenOwner, uint256 amount) internal virtual {
        require(tokenOwner != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), tokenOwner, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            balances[tokenOwner] += amount;
        }
        emit Transfer(address(0), tokenOwner, amount);

        _afterTokenTransfer(address(0), tokenOwner, amount);
    }

    // Burn token
    function burn(address tokenOwner, uint256 amount) internal virtual {
        require(tokenOwner != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(tokenOwner, address(0), amount);

        uint256 accountBalance = balances[tokenOwner];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balances[tokenOwner] = SafeMath.sub(accountBalance, amount);
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(tokenOwner, address(0), amount);

        _afterTokenTransfer(tokenOwner, address(0), amount);
    }

    // Transfer from delegate
    function transferFrom(
        address from,
        address to,
        uint tokens
    ) public returns(bool) {
        require(tokens <= balances[from]);
        require(tokens <= allowed[from][msg.sender]);
        balances[from] = SafeMath.sub(balances[from], tokens);
        allowed[from][msg.sender] = SafeMath.sub(allowed[from][msg.sender], tokens);
        balances[to] = SafeMath.add(balances[to], tokens);

        emit Transfer(from, to, tokens);
        return true;
    }

    function approveAndCall(
        address spender,
        uint tokens
    ) public returns(bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}