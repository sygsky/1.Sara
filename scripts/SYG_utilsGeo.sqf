/**
 *
 * SYG_utilsGeo.sqf : utils for geography functions
 *
 */
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "GRU_setup.sqf"

#define inc(x) (x=x+1)
#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))

#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})
#define argpopt(a,num,val) if((count a)<=(num))then{val}else{argp(a,num)}
#define argoptskip(num,defval,skipval) (if((count _this)<=(num))then{defval}else{if(arg(num)==(skipval))then{defval}else{arg(num)}})

if ( isNil "SYG_UTILS_GEO_COMPILED" ) then  // generate some static information
{
	SYG_UTILS_GEO_COMPILED = true;

#ifdef __DEFAULT__

	SYG_Sahrani_p0 = [13231.3,8890.26,0]; // City Corazol center
	SYG_Sahrani_p1 = [14878.6,7736.74,0]; // Vector dividing island to 2 parts (North and South) begininig, point p1
	SYG_Sahrani_p2 = [5264.39,16398.1,0]; // Vector dividing island to 2 parts (North and South) end, point p2
	SYG_Sahrani_desert_max_Y = 7890; // max Y coordinates for desert region of sahrani

	SYG_Sahrani_desert_rects = // rectangles containing all desert lands
	[
	    [   [9529,  4390,0], 10000, 3500,  0 ],
	    [   [17551,18732,0],  1200, 1200,  0 ],
	    [   [7873,  9107,0],  2000,  500, 315 ] // Ambergris (on coast west from Chantico)
    ];

	SYG_SahraniIsletCircles = 
	[
		["isle1",[12281.7,10650.4,0],600, "острова в заливе Abra de Boca"],
		["isle2",[14019.2,8010.04,0],220, "Islas Gatunas"],
		["isle3",[17497.5,4029.05,0],1500,"Antigua Isles group"],
		["isle4",[17462.2,18669.0,0],1500,"Юго-восточные острова"],
		["isle5",[7821.18,14328.8,0],400, "Trelobada"],
		["isle6",[5159.06,15475.9,0],1000,"Isla de Vassal"],
		["isle7",[2115.56,17959.3,0],1100,"Most western islets"],
		["isle8",[10755.2,16742.6,0],200, "Isla des Compadres"],
		["isle9",[9533.61,3497.75,0],500, "San Tomas"],
		["isle10",[11630.9,16940.8,0],50, "полуостров в заливе Porto de Perolas"],
		["isle11",[11801.7,11435.4,0],200,"островки на юго-западном побережье Северного Сахрани, залив Абра да Бока"]
	];

	SYG_RahmadiIslet = ["isle12",[2537.55,2538.37,0],1500,"Rahmadi"];

    SYG_chasmArray = [
        [[14269,10545,0],70,[13919,10632,0], "Obregan"],
        [[11725,15467,0],70,[11371,14877], "Pesados"]
    ];

#endif

};	

//
// Checks if pos of vehicle is in one of chasm (no exit by BIS algorithm)
// if found that chasm wayout waypoit is returned
// if not in chasm, empty array is returned
//  call:
//  _newWP = (getPos _vehicle) call SYG_chasmExitWP;
//  if ( count _newWP == 3) _vehicle addWP _newWP
//
SYG_chasmExitWP = {
    private ["_ret","_center","_radious"];
   _ret = [];
#ifdef __DEFAULT__
    if ( typeName _this == "OBJECT") then
    {
        _this = getPos _this;
    };
    if ( typeName _this != "ARRAY") exitWith
    {
        _ret
    };
    if ( count _this != 3 ) exitWith
    {
        _ret
    };
    {
        _center = _x select 0;
        _radious = _x select 1;
        if ([_this, _circle, _radious] call SYG_pointInCircle) exitWith
        {
            // yes, in circle
            _ret = _x select 2;
        };
    } forEach SYG_chasmArray;
#endif
    _ret
};

/**
 * Finds designated location type nearest to the designated point within designated radious
 * Call:
 *     _ret = [<getPos >player,["Name","NameCity","NameCityCapital","NameVillage","NameLocal"...], 1000] call SYG_nearestLocation;
 * returns:
 *      location : nearest location of designated settlement types
 * to get position of location, call _pos = position _loc;
 * to get text of location call _text = text  _loc;
 * if no such location found, returns objNull
 */
SYG_nearestLocationD = {
	private ["_loc"];
	_loc = [arg(0),arg(1)] call nearestLocationA;
	if ( ((position _loc) distance arg(0)) > arg(2)) then {_loc = objNull;};
	_loc
};

/**
 * Finds nearest to the designated point location from designated location type list
 * Possible calls form:
 *     _ret = [player, _locTypeList] call SYG_nearestLocationA;
 *     _ret = [(getPos player), _locTypeList] call SYG_nearestLocationA;
 *     _ret = [_group, _locTypeList] call SYG_nearestLocationA;
 *     _ret = [_location, _locTypeList] call SYG_nearestLocationA;
 * returns:
 *      location : nearest location with designated in _locTypeList names or
 *      objNull if bad or  empty list is designated
 *
 * to get position of location, call: _pos = position _loc;
 * to text of location call: _text = text  _loc;
 */
SYG_nearestLocationA = {
	private ["_pos","_dist","_nearloc", "_loc","_lst","_ploc"];
	_pos = arg(0);
	switch (typeName _pos) do
	{
		case "OBJECT": {_pos = position _pos;};
		case "LOCATION": {_pos = locationPosition _pos;};
		case "ARRAY": {/* correct */};
		case "GROUP": { _pos = if ( isNull leader _pos) then {position ((units _pos) select 0)} else {position leader _pos};};
		default {/* error */};
	};
	_lst = arg(1);
	switch (typeName _lst) do
	{
		case "STRING": {_lst = [_lst];};
		case "ARRAY": {/* correct */};
		default {/* error */};
	};
	
	_dist = 9999999.9;
	_nearloc = objNull; // default value
	{
		_loc = nearestLocation [_pos, _x];
		_ploc = locationPosition _loc;
		if ( (_pos distance _ploc) < _dist ) then
		{
			_dist = _pos distance _ploc;
			_nearloc = _loc;
		};
	} forEach _lst; // search for any listed locations
	_nearloc
};

