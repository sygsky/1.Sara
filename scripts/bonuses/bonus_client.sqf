/*
	1.Sara/scripts/bonuses/bonus_client.sqf: draws and control all markers on client
	author: Sygsky
	description: none
	returns: nothing
*/

#include "bonus_def.sqf"

private ["_bonus_markers", "_bonus_array", "_delay","_i","_veh","_mrk"];

while {isNil "bonus_markers_array"} do {sleep DELAY_WHILE_NIL};
player groupChat "+++ bonus_client started";
// markers for each markerd bouns vehicle
_bonus_markers = [];
_bonus_array   = [0];

//
// reset bonus markers system from the scratch
//
_reset_params = {
	private ["_veh","_mrk", "_i","_x"];
	_bonus_array = + bonus_markers_array; // copy array
	hint localize format["+++ bonus_client.sqf: list updated, draw new %1 markers", count _bonus_array ];
	//  remove all available markers
	{ deleteMarkerLocal _x; sleep 0.1; } forEach _bonus_markers;
	_bonus_markers resize ((count _bonus_array) - 1);
	for "_i" from 1 to ((count _bonus_array) - 1) do {
		_veh = _bonus_array select (_i);
		_mrk = createMarkerLocal [format["_marker_veh_%1", _i], _veh];
		_mrk setMarkerColorLocal "ColorGreen";
		_mrk setMarkerTypeLocal "DOT"; // TODO: set marker type according to the vehicle type
		_mrk setMarkerSizeLocal [0.5, 0.5];
		_bonus_markers set [_i - 1, _mrk];
		sleep 0.1;
	};
};

//
// eternal loop to redraw moved markers
//
hint localize "+++  : main loop started";
_sleep = DELAY_SHORT;
while { true } do {
	_dead_cnt = 0;
	_moved = false;
	if ((_bonus_array select 0) != (bonus_markers_array select 0)) then { // timestamp changed, reset all
		// global array changed, get it to the internal buffer
		hint localize format["+++ bonus_client: marker list changed  %1 => %2", (_bonus_array select 0), (bonus_markers_array select 0)];
		call _reset_params;
		_sleep = DELAY_SHORT;
	} else {
		// re-draws moved markers, 0-based item is the time-stamp, not markered vehicle
		_dead_cnt = 0;
		for "_i" from 1 to (count _bonus_array) -1 do {
			_veh = _bonus_array select _i;
			if (alive _veh) then{
				_mrk = _bonus_markers select (_i - 1);
				hint localize format["+++ bonus_client: %1 moved %2",_mrk, round((markerPos _mrk) distance _veh)];
				_dist = (markerPos _mrk) distance _veh;
				if ( _dist  > 1 ) then {
					if ( _dist > DIST_TO_REDRAW) then {
						_moved = true;
						_sleep = DELAY_SHORT;
					};
					_mrk setMarkerPosLocal (getPos _veh);
					sleep 0.05;
				};  // mark  moved state
			} else {_dead_cnt = _dead_cnt + 1;};
		};
	};
	if (!_moved) then { _sleep = (_sleep + DELAY_SHORT) min DELAY_STD };
	_str = if ( _moved ) then { "veh[s] moved"} else {"no veh[s] moved" };
	hint localize format["+++ bonus_client: vehs dead %1, %2, sleep %3", _dead_cnt, _str, _sleep];
	sleep _sleep;
};