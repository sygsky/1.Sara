/*
    scripts\bonuses\getin.sqf: now not used
	author: Sygsky

	Triggered when any of units enters the object (only useful when the event handler is assigned to a vehicle) first time only.
	After it getin event reassigned to getin2.sqf file
	It does not trigger upon a change of positions within the same vehicle.
	It also is not triggered by the moveInX commands.

        Global. Works only on server.

        Passed array: [vehicle, position, unit]

        vehicle: Object - Vehicle the event handler is assigned to
        position: String - Can be either "driver", "gunner", "commander" or "cargo"
        unit: Object - Unit that entered the vehicle

	returns: nothing
*/

#include "x_setup.sqf"
#include "x_macros.sqf"

	//+++ code body +++
	_veh = _this select 0;
	if ( isNull _veh ) exitWith {}; // that is an empty call
	_rec = _x getVariable "RECOVERABLE";
	if (!isNil "_rec") exitWith {
		// TODO: remove all events call _resetVehEvents;
		// TODO: add bonus events
		// TODO: print common message about end of this duty
	};

	_unit = _this select 2;
	if (isNull _unit) exitWith {};

	_marker_name = _veh getVariable "MARKER_NAME";
	// check if marker is not set before
	if (getMarkerType _marker_name == "") exitWith {
		// yes, this vehicle hasnt marker assigned
		// Create marker with unique name: userName|vehicleType|timeRounded
		if (isNil "SYG_hidden_bonus_veh_list" ) then {
			SYG_hidden_bonus_veh_list = [];
			[] execVM "scripts\bonuses\check_bonus_list.sqf";
		};
		if (!(_veh in SYG_hidden_bonus_veh_list)) exitWith {
			SYG_hidden_bonus_veh_list set [ count SYG_hidden_bonus_veh_list, _veh ];
			_marker_name = format[ "%1|%2|%3", _player, typeOf _veh, _time ];

			// create and show vehicle marker onto current position
			_marker_type = _veh call SYG_getVehicleMarkerType;
			_marker = createMarker [ _marker_name, getPos _veh];
			_veh setVariable ["MARKER_NAME", _marker];
			_marker setMarkerType  _marker_type;
			_marker setMarkerColor "ColorGreen";
			_marker setMarkerSize [.5,.5];
			// TODO: inform player about vehicle found, add some scores to him too
		};
	};

	// find player who entered vehicle
	if( !isPlayer _unit ) exitWith { };
	_player = name _unit;

	[localize "STR_SYS_1234", typeOf _veh, 4] call _sendBonusRewardToUser;

	_is_onBase = [ getPos _veh, d_base_array ] call SYG_pointInRect ; // is vehicle on base (true) or not (false)

	if (_is_onBase) exitWith {
		// remove marker and remove bonus info only if recovery server is alive
		if (isNull d_wreck_repair_fac) exitwith {
			_veh setVariable ["RECOVERABLE", nil];
			if (!isNil "_bonus") then {
				BONUS_MARKER_NAME call _clearMarker;
				_veh setVariable["bonus", nil];
				_veh call _resetVehEvents; // the vehicle is now recoverable
			};
			[["STR_SYS_1232", typeOf _veh]] call _sendMsgToUser; // %1 added to the recoverable vehicles list
		};
		// wait until wreck service is alive
		[["STR_SYS_1233", typeOf _veh]] call _sendMsgToUser;  // Restore service to put %1 on the list of devices to be restored
	};

	// somebody entered vehicle not on the base
	// test if it is empty vehicle (no any crew)
	if ( ( { alive _x } count ( crew _veh ) ) > 0 ) exitWith { }; // not empty vehicle does nothing

	// vehicle was empty before entering the player
	if ( !isNil "_bonus" ) exitWith { BONUS_MARKER_NAME call _clearMarker; }; // clear marker in any case
