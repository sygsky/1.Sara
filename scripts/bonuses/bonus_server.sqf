/*
	author: Sygsky

	description: this code checks if prize vehicle is not dead and not on base.
	As if it is opposite, vehicle is removed from the list and publishd over network;

	returns: nothing
*/

#include "bonus_def.sqf"

player groupChat "+++ bonus_server started";

while {true} do {
	_remove_marker = false;
	for "_i" from 1 to ((count bonus_markers_array) - 1) do {
		_x = bonus_markers_array select _i;
		// check if vehicle is dead
		if (!alive _x) then {
			_remove_marker = true;
			bonus_markers_array set [_i, "RM_ME"];
		} else {
			// check vehicle is on base
			if ( [ getPos _veh, d_base_array ] call SYG_pointInRect) exitWith {
				// TODO: assign vehicle to be prize one in ordinal way
				_remove_marker = true;
				bonus_markers_array set [_i, "RM_ME"];
			};
		};
		sleep 0.1;
	};
	if (_remove_marker) then {
		hint localize "+++ bonus_server: some bonus vehicle found to be dead, remove	 it from the markered list ...";
		bonus_markers_array call SYG_clearArray;
		// update glocbal array
		bonus_markers_array set [0, time];
		publicVariable "bonus_markers_array";
	};
	sleep DELAY_STD;
};


