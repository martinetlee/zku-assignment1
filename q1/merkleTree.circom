pragma circon 2.0.0;

include "mimcsponge.circom";

template GetParent(){
    input a;
    input b;
    output parent;

    component mimc;
    mimc = MiMCSponge(2, 220, 1);
    mimc.ins[0] = a;
    mimc.ins[1] = b;
    mimc.k = 0;

    parent = mimc.outs[0];
}

template MerkleRoot(nLeafCount) {
    input leaves[nLeafCount];
    output root;
    component hashes[nLeafCount];

    var curLeafCount = nLeafCount;
    var curLeaves[nLeafCount/2];
    var levelBase = 0;
    var lastLevelBase = 0;

    for(var i = 0 ; i < curLeafCount; i = i+2) {
        var curHashId = i/2;
        hashes[curHashId] = MiMCSponge(2,220,1);
        hashes[curHashId].ins[0] = leaves[i];
        hashes[curHashId].ins[1] = leaves[i+1];
    }

    curLeafCount = nLeafCount/2;
    levelBase = nLeafCount/2;
    lastLevelBase = 0;

    while(curLeafCount > 1) {
        for(var i = 0 ; i < curLeafCount ; i = i+2) {
            var curHashId = levelBase + i/2;
            hashes[curHashId] = MiMCSponge(2,220,1);
            hashes[curHashId].ins[0] = hashes[lastLevelBase + i * 2].outs[0];
            hashes[curHashId].ins[1] = hashes[lastLevelBase + i * 2 + 1].outs[0];
        }
        lastLevelBase = levelBase;
        levelBase += curLeafCount/2;
        curLeafCount = curLeafCount / 2;
    }
    var lastHashId = nLeafCount - 1;
    hashes[lastHashId] = MiMCSponge(2,220,1);
    hashes[lastHashId].ins[0] = hashes[lastLevelBase].outs[0];
    hashes[lastHashId].ins[1] = hashes[lastLevelBase+1].outs[0];

    root = hashes[lastHashId].outs[0];
}
