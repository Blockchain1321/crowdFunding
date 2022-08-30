pragma solidity >=0.5.0 < 0.9.0;
// this statement show this support the version of solidit greater than 5 less than 9

contract CrowdFunding{
    mapping(address=>uint) public contributors;
    // address will store the contributor address so we are able to find who is contributor
    // in unit we are taking that how much he contribute
    address public manager;
    // here we are defining the manager who representing company

    uint public minimumContribution;
    uint public deadline;
    uint public target;

    uint public raisedAmount;
    // raised amount will contain how much amount we collected till now
    uint public noOfContributors;
    // it contain how many contributors conitributed

    struct Request{
        string description;
        // this description of our request
        address payable recipient;
        // person who is benifited from this amount
        uint value;
        // how much amount he want
        bool completed;
        // this checks our voting is completed or not
        uint noOfVoters;
        // no of contributors voted for this contract
        mapping(address=>bool) voters;
        // address of voter who voted for it
    }
    mapping(uint=>Request) public requests;
    // here we are mapping multiple requests
    // 0   charity
    // 1 business
    uint public numRequests;


    constructor(uint _target,uint _deadline) public {
        // our manager set the deadline and target
        target = _target;
        deadline = block.timestamp + _deadline;
        // block.timstamp gives the current block time stamp
        //  it gives the time in the unix which in the seconds
        // our block made at 10sec and we want to run it for 1hr so we add 3600sec
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp < deadline,"Deadline had passed");
        // here we are checking that our contract passed the deadline or not
        require(msg.value >= minimumContribution,"Minimum Contribution is not met");
        // here we are checking that contributor donating  minimum value or not

        if(contributors[msg.sender]==0){
            noOfContributors++;
            // here we are checking that contributor is new or not
            // if contributor is new we are increasing the contributor count
        }
        contributors[msg.sender]+=msg.value;
        // here we are storing the contributor address with given amount
        raisedAmount+=msg.value;
        // we are adding the given amount into the raised amount
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;
        // this giving the contract current balance
    }

    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"You are not eligible for refund");
        // here we check the condition for the refund 
        require(contributors[msg.sender]>0,"you didn't contribute anything");
        // here we are checking that contributors contributed or not
        address payable user= payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    modifier onlyManger(){
        require(msg.sender==manager,"Only manager can call this");
        _;
    }

    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManger{
        Request storage newRequest = requests[numRequests];
        // if we use the mapping inside the structure then we need to use the storage
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You must be contributor");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already");
        // here we are checking that he already voted or not
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManger{
        require(raisedAmount>=target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;   
    }
}