/**
 * Text name of location found with call to SYG_nearestLocation
 */
SYG_nearestLocationName = {text (_this call SYG_nearestLocation)};

/**
 * Call:
 *     _ret = getPos player call SYG_nearestLocation;
 *     //     or
 *     _ret = player call SYG_nearestLocation;
 * returns:
 *      location : nearest map well known name
 * to get position of location, call _pos = position _loc;
 * to text of location call _text = text  _loc;
 */
SYG_nearestLocation = {
	[_this, ["NameCity","NameCityCapital","NameVillage","NameLocal","NameMarine","Hill"]] call SYG_nearestLocationA
};

/**
 * Call:
 *     _ret = getPos player call SYG_nearestSettlement;
 *     //     or 
 *     _ret = player call SYG_nearestSettlement;
 * returns:
 *      location : nearest settlement 
 * to get position of location, call _pos = position _loc;
 * to text of location call _text = text  _loc;
 */
SYG_nearestSettlement = {
	[_this, ["NameCity","NameCityCapital","NameVillage"]] call SYG_nearestLocationA
};

/**
 * Finds nearest forest of any type
 * Call:
 *     _ret = getPos player call SYG_nearestForest;
 *     //     or 
 *     _ret = player call SYG_nearestSettlement;
 * returns:
 *      location : nearest good enough forest
 * to get position of location, call _pos = position _loc;
 * to text of location call _text = text  _loc;
 */
SYG_nearestForest = {
	[_this, ["VegetationBroadleaf","VegetationFir","VegetationPalm"]] call SYG_nearestLocationA
};

SYG_nearestHeight = {
    private [ "_loc", "_obj_arr" ];
	_loc = [_this, ["Mount"]] call SYG_nearestLocationA;
	// detect if some obstacles are near
	_loc
};

SYG_heightValue = {
    if (typeName _this != "LOCATION") exitWith {-9999.0};
    private [ "_veh", "_pos" ];
    _veh = "HeliHEmpty" createVehicleLocal locationPosition _this;
    _pos = getPosASL _veh;
    deleteVehicle _veh;
    _pos select 2;
};

SYG_heightIsGood = {
    private ["_obj_arr"];
	// detect if some obstacles are near
	_obj_arr =  nearestLocations  [ (locationPosition _this), ["RockArea"], 15 ];
	if (count _obj_arr > 0) exitWith {  player groupChat format["%1 RockArea[s]] in radius 15 m", count _obj_arr]; false };
	_obj_arr = (locationPosition _this) nearObjects ["Building", 15];
	if (count _obj_arr > 0) exitWith {  player groupChat format["%1 NonStrategic obj[s] in radius 15 m: %2",count _obj_arr, typeName (_obj_arr select 0)]; false };
	(count _obj_arr) == 0
};

SYG_clearAroundHeight = {
	// detect if some obstacles are near
	_obs_arr =  nearestLocations [(position _this),["RockArea","VegetationBroadleaf","VegetationFir","VegetationPalm","VegetationVineyard"],15];
};

/**
 * Zone can be as follows:
 * 1. Main target town
 * 2. Occupied town
 * 3. Airbase
 * 4. Secondary target point
 * 5. Geographic location on map (village, town, city, some natural zone names etc)
 *
 * call: _pos_arr= [_pos,_same_island_part,_wanted_zones_list<,_min_dist>] call SYG_nearestZoneOfInterest;
 *
 * Where:
 *  _pos: position or object to search proximity for
 *  _same_island_part: boolean, if TRUE only zones on the same Sahrani part will be used else zones on both parts will be seeked
 *	designated_zones: array of follow string for requested war zone types
 *                a) - main target town (if assigned) "MAIN"
 *                b) - occupied town (if any occupied) "OCCUPIED"
 *                с) - airbase (if there is some desant on it) "AIRBASE"
 *                d) - sidemission target (if not on Rahmadi) "SIDEMISSION"
 *                e) - location "LOCATION", including "NameCity","NameCityCapital","NameVillage","NameLocal"
 *                f) - settlement "SETTLEMENT", including "NameCity","NameCityCapital","NameVillage"
 * _min_dist    : minimum distance to the designated position, optional, default is 999999.9 meters (all the Arma universe)
 *
 * E.g.: _res_arr = [getPos player, false,["MAIN","OCCUPIED","AIRBASE","SIDEMISSION","LOCATION","SETTLEMENT"],1000] call SYG_nearestZoneOfInterest;
 *
 * Returns: array of 
 *  [ [_posMain,_posOccupied,_posAirbase,_posSecondary, ...etc], _nearestIndex]
 *	with 1st array of same size as input one containing corresponding positions of zones found, where [] pos means of no value, 
 *  and 2nd item (_nearestIndex) stand for index in original array with shortest distance to the closest zone type. 
 *  _nearestIndex -1 means NO any zone found. It is possible when you search only for ["MAIN"<,"SIDEMISSION"<,"OCCUPIED">>] at start
 *  or end of game or in very-very rare moments between main/secondary/occupied mission is finshed and still not started
 */
