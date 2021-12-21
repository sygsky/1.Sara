/*
	1.Sara/scripts/bonuses/bonus_veh_markers.sqf: draws and control all markers on client
	author: Sygsky
	description: none
	returns: nothing
*/

#include "bonus_def.sqf"

private ["_bonus_markers", "_bonus_array", "_delay","_i","_veh","_mrk"];

while {isNil "bonus_markers_array"} do {sleep DELAY_WHILE_NIL};

// markers for each markerd bouns vehicle
_bonus_markers = [];
_bonus_array   = [0];

//
// reset bonus markers system from the scratch
//
_reset_params = {
	_bonus_array = + bonus_markers_array; // copy array
	//  remove all available markers
	{ deleteMarkerLocal _x; sleep 0.1; } forEach _bonus_markers;
	_bonus_markers resize count (_bonus_array - 1);
	for "_i" from 1 to count (_bonus_array -1) do {
		_veh = _bonus_array select (_i);
		_mrk = createMarkerLocal [format["_marker_veh_%1", _i], _veh];
		_mrk setMarkerColorLocal "GREEN";
		_mrk setMarkerTypeLocal "DOT"; // TODO: set marker type according to the vehicle type
		_mrk setMarkerSizeLocal [0.5, 0.5];
		_bonus_markers set [count _bonus_markers, _mkr];
		sleep 0.1;
	};
	hint localize format["+++ bonus_veh_markers.sqf: udate to %d markers to redraw", count _bonus_markers];
};

//
// eternal loop to redraw moved markers
//
while { true } do {
	_sleep = DELAY_STD;
	if ((_bonus_markers select 0) != (bonus_markers_array select 0)) then { // timestamp changed, reset all
		// global array changed, get it to the internal buffer
		call _reset_params;
		_sleep = DELAY_SHORT;
	} else {
		// re-draws moved markers, 0-based item is the time-stamp, not markered vehicle
		for "_i" from 1 to count _bonus_array -1 do {
			_veh = _bonus_array select _i;
			if (alive _veh) then{
				_mrk = _bonus_markers select (_i - 1);
				if ( ((markerPos _mrk) distance _veh) > DIST_TO_REDRAW ) then {
					_mrk setMarkerPosLocal (getPos _veh);
					_sleep = DELAY_SHORT; // mark  moved state
				};
			};
		};
	};
	sleep _sleep;
};