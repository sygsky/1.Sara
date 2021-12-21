/*
	author: Sygsky
	description: none
	returns: nothing
*/

_arr10 = nearestObjects [player, [], 10];
_cnt10 = { (typeOf _x) == ""} count _arr10;

_arr20 = nearestObjects [player, [], 20];
_cnt20 = { (typeOf _x) == ""} count _arr20;

_arr30 = nearestObjects [player, [], 30];
_cnt30 = { (typeOf _x) == ""} count  _arr30;

player groupChat format[ "Counts of trees: %1/%2 (10m), %3/%4 (20m), %5/%6 (30m)", _cnt10, count _arr10,  _cnt20, count _arr20, _cnt30, count _arr30 ];
