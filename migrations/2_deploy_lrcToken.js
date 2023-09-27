const LRCToken = artifacts.require("LRCToken");

module.exports = function(deployer) {
    deployer.deploy(LRCToken);
}