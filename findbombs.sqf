private [ "_unit", "_dist", "_objlist", "_mlist", "_wlist","_bomb" ];

#define ROUND2(val) (floor((val)*100.0)/100.0)
#define ROUND4(val) (floor((val)*10000.0)/10000.0)
#define ROUND0(val) (round(val))

if (isNil "SYG_PIPEBOMB_HOLDER_NAME" ) then
{
	SYG_PIPEBOMB_HOLDER_NAME = "WeaponHolder";
};

_unit = _this select 0;
_this = _this select 3;

if ( count _this > 0 ) then { _dist = _this select 0;} else {_dist = 20;};
player globalChat format[ "findbombs.sqf: dist %1", _dist];


_objlist = nearestObjects [ _unit, [ /* SYG_PIPEBOMB_HOLDER_NAME, "PipeBomb" */ ], _dist];
_cnt =  count _objlist;
if ( _cnt > 0 ) then
{
	for "_i" from 0 to _cnt - 1 do
	{
		_obj = _objlist select _i;
		if ! (_obj isKindOf SYG_PIPEBOMB_HOLDER_NAME OR _obj isKindOf "PipeBomb") then { _objlist set [_i,"RM_ME"]};
	};

	_objlist = _objlist - ["RM_ME"];
	if ( (count _objlist) > 0 ) then 
	{
		_idx = 0;
		player globalChat format[ "At radius %3 found: obj %1, WeHo/PiBo %2", _cnt, count _objlist, _dist ];
		{
			private ["_z0","_z1", "_z2"];
			_z0 = getPos _x select 2;
			_z1 = (getPosASL _x) select 2;
			_z2 = (_x modelToWorld [0,0,0]) select 2;
			player globalChat format[ "%1: %2 at rad %3: Z: %4, ASLZ:%5, M2WZ:%6", _idx, typeOf _x, ROUND2(player distance _x), ROUND4(_z0), ROUND4(_z1), ROUND4(_z2)];
			_idx = _idx + 1;
		} forEach _objlist;
	}
	else
	{
		player globalChat format[ "No any 'WeHo/PiBo' found at radious %1", _dist];
	};
}
else
{
	player globalChat format[ "No any 'WeHo/PiBo' found at radious %1", _dist];
};

if ( true ) exitWith {_cnt};