//
// Sygsky: camphandler.sqf, handles whole camp activity (spawning, flares, removement etc)
//

#include "x_setup.sqf"
#include "x_macros.sqf"

#define PROBABILITY_TO_DELETE_CAMP 0.1
#define PROBABILITY_TO_CREATE_CAMP 0.5
#define DISTANCE_TO_DELETE 15
#define DISTANCE_TO_CREATE 5

#ifdef __DEBUG__

#define PROBABILITY_TO_DELETE_CAMP 0.5

#define DELAY_BETWEEN_SPAWNS (15)
#define DELAY_BEFORE_START 30

hint localize format["camphandler.sqf started: DELAY_BETWEEN_SPAWNS == %1, PROBABILITY_TO_DELETE_CAMP == %2, PROBABILITY_TO_CREATE_CAMP == %3", DELAY_BETWEEN_SPAWNS, PROBABILITY_TO_DELETE_CAMP, PROBABILITY_TO_CREATE_CAMP];

#else

#define DELAY_BEFORE_START (3000+random 1200)
#define DELAY_BETWEEN_SPAWNS (3000+random 1200)

#endif
_PROB_TO_DELETE = PROBABILITY_TO_DELETE_CAMP;
_PROB_TO_CREATE = PROBABILITY_TO_CREATE_CAMP;

if ( !isNil "d_camps_spawned" ) exitWith
{
	hint localize "--- camphandler.sqf: script already executed ---";
};

if ( isNil "d_camp_arr" ) exitWith
{
	hint localize "--- camphandler.sqf: d_camp_arr isNil ---";
};

sleep DELAY_BEFORE_START;

d_camps_spawned = []; // already spawned camps 
_inventory_number = 1; // initial inventory number


//
// Call: _exists = _camp_index call _camp_exists;
// if error index used false is returned in any case
//
_camp_exists = 
{
	!isNull (_this call _find_camp)
};

//
// Call: _camp = _camp_index call SYG_find_camp;
// Returns object found at index positions or objNull if empty. If index out of range used objNull is returned in any case
//
_find_camp = {
	private [ "_arr", "_ret" ];
/* #ifdef __DEBUG__
	hint localize format[ "camphandler.sqf: _find_camp index %1", _this];	
#endif	
 */	if ( (_this < 0)  || (_this  >= count d_camp_arr) ) exitWith { objNull };
	_ret = objNull;
	{
		_arr = nearestObjects[ _x, ["ACamp"], 10];
		if ( count _arr > 0) exitWith { _ret = _arr select 0 };
	} forEach (d_camp_arr select _this);
	_ret
};

//
// Call: _was_deleted = _camp_index call _delete_camp;
//
_delete_camp = {
	private [ "_camp","_arr", "_ret" ];
	_camp = _this call _find_camp;
	if ( isNull _camp ) exitWith { false }; // no camp to deleted
	_arr = nearestObjects [ _camp, ["ACamp","Land_SleepingBag"], DISTANCE_TO_DELETE ];
#ifdef __DEBUG__
	hint localize format[ "camphandler.sqf: deleting %1 at index %2", _arr, _this ];
#endif	
	_ret = true;
	if ( (count _arr) == 0) then 
	{
#ifdef __DEBUG__
		hint localize format[ "--- camphandler.sqf: delete camp, items not found at index %1 ---", _this ];
#endif	
		_ret = false;
	}
	else
	{
#ifdef __DEBUG__
		hint localize format[ "camphandler.sqf: delete camp, items at index %1 removed", _this ];
#endif	
		{
			deleteVehicle _x;
			sleep 0.01;
		} forEach _arr;
	};
	_ret
};

//
// Call: _was_spawned = _camp_index call _spawn_camp;
// Returns: position array [x, y, z] if created or empty [] array if camp already exists or index out of range
//
_spawn_camp = {
	private ["_arr","_pos","_camp","_bag"];
	if ( (_this < 0)  || (_this  >= count d_camp_arr) ) exitWith {[]}; // bad index
	if ((_this call _camp_exists) ) exitWith {[]}; // camp already exists
#ifdef __DEBUG__
	hint localize format["camphandler.sqf: spawning ACamp at index %1", _this];
#endif	

	_pos = _this call _get_camp_pos;
	_camp = createVehicle ["ACamp", _pos, [], 0, "CAN_COLLIDE"];
	if ( isNull _camp ) exitWith 
	{
		hint localize format["--- camphandler.sqf: ACamp#%1 not created ---", _this];
		[]
	};
	sleep 0.123;
	if ( X_Client) then
	{
		_id = _camp addAction ["Обследовать", "campcheck.sqf" , [_inventory_number, floor random 5, floor random 6, floor random 6], 0, true/*, false , "", "{(_target distance _this) <= 2}" */];
		_inventory_number = _inventory_number + 1;
		player groupChat format["Camp#%1 action id %2", _this, _id];
	};
	_bag = createvehicle ["Land_SleepingBag", _pos, [], DISTANCE_TO_CREATE, "NONE"];
	sleep 0.1267;
/* #ifdef __DEBUG__
	hint localize format["camphandler.sqf: spawned ACamp at pos %1", _pos];
#endif	
 */	_pos
};

