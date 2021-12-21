// by Sygsky, scripts\tree_bb_check.sqf to test vegetation bounding boxes (exist or not at all)
//
//  Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//    target (_this select 0): Object - the object which the action is assigned to
//    caller (_this select 1): Object - the unit that activated the action
//    ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//    arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
//
//private [""];

_arr = nearestObjects [ getPos player, [], 15];
if (count _arr == 0) exitWith { player groupChat "--- No objects in radius 5 meters found" };
_veg = [];
{
	if (typeOf _x == "") then {_veg set [count _veg, _x]};
} forEach _arr;

if (count _vag == 0) exitWith { player groupChat"--- no any vegetation found in radius 5 meters"};
player groupChat format["+++ Parse %1 vegetaion items of %2", count _veg, count _arr];

_cnt = 1;
{
	_bb =  boundingBox _x;
	_rad = sizeOf typeOf _x;
	_msg = format["%1: ""%2"", %3, Height %4 m",
	_cnt call SYG_twoDigsNumberSpace,
	format["%1",_x],
	typeOf _x,
//	(((_bb select 1) select 0) - ((_bb select 0) select 0)) *
//	(((_bb select 1) select 1) -( (_bb select 0) select 1)) *
	_x call SYG_getObjectHeight
	];
	hint localize _msg;
	player groupChat _msg;
	_cnt = _cnt + 1;
} forEach _veg;