SYG_nearestZoneOfInterest = {
	private ["_dist","_dist1","_min_dist","_wanted_dist","_reta","_pos","_pos1","_pos2","_ret","_part","_part1","_same_part","_opt","_opts"];
	
	_pos          = arg(0);
	_same_part    = arg(1);
	_opts         = arg(2);
	_wanted_dist  = argopt(3,999999.9);
	_ind = -1;
	_reta = [];
	
//	hint localize format[ "SYG_nearestZoneOfInterest: pos %1, same %2, opts %3, dist %4", _pos, _same_part, _opts, _wanted_dist];
	
	if ( count _opts > 0 ) then
	{
		if ( typeName _pos != "ARRAY" ) then { _pos = position _pos;};
		_part = _pos call SYG_whatPartOfIsland; // island part (upper, lower) for designated point
		if ( _same_part ) then // check need for the same part
		{
			if ( _part == "CENTER" ) then {_same_part = false;}; // doesn't matter where is situated tested point according to the Corazol city
		};
		
		_min_dist = 9999999.9;
		for "_i" from 0 to (count _opts) - 1  do
		{
			_opt = toUpper (_opts select _i);
			_dist = -1;
			_pos1 = [];
			switch _opt do
			{
				case "MAIN": 
				{
					_ret = call SYG_getTargetTown; // returs some about [[9348.73,5893.4,0],"Cayo", 210]
					if ( count _ret > 0 ) then 
					{
						_pos1 = _ret select 0;
						_part1 = _pos1 call SYG_whatPartOfIsland;
						if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then
						{
							if (count _ret > 0) then {_dist = _pos distance (_ret select 0);};
						};
					};
				};
				case "AIRBASE": 
				{
					if ( !isNil "FLAG_BASE" ) then
					{
						_pos1 = position FLAG_BASE;
						_part1 = _pos1 call SYG_whatPartOfIsland;
//						hint localize format[ "SYG_nearestZoneOfInterest: same part %1, _pos1 %2, _pos %3, dist %4", _same_part, _pos1, _pos, round(_pos1 distance _pos) ];
						if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part) ) then
						{
							_dist =  _pos1 distance _pos;
						};
					};
					
				};
				case "LOCATION": 
				{
					_pos1 = _pos call SYG_nearestLocation; // location returned!!!
					_part1 = _pos1 call SYG_whatPartOfIsland;
					if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then
					{
						_dist =  _pos distance _pos1;
					};
				};
				case "SETTLEMENT": 
				{
					_pos1 = _pos call SYG_nearestSettlement; // settlement returned!!!
					_part1 = _pos1 call SYG_whatPartOfIsland;
					if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then
					{
						_dist = _pos distance _pos1;
					};
				};
				case "OCCUPIED": 
				{
					if ( isServer ) then
					{
						_pos2 = [];
						{
							_ret = target_names select _x; //  e.g. [[9348.73,5893.4,0],"Cayo", 210],
							_pos1 = _ret select 0;
							_part1 = _pos1 call SYG_whatPartOfIsland;
							if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then
							{
								_dist1 = _pos1 distance _pos;
								if ( (_dist1 < _dist) || (_dist < 0)) then { _dist = _dist1; _pos2 = _pos1;};
							};
						} forEach d_recapture_indices;
						_pos1 = _pos2;
					};
				};
				case "SIDEMISSION": 
				{
					if (!all_sm_res AND !side_mission_resolved AND (current_mission_index >= 0)) then
					{
						if ( !(current_mission_index in [51,52,20,21,22]) ) then // don't use non-static sidemissions (convoys, pilots etc)
						{
							_pos1 = x_sm_pos select 0;
							if (!(_pos1 call SYG_pointOnIslet) || (_pos1 call SYG_pointOnRahmadi)) then // filter out any islet missions
							{
								_part1 = _pos1 call SYG_whatPartOfIsland;
								if ((!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then // it is possible to reach from designated point
								{
									// check if mission is on any of islets
									_dist = _pos distance _pos1;
								};
							};
						};
					};
				};
			};
			if ( (_dist < _wanted_dist) && (_dist < _min_dist)  && (_dist >= 0) ) then {_min_dist = _dist; _ind = _i;};
			_reta set [_i, _pos1];
		};
	};
	[_reta,_ind]
};
 
/**
 * call:
 *    _part = _getPos player call SYG_whatPartOfIsland; // "NORTH", "SOUTH", "CENTER" for Corazol area
 */
SYG_whatPartOfIsland = {
	private ["_pos","_str","_res"];
	_pos = [];
	switch toUpper(typeName _this) do
	{
		case "OBJECT": {_pos = getPos _this;};
		case "LOCATION": {_pos = locationPosition _this;};
		case "GROUP": {_pos = getPos leader _this;};
		case "ARRAY": {_pos = _this;};
	};
	_str = "<ERROR DETECTED>";
	if ( count _pos > 0 ) then
	{
		_res = _pos distance SYG_Sahrani_p0;
		if ( _res < 500 ) then {_str = "CENTER";} else
		{
			_res = [SYG_Sahrani_p1,SYG_Sahrani_p2,_pos] call SYG_pointToVectorRel; // vector comes approximately from S-E to N-W through Corazol
			_str = if (_res >= 0) then {"NORTH"} else {"SOUTH"};
		};
	};
	_str
};

/**
 * Decides if point is in desert region or no
 * call:
 *    _amIInDesert = _getPos player call SYG_isDesert; // TRUE or FALSE
 */
SYG_isDesert = {
	private ["_pos","_ret"];
	_pos = [];
	switch toUpper(typeName _this) do
	{
		case "OBJECT": {_pos = getPos _this;};
		case "LOCATION": {_pos = locationPosition _this;};
		case "GROUP": {_pos = getPos (leader _this);};
		case "ARRAY": {_pos = _this;};
	};
	//hint localize format["*** %1 call SYG_isDesert", _this];
	if ( (count _pos) < 2 ) exitWith {hint localize format["--- SYG_isDesert bad param!"]; false};
	// this is a max Y coordinate of desert region on Sahrani (by my estimation)
	//argp(_pos,1) < SYG_Sahrani_desert_max_Y
	_ret = false;
    {
        //hint localize format["*** %1 call SYG_pointInRect", [_pos,_x]];
        if ([_pos,_x] call SYG_pointInRect) exitWith {_ret = true};
    } forEach SYG_Sahrani_desert_rects;
    _ret
};

