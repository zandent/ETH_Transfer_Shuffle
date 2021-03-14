pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import 'lib/SafeMath.sol';
import 'UserRecord.sol';
import 'lib/ECDSA.sol';
contract TrasnsferHelper is UserRecord{
    using SafeMath for uint256;
    using ECDSA for bytes32;
    function TransferFunc(
        address payable[] memory senders, 
        address payable[] memory receivers, 
        //no need for pubkeys, address is enough
        //uint256[] memory sender_pubKeys, 
        uint256 NoOfClaimers,
        uint256 amount,
        uint256 total_amount_to_firstClaimer,
        //signiture components
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) public payable{
        require(information[msg.sender].hoster.hoster_end_timestamp > block.timestamp, 
        "The first claimer address is not valid right now!");
        require(information[msg.sender].amount == amount,
        "The amount to be transferred does not match");
        require(information[msg.sender].isTxDone == false,
        "The transfer is already done!");
        bool memberCheck = false;
        for(uint256 i = 0; i < NoOfClaimers; i++) {  
            memberCheck = false;       
            for(uint256 j = 0; j < information[msg.sender].noOfClaimers; j++) {         
                if(senders[i] == information[msg.sender].claimers[j].addr){
                    //balance verification
                    require(information[msg.sender].claimers[j].balance >= amount,"someone balance is not enough");
                    information[msg.sender].claimers[j].balance = information[msg.sender].claimers[j].balance.sub(amount);
                    memberCheck = true;
                }
            }
            //Should not fail
            require(memberCheck == true, "Adversary detected! Some sender does not register!"); 
        }
        information[msg.sender].isTxDone=true;
        
        //TODO: signiture verification
        //s1: packed data to message as a form of byte array.
        bytes memory message = abi.encodePacked(senders[0]);
        for(uint256 i = 1; i < NoOfClaimers; i++) {         
            message = abi.encodePacked(message, senders[i]);
        }
        for(uint256 i = 0; i < NoOfClaimers; i++) {         
            message = abi.encodePacked(message, receivers[i]);
        }
        message = abi.encodePacked(message, NoOfClaimers);
        message = abi.encodePacked(message, amount);
        message = abi.encodePacked(message, total_amount_to_firstClaimer);
        //s2: hash the message
        bytes32 hashmsg = sha256(message);
        //s3: check generated address matches or not.
        for(uint256 i = 0; i < NoOfClaimers; i++) {         
            require(hashmsg.recover(v[i],r[i],s[i]) == senders[i], "signiture is invalid!");
        }

        for(uint256 i = 0; i < NoOfClaimers; i++) {         
            receivers[i].transfer(amount);
        }
        senders[0].transfer(total_amount_to_firstClaimer);
    }
}