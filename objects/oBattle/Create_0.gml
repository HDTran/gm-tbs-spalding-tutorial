instance_deactivate_all(true); // oBattle will take over everything

// set up battle
units = [];
turn = 0;
unitTurnOrder = [];
unitRenderOrder = [];

turnCount = 0;
roundCount = 0;
battleWaitTimeFrames = 30;
battleWaitTimeRemaining = 0;
currentUser = noone;
currentAction = -1;
currentTargets = noone;

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

// state steps
function BattleStateSelectionAction() {
    if (!instance_exists(oMenu)) {
        // get current unit
        var _unit = unitTurnOrder[turn];
        
        // is the unit dead or unable to act?
        if ((!instance_exists(_unit)) || (_unit.hp <= 0)) {
            battleState = BattleStateVictoryCheck;
            exit;
        }
        
        // select an action to perform
        // BeginAction(_unit.id, global.actionLibrary.attack, _unit.id); // TODO: Fix this by deleting and replacing
        
        // if unit is player controlled
        if (_unit.object_index == oBattleUnitPC) {
            // compile the action menu
            var _menuOptions = [];
            var _subMenus = {};
            
            var _actionList = _unit.actions;
            
            for(var i = 0; i < array_length(_actionList); i++) {
                var _action = _actionList[i];
                var _available = true; // later we'll check mp cost here...
                var _nameAndCount = _action.name; // TODO: later we'll modify the name to include the item count, if the action is an item
                if (_action.subMenu == -1) {
                    array_push(_menuOptions, [_nameAndCount, MenuSelectAction, [_unit, _action], _available]);
                } else {
                    // create or add to a submenu
                    if (is_undefined(_subMenus[$ _action.subMenu])) {
                        variable_struct_set(_subMenus, _action.subMenu, [[_nameAndCount, MenuSelectAction, [_unit, _action], _available]]);
                    } else {
                        array_push(_subMenus[$ _action.subMenu], [_nameAndCount, MenuSelectAction, [_unit, _action], _available]);
                    }
                }
                
                // turn sub menu struct back to array to add
                var _subMenusArray = variable_struct_get_names(_subMenus); // like JavaScript Object.keys
                for (var i = 0; i < array_length(_subMenusArray); i++) {
                    // TODO: sort submenu if needed here
                    
                    // add back option at the end of each submenu
                    array_push(_subMenus[$ _subMenusArray[i]], ["Back", MenuGoBack, -1, true]);
                    
                    // add submenu into main menu
                    array_push(_menuOptions, [_subMenusArray[i], SubMenu, [_subMenus[$ _subMenusArray[i]]], true]);
                }
            }
            
            Menu(x+10, y+110, _menuOptions, , 74, 60); // GMS allowing no parameters here is weird to skip a function call
        } else {
            // if unit is AI controlled
            var _enemyAction = _unit.AIscript();
            if (_enemyAction != -1) {
                BeginAction(_unit.id, _enemyAction[0], _enemyAction[1]);
            }
        }
    }
}

function BeginAction(_user, _action, _targets) {
    currentUser = _user;
    currentAction = _action;
    currentTargets = _targets;
    
    if (!is_array(currentTargets)) {
        currentTargets = [currentTargets];
    }
    battleWaitTimeRemaining = battleWaitTimeFrames;
    with (_user) {
        acting = true;
        // play user animation if it is defined for that action, and that user
        if ((!is_undefined(_action[$ "userAnimation"])) && (!is_undefined(_user.sprites[$ _action.userAnimation]))) {
            sprite_index = sprites[$ _action.userAnimation];
            image_index = 0;
        }
    }
    battleState = BattleStatePerformAction;
}

function BattleStatePerformAction() {
    // if animation, etc. is still playing
    if (currentUser.acting) {
        // when it ends, perform action effect if it exists
        if (currentUser.image_index >= currentUser.image_number-1) {
            with (currentUser) {
                sprite_index = sprites.idle;
                image_index = 0;
                acting = false;
            }
            
            if (variable_struct_exists(currentAction, "effectSprite")) {
                if ((currentAction.effectOnTarget == MODE.ALWAYS) || ((currentAction.effectOnTarget == MODE.VARIES) && (array_length(currentTargets) <= 1))) {
                    for (var i = 0; i < array_length(currentTargets); i++) {
                        instance_create_depth(currentTargets[i].x, currentTargets[i].y, currentTargets[i].depth-1, oBattleEffect, { sprite_index: currentAction.effectSprite });
                    }
                } else {
                    // play it at 0,0
                    var _effectSprite = currentAction.effectSprite;
                    if (variable_struct_exists(currentAction, "effectSpriteNoTarget")) {
                        _effectSprite = currentAction.effectSpriteNoTarget;
                    }
                    instance_create_depth(x, y, depth-100, oBattleEffect, { sprite_index: _effectSprite });
                }
            }
            currentAction.func(currentUser, currentTargets);
        }
    } else {
        // wait for delay and then end the turn
        if (!instance_exists(oBattleEffect)) {
            if (!instance_exists(oBattleEffect)) {
                battleWaitTimeRemaining--;
                if (battleWaitTimeRemaining == 0) {
                    battleState = BattleStateVictoryCheck;
                }
            }
        }
    }
}

function BattleStateVictoryCheck() {
    battleState = BattleStateTurnProgression;
}

function BattleStateTurnProgression() {
    turnCount++;
    turn++;
    
    // loop turns
    if (turn > array_length(unitTurnOrder) - 1) {
        turn = 0;
        roundCount++;
    }
    battleState = BattleStateSelectionAction;
}

battleState = BattleStateSelectionAction;