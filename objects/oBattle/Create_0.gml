instance_deactivate_all(true); // oBattle will take over everything

// set up battle
units = [];
turn = 0;
unitTurnOrder = [];
unitRenderOrder = [];

// make enemies
for (var i = 0; i < array_length(enemies); i++) {
    enemyUnits[i] = instance_create_depth(x+250+(i*10), y+68+(i*20), depth-10, oBattleUnitEnemy, enemies[i]);
    // multiple rows canm be done with (x+250+((i mod 3)*10)+((i div 3)*25),y+68+((i mod 3)*20)
    array_push(units, enemyUnits[i]);
}

// make party
for (var i = 0; i < array_length(global.party); i++) {
    partyUnits[i] = instance_create_depth(x+70+(i*10), y+68+(i*20), depth-10, oBattleUnitPC, global.party[i]);
    array_push(units, partyUnits[i]);
}

// shuffle turn order
unitTurnOrder = array_shuffle(units);

// get render order, by y coordinates
RefreshRenderOrder = function() {
    unitRenderOrder = [];
    array_copy(unitRenderOrder, 0, units, 0, array_length(units));
    // higher units are treated as far away from the camera
    array_sort(unitRenderOrder, function(_1, _2) {
        return _1.y - _2.y;
    });
}
RefreshRenderOrder();