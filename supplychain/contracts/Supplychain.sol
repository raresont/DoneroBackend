pragma solidity >=0.5.1;

contract Supplychain {

	struct Project {
		uint projectId;
		uint totallyRaised;
    uint currentFunds;
    uint[] goals;
    address owner;
    bool validity;
    uint lastGoal;
    bool freeze;
	}

  struct Donation {
    uint projectId;
    uint donationId;
    uint totalMoneyDonated;
    address owner;
  }

	uint[] projectIdList;
  uint[] donationIdList;

	mapping (uint => Project) projects;
  mapping (uint => Donation) donations;
  mapping (uint => address[]) projectDonors; 

  // As it's not the main part of the application, we'll just assume token transactions
  // will be performed with some ERC20 Token
  // MyToken appc;

  
  // Given an user address, and an project id, returns whether the project is autorized to withdraw from the contract
  mapping (address => mapping(uint => bool)) autorizedProjects;

  address public owner;

  // Given an user and a project, returns the total of money this user donated
  // to the project and hasn't been unfreezed yet.
  mapping (address => mapping (uint => uint)) userProjectBalance;


	event ProjectCreated(uint _projectId, uint[] _goals, address _owner);

  event ProjectCancelled(uint _projectId);

  event DonationReceived(uint _projectId, uint _donationId, uint _totalMoneyDonated, address _owner);

  event GoalReached(uint _projectId, uint _goalNumber); 

  event GoalVerified(uint _projectId, uint _goalNumber);

  event MoneyWithdrawnFromProject(uint _projectId, uint _value, address _receiver);

  event MoneyReleased(uint _projectId, uint _value, address _owner);


  /**
  * Constructor function
  */
  constructor () public {
      owner = msg.sender;
  }

	/**
	* Creates a campaign for a certain package name with
	* a defined price and budget and emits a CampaignCreated event
	*/
	function createProject (uint _projectId, uint[] calldata _goals, address _owner) external {
    require(msg.sender == owner);

		projectIdList.push(_projectId);
		projects[_projectId] = Project(_projectId, 0, 0, _goals, _owner, true, 0, false);

    autorizedProjects[_owner][_projectId] = true;

    emit ProjectCreated(_projectId, _goals, _owner);
	}

	function cancelProject (uint _projectId) external {
		require (owner == msg.sender);

		projectClawback(_projectId);
		setProjectValidity(_projectId,false);

    emit ProjectCancelled(_projectId);
	}

  // Obtains the quantity necessary to overpass next stage
  function getNextGoal (uint _projectId) internal view returns (uint) {
    uint sum = 0;
    for(uint i = 0; i <= projects[_projectId].lastGoal; i++){
      sum += projects[_projectId].goals[i];
    }
    return sum;
  }

  function projectClawback(uint _projectId) internal {
    for (uint i=0; i< projectDonors[_projectId].length; i++){
      userClawback(_projectId, projectDonors[_projectId][i]);
    }
  }

  function userClawback (uint _projectId, address _user) internal {
    // appc.transfer(userProjectBalance[_user][_projectId])
    userProjectBalance[_user][_projectId] = 0;
  }

	function setProjectValidity (uint _projectId, bool _boolean) internal {
    projects[_projectId].validity = _boolean;
	}

  function getOwnerOfProject (uint _projectId) public view returns(address) {
		return projects[_projectId].owner;
	}

  // When a donation is created, money is not delivered inmmediately. We just register it
  // and ajust the balance for the user.
  function makeDonation (uint _projectId, uint _value, uint _donationId) external {

    require(projects[_projectId].validity == true);

    // require(balanceOf(msg.sender)) >= value)

    donationIdList.push(_donationId);

		donations[_projectId] = Donation(_projectId, _donationId, _value, msg.sender);

    // There's no problem with initialization, as it is directly initialized to zero
    userProjectBalance[msg.sender][_projectId] += _value;

    emit DonationReceived(_projectId, _donationId, _value, msg.sender);
  }

  function freezeDonations(uint _projectId) internal{
    projects[_projectId].freeze = true;
  }

  function releaseNextStage(uint _projectId) external {
    require (msg.sender == owner);
    require (projects[_projectId].freeze == true);
    emit GoalVerified(_projectId, projects[_projectId].lastGoal);
    projects[_projectId].lastGoal += 1;
    projects[_projectId].freeze = false;
  }

  function withdrawFromProject(uint _projectId, uint _value) external {
    require (autorizedProjects[msg.sender][_projectId] == true);
    require (_value <= projects[_projectId].currentFunds);

    projects[_projectId].currentFunds -= _value;
    // for each client, invoke function appc.transfer(...)
    emit MoneyWithdrawnFromProject(_projectId, _value, msg.sender);
  }

  // Both the owner or the client can decide to unlock part of the owner's pending donation
  function releaseFundsFromClient(uint _projectId, uint _value, address _owner) external{
    require(msg.sender == owner || msg.sender == _owner);
    require(projects[_projectId].freeze == false);
    require(_value <= userProjectBalance[_owner][_projectId]);
    Project storage currentProject = projects[_projectId];
    currentProject.totallyRaised += _value;
    currentProject.currentFunds += _value;

    userProjectBalance[_owner][_projectId] -= _value;

    emit MoneyReleased(_projectId, _value, _owner);

    // We have to check if enough money has been raised to next goal, so 
    // that freeze donations.
    if (currentProject.totallyRaised >= getNextGoal(_projectId)){
      emit GoalReached(_projectId, currentProject.lastGoal);
      freezeDonations(_projectId);
    }
  }

  function getTotallyRaisedMoneyInProject(uint _projectId) public view returns(uint){
    return projects[_projectId].totallyRaised;
  }

  function getCurrentFundingMoneyInProjectAccount(uint _projectId) public view returns(uint){
    return projects[_projectId].currentFunds;
  }
}