/**
 * Detects if point is on any of small islet, not on main Island Sahrani
 * call:
 *    _bool = (getPos player) call SYG_pointOnIslet; // true or false is returned
 */
SYG_pointOnIslet = {
	private ["_ret"];
	_ret = false;
	if (typeName _this != "ARRAY") then {_this = position _this;};
	{
		if ([_this,_x select 1, _x select 2] call SYG_pointInCircle) exitWith {_ret = true;};
	}forEach SYG_SahraniIsletCircles;
	_ret
};

/**
 * Detects if point is on any of small islet, not on main Island Sahrani
 * call:
 *    _bool = (getPos player) call SYG_pointOnIslet; // true or false is returned
 */
SYG_pointOnRahmadi = {
	if (typeName _this != "ARRAY") then {_this = position _this;};
	[_this,SYG_RahmadiIslet select 1, SYG_RahmadiIslet select 2] call SYG_pointInCircle
};

/**
 * call: 
 *   _reta =  call SYG_getTargetTown;
 * Where:
 *   _reta is _target_array (e.g. [[9348.73,5893.4,0],"Cayo", 210] ) or empty array ([]) if target not available
 */
SYG_getTargetTown = {
	private [ "_ret","_cur_cnt" ];
	_ret = [];
	// target_clear == false if town still not liberated and still occupied
	_cur_cnt = if ( isServer ) then {current_counter} else {client_target_counter};
	if ( (_cur_cnt <= number_targets) && (!target_clear) && (current_target_index >=0)) then
	{
		_ret = target_names select current_target_index; //  e.g. [[9348.73,5893.4,0],"Cayo", 210],
	}
	else
	{
		hint localize format["--- error in SYG_getTargetTown: time=%3,c_c=%1,c_c2=%5,t_c=%2,c_t_i=%4",_cur_cnt, target_clear, call SYG_nowTimeToStr,current_target_index,current_counter];
	};
	_ret
};

//
// call:
//   _tgtname = call SYG_getTargetTownName;
// returns: found town name or "<not defined>" if not
//
SYG_getTargetTownName = {
	private [ "_ret" ];
	_ret = call SYG_getTargetTown;
	if (count _ret == 0 ) then {"<not defined>"} else { _ret select 1};
};

/**
 * Returns index for current side mission. If no mission is available, -1 is returned;
 * call:
 *      _smindex = call SYG_getSideMissionIndex;
 */
SYG_getSideMissionIndex = {
	if (!all_sm_res AND !side_mission_resolved AND (current_mission_index >= 0)) then {current_mission_index} else {-1};
};

//==================================
// read marker info struct as follows: [center_point,a,b,angle,type]
// where center_point is: [x,y,z]
//       a - axis on X
//       b - axis on Y
//       angle - rotation in right system (from X axis to clockwise)
//       type for marker is one of Arma's ones - "RECTANGLE", "ELLIPSE" or "ICON"
//
// call: _descr = ["marker_name",SHAPE] call SYG_readMarkerInfo; // SHAPE if of follow types: "RECTANGLE,"ELLIPSE"
// 
// if marker not exists or bad parameter designated, empty array returned: []
//
SYG_readMarkerInfo = {
	private ["_shape","_size","_name"];
	_shape = toUpper(arg(1));
	if ( !(_shape in ["ELLIPSE","RECTANGLE"]) ) exitWith {[]};
	_name = arg(0);
	if ( markerType _name == "" ) exitWith {[]};
	_size = markerSize _name;
	[markerPos _name, argp(_size,0),argp(_size,1),markerDir _name,_shape]
};

/**
 * Detects if a designated point is in a designated marker of any form
 *
 * call:
 *      _bool = [pnt,[center_point,  width,height,angle,"RECTANGLE"]] call SYG_pointInMarker;
 *      _bool = [pnt,[center_point,  width,height,angle,"ELLIPSE"  ]] call SYG_pointInMarker;
 *      _bool = [pnt,[center_point,radious,     0,    0,"CIRCLE"   ]] call SYG_pointInMarker;
 *      _bool = [pnt,[center_point,radious                         ]] call SYG_pointInMarker; // for circles
 *      _bool = [pnt,[center_point,  width,height,angle            ]] call SYG_pointInMarker; // for rectangle
 *      _bool = [pnt,[center_point,  width,height                  ]] call SYG_pointInMarker; // for rectangle withno rotation
 *      _bool = [pnt,marker_name,shape] call SYG_pointInMarker; // shape is "CIRCLE" or "ELLIPSE" or "RECTANGLE"
 * note: angle is counted clockwise from 0 of Dekart x-axis. So it is -angle in real
 */
SYG_pointInMarker = {
	private ["_pnt","_mrk","_ret"];
	_mrk = arg(1);
	switch typeName _mrk do
	{
		case "ARRAY":  // marker description array (by Xeno, 4 params for rectangle, 2 - for circle)
		{
			switch  count _mrk do
			{
				//hint localize format["Marker for circle ""%1"" converted to a form [center,w,h,angle]",_mrk];
				case 2: {_mrk = [argp(_mrk,0), argp(_mrk,1),0,0,"CIRCLE"];};
				case 3: {_mrk = [argp(_mrk,0), argp(_mrk,1),argp(_mrk,2),0,"RECTANGLE"];};
				case 4: {_mrk = [argp(_mrk,0), argp(_mrk,1),argp(_mrk,2),argp(_mrk,3),"RECTANGLE"];};
			};
		};
		case "STRING":  // marker name, convert to Xeno array
		{
			//hint localize format["Marker ""%1"" converted to a form [center,w,h,angle]",_mrk];
			_mrk = [_mrk,arg(2)] call SYG_readMarkerInfo;
			hint localize format["%1",_mrk];
		};
	};
	_pnt = arg(0);
	_ret = false;
	switch argp(_mrk,4) do
	{
		case "CIRCLE": 
		{
			_ret = [_pnt, argp(_mrk,0),argp(_mrk,1)] call SYG_pointInCircle;
		};
		case "ELLIPSE": 
		{
			_ret = [_pnt, _mrk] call SYG_pointInEllipse;
		};
		case "RECTANGLE": 
		{
			_ret = [_pnt, _mrk] call SYG_pointInRect;
		};
	};
	_ret
};

