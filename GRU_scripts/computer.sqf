/*
	author: Sygsky
	description: none
	returns: nothing
*/

player groupChat "Эмуляция меню компьютера ГРУ";

/**
 * Retuns the angle between axe of computer monitor and direction to the any unit
 *
 * call: _angle = [_comp, _unit] call SYG_angleToComp
 */
SYG_angleToComp = {
    _comp = _this select 0;
    _unit = _this select 1;

    _dir  = [_comp, _unit] call XfDirToObj; // direction to player
    _dir1 = getDir _comp; // dir of comp (perpedicular to system block from left side if look from forehead)
    _dir2 = _dir1 - 65; // direction of monitor
    round(abs(_dir2 - _dir))
};
/*
_dev  = if ( _dir <= _dir2) then { _dir2 - _dir } else{ (_dir  + (360 - _dir2))  mod 360};
if ( _dev > 180 ) then {_dev = 360 - _dev;};
*/

_str = format[ "computer.sqf: get intel task -> pl angle to screen is %1", [_this select 0, _this select 1] call SYG_angleToComp];

hint localize _str;
player groupChat _str;
