// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "hardhat/console.sol";

contract Paypal {

    // Define the owner of the smart contract
    address public owner;

    constructor () {
        owner = msg.sender;
    }


    // Create Struct & Mapping for request, transaction & name
    // - Structs show what consist inside the transaction i.e. address of requestor, name of requestor, amount requested & message
    // - Mappings allow you to see from which address the Struct is from - map addresses to structs
    struct request {
        address requestor;
        uint amount;
        string message;
        string name;
    }

    struct sendReceive {
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    struct userName {
        string name;
        bool hasName;
    }

    mapping(address => userName) names; // map address to userName struct, name of mapping: names
    mapping(address => request[]) requests; // request[] so when calling requests[address] an array of request structs will be returned
    mapping(address => sendReceive[]) history; // sendReceive[] so when calling history[address] an array of sendReceive structs will be returned


    // Add name to wallet address i.e. give wallet a name
    function addName(string memory _name) public {

        // Create "userName" struct and "storage" to store data inside this contract
        // Create temporary name "newUserName" which is used to update storage values of struct
        // note that address mapping is set by names[msg.sender]
        userName storage newUserName = names[msg.sender];
        newUserName.name = _name;
        newUserName.hasName = true;

    }


    // Create and record a payment request
    function createRequest(address user, uint256 _amount, string memory _message) public {

        request memory newRequest; // Create request struct, temporarily store in memory as newRequest
        newRequest.requestor = msg.sender; // Set caller of function as the requestor to newRequest
        newRequest.amount = _amount; // Amount is passed into newRequest
        newRequest.message = _message; // Message is passed into newRequest
        if (names[msg.sender].hasName) { // If msg.sender hasName, then put their name into newRequest
            newRequest.name = names[msg.sender].name;
        } // If no name set then this will be an empty string

        requests[user].push(newRequest); // This pushes the newRequest struct into the requests[] array of user

    }


    // Pay the request
    // _request is an int becuase its targetting the request inside requests[] array
    function payRequest(uint256 _request) public payable {

        require(_request < requests[msg.sender].length, "No such request");
        request[] storage myRequests = requests[msg.sender]; // Temp var's: request[], myRequests to get requests array of msg.sender
        request storage payableRequest = myRequests[_request]; // Target the specific request thats passed into this function

        uint256 toPay = payableRequest.amount *  1000000000000000000; // Convert to wei, 18 decimals
        require(msg.value == (toPay), "Pay correct amount"); // Checks to see if number of wei sent with the message matches "toPay"

        payable(payableRequest.requestor).transfer(msg.value); // Takes requestor and transfers msg.value to the requestor

        addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message); // Add requests into history storage array of sender & receiver respectively

        myRequests[_request] = myRequests[myRequests.length - 1]; // Swap last request in myRequests & swap with current _request we just paid
        myRequests.pop(); // Now we remove the last request (one we just paid) from the myRequests array

    }
    
    // Record payment history
    function addHistory(address sender, address receiver, uint256 _amount, string memory _message) private {

        sendReceive memory newSend; // Create temp var that is sendReceive struct
        newSend.action = "-"; // Set negative symbol as action of newSend as sender is sending money
        newSend.amount = _amount; // Set amount of newSend sender struct
        newSend.message = _message; // Set message of newSend
        newSend.otherPartyAddress = receiver; // Set other party involved in transaction
        if (names[receiver].hasName) { // If receiver hasName, then put their name into newSend
            newSend.otherPartyName = names[receiver].name;
        } // If no name set then this will be an empty string
        history[sender].push(newSend); // Add to sender's history array of transactions

        sendReceive memory newReceive; // Create temp var that is sendReceive struct
        newReceive.action = "+"; // Set positive symbol as the receiver is gaining money
        newReceive.amount = _amount; // Set amount of newSend receiver struct
        newReceive.message = _message; // Set message of newSend receiver struct
        newReceive.otherPartyAddress = sender; // Set other party involved in transaction
        if (names[sender].hasName) { // If sender hasName, then put their name into newSend
            newReceive.otherPartyName = names[sender].name;
        }// If no name set then this will be an empty string
        history[receiver].push(newReceive); // Add to receiver's history array of transactions
    }


    // Get all requests sent to a User
    function getMyRequests(address _user) public view returns (address[] memory, uint256[] memory, string[] memory, string[] memory) {

        // Get length of user's requests array
        uint256 user_requests_length = requests[_user].length;

        // Create temp arrays that will get populated by the for loop
        address[] memory addrs = new address[](user_requests_length);
        uint256[] memory amnt = new uint256[](user_requests_length);
        string[] memory msge = new string[](user_requests_length);
        string[] memory nme = new string[](user_requests_length);

        // Loop through user's requests array and populate each individual request item (addrs, amnt, msge, nme)
        for (uint i=0; i < user_requests_length; i++) {
            request storage myRequests = requests[_user][i];
            addrs[i] = myRequests.requestor;
            amnt[i] = myRequests.amount;
            msge[i] = myRequests.message;
            nme[i] = myRequests.name;
        }

        // Will return 4 arrays each of will are: addrs, amnt, msge & nme
        return (addrs, amnt, msge, nme);
    }
    

    // Get all historic transactions a user has been a part of
    function getMyHistory(address _user) public view returns(sendReceive[] memory) {
        return history[_user];
    }

    // Get the name assigned to address
    function getMyName(address _user) public view returns(userName memory) {
        return names[_user];
    }

}