// west names
SYG_gendirlistW = ["N","N-NE","NE","E-NE","E","E-SE","SE","S-SE","S","S-SW","SW","W-SW","W","W-NW","NW","N-NW","N"];
// east names
SYG_gendirlistE = ["C","С-СВ","СВ","В-СВ","В","В-ЮВ","ЮВ","В-ЮВ","Ю","Ю-ЮВ","ЮЗ","З-ЮЗ","З","З-СЗ","СЗ","С-СЗ","С"];
// call: _dirname = _dir call SYG_getDirName;
SYG_getDirName = {
//	hint localize format["SYG_getDirName: this %1", _this];
	_this  = _this mod 360;
	if ( _this < 0 ) then {_this = _this + 360;};
	switch localize "STR_LANG" do
	{
		case "RUSSIAN": { SYG_gendirlistE select (round (_this/22.5))};
		case "ENGLISH";
		case "GERMAN";
		default { SYG_gendirlistW select (round (_this/22.5))};
	};
};

SYG_getDirNameEng = {
//	hint localize format["SYG_getDirNameEng: this %1", _this];
		_this  = _this mod 360;
	if ( _this < 0 ) then {_this = _this + 360;};
	SYG_gendirlistW select (round (_this/22.5))
};

//++++++++++++++++++++++++++++++++++++ START of GRU SERVICES ++++++++++++++++++++++++++++++++

// how far to check GRU houses
#define GRU_HOUSE_SEARCH_DIST 250

// Ids of houses GRU can use as computer link center, 82124 is house near airfield and base building
SYG_intelHouseIds = [82124,220,354,356,360];
SYG_intelObjects =
[
	[[9709.46,9960.43,1.4], 155, "Computer", "GRU_scripts\computer.sqf", "STR_COMP_ENTER"],
	[[9712.41,9960,0.6], 90, "Wallmap", "GRU_scripts\mapAction.sqf","STR_CHECK_ITEM"]
	// GRUBox position[]={9707.685547,143.645111,9963.350586};	azimut=90.000000;
];

SYG_intelThingsRelArr =
[
    "Land_army_hut2_int", // type of house
    [[-0.0595703, -1.77051, -0.173746], 155,      "Computer", objNull], // 1st thing
    [[   2.89063,  -2.2002, -0.973746],  90,       "Wallmap", objNull], // 2nd
    [[  -1.83398,  1.09961, 0.0312543],  90, "ACE_WeaponBox", objNull]  // 3rd
];

SYG_computerPos = {getPos (call SYG_getGRUComp)};
SYG_mapPos = {getPos (call SYG_getGRUMap)};
SYG_GRUHouseType = {argp(SYG_intelThingsRelArr,0)};

//
// call: _dist = _obj call SYG_distToGRUComp;
//       _dist = (getPos _obj) call SYG_distToGRUComp; 
// 
SYG_distToGRUComp = [_this, call SYG_computerPos] call SYG_distance2D;

SYG_getGRUCompPos = SYG_computerPos;
SYG_getGRUMapPos = SYG_mapPos;

if (isServer) then
{
    SYG_getGRUComp = {argp(argp(SYG_intelThingsRelArr,1),3)};
    SYG_getGRUMap = {argp(argp(SYG_intelThingsRelArr,2),3)};}
else
{
SYG_getGRUComp = {
        _list = FLAG_BASE nearObjects [call SYG_getGRUCompType, GRU_HOUSE_SEARCH_DIST];
        if ( count _list == 0) exitWith {objNull};
        argp(_list,0);
    };
    SYG_getGRUMap = {
        _list = FLAG_BASE nearObjects [call SYG_getGRUMapType, GRU_HOUSE_SEARCH_DIST];
        if ( count _list == 0) exitWith {objNull};
        argp(_list,0);
    };
};

SYG_getGRUCompActionTextId = {
	argp( argp(SYG_intelObjects, 0), 4 )
};

SYG_getGRUCompType = {argp(argp(SYG_intelThingsRelArr,1),2)};

SYG_getGRUCompScript = {
	argp( argp(SYG_intelObjects, 0), 3 )
};

SYG_getGRUMapActionTextId = {
	argp( argp(SYG_intelObjects, 1), 4 )
};

SYG_getGRUMapType = {argp(argp(SYG_intelThingsRelArr,2),2)};

SYG_getGRUMapScript = {	argp( argp(SYG_intelObjects, 1), 3 ) };

SYG_getMainTaskTargetPos = {arg((call SYG_getTargetTown),0)};

