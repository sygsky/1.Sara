// scripts/nearBuilding.sqf
// Sygky
//
// Check nearest building
//
#include "x_setup.sqf"
#include "x_macros.sqf"

private ["_cmd","_nb", "_pos","_cnt","_pos1","_dist","_town_center","_tname","_param"];

#define inc(x) (x=x+1)
#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))

#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})
#define argoptp(a,num,val) (if((count a)<=(num))then{val}else{argp(a,num)})

#define argoptskip(num,defval,skipval) (if((count _this)<=(num))then{defval}else{if(arg(num)==(skipval))then{defval}else{arg(num)}})
#define argoptpskip(a,num,defval,skipval) (if((count a)<=(num))then{defval}else{if(argp(a,num)==(skipval))then{defval}else{argp(a,num)}})


//
//===================================================== MAIN CODE ===============================================
//
_cmd = (_this select 3);
_dist = 150;
_town_center = [];

if ( (typeName _cmd) == "ARRAY" ) then 
{
	_town_center = argoptp(_cmd,1,[]);
	_dist = argoptp(_cmd,2,150);
	_cmd  = argp(_cmd,0);
};

if ( _cmd == "" ) exitWith {}; // mothing to do

player groupChat format[ "Action run with [""%1"", %2, %3]", _cmd, _town_center, _dist ];

if ( count _town_center == 0 ) then
{
	if (isNil "town_center") then
	{
		// get nearest town center
		_loc = player call SYG_nearestSettlement;
		if (toUpper(format["%1",_loc]) == "NO LOCATION") then
		{
			// no ANY settlement found!!! This is some test map, not real world
			player groupChat format[ "No any  settlement found (""%1"")!!!", _loc];
		}
		else
		{
//			player groupChat format[ "nearest loc is ""%1""", _loc];
		};
		_town_center = position _loc;
	}
	else
	{
		_town_center = getPos town_center;
	};
//	player groupChat format[ "town_center %2isNil, _town_center %1]", _town_center, if (isNil "town_center") then {""} else {"!"}];
};

switch (toUpper _cmd) do
{
	case "TELEPORT": {
		_nb = [_town_center, 10, _dist, 4] call SYG_nearestGoodHouse;
		if ( !isNull _nb) then
		{
			_id = [_nb, "RANDOM_CENTER",20] call SYG_teleportToHouse;
/* 		_cnt  = _nb call SYG_housePosCount;
		_beam = floor (_cnt / 2);
		_pos = _nb buildingPos _beam;
		player setPos _pos;
		
 */	//		player groupChat format["TELEPORT: player teleported to building %1, pos %2", typeOf _nb, _id];
		}
		else
		{
			player groupChat format["TELEPORT: no building found at pos %1, dist %2", _town_center, _dist];
		};
	};
	case "TELEPORT_TARGET_TOWN":
	{
		_target_town = argp(target_names,current_target_index);
		_str = format["Teleported to %1",argp(_target_town,1)];
		_ret = [_target_town,_dist,4] call SYG_teleportToTown;
		switch _ret do
		{ 
			case 1: 
			{
/*			
				SYG_intelObjects = 	
				[
					[[9709.46,9960.43,1.4], 155, "Computer", "scripts\computer.sqf", "STR_COMP_ENTER"],
					[[9712.41,9960,0.6], 90, "Wallmap", ""]
				];
*/
				[argp(argp(SYG_intelObjects,0),0), 10,_scorePlus, _scoreMinus] execVM "GRU_scripts\GRU_townreconnaissance.sqf";
			}; 
			case 0: {_str = "TELEPORT_TARGET_TOWN: bad parameters"}; 
			default {_str = "TELEPORT_TARGET_TOWN: unknown error"};
		};
		hint localize _str;
	};
	case "TELEPORT_NEXT": { // teleport to the next town in the main list
		if ( isNil "SYG_nextTownId") then
		{
			SYG_nextTownId = 0;
		};
		_town_center1 = argp(target_names,SYG_nextTownId);
		_tname = argp(target_names,SYG_nextTownId) select 1;
		_town_center = argp(_town_center1,0);
		_nb = objNull;
		_cnt = 4; // min pos counter
		player removeAction teleactid;
		[_town_center1, _dist, _cnt] call SYG_teleportToTown;
		SYG_nextTownId = SYG_nextTownId + 1; // this time next town
		if ( SYG_nextTownId >= count target_names ) then
		{
			SYG_nextTownId = 0;
		};
		_tname = argp(target_names,SYG_nextTownId) select 1;

		teleactid = player addAction [format["teleport to %1", _tname], "scripts\nearBuilding.sqf",["TELEPORT_NEXT",[],150]];
	};

	case "TOWNINFO": {
		_nb = [_town_center, 10, _dist] call SYG_nearestGoodHouse;
		if ( !isNull _nb) then
		{
			player groupChat format["TOWNINFO: Building %1, dist from pos %2, positions %3", typeOf _nb, _nb distance _town_center, (_nb call SYG_housePosCount)];
		}
		else
		{
			player groupChat format["TOWNINFO: no buildings at dist %1 from town center %2", _dist, _town_center];
		};
	};
	case "BUILDINGINFO":
	{
		_nb = [getPos player, 10, _dist] call SYG_nearestGoodHouse;
		if ( !isNull _nb) then
		{
			player groupChat format["BUILDINGINFO: %1, dist from pos %2, positions %3", typeOf _nb, _nb distance _town_center, (_nb call SYG_housePosCount)];
		}
		else
		{
			player groupChat format["BUILDINGINFO: no found dist %1 from town center %2", _dist, _town_center];
		};
	};
	case "INFO";
	default {
		_nb = nearestBuilding player;
		player groupChat format["INFO: Building %1, dist from pos %2, positions %3", typeOf _nb, _nb distance player, (_nb call SYG_housePosCount)];
		
		[_town_center, 300, true] call SYG_getScore4IntelTask;
/* 		_info  = [west, _town_center, _dist] call SYG_sideStat;
		player groupChat format["_info %1",_info];
		_stat = _info call SYG_statScore;
		hint localize format["West stat on TOWN: side %1, cnt %8, score %9, men %2, static %3, tank %4, apc %5, car %6, aa %7", west,argp(_info,0),argp(_info,1),argp(_info,2),argp(_info,3),argp(_info,4),argp(_info,5), argp(_stat,0), argp(_stat,1)];
		
		_info  = [east, _town_center, _dist] call SYG_sideStat;
		_stat1 = _info call SYG_statScore;
		hint localize format["East stat on town: side %1, cnt %8, score %9, men %2, static %3, tank %4, apc %5, car %6, aa %7", east,argp(_info,0),argp(_info,1),argp(_info,2),argp(_info,3),argp(_info,4),argp(_info,5), argp(_stat1,0), argp(_stat1,1)];
		
//		_arr = nearestObjects [_town_center, ["BMP2_MHQ"], _dist + 50];
		_arr = _town_center nearObjects ["BMP2_MHQ", _dist + 100];
		
		_resultScore = (argp(_stat,1)/ ((count _arr) +1) - argp(_stat1,1) * 2) max 0;
		hint localize format["******** Result score for town is %1 / %2  - %3 == %4",argp(_stat,1), ((count _arr) +1),argp(_stat1,1) * 2, round(_resultScore / 10) * 10];
 */	
	};
};

if (true) exitWith {};