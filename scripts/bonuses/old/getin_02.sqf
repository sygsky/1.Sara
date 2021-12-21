/*
    scripts\bonuses\getin_1.sqf : initial getin event for light version of bunus vehicle creation on island territory not the base only
	author: Sygsky

	Triggered when any of units enters the object (only useful when the event handler is assigned to a vehicle).
	It does not trigger upon a change of positions within the same vehicle.
	It also is not triggered by the moveInX commands.

        Global. Works only on server.

        Passed array: [vehicle, position, unit]

        vehicle: Object - Vehicle the event handler is assigned to
        position: String - Can be either "driver", "gunner", "commander" or "cargo"
        unit: Object - Unit that entered the vehicle

	returns: nothing
                                    0               1               2               3               4
    "bonus" variable format: ["player_name", _score_assigned, _last_enter_time, _marker_name, _marker_type]
    marker array format: "marker_name"

*/

#include "x_setup.sqf"
#include "x_macros.sqf"

#include "bonus_def.sqf"

	//++++++++++++++++++++++++++++++++++++++++++++++
	//++++++++++++++++++++++++++++++++++++++++++++++ methods
	//++++++++++++++++++++++++++++++++++++++++++++++

	// remove marker if it is visible
	_clearMarker = {
		if (typeName _this == "STRING") exitWith {
			if( (getMarkerType _this) == "" ) exitWith {}; // no such marker, do nothing
			deleteMarker _this // clear designated marker
		};
		if (typeName _this == "OBJECT") exitWith {
			private ["_bonus"];
			_bonus = _this getVariable "bonus";
			if (isNil "_bonus") exitWith {};
			BONUS_MARKER_NAME call _clearMarker;
		};
	};

	// draw marker: _name|_veh call _showMarker;
	_showMarker = {
		if (typeName _this == "STRING") exitWith {
			if( (getMarkerType _this) != "" ) exitWith {
				_this setMarkerPos (getPos _veh);
			}; // already drawn marker
			createMarker [_this, getPos _veh];
		};
		if (typeName _this == "OBJECT") exitWith {
			private ["_bonus"];
			_bonus = _this getVariable "bonus";
			if (isNil "_bonus") exitWith {};
			BONUS_MARKER_NAME call _clearMarker;
		};
	};

	// adds bonus info to the vehicle
	_setMarkerName = {
		private ["_marker_type","_time","_marker_name","_bonus"];
		_marker_type = _veh call SYG_getVehicleMarkerType;
		_time = round(time);
		// Create marker with unique name: userName|vehicleType|timeRounded
		_marker_name = format[ "%1|%2|%3", _player, typeOf _veh, _time ];
		// bonus consists of: [bonus_owner_name, score_assigned, time of assignment, marker_name, marker_type_to_create]
		// #define BONUS_NAME (_bonus select 0)
		_bonus = [ _player, 0, time, _marker_name, _marker_type ];
		_veh setVariable ["bonus", _bonus];
	};

	// removes all standard events from vehicle
	_removeAllStdEvents = {
		if (typeName _this != "OBJECT") exitWith {};
		_this removeAllEventHandlers "getin";
		_this removeAllEventHandlers "getout";
		_this removeAllEventHandlers "killed";
		#ifdef __AI__
        	#ifdef __NO_AI_IN_PLANE__
            // check for any pilot or driver to be AI and get them out if yes
            if ( (_veh isKindOf "Plane") ) then { _veh addEventHandler ["getin", {_this execVM  "scripts\SYG_eventPlaneGetIn.sqf"}]; };
        	#endif
        #endif
	};

	_sendBonusRewardToUser = {
		_this call _sendMsgToUser;
		player addScore 4;
	};

	_sendMsgToUser =  {
		player groupChat format _this;
		hint localize format _this;
	};

	//+++++++++++++++++
	//+++ code body +++
	//+++++++++++++++++
	_veh = _this select 0;
	if ( isNull _veh ) exitWith { hint localize "--- getin_2.sqf: isNull vehicle detected, exit script"; }; // that is an empty call
__FILE__
	_unit = _this select 2;
	if ( isNull _unit ) exitWith {hint localize "--- getin_2.sqf: isNull unit detected, exit script";};

	_veh call _clearMarker; // remove marker just in case

	// find player who entered vehicle
	// TODO: detect if AI belongs to the some player
	_player = "";
	if( !isPlayer _unit ) then { } else { _player = name _unit; };
	if ( _player == "" ) exitWith { hint localize format[ "--- getin_1.sqf: not player entered into %1, exit script", typeOf _veh ] };

	// 1. remove this getin event handler
	_veh call _removeAllStdEvents;

	// check if vehicle is on base during 1st entering
	_is_onBase = [ getPos _veh, d_base_array ] call SYG_pointInRect ; // is vehicle on base (true) or not (false)
	if (_is_onBase) exitWith {
		// some player/his AI entered vehicle first time and it is on base!!
		// remove marker and remove bonus info only if recovery server is alive
		if (isNull d_wreck_repair_fac) exitwith {
			_veh setVariable ["RECOVERABLE", true]; // allow to restore vehicle
			// TODO: add restorable vehicle "killed" event
			[["STR_SYS_1232", typeOf _veh]] call _sendMsgToUser; // %1 added to the recoverable vehicles list
		};
		// wait until wreck service is alive
		[["STR_SYS_1233", typeOf _veh]] call _sendMsgToUser;  // Restore service to put %1 on the list of devices to be restored
	};

	// 2. set bonus
	call _setMarkerName;
	// 3. reward player
//	if ( _ai_getin ) exitWith{ [localize "STR_SYS_1235", typeOf _veh, 4] call _sendBonusRewardToUser;};
	[localize "STR_SYS_1234", typeOf _veh, 4] call _sendBonusRewardToUser;

	// somebody entered vehicle not on the base first time
	// test if it is empty vehicle (no any crew)
//	if ( ( { alive _x } count ( crew _veh ) ) > 0 ) exitWith { }; // not empty vehicle does nothing

	// vehicle was empty before entering the player
//	if ( !isNil "_bonus" ) exitWith { BONUS_MARKER_NAME call _clearMarker; }; // clear marker in any case