///////////////////////////////////////////////////////////////////////////// GRU Computer handling functions
#define __DEBUG_COMP__
//
// Updates GRU house equipment. Call only from server if MP
// 1. Check for the computer house presence,
// 2. Check for computer presence if not present, create all equipment
// 3. Check if computer is in nearest house
// 4. if true, wait until next loop
// 5. if false, moves computer to the nearest hose
//
SYG_updateIntelBuilding = {
	private ["_house","_compArr","_comp","_pos","_pos1","_mapArr","_maps","_map"];
	// get nearest house
	// 1. check if equipment exists at all
	// check comp
	_compArr = argp(SYG_intelObjects, 0);
	_comp = nearestObject [ argp(_compArr, 0), argp(_compArr, 2) ];
	if ( isNull _comp ) then // create it
	{
		_comp = argp(_compArr,2) createVehicle [0,0,0];
		_comp setPos argp( _compArr, 0 );
		_comp setDir argp( _compArr, 1);
#ifdef __DEBUG_COMP__		
		hint localize "SYG_updateIntelBuilding: computer created";
#endif
		
		sleep 0.1;
#ifdef __LOCAL__
		playSound "ACE_VERSION_DING"; // inform about computer creation
		// add action
		_comp addAction [ localize argp(_compArr,4), argp(_compArr,3) ];
#else
		hint localize "GRU_msg: GRU_MSG_COMP_CREATED sent to clients";
		["GRU_msg", GRU_MSG_COMP_CREATED] call XSendNetStartScriptClient;
#endif
	}
	else
	{
		// 1.1 check if equipment is damaged or stand not on place
		//if ( !alive _comp) then { _comp setDamage 0;};
		_pos  = getPos _comp;
		_pos1 = argp(_compArr, 0);
		_pos set [2, 0];
		_pos1 = [argp(_pos1,0), argp(_pos1,1),0];
		if ( ((_pos distance _pos1) > 0.1) || (((vectorUp _comp) distance [0,0,1]) > 0.1 ) ) then 
		{
			_pos = argp(_compArr, 0);
			_comp setPos _pos;
			sleep 0.01;
			_comp setVectorUp [0,0,1];
			_comp setDir argp(_compArr, 1);
			sleep 0.01;
		};
	};
	
	// TODO: play with building
/* 	_house = nearestBuilding _comp;
	if ( _house distance _comp > 5 ) exitWith { hint localize "SYG_updateIntelBuilding: no house found" };
 */	
	// check map
	sleep 0.01;
	_mapArr = argp(SYG_intelObjects,1);
	_map = objNull;
	_maps = nearestObjects [ argp(_mapArr, 0), ["Wallmap","RahmadiMap"],10 ];
	// 2. check if map has correct image (Sahrani or Rahmadi)
	_name = if ( (call SYG_getTargetTownName) == "Rahmadi" ) then {"RahmadiMap"} else {"Wallmap"};
	if ( count _maps > 0) then // check type to be correct
	{
		_map = argp(_maps, 0);
		if ( typeOf _map != _name ) then 
		{
//			hint localize format["SYG_updateIntelBuilding: target town ""%3"", typeOf ""%1"" != ""%2"";",typeOf _map, _name, (call SYG_getTargetTownName) ];
			deleteVehicle _map;
			sleep 0.01;
			_map = objNull;
			sleep 0.02;
		};
	};
	
	if ( isNull _map ) then // create it
	{
//		hint localize format["SYG_updateIntelBuilding: create map ""%1""", _name];
		_map = _name createVehicle [0,0,0];
		sleep 0.1;
		_map setPos argp(_mapArr, 0);
		_map setDir argp(_mapArr, 1);
		sleep 0.1;
		//_mapArr set [0, getPos _map];
		["GRU_msg", GRU_MSG_INFO_TO_USER, GRU_MSG_INFO_KIND_MAP_CREATED] call XSendNetStartScriptClient;
	}
	else
	{
		// 1.1 check if equipment is damaged or stand not in place
		//if ( !alive _map) then { _map setDamage 0;};
		_pos  = getPos _map;
		_pos set [2, 0];
		_pos1 = argp(_mapArr, 0);
		_pos1  = [_pos1 select 0, _pos1 select 1, 0];
		if ( ((_pos distance _pos1) > 0.1) || ( ((vectorUp _map) distance [0,0,1]) > 0.1 ) ) then 
		{
			_map setVectorUp [0,0,1];
			_map setPos argp(_mapArr, 0);
			_map setDir argp(_mapArr, 1);
			sleep 0.01;
		};
	};
};

//
// _result = [_objIndex, _type] call  SYG_recreateGRUObj;
//
SYG_recreateGRUObj =
{
    if ( typeName _this != "ARRAY" ) exitWith { hint localize "SYG_recreateGRUObj: 1st argument is not array"; false };
    if (count _this < 2) exitWith {false};
    _ind = arg(0);
    if ( typeName _ind != "SCALAR" ) exitWith { hint localize "SYG_recreateGRUObj: 1st argument of partam array not scalar"; false };
    _objArr = argp( SYG_intelThingsRelArr, _ind );
    _obj = argpopt( _objArr, 3, objNull );
    if ( isNull _obj ) exitWith {hint localize "SYG_recreateGRUObj: object to recreate in null";false}; // can't work with nothing
    _type = typeOf _obj;
    if ( _type == arg(1) ) exitWith { _obj setDamage 0;_obj setVectorUp [0,0,1]; false}; // no need to recreate obj (type is the same)
    player groupChat format["SYG_recreateGRUObj: Object type changed to %1", arg(1)];
    _pos = _obj modelToWorld [ 0, 0, 0 ];
    _dir = getDir _obj;
    hint localize format["SYG_recreateGRUObj: object %1 recreated to %2, action added", _type, arg(1)];
    _obj removeAction 0;
    _obj removeAction 1;
    deleteVehicle _obj;
    sleep 0.01;
    _obj = createVehicle [arg(1), [0,0,0], [], 0, "CAN_COLLIDE"];
    sleep 0.01;
    _obj setVectorUp [0,0,1];
    _obj setDir ( _dir);
    _obj setPos ( _pos);
    _objArr set [3, _obj]; // store new object in array

    true
};

