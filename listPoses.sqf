/* listPoses.sqf
	author: Sygsky
	description: none
	returns: nothing
*/

private ["_bld","_cnt","_i","_str"];
//_bld = nearestBuilding player;
_bld = nearestObject [getPos player, "HouseBase"];
_cnt = _bld call SYG_housePosCount;

_str = " ";
for "_i" from 0 to _cnt - 1 do
{
    _pos = _bld buildingPos _i;
    //player groupChat format["pos %1",_pos];
    _str = _str + format["%1,", _pos select 2];
};

player groupChat format["%1(%2):%3", typeOf _bld, _cnt, _str ];