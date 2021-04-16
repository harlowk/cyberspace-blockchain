pragma solidity ^0.8.0;
contract CyberAsset {
    
    enum StateType { PendingReview, Healthy, UnHealthy, Modified, PendingInspection, Inspected, CommisionerAccepted, ResourceOwnerAccepted, Locked, Disabled, Terminated }
    struct Meta {
        string ID;
        string ResourceType;
        string EntityType;
        string EntityClass;
    }

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public assets;
    mapping (address => mapping (address => uint256)) public allowed;

    address public Scout; 
    address public Owner; 
    address public Oracle;
    
    Meta public AssetMeta;
    StateType public State;  

    constructor(Meta memory assetMeta, address owner, address oracle)
    {
        Scout = msg.sender;
        Owner = owner;
        Oracle = oracle;

        AssetMeta = assetMeta;
        State = StateType.PendingReview;
    }

}