//
// MAIN METHOD for GRU house and equipment. Call it periodically until it return false.
// If so (false returned) stop checking as it is more not possible to support GRU equipment (no more corresponding houses)
//
// Checks GRU object to be whole, not crashed.
//
// _result = _computer call SYG_checkGRUHouse; // false if GRU house and equipment is off forever, TRUE if GRU is on for this game
//
SYG_checkGRUHouse =
{
    private ["_house"];
    _comp = call SYG_getGRUComp;
    _list = [];
    _list = nearestObjects [ FLAG_BASE, ["Land_army_hut2_int"], 300 ]; // list of nearest Land_army_hut2_int
    hint localize format["Found %1 of Land_army_hut2_int building[s]", count _list];
    if( isNull _comp && count _list == 0 ) exitWith
    {
        player groupChat "End of GRU missions on base (no [more] houses/no computer)";
        false
    }; // not exists, no houses, exit

    _house = objNull;
    {
        _pos = _x modelToWorld [0,0,0];
        //player groupChat format["pos %1", _pos];
        if (argp(_pos,2) > -5) exitWith {_house = _x;};
    } forEach _list;

    if (isNull _house) exitWith // no houses, equipment still may exists, so wipe it out of island
    {
        player groupChat "End of GRU missions on base (no more houses), removing equipment";
        {
            _objArr = argp( SYG_intelThingsRelArr, _x );
            _obj    = argpopt(_objArr,3,objNull);
            if ( !isNull _obj ) then
            {
                _obj removeAction 0;
                _obj removeAction 1; // just in case
                deleteVehicle _obj;
                sleep 0.01;
                _objArr set [3, objNull];
            };
        } forEach [1,2,3];
        false
    };

    // play with map type: Sahrani or Rahmadi
    _name = "Wallmap"; // type name for the map
    if ( !isNil "SYG_getTargetTownName") then
    {
    	if ( (call SYG_getTargetTownName) == "Rahmadi" ) then { _name = "RahmadiMap" };
    };

    // 1. check equipment (comp, map, ammobox)
    if ( isNull _comp) exitWith // create computer etc first time
    {
        //player groupChat "Create GRU computer,map,ammobox";
        _houseDir = getDir _house;
        {
            _objRelArr = argp(SYG_intelThingsRelArr,_x);
            _objArr = [_house, [argp(_objRelArr,0),argp(_objRelArr,1)]]  call SYG_calcRelArr; // get position and dir of object
            _objType = argp( _objRelArr, 2 );
            _obj = createVehicle [ _objType, [0,0,0], [], 0, "CAN_COLLIDE"]; // create object to pos in house
            sleep 0.01;
            _obj setDir (argp(_objArr,1));
            _obj setPos (argp(_objArr,0));
            _obj setVectorUp [0,0,1];
            _objRelArr set [3, _obj]; // store object
            switch (_x) do {
                case 1: { _obj call SYG_addCompAction; };
                case 2: {_obj call SYG_addMapAction; };
                default { /* Nothing to do */ };
            };
        } forEach [1,2,3]; // comp(1), map(2), ammobox(3)
        hint localize "GRU computer + map + ammobox created";
        true
    };

    // 1. Checks computer to be in the unbroken house and map is standing upright
    _map = call SYG_getGRUMap;
    if ( ((_comp distance _house) > 3) || ( ((vectorUp _map) distance [0,0,1]) > 0.1 ) || ( ((vectorUp _comp) distance [0,0,1]) > 0.1 ))exitWith
    {
        player groupChat format["GRU computer found in ruines (%1), move it to the nearest house dist %2 m", _house, _comp distance _house ];
        {
            _objRelArr = argp(SYG_intelThingsRelArr,_x);
            _objArr = [_house, [argp(_objRelArr,0),argp(_objRelArr,1)]]  call SYG_calcRelArr; // calculate position and dir of object in format [[x, y, z], dir]
            player groupChat format["GRU thing now at %1", _objArr];
            _obj = argp(_objRelArr,3);
            _obj setDamage 0;
            _obj setDir (argp(_objArr,1));
            _obj setPos (argp(_objArr,0));
            _obj setVectorUp [0,0,1];
            if ( _x == 2 ) then // map
            {
                if ([2, _name] call SYG_recreateGRUObj ) then
                {
                    _obj setVehicleInit "this call SYG_addMapAction;";
                };
            };
        } forEach [1,2,3];
        processInitCommands;
        true
    };

    //player groupChat format["GRU computer is alive (%1) and in the house (%2)", getPos _comp, getPos _house];
    // check map type in case of change
    if ([2, _name] call SYG_recreateGRUObj) then // re-create map just in case
    {
        // update action
//        _obj addAction ["Изучить", "scripts\investigate.sqf"];
        _obj setVehicleInit "this call SYG_addMapAction;";
        processInitCommands;
    };
    true
};

// Adds action to the map
SYG_addMapAction = {
    _this removeAction 0;
    _this addAction [localize (call SYG_getGRUMapActionTextId), call SYG_getGRUMapScript];
};

// adds action[s] to the GRU computer
SYG_addCompAction = {
    {_this removeAction _x} forEach [0,1,2,3,4,5];
    _this addAction[localize (call SYG_getGRUCompActionTextId), call SYG_getGRUCompScript];
};

//------------------------------------ END of GRU SERVICES --------------------------------

//
// call as follow:
// [_display_id, _ctrl_id, _end_pos] call SYG_setMapPosToMainTarget;
//
// where 
//       _dialog_id = dialog for GRU tasks
//       _ctrl_id = id for map control in dialog
//       _end_pos = position to set map at end, start pos always is player position
//
SYG_setMapPosToMainTarget = {
	private ["_display","_ctrlmap","_start_pos"];
	if ( (count _this) < 3) exitWith {hint format["Expected number of params to call SYG_setMapPosToMainTarget is %1 (invalid, must be 3)", count _this];};
	_display = findDisplay arg(0);
	if (isNull _display) exitWith {hint format["Expected display id in [%1,%2,%3] call  SYG_setMapPosToMainTarget is invalid",arg(0),arg(1),arg(2)];};
	_ctrlmap = _display displayCtrl arg(1);
	ctrlMapAnimClear _ctrlmap;

	_start_pos = position player;
	_ctrlmap ctrlMapAnimAdd [0.0, 1.00, _start_pos];
	_ctrlmap ctrlMapAnimAdd [1.2, 1.00, arg(2)];
	_ctrlmap ctrlMapAnimAdd [0.5, 0.30, arg(2)];
	ctrlMapAnimCommit _ctrlmap;
};

