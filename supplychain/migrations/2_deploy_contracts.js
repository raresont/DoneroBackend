var HelloWorld=artifacts.require("./Supplychain.sol");
module.exports = function(deployer) {   
   
	deployer.deploy(HelloWorld);
}
