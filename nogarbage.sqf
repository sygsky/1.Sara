//
// Action script removes all possible garbage items laying on grass
//
// Parameters:
// _pos: center of search zone
// _radious (optional): radious of search zone in meters, default is 50
// _debug (optional): debug message output mode. Default is false
//
// call example: _unit action ["Remove garbage", "nogarbage.sqf", [30]]; // remove garbage 30 meters zone around
//
private ["_unit", "_dist", "_objlist", "_debug", "_cnt"];

if (isNil "SYG_PIPEBOMB_HOLDER_NAME" ) then
{
	SYG_PIPEBOMB_HOLDER_NAME = "WeaponHolder";

	/**
	 * call:
	 *      _cnt = [_pos/_obj, _dist ] call SYG_removeGarbage
	 */
	SYG_removeGarbage = {
		private ["_pos","_dist","_objlist","_cnt","_i"];
		_pos = _this select 0;
		//if ( typeName _pos != "ARRAY" ) then {_pos = position _pos};
		_dist = _this select 1;
		//_cls = if ( count _this > 2) then {_this select 2} else {[]};
		//_rm_height = if ( count _this > 3) then {_this select 3} else {0.7}; // max height to get as garbagex
		_objlist = nearestObjects [ _pos, [], _dist];
		_cnt =  count _objlist;
		if (_cnt > 0 ) then
		{
			for "_i" from 0 to _cnt - 1 do
			{
				_obj = _objlist select _i;
				if ! (_obj isKindOf SYG_PIPEBOMB_HOLDER_NAME OR _obj isKindOf "PipeBomb") then { _objlist set [_i,"RM_ME"]};
			};
			sleep 0.1;
			_objlist = _objlist - ["RM_ME"];
		};

		_cnt = 0;
		{
			if ( ((_x modelToWorld [0,0,0]) select 2) < 0.7 ) then // delete only holders laying on the grass with modelToWorld Z < 0.7
			{	
				deleteVehicle _x;
				_cnt = _cnt + 1;
				sleep 0.05;
			};
		} forEach _objlist;
		_objlist = nil;
		_cnt
	};
	
//	SYG_removeGarbage = { deleteVehicle _this};
};

_unit = _this select 0;
_this = _this select 3;

_dist = if ( count _this > 0 ) then { _this select 0;} else {50};
_debug = if ( count _this > 1 ) then { _this select 1;} else {false};

player globalChat format[ "nogarbage.sqf init: dist %1, debug %2", _dist, _debug];

_cnt = [_unit,_dist] call SYG_removeGarbage;

/* _objlist = nearestObjects [ _unit, [ ], _dist]; // [SYG_PIPEBOMB_HOLDER_NAME, "PipeBomb"]
_cnt =  count _objlist;
if (_cnt > 0 ) then
{
	for "_i" from 0 to _cnt - 1 do
	{
		_obj = _objlist select _i;
		if ! (_obj isKindOf SYG_PIPEBOMB_HOLDER_NAME OR _obj isKindOf "PipeBomb") then { _objlist set [_i,"RM_ME"]};
	};
	_objlist = _objlist - ["RM_ME"];
};

if ( _debug ) then 
{
	player globalChat format[ "nogarbage.sqf: searching WeHi/PIBo at radius %1, found %2, %3", _dist, count _objlist, if (count _objlist == 0) then {"nothing to remove"} else {"removing"}];
};
_cnt = 0;
{
	if ( ((_x modelToWorld [0,0,0]) select 2) < 0.7 ) then // delete only holders laying on the grass with modelToWorld Z < 0.7
	{	
		deleteVehicle _x;
		_cnt = _cnt + 1;
		sleep 0.05;
	};
} forEach _objlist;
 */
if ( true ) exitWith { if (_debug) then {player globalChat format[ "nogarbage.sqf: removed garbage items %1", _cnt]}; _cnt};