//
// Gets one of available positions at designated index
// Call: _pos = _camp_index call _get_camp_pos;
// Returns: random position array [x,y,z] at designated index or empty array [] if index is out of range
_get_camp_pos = 
{
	if ( ( _this < 0 )  || ( _this  >= count d_camp_arr ) ) exitWith {[]}; // bad index
	_this = d_camp_arr select _this; // array of positions for the designated camp index
	_this select (floor ( random (count _this) ) ); // random position for designated camp index
};

//
//=========================================================================== CODE START ========================
//

//=====================
// initiate spawned camp array with empties
//
{
	d_camps_spawned set [ count d_camps_spawned, objNull];
} forEach d_camp_arr;

_CAMP_NUMBER = count d_camp_arr;

//======================================
//=====================       M A I N   L O O P
//======================================
#ifdef __DEBUG__
hint localize format["camphandler.sqf: entering MAIN loop, _CAMP_NUMBER %1", _CAMP_NUMBER];
player groupChat format["camphandler.sqf: entering MAIN loop, _CAMP_NUMBER %1", _CAMP_NUMBER];
#endif	
while { true } do
{
	//===================================
	// clean spawned camps list
	//
	_free_index_arr = []; // array of indexes in camp array with empty positions
	_load_index_arr = [];
	for "_i" from 0 to _CAMP_NUMBER - 1 do
	{
		_camp = d_camps_spawned select _i;
		if ( !isNull _camp ) then
		{
			if ( !alive _camp ) then // clean entry
			{
				if ( _i call _delete_camp ) then
				{
#ifdef __DEBUG__
					hint localize format[ "camphandler.sqf: ACamp at index %1 cleaned", _i ];
#endif	
					d_camps_spawned set [ _i, objNull ];
					_free_index_arr = _free_index_arr + [ _i ];
				}
				else
				{
#ifdef __DEBUG__
					hint localize format[ "--- camphandler.sqf: failed to clean ACamp at index %1 ---", _i ];
#endif	
				};
			}
			else 
			{
				_load_index_arr = _load_index_arr + [ _i ]
			};
		}
		else
		{
			_free_index_arr = _free_index_arr + [ _i ];
		};
	};
	
	//==========================================
	// try spawn next camp
	//
/* #ifdef __DEBUG__
	hint localize format[ "camphandler.sqf: count _free_index_arr == %1", count _free_index_arr ];
#endif	
 */	if ( (count _free_index_arr) > 0 ) then // we can add one more camp
	{
		if ((random 1.0) < _PROB_TO_CREATE) then // ad it now
		{
			_ind = floor ( random (count _free_index_arr) ); // index to spawn new camp 
			_ind   = _free_index_arr select _ind; // index of camp to create
			_pos = _ind call _spawn_camp; // spawn camp at random position near base one
			if ( (count _pos) > 0 ) then // camp position is not occupied
			{
				_camp = _ind call _find_camp;
				if ( isNull _camp ) then
				{
#ifdef __DEBUG__
					hint localize format[ "--- camphandler.sqf: spawned camp index %1 not found ---", _ind];
					player groupChat format[ "--- camphandler.sqf: spawned camp index %1 not found ---", _ind];
#endif	
				}
				else
				{
					d_camps_spawned set [_ind, _camp]; // store object into array			
					// TODO inform all players about new camp creation
#ifdef __DEBUG__
					hint localize format[ "camphandler.sqf: camp index %1 created (near %3); %2", _ind, _free_index_arr, text (_camp call SYG_nearestSettlement) ];
					player groupChat format[ "camphandler.sqf: camp index %1 created", _ind, _free_index_arr ];
#endif	
				};
			}
			else
			{
#ifdef __DEBUG__
				hint localize format[ "camphandler.sqf: camp index %1 to create already EXISTS (near %3); %2", _ind, _free_index_arr,text (_camp call SYG_nearestSettlement) ];
				player groupChat format[ "camphandler.sqf: camp index %1 to create already exists", _ind ];
#endif	
			};
		};
	};
	
	// all camps were spawned, check if we should remove any of them
	if ( ( count _load_index_arr) > 0 ) then // there is at least one camp to remove
	{
		if ( (random 1.0) < _PROB_TO_DELETE ) then  // remove random camp
		{
			_ind = _load_index_arr select (floor ( random (count _load_index_arr)));
			_camp = _ind call _find_camp; // camp to delete
			if ( isNull _camp ) then
			{
#ifdef __DEBUG__
				hint localize format["camphandler.sqf: camp index %1 to delete NOT FOUND", _ind ];
				player groupChat format["camphandler.sqf: camp index %1 to delete NOT FOUND", _ind ];
#endif	
			}
			else
			{
				if ( _ind call _delete_camp ) then
				{
				 // TODO: informa all players about camp deleted
#ifdef __DEBUG__
					hint localize format["camphandler.sqf: camp index %1 deleted", _ind ];
					player groupChat format["camphandler.sqf: camp index %1 deleted", _ind ];
#endif	
				}
				else
				{
#ifdef __DEBUG__
					hint localize format["--- camphandler.sqf: failed to delete randomly selected ACamp at index %1 ---", _i ];
#endif	
				};
			};
		};
	};
#ifdef __DEBUG__
//	hint localize format[" camphandler.sqf: sleep %1 secs", DELAY_BETWEEN_SPAWNS ];
#endif	
	sleep DELAY_BETWEEN_SPAWNS + random (DELAY_BETWEEN_SPAWNS/5);
};