// call: _dist = [_obj1||_pos1, _obj2||_pos2] call SYG_distance2D;
SYG_distance2D = {
	private ["_pos1", "_pos2"];
	_pos1 = arg(0);
	if ( typeName _pos1 == "OBJECT") then { _pos1 = position _pos1;};
	_pos2 = arg(1);
	if ( typeName _pos2 == "OBJECT") then { _pos2 = position _pos2;};
	[argp(_pos1,0), argp(_pos1,1)] distance [argp(_pos2,0),argp(_pos2,1)]
};

//
// Creates message with any object distance and direction according to the nearest location
// Input: _msg = player call SYG_MsgOnPos;
// Result message is localized as follow: "%DIST m. to %DIR from %LOC_NAME", please compound you messsage as follow:
// e.g. "You are " + "1400 м. to North from Bagango" 
// или "Вы на расстоянии " + "1400 м. к северу от Bagango"
//
SYG_MsgOnPos = {
	[_this, localize "STR_SYS_151"] call SYG_MsgOnPosA
};

//
// Creates localized message based on user format string with 3 params %1, %2, %3 in follow order:
// distance_to_location direction_to_location
//
// call as: _msg_localized = [_obj, _format_msg] call SYG_MsgOnPosA;
//
SYG_MsgOnPosA = {
	private ["_obj","_msg","_pos1","_pos2","_loc","_dir","_dist","_locname"];
	_obj = arg(0);
	_msg = arg(1);
	_loc = _obj call SYG_nearestLocation;
	_pos1 = position _loc;
	_pos1 set [2,0];
	_pos2 = position _obj;
	_pos2 set [2,0];
	_dist = (round ((_pos1 distance _pos2)/100)) * 100;
	_dir = ([locationPosition _loc, _obj] call XfDirToObj) call SYG_getDirName;
	_locname = text _loc;
	format[ _msg, _dist, _dir, _locname ]
};

//
// Creates english message based on user format string with 3 params %1, %2, %3 in follow order:
// distance_to_location direction_to_location location_name
//
// call as: _msg_eng = [_obj, _format_msg] call SYG_MsgOnPosE;
//
SYG_MsgOnPosE = {
	private ["_obj","_msg","_pos1","_pos2","_loc","_dir","_dist","_locname"];
	_obj = arg(0);
	_msg = arg(1);
	_loc = _obj call SYG_nearestLocation;
	_pos1 = position _loc;
	_pos1 set [2,0];
	_pos2 = position _obj;
	_pos2 set [2,0];
	_dist = (round ((_pos1 distance _pos2)/100)) * 100;
	_dir = ([locationPosition _loc, _obj] call XfDirToObj) call SYG_getDirNameEng;
	_locname = text _loc;
	format[ _msg , _dist, _dir, _locname ]
};

/*
 * Apppoximated distance to the base by feet in meters approximatelly

  calls:
        _dist = player call SYG_distToBase;
        _dist = (getPos player) call SYG_distToBase;
 */
SYG_distByCar = {
    (_this call SYG_geoDist) * 1.4
};

/*
 * Distance from 1st point to 2nd by land. To make it distance by car multiply result by 1.4.

  Calls:
        _dist = [player, FLAG_BASE] call SYG_distByCar;
        _dist = [_pos1, _pos2] call SYG_distByCar;
  Note:
        both points must be on mainland, not in water or on any of islets
  Returns -1 if parameters are invalid, distance between point by car/feet on the land
 */
SYG_geoDist = {
    if (typeName _this != "ARRAY") exitWith {-1};
    if (count _this != 2) exitWith{-1};
    private ["_pos1","_pos2","_pn1","_pn2","_part1","_part2","_onSamePart"];
    _pos1 = arg(0);
    _pos2 = arg(1);
    if (typeName _pn1 == "OBJECT") then {_pos1 = getPos _pos1;};
    if (typeName _pn1 != "ARRAY") then {-1};
    if (typeName _pn2 == "OBJECT") then {_pos2 = getPos _pos2;};
    if (typeName _pn2 != "ARRAY") then {-1};
    // "NORTH", "SOUTH", "CENTER"
    _part1 = _pos1 call SYG_whatPartOfIsland;
    _part2 = _pos2 call SYG_whatPartOfIsland;
    _onSamePart = (_part1 == "CENTER" || _part2 == "CENTER");
    if ((_part1 == _part2) || _onSamePart) exitWith {_pos1 distance _pos1};
    ((_pos1 distance SYG_Sahrani_p0) + (_pos2 distance SYG_Sahrani_p0))
};
/*
 * Finds nearest to the designated point/object boat station, marked by markers of follow names: "boats1", "boats2", ...
 * call: _obj call SYG_nearestBoatsMarker; // nearest marker of boat station
 * call: [_x,_y<,_z>] call SYG_nearestBoatsMarker; // nearest marker of boat station
 */
SYG_nearestBoatsMarker = {
    if (typeName _this == "OBJECT") then { _this = position _this};
    if (typeName _this != "ARRAY") exitWith {""}; // bad parameter in call
    if (count _this < 2) exitWith {""}; // bad array with position coordinates (length msut be 2..3)
    private ["_id","_near_dist","_near_marker_name","_marker","_mpos"];
    _id = 1;
    _near_dist = 999999;
    _near_marker_name = "";
    // find all boats marker
    while {true} do {
        _marker = format["boats%1", _id];
        if ( (getMarkerType _marker) == "") exitWith {}; 
        _mpos = getMarkerPos _marker;
        if ( (_mpos distance _this) < _near_dist) then {
            _near_dist =  _mpos distance _this;
            _near_marker_name = _marker;
        };
        _id = _id + 1;
    };
    _near_marker_name // return nearest marker name or "" if error occured
};
if (true) exitWith {};