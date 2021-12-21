// by Sygsky
// script to restore vehicles from designated list
// independentry on their type and position
// restore delay may be user-defined too
// Example:
// [moto1, ... ,motoN] execVM "motorespawn.sqf";
//
// Where motoN - reference to device with position to keep it here
//
#include "x_macros.sqf"

private ["_motoarr", "_mainCnt", "_moto", "_timeout", "_pos", "_pos1", "_type", "_nobj", "_driver_near"];

if (!isServer) exitWith{};

// comment next line to not create debug messages
#define __DEBUG__

// 5 mins timeout will be good
#define RESTORE_DELAY_NORMAL 420
#define RESTORE_DELAY_SHORT 30
#define CYCLE_DELAY 15
#define TIMEOUT_ZERO 0
#define MOTO_ON_PLACE_DIST 3
#define DRIVER_NEAR_DIST 10

// offsets for vehicle status array items
#define MOTO_ITSELF 0
#define MOTO_ORIG_POS 1
#define MOTO_ORIG_DIR 2
#define MOTO_TIMEOUT 3

#define inc(val) (val=val+1)
#define TIMEOUT(addval) (time+(addval))

_motoarr = []; // create array of vehicles to return to original position after some delay
sleep 2;
{
//	_motoarr = _motoarr + [[_x, getPos _x, direction _x, TIMEOUT_ZERO]];
	_pos = getPos _x;
	_pos set[2,0]; // zero Z coordinate
	_x setPos _pos;
	sleep 0.5;
	_motoarr = _motoarr + [[_x, getPos _x, getDir _x, TIMEOUT_ZERO]];
} forEach _this; // list all motocyrcles/automobiles
#ifdef __DEBUG__
	hint localize format["motorespawn.sqf: initial arr %1", _motoarr];
#endif			


sleep CYCLE_DELAY;
//_mainCnt = 1;
while {true} do {

	if (X_MP AND ((call XPlayersNumber) == 0) ) then 
	{
		waitUntil {sleep (25.012 + random 1);(call XPlayersNumber) > 0};
	};

	sleep CYCLE_DELAY; // main cycle time-out

	//  forEach _motoarr;
	{ 
		_moto = _x select MOTO_ITSELF;
		_timeout = _x select MOTO_TIMEOUT;
		_pos = _x select MOTO_ORIG_POS;
		
		_pos1 = getPos _moto;
		if ( _timeout == TIMEOUT_ZERO ) then
		{
			_pos1 set [2,0]; // zero Z coordinate
			if ( NOT ((canMove _moto) AND ((fuel _moto) > 0.2) AND ( ( _pos1 distance _pos) < MOTO_ON_PLACE_DIST) ) ) then
			{
				if ((count (crew _moto)) == 0) then
				{
					if ( (canMove _moto) AND ((fuel _moto) > 0.2) ) then  {_x set [MOTO_TIMEOUT, TIMEOUT(RESTORE_DELAY_NORMAL)]}
					else {_x set [MOTO_TIMEOUT, TIMEOUT(RESTORE_DELAY_SHORT)]};
#ifdef __DEBUG__
					hint localize format["motorespawn.sqf: time %1, %2 marked for respawn. CanMove %3, shift %4, pos %5", round(time), _moto, canMove _moto, ( _pos1 distance _pos), _pos1];
#endif			
				};
			};
		}
		else // time-out was already set
		{
			if ( time > _timeout) then 
			{
				_nobj = nearestObject [ _pos1, "CAManBase" ];
				_driver_near = ((side _nobj) == east) AND ((_nobj distance _pos1) < DRIVER_NEAR_DIST);
				if ( NOT (((count (crew _moto)) > 0) OR _driver_near)) then // if !occupied and driver onis not near moto
				{
					if ( !alive _moto ) then // recreate vehicle
					{
						_type = typeOf _moto;
						deleteVehicle _moto;
						_moto = objNull;
						sleep 1.375;
						_moto = _type createVehicle [0,0,0];
						_x set[MOTO_ITSELF, _moto];
#ifdef __DEBUG__
						hint localize format["motorespawn.sqf: time %1, %2 created as %3 after breakdown",round(time), _moto, _type];
#endif			
					}
					else	// use current vehicle item
					{
#ifdef __DEBUG__
						hint localize format["motorespawn.sqf: time %1, %2 moved back as alive",round(time), _moto];
#endif			
						_moto setDammage 0.0;
						_moto setFuel 1.0;
					};
					sleep 1.11;
					_moto setpos (_pos);
					sleep 0.25;
					//_x set [MOTO_ORIG_POS, getPos _moto];
					_moto setDir (_x select MOTO_ORIG_DIR);
					sleep 0.5 + random 0.5;
					if ( isEngineOn _moto) then { _moto engineOn false; };
					sleep 0.234;
#ifdef __DEBUG__
					hint localize format[ "motorespawn.sqf: time %1, pos %5, %2 dir %3, engine on %4",round(time), _moto, getDir _moto, isEngineOn _moto, getPos _moto ];
#endif			
				};
				_x set [MOTO_TIMEOUT, TIMEOUT_ZERO];
			};
		};
		sleep CYCLE_DELAY; // main cycle time-out
	} forEach _motoarr;
	//_mainCnt = _mainCnt +1;
};
_motoarr = [];
_motoarr = nil;