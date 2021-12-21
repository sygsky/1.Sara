/**
 *
 * SYG_utilsAir.sqf
 *
 */
 
#include "x_macros.sqf"


#define inc(x) x=x+1
#define arg(x) (_this select (x))
#define parg(x) (_params select (x))
#define argopt(num,val) (if(count _this<=(num))then{val}else{_this select (num)})

#define TYPE_VEHICLE_AIR "AIR"
#define TYPE_VEHICLE_LAND "LAND"

#define TYPE_ORDER_ESCAPE "ESCAPE"
#define TYPE_ORDER_FIGHT "FIGHT"

#define TYPE_FAIL_REMOVE "KILL"
#define TYPE_FAIL_JOIN "JOIN"
#define TYPE_FAIL_JOIN "DEFEND"

#define VEHICLE_IS_USABLE(x) ((!isNull x) AND (alive x) AND (!locked x) AND (({group _x != _grp}count crew x) == 0))
#define VEHICLE_IS_BAD(x) ((isNull x) OR (!alive x) OR (locked x) OR (({group _x != _grp}count crew x) == 0))
#define CAN_MOVE(x) ((!isNull x) AND (canMove x))

#define GRP_IS_EMPTY (({ !isNull _x AND canMove _x} count (units _grp)) == 0)
#define GRP_NOT_EMPTY (({ !isNull _x AND canMove _x} count (units _grp)) > 0)

#define ASSIGN_AS(unit,role,veh) unit assignAs##role## veh; 


/**
 * Let group find and steal empty vehicle/heli
 *
 * call: [_grp, _dist, [], ["Helicopter"],"JOIN_ANY_GROUP","ESCAPE",[]] call SYG_stealVehicle;
 *
 * returns true is heli is stealed and removed from game, false if parameters error or mission failed
 */
