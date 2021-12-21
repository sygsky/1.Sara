/*
	author: Sygsky
	description: none
	returns: nothing
*/

_list = nearestObjects [player, ["Car"], 10];
if (count _list == 0) exitWith {"No cars nearby 10 m"};
_obj = _list select 0;

_obj setDamage 1;
_obj setDamage 0;
//_obj setDamage 1;

player groupChat format["Vec. %1 wrecked", typeOf _obj];