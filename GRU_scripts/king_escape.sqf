// king_escape.sqf, created by Sygsky at 12-JUN-2016. Provides king (5th side mission) escape if enemy is detected in the hotel

// call:
//      _unit execVM "king_escape.sqf"
// TODO: organize the escape of the king to some safe place

#define SEARCH_DISTANCE 400
#define WAIT_BEFORE_ESCAPE 1

if (isNil "king")  exitWith {hint localize "--- GRU_scripts\king_escape.sqf: king is nil";};
if (! alive king) exitWith {hint localize "--- GRU_scripts\king_escape.sqf: king is null or dead";};

sleep WAIT_BEFORE_ESCAPE;

private ["_center","_nbarr","_ind","_house","_pos"];
_center = [10750,7363,0];
_nbarr = nearestObjects [_center, ["Land_hlaska","Land_bouda2_vnitrek"], SEARCH_DISTANCE];
if ( (count _nbarr) == 0) exitWith {hint localize format["--- king_escape.sqf: no building(s) %1 in range of %2 m. near %3",["Land_hlaska","Land_bouda2_vnitrekw"], SEARCH_DISTANCE, _center]};
_ind = floor random (count _nbarr);
_house = _nbarr select _ind;
_pos = [_house, "RANDOM", king] call SYG_teleportToHouse;
hint localize format["king_escape.sqf: king teleported to building %1 at pos %2", typeOf _house, _pos];
if (local king) then 
{
	player groupChat format["king_escape.sqf: king teleported to building %1 at pos %2", typeOf _house, _pos]
};
//player groupChat format["_hide_king: king teleported to house type %1 at pos %2", typeOf _house, _pos];
