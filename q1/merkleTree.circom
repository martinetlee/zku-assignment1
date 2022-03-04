pragma circom 2.0.0;

include "mimcsponge.circom";

template MerkleRoot(nLeafCount) {
    signal input leaves[nLeafCount];
    signal output root;
    component hashes[nLeafCount];

    var curLeafCount = nLeafCount;
    var levelBase = 0;
    var lastLevelBase = 0;

    for(var i = 0 ; i < curLeafCount; i = i+2) {
        var curHashId = i/2;
        hashes[curHashId] = MiMCSponge(2,220,1);
        hashes[curHashId].ins[0] <== leaves[i];
        hashes[curHashId].ins[1] <== leaves[i+1];
        hashes[curHashId].k <== 0;
    }

    curLeafCount = nLeafCount/2;
    levelBase = nLeafCount/2;
    lastLevelBase = 0;

    while(curLeafCount > 1) {
        for(var i = 0 ; i < curLeafCount ; i = i+2) {
            var curHashId = levelBase + i/2;
            hashes[curHashId] = MiMCSponge(2,220,1);
            hashes[curHashId].ins[0] <== hashes[lastLevelBase + i ].outs[0];
            hashes[curHashId].ins[1] <== hashes[lastLevelBase + i + 1].outs[0];
            hashes[curHashId].k <== 0;
            log(i);
        }
        lastLevelBase = levelBase;
        levelBase += curLeafCount / 2;
        curLeafCount = curLeafCount / 2;
    }

    root <== hashes[lastLevelBase].outs[0];
}

component main = MerkleRoot(8);