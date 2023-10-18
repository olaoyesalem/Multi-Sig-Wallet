
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MultiSigWallet{

    event Deposit(address indexed  sender, uint256 amount);
    event Submit(uint256 indexed  txId);
    event Approve(address indexed  owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint256 indexed  txId);

    modifier onlyOwner{
        require(isOwner[msg.sender],"Not Owner");
        _;
    }

    modifier txExists(uint _txId){
        require(_txId< transactions.length, " tx does not exist");
        _;
    }

    modifier  notApprovetxId(uint _txId){
        require(!approved[_txId][msg.sender],"tx already Approved");
        _;
    }

    modifier   notExecuted(uint _txId){
        require(!transactions[_txId].executed,"tx already Executed");
        _;
    }

    struct Transaction{
        address to;// address whwrrre the txn is executed
        uint256 value;// amount to  be sent to the 2 addresses
        bytes data;// the data to be sent to the 2 addreses
        bool executed;
    }

    address[] public  owners;
    mapping (address => bool)public isOwner;

    uint256 public required;// number of users that must approve the function befoire the txn can be executed

    Transaction[]public  transactions;
    mapping (uint256 =>mapping (address=>bool)) public  approved;

    constructor(address[] memory _owners,uint _required){
        require(_owners.length>0,"Owners Required");
        require(_required>0 && _required<=_owners.length, "Invalid Required Number Of owners");

        for (uint i; i<_owners.length;i++){
            address owner = _owners[i];
            require(owner!=address(0), "Invalid Owner");

              isOwner[owner]=true;
              owners.push(owner);      
        }
      
        required=_required;
    }

        function submit(address _to, uint256 _value, bytes calldata _data) external onlyOwner{
            transactions.push(
                Transaction({
                    to:_to,
                    value:_value,
                    data:_data,
                    executed:false
                })
            );
            emit Submit(transactions.length-1);
        }

        function approve( uint _txId) external onlyOwner txExists(_txId) notApprovetxId(_txId)
        notExecuted(_txId){
            approved[_txId][msg.sender]=true;

            emit Approve(msg.sender, _txId);

        }

        function _getApprovedCount(uint _txId )

        receive() external  payable {
            emit  Deposit(msg.sender, msg.value);
        }
}
