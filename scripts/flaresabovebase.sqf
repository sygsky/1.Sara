// by Sygsky
// script to shoot flares above base from wounded diversants
// Example:
// [] execVM "scripts\flaresabovebase.sqf";
//
// script uses global variable d_on_base_groups as array of sabotage groups sent to blow base
//
#include "x_macros.sqf"

if (!isServer) exitWith{};

// comment next line to not create debug messages
#define __DEBUG__

// delay between flares 
#define INTERGROUP_DELAY 60

#ifdef __DEBUG__
#define CYCLE_DELAY 10
#define START_DELAY  10
#else
// 5 mins timeout will be good
#define CYCLE_DELAY 300
#define START_DELAY  5000
#endif

#define inc(val) (val=val+1)
#define TIMEOUT(addval) (time+(addval))
#define ROUND0(val) (round(val))
#define arg(num) (_this select(num))
#define argp(arr,num) ((arr)select(num))
#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})

_illumination = {
	private ["_trg_center","_radius","_height","_type","_x","_y","_flare","_angle"];
	
	_trg_center = _this select 0;
	_radius     = _this select 1;
	_height     = argopt(2,250); // default 250
	_type       = argopt(3,"F_40mm_Red"); // default is "F_40mm_Red"
	
	_x   = _trg_center select 0;
	_y = _trg_center select 1;
	_flare  = objNull;
	_radius = (sqrt((random _radius)/_radius))*_radius;

	_angle = floor (random 360);
	_x = _x - _radius * sin _angle;
	_y = _y - _radius * cos _angle;
	_flare = _type createVehicle [_x, _y, 250];
	sleep (_height/10)  + random 30;
	if (!isNull _flare) then {deleteVehicle _flare};
};

//player groupChat "flaresabovebase.sqf: ENTERED";
_PRINT("*******************************");
//_PRINT(format["flaresabovebase.sqf: ENTERED,d_on_base_groups = %1", d_on_base_groups]);
player groupChat format["flaresabovebase.sqf: ENTERED,d_on_base_groups = %1", d_on_base_groups];
hint localize format["flaresabovebase.sqf: ENTERED,d_on_base_groups = %1", d_on_base_groups];

waitUntil {sleep 1.0; !(isNil "d_on_base_groups")}; // wait until global variable is initiated

player groupChat "flaresabovebase.sqf: continue";
hint localize "flaresabovebase.sqf: continue";

#ifdef __DEBUG__
player groupChat format["flaresabovebase.sqf: d_on_base_groups %1",d_on_base_groups];
hint localize  format["flaresabovebase.sqf: d_on_base_groups %1",d_on_base_groups];
_delay = START_DELAY + random 2;
player groupChat format["flaresabovebase.sqf: start delay %1 secs",ROUND0(_delay)];
hint localize format["flaresabovebase.sqf: start delay %1 secs",ROUND0(_delay)];
#else
_delay = START_DELAY + random 1200;
#endif	

sleep _delay;
#ifdef __DEBUG__
player groupChat "flaresabovebase.sqf: awakened";
hint localize  "flaresabovebase.sqf: awakened";
_first_time = true;
#endif
while { true } do {
#ifdef __DEBUG__
	if ( _first_time ) then
	{
		player groupChat "flaresabovebase.sqf: entering while loop";
		hint localize  "flaresabovebase.sqf: entering while loop";
		_first_time = false;
	};
#endif
	if (false /* X_MP AND ((call XPlayersNumber) == 0) */ ) then 
	{
#ifdef __DEBUG_
		player groupChat "flaresabovebase.sqf: waits for player";
		hint localize  "flaresabovebase.sqf: waits for player";
#endif			
		waitUntil {sleep (random CYCLE_DELAY);(call XPlayersNumber) > 0};
#ifdef __DEBUG_
		player groupChat "flaresabovebase.sqf: player entered";
		hint localize  "flaresabovebase.sqf: player entered";
#endif			
	}
	else
	{
#ifdef __DEBUG_
		_delay = random CYCLE_DELAY;
		player groupChat format["flaresabovebase.sqf: sleep %1", ROUND0(_delay)];
		hint localize  format["flaresabovebase.sqf: sleep %1", ROUND0(_delay)];
		sleep _delay;
#else	
		sleep random CYCLE_DELAY;
#endif			
	};
#ifdef __DEBUG_
	player groupChat format[ "flaresabovebase.sqf: loop, %1 groups in list", count d_on_base_groups ];
	hint localize    format[ "flaresabovebase.sqf: loop, %1 groups in list", count d_on_base_groups ];
#endif			
	// check groups
	if ( count d_on_base_groups > 0 ) then
	{
#ifdef __DEBUG_
	player groupChat format[ "flaresabovebase.sqf: do loop on %1 groups in list", count d_on_base_groups ];
	hint localize    format[ "flaresabovebase.sqf: do loop on %1 groups in list", count d_on_base_groups ];
#endif			
		_empty_found = false;
		for "_i" from 0 to count d_on_base_groups - 1 do
		{
			_grp = argp(d_on_base_groups,_i);
			if ( typeName _grp != "STRING" ) then // item is not marked for remove
			{
				if ( isNull _grp OR ({alive _x} count (units _grp)) == 0 ) then 
				{
					d_on_base_groups set [_i, "RM_ME"];
					_empty_found = true;
				} 
				else // check group for wounded unconscious men
				{
					{
						if ( !isNull _x AND alive _x AND !canMove _x ) exitWith // found wounded man, launch red flare above he
						{
							// launch flare now
							[getPos _x,20,200,"F_40mm_Red"] spawn _illumination;
							sleep random INTERGROUP_DELAY; 
						};
					}
					forEach units _grp;
				};
			} //if ( typeName _grp != "STRING" ) then // item is not marked for remove
			else
			{
				_empty_found = true;
			};
		}; //for "_i" from 0 to count d_on_base_groups - 1 do
		if _empty_found then 
		{
			d_on_base_groups = d_on_base_groups - ["RM_ME"];
#ifdef __DEBUG_
	player groupChat format[ "flaresabovebase.sqf: %1 groups in list", count d_on_base_groups ];
	hint localize    format[ "flaresabovebase.sqf: %1 groups in list", count d_on_base_groups ];
#endif			
		};
	} // if ( count d_on_base_groups > 0 ) then
	else
	{
#ifdef __DEBUG_
	player groupChat "flaresabovebase.sqf: no groups in list";
	hint localize    "flaresabovebase.sqf: no groups in list";
#endif			
	}; 
}; // while {true} do

#ifdef __DEBUG_
	player groupChat "flaresabovebase.sqf: EXIT";
	hint localize    "flaresabovebase.sqf: EXIT";
#endif			
 
if true exitWith{true};
