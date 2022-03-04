nLeafCount = 8;

curLeafCount = nLeafCount/2;
levelBase = nLeafCount/2;
lastLevelBase = 0;

while(curLeafCount > 1) {
    for(var i = 0 ; i < curLeafCount ; i = i+2) {
        var curHashId = levelBase + i/2;
        var input1 = lastLevelBase + i;
        var input2 = lastLevelBase + i + 1;

        console.log(curHashId, ": ", input1, input2);
    }
    lastLevelBase = levelBase;
    levelBase += curLeafCount / 2;
    curLeafCount = curLeafCount / 2;
}