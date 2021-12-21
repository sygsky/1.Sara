/*

	...

	author: Sygsky
	description: none
	returns: nothing
*/

_str = format["+++ Action called: %1", _this];
hint localize _str;

//
// Sends info to the enterer or his leader if enterer is not the player
//
_sendInfoToPlayer = {
//    hint localize format ["_sendInfoToPlayer: %1", _this];
    player groupChat _this;
    hint localize _this;
};

//
// Sends info in form of format script command ... array parameters
// parameters for format, e.g. ["STR_BONUS_1_1", typeOf _veh] // STR_BONUS_1_1,"Your squad has detected %1! The one who delivered the find to the base will receive points, and the car will be able to fully restore on the service."
//
_sendInfo = {
    if (typeName _this == "ARRAY") then { _this = format _this;  };
    _this call _sendInfoToPlayer;
};

// Creates sabotage stash

if (count _this == 0) exitWith {
	// add actions to the user menues
	hint localize "+++ Stash menu created";
	player groupChat "+++ Stash menu created";
    player addAction ["Create stash","scripts\sabstash\createStashMenus.sqf", "NEW"];
    stash_id = 0;
};

_town_descr = target_names select stash_id;
_stash_id = (stash_id + 1) % (count target_names); // bump to next. If out of count, set 0
_town_descr1 = target_names select _stash_id;
["+++ bump next target: town was %1[%2], changed to %3[%4]", _town_descr select 1, stash_id, _town_descr1 select 1, _stash_id]  call _sendInfo;
stash_id = _stash_id;

_town_rad = _town_descr select 2;
_cmd = "NEW"; // toUpper(_this select 3);

hint localize format[ "+++ create Stash params: %1", [ _town_descr select 0, _town_rad, _cmd ] ];

switch ( toUpper _cmd ) do {
    case "NEW": {
    	// create box
    	_code = compile (preprocessFileLineNumbers "scripts\sabstash\SYG_sabotage_stash.sqf");
        _box = [_town_descr select 0, _town_rad] call _code ;
        if (typeName _box != "OBJECT") exitWith {
        	_str = format["--- STASH is of bad type %1", _box];
        	hint localize _str;
        	player groupChat _str;
        };
        if (isNull _box) exitWith {
        	_str = "--- STASH is null";
        	hint localize _str;
        	player groupChat _str;
        };
        // teleport payer to the box
        player setPos (getPos _box);
        hint localize format["+++ SABOTAGE STASH created at %1", getPos _box];
        player groupChat format["+++teleport to %1", _town_descr select 1];
    };
    default {
    	_str = format["--- createStashMenus.sqf: unknown command ""%1""", _cmd];
    };
};

