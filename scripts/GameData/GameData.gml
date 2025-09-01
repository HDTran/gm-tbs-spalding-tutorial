// action library
global.actionLibrary = {
    attack: {
        name: "Attack", 
        description: "{0} attacks!",
        subMenu: -1,
        targetRequired: true,
        targetEnemyByDefault: true,
        targetAll: MODE.NEVER,
        userAnimation: "attack",
        effectSprite: sAttackBonk,
        effectOnTarget: MODE.ALWAYS,
        func: function(_user, _targets) {
            // even if single target, use a single target in an array for _targets for simplicity of the function
            var _damage = ceil(_user.strength + random_range(-_user.strength * 0.25, _user.strength *0.25));
            BattleChangeHP(_targets[0], -_damage, 0);
        }
    }
}

enum MODE
{
    NEVER = 0,
    ALWAYS = 1,
    VARIES = 2
}

// party data
global.party = 
[
	{
		name: "Lulu",
		hp: 89,
		hpMax: 89,
		mp: 10,
		mpMax: 15,
		strength: 6,
		sprites : { idle: sLuluIdle, attack: sLuluAttack, defend: sLuluDefend, down: sLuluDown},
		actions : []
	}
	,
	{
		name: "Questy",
		hp: 18,
		hpMax: 44,
		mp: 20,
		mpMax: 30,
		strength: 4,
		sprites : { idle: sQuestyIdle, attack: sQuestyCast, cast: sQuestyCast, down: sQuestyDown},
		actions : []
	}
]

//Enemy Data
global.enemies =
{
	slimeG: 
	{
		name: "Slime",
		hp: 30,
		hpMax: 30,
		mp: 0,
		mpMax: 0,
		strength: 5,
		sprites: { idle: sSlime, attack: sSlimeAttack},
		actions: [global.actionLibrary.attack],
		xpValue : 15,
		AIscript : function()
		{
			// attack random party member
            var _action = actions[0]; // TODO: better to make sure to have the attack action before invoking it
            
            var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index) {
               return (_unit.hp > 0); 
            });
            var _target = _possibleTargets[irandom(array_length(_possibleTargets)-1)];
            
            // TODO: game will crash if there are no valid targets currently
            
            return [_action, _target];
		}
	}
	,
	bat: 
	{
		name: "Bat",
		hp: 15,
		hpMax: 15,
		mp: 0,
		mpMax: 0,
		strength: 4,
		sprites: { idle: sBat, attack: sBatAttack},
		actions: [global.actionLibrary.attack],
		xpValue : 18,
		AIscript : function()
		{
			// attack random party member
            var _action = actions[0]; // TODO: better to make sure to have the attack action before invoking it
            
            var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index) {
               return (_unit.hp > 0); 
            });
            var _target = _possibleTargets[irandom(array_length(_possibleTargets)-1)];
            
            // TODO: game will crash if there are no valid targets currently
            
            return [_action, _target];
		}
	}
}





