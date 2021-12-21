/*

Purpose: Have A1Z engage player

Preconditions:  A1Z (snake) spawn

Activator:  snake

Author:  Henderson

TO USE:

Save this file in C:\Documents and Settings\user\My Documents\VBS2\mpmissions\missionname\
Make an M1A1 and name it player
Make an AH1Z and name it snake
	- use the following initialization script for snake

	 call {player execVM "snake.sqf";}

_result = [_tank, _heli]  execVM "AirKiller.sqf";

Run like the dickens!

*/

if ( typeName _this != "ARRAY") exitWith {hint localize format["AirKiller expected array found %1", typeName _this]; false};
if ( count _this < 2) exitWith {hint localize format["AirKiller expected array size 2, found %1", count _this]; false};

_tank = _this select 0;
if ( typeName _tank != "OBJECT") exitWith {hint localize format["AirKiller expected 1ast param as ""LandVehicle"", found %1", typeName _tank]; false};
if ( ! (_tank isKindOf "LandVehicle") ) exitWith {hint localize format["AirKiller expected 1ast param as ""LandVehicle"", found %1", typeOf _tank]; false};
_heli = _this select 1;
if ( typeName _heli != "OBJECT") exitWith {hint localize format["AirKiller expected 1ast param as ""Air"", found %1", typeName _heli]; false};
if ( !(_heli isKindOf "Air") ) exitWith {hint localize format["AirKiller expected 1ast param as ""Air"", found %1", typeOf _heli]; false};

//Feedback on script start
hint "Snake Started!";
_heli flyInHeight 300;

_speedMode = speedMode _heli; // remember
_behaviour = behaviour _heli;
_combatMode = combatMode _heli;

player sideChat format["Heli: speed %1, behaviour %2, combatMode %3",_speedMode, _behaviour, _combatMode];

_heli setSpeedMode "FULL";
_heli setBehaviour "AWARE";
_heli setCombatMode "RED";

player sideChat format["WPS %1", waypoints _heli];
hint localize format["WPS %1", waypoints _heli];

_grp = group ((crew _heli) select 0);
[_grp, 1] setWaypointPosition [getPos _tank, 0];
_grp setSpeedMode "FULL";
_grp setBehaviour "COMBAT";

while {alive _tank && canMove _heli} do
{
	_heli doMove getPos _tank;
	_heli doTarget _tank;
	//hsnake selectWeapon "HellfireLauncher";
	_heli doFire _tank;

	sleep 2;
};
if ( !alive _tank ) then {
    if ( canMove _heli ) exitWith { hint "Snake killed player!"; true };
    hint "Snake not killed player!";
    true
}
else {
    hint "player no destroyed";
    false
};


