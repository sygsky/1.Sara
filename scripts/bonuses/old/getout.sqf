/*
	scripts\bonuses\getout.sqf
	author: Sygsky
        Triggered when a unit gets out from the object, works the same way as GetIn.
        Global.
        Passed array: [vehicle, position, unit]

        vehicle: Object - Vehicle the event handler is assigned to
        position: String - Can be either "driver", "gunner", "commander" or "cargo"
        unit: Object - Unit that entered the vehicle

    returns: nothing
    "bonus" variable format: ["player_name", _score_assigned, _last_enter_time, _marker_name, _marker_type]

    Variants:
    1. Exit on base:
        1.1.1 Bonus exists: send score to owner, remove events and marker, exit
        1.1.2 On bonus: print infom,  remove events and marker, exit

    1.2 Bonus not assigned to the player : exit without action
        1.2.1 Vehicle still not empty: exit
        1.2.2
    2. Bonus not exists : exit without actions
*/

#include "x_setup.sqf"
#include "x_macros.sqf"
#include "bonus_def.sqf"

private ["_veh","_unit","_bonus","_bonus_name","_bonus"];

//
// Sends info to the enterer or his leader if enterer is not the player
//
_sendInfoToPlayer = {
    player groupChat _this;
    hint localize _this;
};

//
// Sends info in form of format script command ... array parameters
// parameters for format, e.g. ["STR_BONUS_1_1", typeOf _veh] // STR_BONUS_1_1,"Your squad has detected %1! The one who delivered the find to the base will receive points, and the car will be able to fully restore on the service."
//
_sendInfo = {
    (format _this) call _sendInfoToPlayer;
};
//+++++++++++++++++++++++++++++++++++
// remove all event handler assigned
// _veh call _removeEvents;
//----------------------------------
_removeEvents = {
	// remove all event handler assigned
	_this removeAllEventHandlers "getin";
	_this removeAllEventHandlers "getout";
	_this removeAllEventHandlers "killed";
    deleteMarker BONUS_MARKER_NAME; // remove marker in any case
    _this setVariable ["bonus", nil];
	hint localize "+++ Bonus veh getout event: remove all events";
};

_addRespawnEvents = {
	hint localize "+++ Bonus veh getout event: assign events for re-spawning";
};

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++ S t a r t   o f   r e a l   g e t o u t   c o d e ++++ +++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

_veh = _this select 0;
if(isNull _veh) exitWith {};

_unit = _this select 2;
if (isNull _unit) exitWith {
    (format["--- bonus_getout: unit is null, _this %1", _this]) call _sendInfoToPlayer;
};

if (side _unit != d_side_player) exitWith {
    format["*** bonus_getout: unknown unit %1 exited", typeOf _unit] call _sendInfoToPlayer;
};

_bonus = _veh getVariable "bonus";

//
// check to be on base
//
_vehIsEmpty = ( {(isPlayer _x) && (alive _x) } count (crew _veh) ) == 0; // human members of crew
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// "getout" on base
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if ( [ getPos _veh, d_base_array ] call SYG_pointInRect ) exitWith {
    if (isNil "_bonus") then {
    	// no bonus when on base (can't imaginate how it could be
//        _str = format[ "--- Vehicle %1 is on base, no bonus found", typeOf _veh];
//        _str call _sendInfoToPlayer;
        [localize  "STR_BONUS_3_1"] call _sendInfo; // "Not bad! Your squad delivered the vehicle to the base, and it got a chance to recover!"
    };
	_veh call _removeEvents;
	_veh call _addRespawnEvents;
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    get out not on base
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if ( _vehIsEmpty ) exitWith {
    // show corresponding marker after last man leave vehicle
    // Vehicle "bonus" variable format: [ name player", _score_assigned, _last_enter_time, _marker_name, _marker_type]
    _marker = createMarker [BONUS_MARKER_NAME, getPos _veh ];
    if ( _marker == "" ) then {
        _marker = BONUS_MARKER_NAME;
        _str = format["*** bonus_getout: marker %1 already exists!!!", _marker];
        _str call _sendInfoToPlayer;
    } else {
        _marker setMarkerType ( BONUS_MARKER_TYPE );
    };
    _marker setMarkerDir ( (getDir _veh) + 90 );
    sleep 0.5;
    _type =  getMarkerType _marker;
    format["+++ bonus_getout: created marker %1 at %2 (checked type is %3)", BONUS_MARKER_NAME, getPos _veh, _type] call _sendInfoToPlayer;
};

// vehicle still not empty, report and exit
format["+++ Vehicle still not empty, crew number is %1", _crew_cnt ] call _sendInfoToPlayer;