SYG_stealVehicle = {

/**
 * common parameters for any internal function calls:
 * [_grp, [_veh1,...,_vehN], [_wp1,...,wpN], MISSION_TYPE, FAIL_PLAN,_current_veh] call _anyFunction;
 */
#define _PARAM_GROUP 0
#define _PARAM_VEHICLES_LISTS 1
#define _PARAM_WPS 2
#define _PARAM_MISSION_PLAN 3
#define _PARAM_FAIL_PLAN 4
#define _PARAM_CURRENT_VEHICLE 5

_removeUnits = {
	if ( count _this > 0 ) then
	{
		{
			if (!isNull _x ) then 
			{
				_x setDammage 1.1;
				[_x] call XAddDead;
				sleep 0.3 + random 0.3;
			};
		} forEach _this;
	};
	player groupChat format["Units %1 deleted", _this];
};

_utilizeUnits = {
	player groupChat format["Utilizing group of %1",_this];
	_unit = objNull;
	_unit = { if (canMove _x) exitWith {_x}}forEach _units;
	if ( !isNull _unit) then 
	{
		_new_grp = [_unit, 1000] call SYG_findNearestSideGroup; // returns objNull if no group found
		if ( isNull _newgrp) exitWith {false};
		_joined = [];
		for "_i" from 0 to (count _units) -1 do
		{
			_unit = _this select _i;
			if ( !isNull _unit AND canMove _unit) then 
			{
				_joined = _joined + [_unit];
				_units set [_i, "RM_ME"];
			};
		};
		if ( count _joined > 0 ) then 
		{
			_joined join _new_grp; 
			player groupChat format["Units %1 joined to other group", _joined];
			sleep 1.0;
		};
		_units = _units - ["RM_ME"];
	};
	_units call _removeUnits;
};

_getDefaultWps = {
	private ["_ret", "_locs"];
	_ret = [20000,2000,0];
	_locs = nearestLocations [ _ret, [/*"BorderCrossing","Hill", "Mount", "Name","NameCity", "NameCityCapital", "NameLocal",*/ "NameMarine"/* , "NameVillage", "RockArea", "VegetationBroadleaf", "VegetationFir", "VegetationPalm", "VegetationVineyard",  "ViewPoint"*/], 2000];
	{
		if ( (text _x) == "Rio Pallido") exitWith {	_ret = [position _x]; };
	} forEach _locs;
	_ret
};

/**
 *
 * call: _params call _moveToVehicle;
 * returns:
 *			 0: all is well, group repaired vehicle and both are alive
 *			-1: group is dead, exit
 *			-2: vehicle is dead, group alive
 */
_repairVehicle = {
	private [];
	
	_grp = arg(_PARAM_GROUP);
	_vehicle = arg(_PARAM_CURRENT_VEHICLE);
	
	while { GRP_NOT_EMPTY AND VEHICLE_IS_USABLE(_vehicle) } do
	{
		//------------------------
		//-- select engineer -----
		//------------------------
		_engineer = leader _grp;
		{ 
			if (_x != _engineer AND CAN_MOVE(_x)) exitWith { _engineer = _x; };
		} forEach units _grp;

		_dmg = getDammage _vehicle;
		_vehicle setFuel 0;
		if ( _dmg > 0.5 ) then { _vehicle setDammage 0.5};
		_engineer assignAsDriver _vehicle; 
		[_engineer] orderGetIn true;
		sleep 0.5;
		_cnt = 0;
		_max_cnt = round (_engineer distance _vehicle);
		_ret = 0;
		waitUntil { sleep 1.0; inc(_cnt);(!CAN_MOVE(_engineer)) OR (!(VEHICLE_IS_USABLE(_vehicle))) OR ((_engineer distance _vehicle) < 3) OR (vehicle _engineer !=_engineer) OR (_cnt > _max_cnt)};

		if ( GRP_IS_EMPTY ) exitWith { player groupChat "group is dead during repairing"; _ret = -1};
		if (VEHICLE_IS_BAD(_vehicle) ) exitWith {player groupChat "group is dead during repairing";_ret = -2};
		if ( count (assignedVehicleRole _engineer) > 0 ) then
		{
			sleep 1.45;
			if ( vehicle _engineer != _engineer ) then {player groupChat "engineer ejected"; _engineer action["eject", vehicle _engineer]; sleep 0.3}; 
		};
		_dir = [_engineer, _vehicle] call XfDirToObj;
		_engineer setDir _dir;
		sleep 0.1;
		//-----------------------
		//- animate repairing   -
		//-----------------------
		player groupChat format["repaire vehicle %1", _vehicle ];
		_engineer playMove "AinvPknlMstpSlayWrflDnon_medic";
		sleep 3.0;
		if ( vehicle _engineer != _engineer ) then 
		{ 
			player groupChat "Engineer is IN vehicle"; 
			_engineer action["eject", vehicle _engineer]; 
			sleep 0.3; 
			_dir = [_engineer, _vehicle] call XfDirToObj;
			_engineer setDir _dir;
		};
		waitUntil {sleep 0.1;animationState _engineer != "AinvPknlMstpSlayWrflDnon_medic"};
		unassignVehicle _engineer;
		sleep 1.0 + random 1;
		if ( VEHICLE_IS_USABLE(_vehicle) ) exitWith {_vehicle setDammage 0; _vehicle setFuel 1;};
	};
	if ( _ret == 0 ) then 
	{	
		if ( GRP_IS_EMPTY ) then {_ret = -1} else
		{
			if ( !VEHICLE_IS_USABLE(_vehicle)) then {_ret = -2};
		};
	};
	_ret
};

/**
 * The only function with calling params  from main function SYG_stealVehicle, 
 * that is [_grp, _dist, [_veh1,...,_vehN], "AIR","JOIN","ESCAPE",[wps1,...,wpsN]]
 * all other functions are called with std param array (see description above)
 *
 * call: _this call _prepareParams;
 * returns: array of internal array with standard parameters (see description above) or
 * empty array on input error
 */
_prepareParams = {
	private ["_grp", "_dist", "_veh_list", "_vehicle_type", "_str", "_fail_plan", "_final_plan", "_escape_wp", "_wps", "_search_types", "_empty_vehicles", "_i", "_veh", "_isKindof"];
	
	player groupChat "Entering _prepareParams";
	
	_grp = arg(0);
	player groupChat format["_grp = %1", _grp];

 	_dist = arg(1);
	player groupChat format["_dist = %1", _dist];
	
	// vehicles list to filter them from found ones with nearestObjects base types array. May be empty array []
	if (count _this < 3 ) exitWith {player globalChat "Expected 3rd argument (_veh_list) absent";[]};
	_veh_list = arg(2);
	//if ( count _veh_list == 0 ) exitWith {player globalChat "_veh_type is [], exit";[]};
	player groupChat format["_veh_list = %1", _veh_list];
	
	if ( count _this < 4) exitWith {player globalChat format["Expected as 4th argument vehicle type (""%1"",""%2"")",TYPE_VEHICLE_AIR,TYPE_VEHICLE_LAND];[]};
	
	_vehicle_type = arg(3); // "AIR" or "LAND"
	player groupChat format["_vehicle_type = %1", _vehicle_type];
	
	 // "KILL" or "JOIN" or "DEFEND", optional
	_str =  argopt(4,TYPE_FAIL_JOIN);
	if ( _str == "" ) then {_str = TYPE_FAIL_JOIN};
	_fail_plan = toUpper(_str);
	player groupChat format["_fail_plan = %1", _fail_plan];
	
	// "ESCAPE" or "FIGHT"
	_str = argopt(5,TYPE_ORDER_ESCAPE);
	if ( _str == "" ) then {_str = TYPE_ORDER_ESCAPE};
	_final_plan = toUpper(_str);
	player groupChat format["_final_plan = %1", _final_plan];
	
	// Waypoints array if ESCAPE, else not parsed
	if ( _final_plan == TYPE_ORDER_ESCAPE ) then
	{
		_escape_wp = call _getDefaultWps; 
		_wps = argopt(6,_escape_wp); // waypoint[s] for escape plan, optional 
		if (count _wps != 0) then {_escape_wp = _wps};
	};
	player groupChat format["_escape_wp = %1", _escape_wp];
	
	_search_types = switch _vehicle_type do {case TYPE_VEHICLE_AIR: {["Air"]}; case TYPE_VEHICLE_AIR:{["LandVehicle"]}; default{[]}};
	if ( count _search_types == 0) exitWith {[]}; // bad vehicle type used, TODO: add ship type too
	player groupChat format["_search_types = %1", _search_types];
	
	// find all designated vehicles in range
	_empty_vehicles = nearestObjects [leader _grp, _search_types, _dist];
	for "_i" from 0 to (count _veh_list)- 1 do
	{	//  forEach _empty_vehicles;
		_veh = _empty_vehicles select _i;
		if ( VEHICLE_IS_USABLE(__veh) ) then 
		{
			if ( (count _empty_vehicles) > 0 ) then
			{
				_isKindof = false;
				{	
					if( _veh isKindOf _x ) exitWith {_isKindof = true};
				} forEach _veh_list;
				if ( !isKindOf ) then { _empty_vehicles set [_i, "RM_ME"] };
			};
		}
		else
		{
			_empty_vehicles set [_i, "RM_ME"];
		};
		player groupChat format["Heli %1, alive %2, crew men %3, in list %4 %5", typeOf _x, alive _x, count crew _x, _veh_list, _isKindOf];
	};
	_empty_vehicles = _empty_vehicles - [ "RM_ME" ];
	// return parsed parameters array
	[_grp, _empty_vehicles, _wps, _final_plan, _fail_plan, objNull]

};

/**
 * call: _params call _getNextVehicle;
 * return next vehicle reference or objNull if no vehicles in list remained
 */
 _getNextVehicle = {
	private ["_veh_list","_veh","_i"];
	_veh_list = arg(_PARAM_VEHICLES_LISTS);
	_veh = objNull;
	player groupChat format["мур list: %1", _veh_list];
	for "_i" from 0 to (count _veh_list) -1 do
	{
		_veh = objNull;
		_veh = _veh_list select _i; // get first vehicle
		player groupChat format["try to select veh ""%1""",_veh];
		if ( VEHICLE_IS_USABLE(_veh) ) exitWith { _veh_list set[_i, "RM_ME"];_this set [_PARAM_CURRENT_VEHICLE, _veh] };
	};
	_veh_list = _veh_list - ["RM_ME"];
	_veh
};

/**
 * Go to vehicle function
 * call: _params call _goToVehicle;
 * returns: 
 *			0: group is near vehicle
 * 			-1: group is not valid
 *			-2: vehicle is dead
 *			-3: group can't go to the vehicle due to unknown obstacles
 */
_goToVehicle = {
	private ["_grp","_vehicle","_ret","_max_cnt", "_cnt","_dist2heli","_pos"];
	_grp = _this select _PARAM_GROUP;
	_vehicle = _this select _PARAM_CURRENT_VEHICLE;
	_ret = 0;
	scopeName = "exit";
	while { _ret == 0 }  do
	{
		if ( GRP_IS_EMPTY ) exitWith {_ret = -2};
		if ( !VEHICLE_IS_USABLE(_vehicle)) exitWith{_ret = -1};

		_dist2heli = leader _grp distance _vehicle;
		_max_cnt = ceil _dist2heli;
		_pos = [leader _grp, _vehicle, -4] call SYG_elongate2;
		(units _grp) allowGetIn true;
		_grp setSpeedMode "FULL";
		(units _grp) commandMove _pos;
		_cnt = 0;
		//_last_pos = getPos (leader _grp);
		player groupChat format["wait to reach heli at dist %1 after %2 secs", (leader _grp) distance (_vehicle), _max_cnt];
		while { VEHICLE_IS_USABLE(_vehicle) AND GRP_NOT_EMPTY AND (((leader _grp) distance _pos) > 2) AND (_cnt < _max_cnt) } do
		{
			sleep 1;
			inc(_cnt);
		};
		if ( GRP_NOT_EMPTY) exitWith 
		{
			player groupChat format["group %1 is dead before group reach him", _grp];
			_ret = -1;
		};
		if (  !VEHICLE_IS_USABLE(_vehicle)) exitWith 
		{
			player groupChat format["vehicle %1 (%2) is dead before group reach him", typeof _vehicle, _vehicle];
			_ret = -2;
		};
		if ( _cnt >= _max_cnt) exitWith 
		{
			player groupChat format["vehicle %1 (%2) pos not reacheable", typeof _vehicle, _vehicle];
			_ret = -3;
		};
	};
	_ret
};

/**
 * call: _ret = _params call _populateVehicle;
 * returns:
 *  [_unit1,...,_unitN] : all is well and returned array contains men not populated into vehicle. may return empty ([]) array if all are populated
 *	-1 : group is dead
 *	-2: group alive but vehicle not ready for (dead, damaged etc)
 */
 _populateVehicle = {
	private ["_grp","_vehicle","_units","_leader","_pos", "_cnt","_unit","_cargoCnt","_iCargo"];
	_grp = arg(_PARAM_GROUP);
	_vehicle = arg(_PARAM_CURRENT_VEHICLE);
	// 2.4 load group into heli
	{
		unassignVehicle _x
	} forEach crew _vehicle;
	_units = units _grp;
	_leader = leader _grp;
	_units = _units - [_leader];
	_units = [_leader] + _units;
	_pos = 0;
	_cnt = (count _units)  - 1;
	scopeName "main_loop";
	{
		if ( (_vehicle emptyPositions _x)  > 0 ) then 
		{
			_unit = objNull;
			while { true } do 
			{
				if ( _pos > _cnt) then {breakTo "main_loop"};
				_unit = _units select _pos;
				if ( canMove _unit ) exitWith {};
			};
			if ( !isNull _unit ) then
			{
				player groupChat format["assigning ""%1"" as %2", _unit, _x ];
				call compile format["%1 assignAs%2 %3;",_unit, _x, _vehicle ];
				[_unit] orderGetIn true;
				_units set [_pos, "RM_ME" ]; // remove good units from possible bad list
				inc(_pos);
				sleep 1.5;
			};
		};
	} forEach ["Driver","Commander","Gunner"];

	if ( _pos <= _cnt) then 
	{
		player groupChat format["Try to assign men %1 to %2 as Cargo",_pos, _cnt];
		_cargoCnt = _vehicle emptyPositions "Cargo";
		_iCargo = 0;
		for "_i" from _pos to _cnt  do
		{
			if (_iCargo >= _cargoCnt) exitWith {false};
			_unit = _units select _i;
			if ( CAN_MOVE(_unit) ) then 
			{
				player groupChat format["assigning ""%1"" to Cargo", _unit ];
				_unit assignAsCargo _vehicle;
				[_unit] orderGetIn true;
				_units set [_i, "RM_ME" ]; // remove good units from possible bad list
				inc(_iCargo);
				sleep 1.5;
			};
		};
	};
	_units = _units - ["RM_ME"];
	if ( _IS_GROUP_EMPTY OR (!canMove(driver _vehicle))) then {_units = -1}
	else
	{	
		if( !VEHICLE_IS_USABLE (_vehicle)) then {_units = -2};
	};
	_units
};

	scopeName "exit";
	
	player groupChat format["Params 1: %1",_this];
	_params = _this call _prepareParams;
	player groupChat format["Params: %1",_params];

	_grp  = _params select _PARAM_GROUP;
	player groupChat format["%1 vehicles found", count (_params select _PARAM_VEHICLES_LISTS)];
	sleep 0.05;
	_cm = combatMode _grp;
	_be = behaviour leader _grp;
	
	_grp setCombatMode "WHITE";
	_grp setBehaviour "SAVE";
	
	_units = []; // array of unwanted units to kill them on exit
	
	while { GRP_NOT_EMPTY } do
	{
		scopeName "vehicle_loop";
		
		//++++++++++++++++++++
		//+ TRY NEXT VEHICLE +
		//++++++++++++++++++++
		_vehicle = _params call _getNextVehicle;
		if ( isNull _vehicle) then {player groupChat "- No more vehicles found, exit"; breakTo "exit"}; // no more vehicles
		if ( VEHICLE_IS_USABLE(_vehicle) ) then 
		{
			player groupChat format["selected vehicle %1 (%2), at dist %3. Start procedure", typeOf _vehicle, _vehicle, (leader _grp) distance (_vehicle)];
			
			sleep 1.145;
			//++++++++++++++++++++
			//+   go to vehicle  +
			//++++++++++++++++++++
			_ret = _params call _goToVehicle;
			if ( _ret == -1 ) exitWith {false};
			if ( _ret == 0 ) then
			{
				//+++++++++++++++++++++++++++++
				//+      repair vehicle       +
				//+++++++++++++++++++++++++++++
				_ret = _params call _repairVehicle;
				if ( _ret == -1 ) exitWith {false};
				if ( _ret == 0 ) then
				{
					//+++++++++++++++++++++++++++++
					//+      populate vehicle     +
					//+++++++++++++++++++++++++++++
					_ret = _params call _populateVehicle;
					if ( typeName _ret != "ARRAY" ) then
					{
						if ( _ret == -1 ) exitWith {false};
					}
					else
					{
						_ret call _utilizeUnits;
					}
				};
			};
		};
	};
/* 		
		if ( VEHICLE_IS_USABLE(_vehicle)) then  // empty heli is found
		{
			player groupChat format["vehicle %1 is usable, start procedure", _vehicle];
			_dist2heli = leader _grp distance _vehicle;
			_max_cnt = ceil _dist2heli;
			// 2. Try to repair item
			// 2.0 come to the heli 
			_pos = [leader _grp, _vehicle, -4] call SYG_elongate2;
//			_pos = getPos _vehicle;
			(units _grp) allowGetIn true;
			_grp setSpeedMode "FULL";
			(units _grp) commandMove _pos;
			_cnt = 0;
			//_last_pos = getPos (leader _grp);
			player groupChat format["wait to reach heli at dist %1 after %2 secs", (leader _grp) distance (_vehicle), _max_cnt];
			while { VEHICLE_IS_USABLE(_vehicle) AND GRP_NOT_EMPTY AND (((leader _grp) distance _pos) > 2) AND (_cnt < _max_cnt) } do
			{
				sleep 1;
				inc(_cnt);
			};
			player groupChat "heli reached";
			if ( VEHICLE_IS_USABLE(_vehicle) AND GRP_NOT_EMPTY AND (_cnt < _max_cnt) ) then 
			{
				player groupChat format["Group at dist %1, try to repair", leader _grp distance _vehicle ];
				scopeName "vehicle_loop";
				while {GRP_NOT_EMPTY} do 
				{
					// 2.1 select pilot to repair, preferrably not to be leader
					_engineer = leader _grp;
					{ 
						if (_x != _engineer AND CAN_MOVE(_x)) exitWith { _engineer = _x; };
					} forEach units _grp;
					
					// 2.2 get in to animate operation for observing players
					//if ( getDammage _vehicle > 0.5 ) then { _vehicle setDammage 0.5};
					//_unit2 assignAsGunner _vehicle;_unit2 moveInGunner _vehicle;
					//player groupChat format["Engineer elected: %1 and assigned", _engineer];
					_engineer assignAsDriver _vehicle; 
					[_engineer] orderGetIn true;
					sleep 0.5;
					if ( count (assignedVehicleRole _engineer) > 0 ) then
					{
						waitUntil { sleep 1.0; (!CAN_MOVE(_engineer)) OR (!(VEHICLE_IS_USABLE(_vehicle))) OR ((_engineer distance _vehicle) < 5) OR (vehicle _engineer !=_engineer)};
						if ( !VEHICLE_IS_USABLE(_vehicle) OR GRP_IS_EMPTY ) then // try other vehicle/group
						{
							player groupChat "--- vehicle or group is down, try other step";
							breakTo "vehicle_loop";
						}; 
						sleep 1.45;
						// jump just in case
						if ( vehicle _engineer != _engineer ) then {player groupChat "pilot ejected"; _engineer action["eject", vehicle _engineer]; sleep 0.3}; 
					};
 
					_dir = [_engineer, _vehicle] call XfDirToObj;
					_engineer setDir _dir;
					sleep 0.2;
					// 2.3 animate repairing
					player groupChat format["repaire vehicle %1", _vehicle ];
					_engineer playMove "AinvPknlMstpSlayWrflDnon_medic";
					sleep 3.0;
					if ( vehicle _engineer != _engineer ) then { player groupChat "Engineer is IN vehicle"; unassignVehicle _engineer; sleep 0.3; _dir = [_engineer, _vehicle] call XfDirToObj;_engineer setDir _dir;};
					waitUntil {sleep 0.1;animationState _engineer != "AinvPknlMstpSlayWrflDnon_medic"};
					unassignVehicle _engineer;
					if ( GRP_NOT_EMPTY AND VEHICLE_IS_USABLE(_vehicle)) then 
					{
						player groupChat format["boarding heli %1", _vehicle ];
						_vehicle setDammage 0;
						_vehicle setFuel 1.0;
						// 2.4 load group into heli
						_units = units _grp;
						_leader = leader _grp;
						_units = _units - [_leader];
						_units = [_leader] + _units;
						_filledCnt = 0;
						{
							unassignVehicle _x
						} forEach crew _vehicle;
						_i = 0;
						_cnt = (count _units)  - 1;
						scopeName "main_loop";
						{
							if ( (_vehicle emptyPositions _x)  > 0 ) then 
							{
								_unit = objNull;
								while { true } do 
								{
									if ( _i > _cnt) then {breakTo "main_loop"};
									_unit = _units select _i;
									if ( canMove _unit ) exitWith {};
								};
								if ( !isNull _unit ) then
								{
									player groupChat format["assigning ""%1"" to %2", _unit, _x ];
									call compile format["%1 assignAs%2 %3;",_unit, _x, _vehicle ];
									[_unit] orderGetIn true;
									_units set [_i, "RM_ME" ];
									inc(_i);
									sleep 1.5;
								};
							};
						} forEach ["Driver","Commander","Gunner"];
						_pos = _i;
						player groupChat format["assigning Cargo from %1 to %2, %3",_i, _cnt, _units];
						for "_i" from _pos to _cnt  do
						{
							if ((_vehicle emptyPositions "Cargo") == 0) exitWith {false};
							_unit = _units select _i;
							if ( CAN_MOVE(_unit) ) then 
							{
								player groupChat format["assigning ""%1"" to Cargo", _unit ];
								_unit assignAsCargo _vehicle;
								[_unit] orderGetIn true;
								sleep 1.0;
							}
						};
						// 3. Try to steal heli and draw to the ocean, to there kill any crew member that not fit into new heli
						player groupChat format["executing ""%1"" plan ", _final_plan ];
						switch _final_plan do 
						{
							"ESCAPE";
							"FIGHT";
							default
							{
								player groupChat format["default action for vehicle team: %1, pilot",crew _vehicle, driver _vehicle];
								// wait until some is in vehicle
								while { count crew _vehicle == 0} do
								{
									if (!(VEHICLE_IS_USABLE(_vehicle) AND GRP_NOT_EMPTY)) then {breakTo "vehicle_loop"};
									sleep 1.5;
								};
								//waitUntil {sleep 1; VEHICLE_IS_USABLE(_vehicle) AND GRP_NOT_EMPTY AND (count crew _vehicle > 0)};
								player groupChat "pilot in vehicle, go-go-go";
								//if ( ! (CAN_MOVE(driver _vehicle)  AND VEHICLE_IS_USABLE(_vehicle)) ) then {"vehicle or pilot are damaged 1";breakTo "vehicle_loop";};
								_vehicle engineOn true;
								driver _vehicle action ["ENGINEON", _vehicle];
								//driver _vehicle action ["LIGHTON", _vehicle];
								while { (getPos _vehicle select 2) < 2} do
								{
									if (!(CAN_MOVE(driver _vehicle)  AND VEHICLE_IS_USABLE(_vehicle))) then {breakTo "vehicle_loop"};
									sleep 0.5;
								};

								_grp setSpeedMode "FULL";
								if ( _vehicle isKindOf "Air" ) then { _vehicle flyInHeight (190 + random 20); };
								if ( ! (CAN_MOVE(driver _vehicle)  AND VEHICLE_IS_USABLE(_vehicle)) ) then {player groupChat "vehicle or pilot are damaged 2";breakTo "vehicle_loop";};
								// check who is boarded now
								_units = units _grp;
								_crew = crew _vehicle;
								for "_i" from 0 to (count crew _vehicle) -1 do
								{
									_unit = _units select _i;
									if ( _unit in _crew) then {_units set [_i, "RM_ME"];};
								};
								_units = _units - [ "RM_ME" ]; // remove whole crew from list
								player groupChat format["%1 men were not boarded to the  %2, utilize them", count _units, typeOf _vehicle ]; 
								_units call _utilizeUnits;
								_i = 0;
								player groupChat format["Start moving through %1 waypoints", count _escape_wp];
								_pos = _escape_wp select _i;
								_i = 1;
								_wp = _grp addWayPoint [_pos, 10];
								player groupChat "goto to the start waitpoint";
								_wp setWaypointType "Move"; // "SAD"
								[_grp, 1] setWaypointStatements ["never", ""];

								while {true} do
								{
									while { (_pos distance  _vehicle) > 100 } do 
									{
										if ( !(VEHICLE_IS_USABLE(_vehicle) AND GRP_NOT_EMPTY) ) then
										{
											player groupChat "vehicle or pilot are damaged 3";
											breakTo "vehicle_loop";
										};
										sleep 2 + random 4;
									};
									if ( _i >= count _escape_wp ) exitWith {true};
									_pos = _escape_wp select _i;
									_wp  setWaypointPosition [_pos, 30];
									//_wp setWaypointType "Move"; // "SAD"
									player groupChat format ["goto to the waitpoint #%1",_i,_x];
									inc(_i);
								};
								// TODO: kill them all
								player groupChat "TODO: kill them all after all";
							};
						}; // switch _final_plan do 
					}; // if ( GRP_NOT_EMPTY AND VEHICLE_IS_USABLE(_vehicle)) then 
				}; //while {GRP_NOT_EMPTY} do
			}; //if ( VEHICLE_IS_USABLE(_vehicle) AND GRP_NOT_EMPTY AND _cnt < _max_cnt) then
		} //if ( VEHICLE_IS_USABLE(_vehicle)) then
		else 
		{ // no empty heli found, lets simply join crew to the nearest frendly group (or order to defence near building)
			player groupChat "No usable helis, try to join infantry group";
			switch _fail_plan do
			{
				case "DEFEND_NEAREST_BUILDING";
				case  "JOIN_ANY_GROUP";
				default 
				{
					// find nearest group of same side
					_new_grp = [leader _grp, 1000] call SYG_findNearestSideGroup; // returns objNull if no group found
					_units = units _grp;
					_cnt = 0;
					if ( !isNull _new_grp ) then
					{
						player groupChat format["find group %1 of %2 men at dist %3",_new_grp, count units _new_grp, round ((leader _grp) distance (leader _new_grp))];
						for "_i" from 0 to (count (units _grp)) - 1 do 
						{
							_unit = _units select _i;
							if ( CAN_MOVE(_unit) ) then { [_unit] join _new_grp; _units set [_i, "RM_ME"]; inc(_cnt); sleep 0.5;};
						};
						player groupChat format["%1 crew men joined to other group %2", _cnt, _new_grp];
						_units = _units - ["RM_ME"];
					}
					else 
					{
						player groupChat format["no any group found at dist %1",1000];
					};
					
					// join crew to group or 
					if ( !isNull _new_grp ) exitWith 
					{// kill whole crew if no group found};	};
						sleep 1.0;
					};
				};
			};
		};
	}; //	while { GRP_NOT_EMPTY } do
	
	// TODO: no more vehicles or grp is not valid
	
	// forEach _units
	player groupChat format["exit script with removing group of %1", _units ];
	_units call _removeUnits;
 */	player groupChat "exiting";
};
