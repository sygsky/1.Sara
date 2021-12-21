//
// Action script shows near targets for deiggnated unit
//
// Parameters: 
// _range (optional): radious of search zone in meters, default is 50
//
// call example: _unit action ["Show targets", "showtargets.sqf", [30]]; // print ll екпуе шт zone of 30 meters
//
private ["_unit", "_range", "_objlist" ];

_unit = _this select 0;
_this = _this select 3;

_range = if (count _this > 0) then {_this select 0} else {50};
player globalChat format[ "neartargets.sqf init: unit %1, range  %2", _unit, _range ];
_objlist = _unit nearTargets _range;

hint localize format[ "neartargets.sqf: %1->%2",count _objlist, _objlist ];
player groupChat format[ "neartargets.sqf: %1->%2",count _objlist, _objlist ];
