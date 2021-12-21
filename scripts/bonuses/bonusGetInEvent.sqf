/*
	scripts\bonuses\bonusGetInEvent.sqf
	author: Sygsky
	description: none

	GETIN event params:
	        Global. Works only on server.
            Passed array: [vehicle, position, unit]

            vehicle: Object - Vehicle the event handler is assigned to
            position: String - Can be either "driver", "gunner", "commander" or "cargo"
            unit: Object - Unit that entered the vehicle

	GETOUT params:

	        Triggered when a unit gets out from the object, works the same way as GetIn.
            Global.
            Passed array: [vehicle, position, unit]

            vehicle: Object - Vehicle the event handler is assigned to
            position: String - Can be either "driver", "gunner", "commander" or "cargo"
            unit: Object - Unit that entered the vehicle

	returns: nothing
*/

if (side (_this select 2) != d_side_player) exitWith {
	hint localize format["--- bonusGetInEvent.sqf: somebody not on your side (%1) visited bonus vehicle near settlement %2. Exit.", side (_this select 2), "<any settlement>"];
};

if (!isPLayer (_this select 2)) exitWith { // TODO
	hint localize format["--- bonusGetInEvent.sqf: not player (%1) visited bonus vehicle near settlement %2. Exit.", typeOf (_this select 2), "<any settlement>"];
};

_veh = _this select 0;
// now remove getin event as it can be called only 1 time
_veh removeEventHandler ["getin", 0];

if ( _veh in bonus_markers_array) exitWith { // TODO
	hint localize format["+++ Vehicle %1 visited by ""%2"" as %3 near %4 already is marked known. Exit.", typeOf (_this select 0), name (_this select 2), _this select 1,"<any settlement>", _this select 1];
};

// add vehicle to the players to the marker vehicles array
// array usd only for newplayers
// [ "bonus_veh", _sub_command, player, _vehicle ]
// add new found vehicle
bonus_markers_array set [ count bonus_markers_array, _this select 0 ];
// change timestamp to flag array change
bonus_markers_array set [ 0, time];
publicVariable "bonus_markers_array";

// try to remove Inspect action menu
_id = _veh getVariable "INSPECT_ACTION_ID";
if (!isNil "_id") then {
	_veh removeAction _id;
	_str  = "+++ Action ""Inspect"" is removed";
	player groupChat  _str;
	hint localize _str;
	_veh setVariable ["INSPECT_ACTION_ID", nil];
} else {
	_str = "--- Action id for ""Inspect"" not found!!!";
	player groupChat _str;
};

// send info to the player[s]
// TODO: send info to all players
_str = format["+++ bonusGetIn: Vehicle %1 visited by ""%2"" as %3 near %4 and put into markered list (%5)",
	typeOf (_this select 0),
	name (_this select 2),
	_this select 1,
	"<any settlement>",
	(count bonus_markers_array) - 1];

player groupChat _str;
hint localize _str;

// Send message to all users and scores to the enterer.