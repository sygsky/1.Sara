// computer.sqf, by Sygsky at 26-NOV-2015

#include "x_setup.sqf"

_comp = _this select 0;
_unit = _this select 1;

#ifdef __LOCAL_DEBUG__
// direction from one object/position to another
// parameters: object1 or position1, object2 or position2 
// example: _dir = [pos1, obj2] call XfDirToObj;
//         _dir = [tank1, pos2] call XfDirToObj;
XfDirToObj = {
	private ["_o1","_o2""_deg"];
	_o1 = _this select 0;_o2 = _this select 1;
	if ( typeName _o1 != "ARRAY" ) then { _o1 = position _o1};
	if ( typeName _o2 != "ARRAY" ) then { _o2 = position _o2};
	_deg = ((_o2 select 0) - (_o1 select 0)) atan2 ((_o2 select 1) - (_o1 select 1));
	if (_deg < 0) then {_deg = _deg + 360};
	_deg
};
#endif

_dir = round([_comp, _unit] call XfDirToObj);
_dir1 = round(getDir _comp);

#ifdef __LOCAL_DEBUG__
hint localize format[ "computer.sqf: get intel task: dir to player %1, comp dir %2", _dir, _dir1 ];
//player groupChat localize format["get intel task: dir to player %1, comp dir %2", round (_dir), round(getDir _comp)];
#endif

// check direction
_dir = _dir1 - _dir;
_str = if ( _dir < 4 OR _dir > 104 ) then {"STR_COMP_4"} else // bad access angle, use computer from front side
{
/* 	{
		hint localize format["computer.sqf: %1 is %2", _x, _x call SYG_weaponClassx];
	} forEach (weapons _unit);
 */	// check weapons
	_weapons = weapons _unit;
	if (format["%1",_unit getVariable "ACE_weapononback"] != "<null>") then
	{
		_wob = _unit getVariable "ACE_weapononback";
//		hint localize format["computer.sqf: weapon check for %1, type %2", _wob, _wob call SYG_weaponClass];
		if (_wob != "" && isClass (configFile >> "cfgWeapons" >> _wob)) then 
		{
			_weapons = _weapons + [_wob];
		};
	};
/*  	{
		hint localize format["computer.sqf: weapon check for %1, type %2", _x, _x call SYG_weaponClass];
	}
	forEach weapons _unit;
 */	
	if ( _unit call SYG_hasOnlyPistol ) then 
	{
		if ( isNil "SYG_intelTasks" ) then { "STR_COMP_5" } // no connection
		else 
		{ 
			if ( (count SYG_intelTasks) == 0 ) then { "STR_COMP_2" } else { "STR_COMP_6" } 
		}
	} else { "STR_COMP_3" }; // Not only pistol
};

localize "STR_COMP_1" hintC [
		composeText[ image "img\red_star_64x64.paa",lineBreak, localize _str, lineBreak, lineBreak, parseText("<t align='center'><t color='#ffff0000'>" + (localize "STR_COMP_0"))]
		//(localize _str) + "\n\n" + (localize "STR_COMP_0")
];

