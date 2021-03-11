pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import 'lib/SafeMath.sol';
import 'UserRecord.sol';
contract TrasnsferHelper is UserRecord{
    function TransferFunc(
        address payable[] memory senders, 
        address payable[] memory receivers, 
        uint256[] memory sender_pubKeys, 
        uint256 NoOfClaimers,
        uint256 amount,
        uint256 amt_to_firstClaimer,
        uint256[] memory signitures
    ) public payable{
        require(information[msg.sender].hoster.hoster_end_timestamp > block.timestamp, 
        "The first claimer address is not valid right now!");
        require(information[msg.sender].amount == amount,
        "The amount to be transferred does not match");
        bool memberCheck = false;
        for(uint256 i = 0; i < NoOfClaimers; i++) {  
            memberCheck = false;       
            for(uint256 j = 0; j < information[msg.sender].noOfClaimers; j++) {         
                if(senders[i] == information[msg.sender].claimers[j].addr){
                    memberCheck = true;
                }
            }
            require(memberCheck == true, "Adversary detected! Some sender does not register!"); 
        }
        require(information[msg.sender].isTxDone == false,
        "The transfer is already done!");
        information[msg.sender].isTxDone=true;
        //TODO: signiture verification
        //TODO: balance verification
        for(uint256 i = 0; i < NoOfClaimers; i++) {         
            receivers[i].transfer(amount);
            if(senders[i] != msg.sender){
                senders[i].transfer(amt_to_firstClaimer);
            }
        }
    }
}