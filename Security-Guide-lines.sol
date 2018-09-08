1. Race Conditions
  1.1 Reentrancy:- Tricking of any smart contracts function to call again before it finishes previous calls.
                  E.g:
                  // INSECURE
                  mapping (address => uint) private userBalances;

                  function withdrawBalance() public {
                    uint amountToWithdraw = userBalances[msg.sender];
                    require(msg.sender.call.value(amountToWithdraw)()); // At this point, the caller's code
                    //is executed, and can call withdrawBalance again
                    userBalances[msg.sender] = 0;
                  }
      Solution:
              1. In the example given, the best way to avoid the problem is to use send() instead
                of call.value()(). This will prevent any external code from being executed as they have
                fixed amount of gas to be used for.
              2. Use external call at the last step i.e external call is the last statement to be called.
    1.2 Cross function race condition:- As above, caller can call your contract's other function as a result of
                                        of external call. see ex. below:-
                                        // INSECURE
                                        mapping (address => uint) private userBalances;

                                        function transfer(address to, uint amount) {
                                          if (userBalances[msg.sender] >= amount) {
                                            userBalances[to] += amount;
                                            userBalances[msg.sender] -= amount;
                                          }
                                        }

                                        function withdrawBalance() public {
                                          uint amountToWithdraw = userBalances[msg.sender];
                                          // call transfer from caller smart contract
                                          require(msg.sender.call.value(amountToWithdraw)());
                                          userBalances[msg.sender] = 0;
                                        }
      1.3 Function which calls untrusted fucntions are also untrusted:-

      // INSECURE
      mapping (address => uint) private userBalances;
      mapping (address => bool) private claimedBonus;
      mapping (address => uint) private rewardsForA;

      function withdraw(address recipient) public {
        uint amountToWithdraw = userBalances[recipient];
        rewardsForA[recipient] = 0;
        require(recipient.call.value(amountToWithdraw)());
      }

      function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        rewardsForA[recipient] += 100;
        withdraw(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedBonus[recipient] = true;
      }
      //SECURE
      mapping (address => uint) private userBalances;
      mapping (address => bool) private claimedBonus;
      mapping (address => uint) private rewardsForA;

      function untrustedWithdraw(address recipient) public {
        uint amountToWithdraw = userBalances[recipient];
        rewardsForA[recipient] = 0;
        require(recipient.call.value(amountToWithdraw)());
      }

      function untrustedGetFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        claimedBonus[recipient] = true;
        rewardsForA[recipient] += 100;
        untrustedWithdraw(recipient); // claimedBonus has been set to true, so reentry is impossible
      }



Difference between send, trasnfer and call:-
          address.transfer()

          throws on failure
          forwards 2,300 gas stipend (not adjustable), safe against reentrancy
          should be used in most cases as it's the safest way to send ether
          address.send()

          returns false on failure
          forwards 2,300 gas stipend (not adjustable), safe against reentrancy
          should be used in rare cases when you want to handle failure in the contract
          address.call.value().gas()()

          returns false on failure
          forwards all available gas (adjustable), not safe against reentrancy
          should be used when you need to control how much gas to forward when
          sending ether or to call a function of another contract


Front runnning/ Transaction order dependence:-
          Since a transaction is in the mempool for a short while, one can know what actions
          will occur, before it is included in a block. This can be troublesome for things like
          decentralized markets, where a transaction to buy some tokens can be seen, and a
          market order implemented before the other transaction gets included.

Timestamp dependence: time stamp is added by miners.

Integer Overflow and Underflow:
