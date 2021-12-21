/*
	author: Sygsky
	description: none
	returns: nothing
*/

#define __EMPTY_LIST_INTERVAL__ 300
#define __STEP_INTERVAL__ 30
#define __MAX_OFFSET__ 5

private ["_x","_clean","_ind","_marker"];

_marker = "";

_mark_to_clean = {
	// remove this vehicle from the list as it is not markered
	_ind =  SYG_hidden_bonus_veh_list find _x;
	if ( _ind >= 0 ) then {
		SYG_hidden_bonus_veh_list set [ _ind, "RM_ME" ];
		_x setVariable ["MARKER_NAME", nil];
		deleteMarker _marker;
		_clean = true;
	};
};

while { true } do {
	          _clean = false;
	_assign_as_bonus = false;
	{
		if (true) then {

			// check if vehicle exists
			if (!alive _x) exitWith { call _mark_to_clean; };

			// check thya marker for the vehicle exists
			_marker = _x getVariable "MARKER_NAME";
			if (isNil "_marker") exitWith { call _mark_to_clean; };

			// check if vehicle already is on the base territory
			if ( [ getPos _veh, d_base_array ] call SYG_pointInRect ) exitWith {
			 	// vehicle is on base
			 	_assign_as_bonus = true;
				call _mark_to_clean;
			};

			// check if vehicle not moved from marker
			_dist = (getMarkerPos _marker) distance _x;
			_empty = {alive _x } count (crew _x);
			if ( (_dist > __MAX_OFFSET__) && _empty) then { _marker setMarkerPos (getPos _x); };
		};
		if (_assign_as_bonus) then {
			// TODO: assign behicle to be RESTORABLE, not ordinal one
			// ... add code here
		};
		sleep 0.05;
	} forEach SYG_hidden_bonus_veh_list;

	// to clear the array if the status flag is set
	if (_clean) then {
		SYG_hidden_bonus_veh_list call SYG_clearArrayB;
	};
	if (count SYG_hidden_bonus_veh_list == 0 )
		sleep __EMPTY_LIST_INTERVAL__;
	else
		sleep __STEP_INTERVAL__;
};
