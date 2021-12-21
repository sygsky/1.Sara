//SYG_ACTCheckHolders = player addAction ["Find holders (20 m)", "findbombs.sqf", [20]];
//SYG_ACTNoHolders = player addAction ["No holders (20 m)", "nogarbage.sqf", [20]];

//SYG_ACTLocTest = player addAction ["Locations test", "locsTest.sqf", [100]];

#include "x_macros.sqf"
#include "x_setup.sqf"

#define ROUND0(val) (round(val))
#define ROUND2(val) (round((val)*100.0)/100.0)
#define ROUNDPOS(vec) (vec set [0,round(vec select 0)];vec set [1,round(vec select 1)];vec set [2,round(vec select 2)];)
#define arg(num) (_this select(num))
#define argp(arr,num) ((arr)select(num))
#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})
#define argpopt(a,num,val) if((count a)<=(num))then{val}else{argp(a,num)}

#define inc(x) x=x+1
#define _PRINT(a) hint localize a; player groupChat a

//+++ Sygsky: Paraiso airfield coordinates and its boundary rectangle box (semi-axis sizes)
d_base_array        = [[9821.47,9971.04,0], 600, 200,0];
SYG_shortNightStart = 19.75;
SYG_shortNightEnd   = 4.6;

//#define __HINT_DISAPPERING_TEST__

// client utils
call compile preprocessFileLineNumbers "scripts\x_functions1.sqf";
call compile preprocessFileLineNumbers "scripts\x_functions2.sqf";

call compile preprocessFileLineNumbers "scripts\SYG_utils.sqf";

#ifndef __HINT_DISAPPERING_TEST__

[] spawn compile preprocessFileLineNumbers "showInfo.sqf";

#else

player groupChat "ShowInfo.sqf not spawned due to __HINT_DISAPPERING_TEST__ definition";

#endif

// from warfare
// Returns an average slope value of terrain within passed radius.
// a little bit modified. no need to create a "global" logic, local is enough, etc
// parameters: position, radius
// example: _slope = [the_position, the_radius] call XfGetSlope;
XfGetSlope = {
	private ["_position", "_radius", "_slopeObject", "_centerHeight", "_height", "_direction", "_count"];
	_position = +(_this select 0);
	_position set [2, 0];
	_radius = _this select 1;
	_slopeObject = "Logic" createVehicleLocal [0,0,0];
	_slopeObject setPos _position;
	_centerHeight = getPosASL _slopeObject select 2;
	_height = 0;_direction = 0;
	for "_count" from 0 to 7 do {
		_slopeObject setPos [(_position select 0)+((sin _direction)*_radius),(_position select 1)+((cos _direction)*_radius),0];
		_direction = _direction + 45;
		_height = _height + abs (_centerHeight - (getPosASL _slopeObject select 2));
	};
	deleteVehicle _slopeObject;
	_height / 8
};


//[300] spawn compile preprocessFileLineNumbers "showLocations.sqf";
//[] spawn compile preprocessFileLineNumbers "showLocations1.sqf";

sleep 1;

//onBriefingPlan "Fire";
//onBriefingNotes "Fountain";
//onBriefingGear "tune";
//onBriefingGroup "Dialogue";

/* {
	if (_x isKindOf "Motorcycle") then {player globalChat format["%1 is  Motorcycle", _x]}
	else {player globalChat format["%1 is  not Motorcycle", _x]};
} forEach [moto1,moto2,moto3,moto4];
 */
_motoarr = [getPos moto1,getPos moto2, getPos moto3, getPos moto4];
hint localize format["init.sqf: initial moto arr %1", _motoarr];

_handle = [moto1,moto2,moto3,moto4] spawn compile preprocessFileLineNumbers "motorespawn.sqf";


[civ, [["P", "ACE_SCAR_L_Marksman_SD", "ACE_30Rnd_556x45_BT_Stanag", 10], ["S","ACE_Glock18","ACE_33Rnd_9x19_G18",4 ],["E", "NVGoggles"], ["ACE_PipeBomb", 1]] + SYG_STD_MEDICAL_SET ] call SYG_armUnit;

[pl, [["P","ACE_RPG7_PGO7","ACE_RPG7_PG7VR",1],["P", "ACE_RPK74", "ACE_45Rnd_545x39_BT_AK", 5], ["S","ACE_Glock18","ACE_33Rnd_9x19_G18",4 ],["E", "NVGoggles","Binocular"], ["ACE_PipeBomb", 1]] + SYG_STD_MEDICAL_SET ] call SYG_armUnit;

pl setVariable ["ACE_weapononback","ACE_Rucksack_Alice"];
pl setVariable ["ACE_Ruckmagazines", [["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_Epinephrine_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3],["ACE_RPG7_PG7VR_PDM",1]]];

{
    ClearWeaponCargo _x;
    ClearMagazineCargo _x;
    //_x addMagazineCargo ["50Rnd_127x107_DSHKM",10];
    _x addMagazineCargo ["ACE_VOG30",10];
} forEach [ammo_box_pl_2,ammo_box_pl_3,ammo_box_pl_4,ammo_box_pl_5];

//player globalChat format["motorespawn.sqf: runned with handle %1", _handle];a

//#define __TEST_HOTEL_HIT__
#ifdef __TEST_HOTEL_HIT__
[] spawn {
	private ["_obj"];
	sleep 1.0;
	{
		_obj = [10000,10000,0] nearestObject _x;
		if ( !isNull _obj ) then
		{
        	player groupChat "Hotel event handled to ""HIT""";
			if ( typeOf _obj == "Land_Hotel" ) then
			{
				_obj addEventHandler ["hit",
				{
				    private [ "_str" ];
				    _str = format["Hotel damaged with %1, dmg = %2",_this select 2,getDammage (_this select 0)];
				    hint _str;
				    (_this select 0) setDammage -1;
                }];
                _obj addAction ["Погладить стенку!", "scripts\touch_hotel.sqf", []];
			};
		};
	} forEach [172902,64642,555078];
};
#endif

_towns = target_names;
	
// call: ["name",_pos] call setDot;
setDot = {
	private ["_mrkname","_mrkobj"];
	_mrkname= "mrk_" + arg(0);
	_mrkobj = createMarkerLocal[_mrkname,[0,0]];
	_mrkobj setMarkerShapeLocal "ICON";
	_markertype = if (isClass(configFile >> "cfgMarkers" >> "WTF_Dot")) then {"WTF_DOT"} else {"DOT"};
	_mrkname setMarkerTypeLocal _markertype;
	_markercolor = "ColorRed";
	_mrkname setMarkerColorLocal _markercolor;
	_mrkname setMarkerTextLocal format["%1",arg(0)];
	_mrkname setMarkerPosLocal arg(1);
	//player groupChat format["%1 -> %2", arg(0), arg(1)];
};
	
//-------------------------------------------------------
//
//
// [name, vec, radius, color, brush, shape, type] call _setMarker;
//
setMarker = {
	//player globalChat format["%1,%2,%3,%4,%5",arg(0),arg(1),arg(2),arg(3),arg(4)];
	private ["_arr", "_mrk", "_type"];
	_mrk = createMarkerLocal [ arg(0), arg(1)];
	_mrk setMarkerPosLocal arg( 1 );
	_mrk setMarkerSizeLocal [arg(2), arg(2)];
	_mrk setMarkerColorLocal  arg(3); 
	_mrk setMarkerBrushLocal arg(4);
	_mrk setMarkerShapeLocal argopt(5, "ELLIPSE");
	_type = argopt(6,"");
	if ( _type != "" ) then {
		_mrk setMarkerTypeLocal _type;
	};
};
//-------------------------------------------------------
//
// [vec, color, brush1, brush2] call _setMarkers;
//
//
setMarkers = {
	//player globalChat format["%1,%2,%3,%4", arg(0),arg(1), arg(2), arg(3)];
	private ["_pos", "_name"];
	_pos = arg(0) select 0;
	_name = arg(0) select 1;
	[ _name, _pos,             300, arg(1), arg(2)] call setMarker;
	//_pos set[0, (_pos select 0) + 300];
	_name = format["%1_real",_name];
	[ _name, _pos, arg(0) select 2, arg(1), arg(3)] call setMarker;
	_name = format["%1_center",_name];
	//["rainmarkt2", _pos,"ICON","ColorBlack",[0, 0],_text,0,"DOT"] call XfCreateMarkerLocal;
	[ _name, _pos, 0.1, "ColorBlack", "Solid", "ICON", "SELECT"] call setMarker;	
};

setViewDistance 6000; // radious of visibility
setTerrainGrid 50; // no grass
player groupChat "View Distance set to 6000 м";

_targets = []; //nearestobjects [FLAG_BASE, ["TargetEpopup"], 800];

{
    _pos = _x select 0; // position
    _target = "TargetEpopup" createVehicleLocal _pos; // create target at pos
    if ( count _x > 1) then { _target setDir (_x select 1);}; // set target direction if designated
    if ( _pos select 2 != 0) then { _target setPos _pos;}; // set target height, may  be this is not needed
	_targets = _targets + [_target];
}forEach [[
    [9663, 9898.2, 0], 180],[[9651.7, 9829.25, 4],180 ],[[9663, 9961, 0], 180],
    [[9700.05,10190.07,0]],
    [[10397.581,10003.883, 0], 90]
];

//_str =  format["%1 targets detected", count _targets];
_str =  format["%1 targets created", count _targets];

player groupChat _str;
hint localize _str;

_id = 1;
{
    [format["t%1",_id],getPos _x] call setDot;
    _id = _id + 1;
} forEach _targets;
_targets execVM "scripts\fireRange.sqf";

// #define __SHOW_TOWN_MARKERS__	
#ifdef __SHOW_TOWN_MARKERS__
_towns spawn {
	sleep 0.01;
	{
		_res = [_x, "ColorRed", "Vertical", "Horizontal" ] call setMarkers;
		sleep 0.01;
	} forEach _this;
	player globalChat format["Markers drown %1", count arg(0)];
};
#endif
	
//#define __SHOW_CONVOY_MARKERS__
#ifdef __SHOW_CONVOY_MARKERS__
[] spawn {
    _convoya =
    /*
        [
                [17452.8,13577.6,0],0,
                [[16963.1,14105.9,0], [15399.6,13744,0], [15135.7,14049.8,0], [13983.5,13168.2,0], [13824.8,13116,0] , [12563.6,13406.7,0], [12395.6,14494,0], [11851.9,14376.5,0]],
                [[16962.4,14106.6,0],[15371.1,12698.4,0],[14602.8,11861.4,0],[14103.6,12405.2,0],[13082.1,11276.8,0],[9990.096680,14181.348633,0],[10100,14120.9,0],[11851.9,14376.5,0]]
        ];
    */
        [ // Corazol - Estrella
            [12723,8729.78,0],20.4149,
            [[12737.5,8787.06,0], [10947.4,10623.1,0], [9614.35,11036.2,0], [8671.46,10084.4,0], [7618.55,9048.34,0], [7766.26,8822.9,0], [6946.93,8226.66,0]],
    //        [[12737.5,8787.4,0],  [10947.2,10623.3,0], [10517.3,9640.52,0],[10147.1,9317.35,0],[8952.3,8345.36,0],[8038.49,8893.38,0],[6946.93,8226.66,0]],
            [[12521,8496.28,0],[12731.1,8053.28,0],[12448,7586.38,0],[11914.4,6354.13,0],[11608.4,6208.08,0],[11571.6,6125.94,0],[11181.9,6139.99,0],[9214.04,6258.08,0],
             [8898.95,6468.03,0],[9143.61,6569.26,0],

             [8802.89,6909.65,0],[8716.59,6923.71,0],[8654.03,6976.59,0],[8505.68,7345.69,0],[8479.92,7708.00,0],[8460.26,7934.54,0],[8715.52,8170.13,0],[8721.81,8297.77,0],

    /*
             [8710.74,6979.2,0],[8947.02,7065.79,0],[8833.02,7134.48,0],[8974.96,7231.35,0],[8847.41,7253.35,0],[8847.41,7253.35,0],
             [8785.15,7670.74,0],[8656.25,8094.64,0],[8741.77,7920.59,0],[8721.73,8311.65,0],
    */

             [7888.45,8403.49,0],[8038.66,8889.25,0],[7363.16,8695.12,0],[6946.93,8226.66,0]]
        ];

    _pos = (_convoya select 0);
    ["S", _pos] call setDot;
    _pnta = _convoya select 2;
    _ind = 1;
    {
        [format["1.%1",_ind], _x ] call setDot;
        inc(_ind);
    } forEach _pnta;
    _ind = 1;
    _pnta = _convoya select 3;
    _ind = 1;
    {
        [format["2.%1",_ind], _x ] call setDot;
        inc(_ind);
    } forEach _pnta;

    _pnta = _convoya select 4;
    _ind = 1;
    {
        [format["3.%1",_ind], _x ] call setDot;
        inc(_ind);
    } forEach _pnta;

    // Show 3rd path for Corazol-Estrella convoy
    /*
    _ind = 1;
    hint localize "        [12723,8729.78,0],20.4149,";
    _str = "        [";
    {
        _pos = getPos _x;
        [format["3.%1", _ind], _pos ] call setDot;
        _ind = _ind + 1;

        _c = _pos select 0;
        _c = round(_c * 100);
        _c = _c / 100;
        _pos set [0, _c];

        _c = _pos select 1;
        _c = round(_c * 100);
        _c = _c / 100;
        _pos set [1, _c];

        _pos set [2,0];

        _str = _str + format["%1,", _pos];

    } forEach [c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c15,c16,c17,c18,c19,c20,c21,c22];
    _str = _str + "];";
    hint localize _str;
    hint localize "    ];"
    */

};

#endif
 
 //["Patrol Area",[12422.8,11518.5,0], "ColorBlack","Vertical",6850, 6850, 0, 5] call setMarker; // patrol area rectngle marker

//hint localize format["// Vectors:"];
//_pos = getMarkerPos "p0";
//hint localize format["_p0=[%1,%2,%3]; // Corazol marker center", _pos select 0, _pos select 1, _pos select 2];
//_pos = getPos p1;
//hint localize format["_p1=[%1,%2,%3]; // Vector being", _pos select 0, _pos select 1, _pos select 2];
//_pos = getPos p2;
//hint localize format["_p2=[%1,%2,%3]; // Vector end", _pos select 0, _pos select 1, _pos select 2];
 
// Test function to detect to what part (North or South) of Island designated position belongs
/* 
player groupChat "*** Test of point position relative vector made by line ***";
{
	_res = (getPos _x) call SYG_whatPartOfIsland;
	player groupChat format["%1 is on %2",_x,_res];
	sleep 0.01;
}forEach [center,left1,left2,left3,left4,right1,right2,right3];

hint localize  "*** *** *** *** *** *** *** ***";
hint localize  "*** Coordinates of circles with island of Sahrani in circumstances ***";
hint localize  "*** [""Name"",[cx,cy,cz],rad, ""Text""] ***";

{
	hint localize format["*** [""%1"",%2,%3,""%4""], ***",_x,markerPos _x,getMarkerSize _x select 0, markerText _x];
	//player groupChat format["*** [%1,%2,%3,""%4""], ***",_x, markerPos _x,getMarkerSize _x select 0, markerText _x];
} forEach ["isle1","isle2","isle3","isle4","isle5","isle6","isle7","isle8","isle9","isle10","isle11","isle12"];

{
	_str = "Out of islet";
	if ( _x call SYG_pointOnIslet ) then {_str = "On Islet"};
	player groupChat format["%1 is %2", _x, _str];
}forEach [on1,on2,on3,on4,off1,off2,off3,off4];

hint localize  "*** *** *** *** *** *** *** ***";
hint localize  "*** Coordinates of separate x_intro.sqf paths ***";
hint localize  "*** [[x1,y1,z1],...[xN,yN,zN]], ***";

hint localize  "_intro_path_arr = ";
hint localize  "  [";
_cnt = 0;
{
	_str = "    [";
	{
		if ( _str != "    [" ) then 
		{
			_str = _str + ",";
		};
		_p = getPosASL _x;
		_str = _str + format["[%1.0,%2.0,%3.0]", round(_p select 0), round(_p select 1), round(_p select 2)];
	}forEach _x;
	hint localize (_str + "],");
	//player groupChat format["*** [%1,%2,%3,""%4""], ***",_x, markerPos _x,getMarkerSize _x select 0, markerText _x];
	_cnt = _cnt + 1;
} forEach [
			[start1,start1_1,start1_2,start1_3],
			[start2,start2_1,start2_2],
			[start3,start3_1],
			[start4,start4_1,start4_2],
			[start5,start5_1,start5_2],
			[start6,start6_1,start6_2,start6_3,start6_4,start6_5,start6_6,start6_7,start6_8,start6_9,start6_10]
		  ];
hint localize  "  ]";

player groupChat format["init.sqf: Intro paths array [%1] created", _cnt];

hint localize  "*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***";
hint localize  "***  Coordinates of separate AAPODS for Isla de Vassal and nearby ones  ***";
hint localize  "***                        [[x1,y1,z1],...[xN,yN,zN]],                  ***";

hint localize  "_array = ";
hint localize  "  [";
_cnt = 0;
_str = "";
{
	if ( _str != "" ) then 
	{
		_str = _str + ",";
	};
	_p = getPos _x;
	_str = _str + format["[%1,%2,%3]", _p select 0, _p select 1, _p select 2];
	_cnt = _cnt +1;
} forEach [aapod1,aapod2,aapod3,aapod4,aapod5,aapod6,aapod7,aapod8];
hint localize _str;
hint localize "  ];";
player groupChat format["init.sqf: AAPod coordinates[%1] created, e.g. %2",_cnt,getPos aapod1];

x_sm_pos = [[4726.85,15689,0],[4385.75,15825.4,0],[4415.64,15790.9,0],[4375.74,15790.8,0],[4392.87,15521.3,0],[4532.88,15304.8,0],[4585.08,15287.2,0],[4978.4,15466.1,0],[4855.92,15535.1,0],[4930.69,15514.1,0],[4956.34,15760.8,0],[4949.85,15827.9,0],[4964.33,16067,0],[4987.25,15717.1,0],[4395.8,15350.6,0],   [4574.74,15374.2,0],[4368.82,15737,0],[5044.83,15799.3,0],[4860.15,15679.2,0]]; // index: 25,   enemy officer on Isla del Vasal or Isla del Vida

hint localize format["missionStart %1", missionStart];

 */
 
//#define __ISLA_DEFENCE__
#ifdef __ISLA_DEFENCE__
//_Stinger_Pod_arr1 = [[4898.79,15460.7,6.87017],[5033.33,16123.4,0.0],[5155.62,15877.1,0.0]]; // Isla da Vida
_Stinger_Pod_arr1 = [[4898.79,15460.7,6.9],[5033.33,16123.4,0.0],[5155.62,15877.1,0.0]]; // Isla da Vida
//_Stinger_Pod_arr2 = [[4520.49,15279.3,5.84021],[4372.36,15264.6,0.0],[4348.18,15932.5,0.0]]; // Isla da Vassal
_Stinger_Pod_arr2 = [[4520.49,15279.3,5.9],[4372.36,15264.6,0.0],[4348.18,15932.5,0.0]]; // Isla da Vassal
_M2HD_mini_TriPod_arr2 = [[4359.98,15937,0.0],[4341.64,15541.9,0.0]]; // Isla da Vassal

extra_mission_vehicle_remover_array = [];
extra_mission_remover_array = [];

_createStaticWeaponGroup = {
	private ["_grp","_vehtype","_utype","_posarr","_pos","_veh","_unit"];
	_grp     = _this select 0;
	_vehtype = _this select 1;
	_utype   = _this select 2;
	_posarr  = _this select 3; // positions array
	
	{ //forEach _posarr;
		_pos = _x;
		_veh = createVehicle [_vehtype, _pos, [], 0, "NONE"];
		_veh setPos _x;
		
		extra_mission_vehicle_remover_array = extra_mission_vehicle_remover_array + [_veh];
		
		_unit = _grp createUnit [_utype, _pos, [], 0, "FORM"];
		_unit setSkill 1.0;
		[_unit] joinSilent _grp;
		_unit assignAsGunner _veh;
		_unit moveInGunner _veh;

		extra_mission_remover_array = extra_mission_remover_array + [_unit];
		sleep 0.1;
	} forEach _posarr;
	
	_grp
};

_createIsleDefence = 
{
	// Add super-defence for this Side Mission immediately
	// TODO: change this adding so that number of AA Pods (not MG) depends on players count 
	// up to the maximum limityed count after some period
	_utype = "ACE_SoldierWB_A";
	_stingertype = "Stinger_Pod";
	_mgtype = "ACE_ZU23M"; //"M2HD_mini_TriPod";
	{
		_grp = createGroup west;
		{ //			_wpn = _x select 0;//			_arr = _x select 1;
			[_grp, _x select 0, _utype, _x select 1] call _createStaticWeaponGroup;
		} forEach _x;
		_grp allowFleeing 0;
		_grp setCombatMode "YELLOW";
		_grp setFormDir (floor random 360);
		_grp setSpeedMode "NORMAL";
		_grp_array = [_grp, _pos, 0, [], [], -1, 0, [], 100, -1];
//		_grp_array execVM "x_scripts\x_groupsm.sqf";
		sleep 0.511;	
	} forEach	[
					[ [_stingertype,_Stinger_Pod_arr1]  ], 
					[ [_stingertype,_Stinger_Pod_arr2],[_mgtype,_M2HD_mini_TriPod_arr2]  ] 
				];
	player groupChat format["IsleDefence created, vehicles %1, units %2",count extra_mission_vehicle_remover_array, count extra_mission_remover_array];
};
//[] spawn _createIsleDefence;

#endif


/* 
SYG_ACTCheckHolders = player addAction ["Find garbage (20 m)", "findbombs.sqf", [20, true]];
SYG_ACTNoGarbage = player addAction ["Remove garbage (20 m)", "nogarbage.sqf", [20, true]];
SYG_ACTShowTargets = player addAction ["Show targets", "showtargets.sqf", []];

 */

#ifdef __FLAG_OF_INTEREST__
// [4726.85,15689,0] -  create flag here
_pos = [4726.85,15689,0];
_flag = createVehicle ["FlagCarrierWest", _pos, [], 0, "CAN_COLLIDE"];
player groupChat format["Flag on point of interest %1 created", _pos];
#endif

#define __FLAG_TEXTURE_TEST__

#ifdef __FLAG_TEXTURE_TEST__
[] spawn {
    if (isNil "FLAG_BASE") then
    {
        hint localize "*** FLAG_BASE is nil";
    }
    else
    {
        hint localize "FLAG_BASE detected, will be retextured to USSR flag";
        FLAG_BASE setFlagTexture "\ca\misc\data\rus_vlajka.pac";
    };
};
#endif



//#define __FOUNTAIN_TEST__

#ifdef __FOUNTAIN_TEST__
 sleep 1;
_nObject = (getPos player) nearestObject 300876;
if ( isNil "_nObject" || isNull _nObject ) then
{
	player groupChat "Fountain 300876 not found at map";
}
else
{
	player groupChat format["Fountain %1 found at %2, type %3, dir %4, damage %5", _nObject, getPos _nObject, typeOf _nObject, getDir _nObject, getDammage _nObject];
};

_nObject execVM "fountain.sqf";
#endif

 
#ifdef __UPS_ARRAY_PRINT__
{
	hint localize format["%1 = [%2,%3,%4,%5];", _x, markerPos _x, markerSize _x select 0, markerSize _x select 1,markerDir _x]; //d_ups_array_2
} forEach ["d_ups_array","d_ups_array_1","d_ups_array_2","d_ups_array_3", "d_ups_array_4"];
player groupChat "Массивы данных для UPS напечатаны!";
#endif

#ifdef __CIRCLES_BY_RECT__
{
	_mrk = _x;
	_pos = markerPos _mrk;
	_size = markerSize _mrk;

	_area = [ _pos, _size select 0, _size select 1, markerDir _mrk ];

	_rect = [argp(_size,0) * 2, argp(_size,1) *2];
	_circles = _rect call SYG_getCirlesByRect;

	hint localize format["w %1, h %2, cirles %3", argp(_rect,0), argp(_rect,1), _circles];
	player groupChat format["SYG_getCirlesByRect: w %1, h %2, cirles %3", argp(_rect,0), argp(_rect,1), _circles];

} forEach ["d_ups_array","d_ups_array_1","d_ups_array_2","d_ups_array_3"];
player groupChat "Проверка SYG_getCirclesByRect сделана!";
#endif


// TODO:check real work of algorithm to find garbage

//======================= Check point in marker functionality


#ifdef __MARKERS_TEST_

hint localize "============ TEST MARKER PROCEDURES ======================";
hint localize "=                                                        =";

{
	// read marker into internal structure
	_descr = [argp(_x,0),argp(_x,1)] call SYG_readMarkerInfo;
	_str = format["Marker ""%1"": %2",argp(_x,0),_descr];
	if ( count _descr > 0 ) then
	{
		// create some points to check algoritms
		_pos = argp(_descr,0);
		_a   = argp(_descr,1);
		_b   = argp(_descr,2);
		_angle   =  argp(_descr,3);
		// type is not important for this test
		_pnt1 = [ argp(_pos,0) - (_a - 10),argp(_pos,1),argp(_pos,2)]; // point near left side of marker on X and at middle on Y
		_val = [_pnt1, _descr] call SYG_pointInMarker;
		//player groupChat format["result 1 %1",_val];
		if ( _val ) then {_str = _str + ", L point in marker";} 
		else {_str = _str + ", L point not in marker";};

		_pnt1 set [0, argp(_pos,0) - 10]; // point near center of on X and at middle on Y
		_val = [_pnt1, _descr] call SYG_pointInMarker;
		if ( _val ) then {_str = _str + ", C point in marker";} 
		else {_str = _str + ", C point not in marker";};
		//player groupChat format["result 2 %1",_val];
	}
	else
	{
		//player groupChat "OUT";
		_str = _str + " not exists!!!";
	};
	hint localize _str;
	player groupChat _str;
}forEach [["unknown_marker","ICON"],["mrk_rot_rect","RECTANGLE"],["mrk_not_rot_ret","RECTANGLE"],["mrk_not_rot_elli","ELLIPSE"],["mrk_rot_elli","ELLIPSE"]];

// show start points for paradrops
_para_start_points = 
	[
		[236.8,13889.7,0],
		[812.8,9521.73,0],
		[8172.8,865.727,0]
	];
_para_end_points = 
[
		[19500.8,6497.73,0],
		[18956.8,17329.7,0],
		[10476.8,20081.7,0]
];

hint localize "== create point of paradrop heli creation";
_cnt = 0;
{
	_cnt = _cnt + 1;
	[format["pds_%1",_cnt], _x] call setDot;
} forEach _para_start_points;

_cnt = 0;
{
	_cnt = _cnt + 1;
	[format["pde_%1",_cnt], _x] call setDot;
} forEach _para_end_points;

d_island_center = getArray(configFile>>"CfgWorlds">>worldName>>"centerPosition");
["CfgWorlds centerPosition", d_island_center] call setDot;
#endif

// test illumination above wounded men

#ifdef __FLARES_OVER_BASE__ 
 // launch flare before player eye 50 meters ahead and 100 meters height
SYG_ACTLaunchFlare = player addAction ["Launch flare [50,100]", "launchflare.sqf", [50,100]]; 
SYG_ACTSetDayTime = player addAction ["daytime [8,30]", "setday.sqf", [8,30]];
SYG_ACTSetNightTime = player addAction ["nightime [22,30]", "setday.sqf", [22,30]];

player groupChat format["init.sqf: spawning flaresoverbase.sqf, d_on_base_groups=%1",d_on_base_groups];


player groupChat format["init.sqf: spawning flaresoverbase.sqf, d_on_base_groups=%1",d_on_base_groups];
hint localize format["init.sqf: spawning flaresoverbase.sqf, d_on_base_groups=%1",d_on_base_groups];

[leader1, "d_ups_array_1"] execVM "scripts\UPS.sqf";
[leader2, "d_ups_array_2"] execVM "scripts\UPS.sqf";

d_on_base_groups = [group leader1,  group leader2];

_pos = leader1;
_list = [];
{
	_list = _list + [typeOf _x];
}forEach (units (d_on_base_groups select 0));
[] execVM "scripts\flaresoverbase.sqf";

[] spawn {
	private [ "_cnt" ];
	sleep 60;
	_cnt = 0;
	{
		if ( !isNull _x ) then
		{
			{
				if ( alive _x ) then { _cnt = _cnt + 1; };
			}forEach units _x;
		};
	} forEach d_on_base_groups;
	
	if ( _cnt == 0 ) then
	{
		d_on_base_groups = [];
		_grp = createGroup west;
		{
			_grp createUnit [ _x, _pos,[], 0, "NONE" ];
		} forEach _list;
		player groupChat format[ "init.sqf: no more units in d_on_base_groups list, spawning one more with %1 men", count _list ];
		d_on_base_groups = d_on_base_groups + [ _grp ];
	};
	
};
#endif

#ifdef __CAN_MOVE_STAND_TEST__
// check canMove and canStand and canFire values for different dammage levels
_grp = group leader1;
_grp spawn {
	private["_grp","_cnt","_dam","_inc","_ret"];
	_grp = _this;
	_cnt = count units _grp;
	_dam = 0;
	_inc = 1/_cnt;
	_ret = [];
	player groupChat format["init.sqf: stat grp cnt %1",_cnt];
	hint localize format["init.sqf: stat grp cnt %1",_cnt];
	{
		_x setDammage _dam;
		sleep 0.3;
		_ret = _ret + [[_dam, canMove _x, canStand _x, canFire _x]];
		_dam = _dam + _inc;
	} forEach units _grp;
	player groupChat format["init.sqf: stat arr %1",_ret];
	hint localize format["init.sqf: stat arr %1",_ret];
};
#endif

//#define __REAMMO_TEST__
#ifdef __REAMMO_TEST__
player groupChat format["Ammotruck: %1", ammotruck];

_ret = ammotruck call SYG_reammoTruck;

if ( _ret ) then
{
	player groupChat "Ammo truck rearmed successfully";
	//hint localize "Ammo truck rearmed successfully";
}
else
{
	player groupChat "Ammo truck NOT rearmed";
	//hint localize "Ammo truck NOT rearmed";
};

_ret = mhq call SYG_reammoMHQ;

ammotruck action ["useWeapon",ammotruck,player,0];

if ( _ret ) then
{
	player groupChat "MHQ rearmed successfully";
	//hint localize "MHQ rearmed successfully";
}
else
{
	player groupChat "MHQ NOT rearmed";
	//hint localize "MHQ NOT rearmed";
};

#endif

// define lower line to handle with camps over island
//#define __CAMP__
 
#ifdef __CAMP__

 //
// prepare camp coordinates array (from 2.sqm)
//

/* _camp_arr = [[camp1],[camp2],[camp3],[camp4],[camp5],[camp6],[camp7],[camp8],[camp9],[camp10,camp10_1,camp10_2]];
hint localize "d_camp_arr = [";
player groupChat format[ "Prepare coordinates array[%1] for camps", count _camp_arr];
{	
	_arr = [];

	{
		_pos = getPos _x;
		_xc = ROUND2(_pos select 0);
		_yc = ROUND2(_pos select 1);
		_pos set [0, _xc];
		_pos set [1, _yc ];
		_pos set [2, 0];
		_arr = _arr + [_pos];
	}	forEach _x;
	hint localize format["%1,", _arr];
}forEach _camp_arr;
hint localize "];";
 */
 
sleep 0.3;

d_camp_arr = [ // 15005.175781,412.224243,14826.478516
	[[11462.0,8447.5,0],[11513.7,8421.5,0]],
	[[8189.87,8577.5,0],[8160.0,8646.6,0],[8245.7,8663.6,0]],
	[[11583.4,9560.0,0],[11524.5,9579.0,0]],
	[[14648.9,9934.0,0],[14771.4,9966.4,0]],
	[[15403.2,11554.4,0],[15463.1,11234.1,0]],
	[[14965.5,14845.7,0],[14831.3,14924.0,0],[15005.2,14826.5,0]],
	[[18090.3,12849.7,0]],
	[[11100.6,13371.5,0]],
	[[8065.12,16254.3,0]],
	[[9478.09,6861.32,0],[9667.19,6920.83,0], [9293.42,6978.22,0]]
];
sleep 0.3;

//
// Create all camps
//
d_partisans_started = false;
[] execVM "camphandler.sqf";

// #ifdef __CAMP__
#endif 

#ifdef __OLD__
d_camp_arr spawn
{
	private ["_arr", "_ind", "_pos", "_camp", "_bag","_id"];
	_arr = _this;
	_i = 0;
	{
		_ind = floor (random count _x);
		_pos = _x select _ind;
		//_x = _pos select 0;
		//_y = _pos select 1;
		_camp = createVehicle ["ACamp", _pos, [], 0, "CAN_COLLIDE"];
		if ( isNull _camp ) then 
		{
			player groupChat format["Acamp#%1 not created", _i];
		}
		else
		{
			_id = _camp addAction ["Обследовать", "campcheck.sqf" , [_i + 1 , floor random 5, floor random 6, floor random 6], 0, true/*, false , "", "{(_target distance _this) <= 2}" */];
			//player groupChat format["Camp#%1 action id %2",_i, _id];
		};
		//_pos = [_x + 2 + random 2, _y + 2 + random 2, 0];
		_bag = createVehicle ["Land_SleepingBag", _pos, [], 5, "NONE"];
		sleep 0.2;
		_i = _i + 1;
		[ format["camp %1", _i + 1], _pos, 0.6, "ColorGreen", "Solid", "ICON", "Flag1"] call setMarker;
	} forEach _this;
};

//SYG_ACTDeleteCamp = player addAction ["Delete camp", "delcamp.sqf", [10]];
#endif

#ifdef __SOUNDS_TEST__
// say some help by civ
//civ say format["TRv0%1",ceil random 4];

sleep 1.0;
/* 
player groupChat "Civilian would say CarHorn";
civ say "CarHorn";
sleep 5;
 */
player groupChat "Civilian would say ACE_VERSION_DING";
civ say "ACE_VERSION_DING";
sleep 5;

player groupChat "Civilian would say Crow";
_soundSource = createSoundSource ["Crow", position civ, [], 0]; //civ say "SorrowDog";
sleep 5;
deleteVehicle _soundSource;
#endif

//#define __FORMAT_PERCENT_SYMBOL_TEST__
#ifdef __FORMAT_PERCENT_SYMBOL_TEST__

player groupChat format["How to show percent symbol in format statement %1%2 (using %3)", 100, "%", "%1%2"];
player groupChat format["Or simply %%%% (using %1)", "%%%%"];

#endif

#ifdef __HINT_DISAPPERING_TEST__

player groupChat "__HINT_DISAPPERING_TEST__ is #defined, test hint localize effects";

hint "Этот hint появится на 2 секунды и исчезнет принудительно, если так работает hint localize\nСледующий hint появится через 5 секунд после hint localize";
sleep 2.0;
hint localize "__HINT_DISAPPERING_TEST__ active";
sleep 5.0;
#endif

//#define __TEST_AA_ON_ASHARAN__
#ifdef __TEST_AA_ON_ASHARAN__
	_grp = group player;
	player groupChat "Создадим ПВО-станки здесь и там";
	//[_grp,"Stinger_Pod_East", "ACE_SoldierEB", [getPos AApos1,getPos AApos2,getPos AApos3]] call SYG_createStaticWeaponGroup;
	
	{
		[_grp, _x select 1, "ACE_SoldierEB", [_x select 0]] call SYG_createStaticWeaponGroup;
	}forEach [[[18266.2,2966.5,0],"Stinger_Pod_East"],[[18212.8,2960.9,0],"ACE_ZU23M"],[[18240.4,2902.3,0],"ACE_ZU23M"],
	[[17894.4,3406.75,0], "ACE_ZU23M"]];
#endif

//#define __TEST_FOG_BOUNDS__

#ifdef __TEST_FOG_BOUNDS__
_world_center = getArray(configFile>>"CfgWorlds">>worldName>>"centerPosition");
_x = (_world_center select 0) * 2; // world X size
_y = (_world_center select 1) * 2; // world Y size

player groupChat format["World center is %1, width %2, height %3",_world_center,_x,_y];

#endif


//#define __TEST_DAY_OF_WEEK__

#ifdef __TEST_DAY_OF_WEEK__
_weekday = {
	private ["_ret","_weekdays"];
	_ret = (_this call SYG_weekDay) call SYG_weekDayLocalName;
	player groupChat format[ "День недели для %1 : %2", _this call SYG_dateOnlyToStr, _ret  ];
};

date call _weekday;

[1957,6,23] call _weekday;

[2015,10,16]  call _weekday;

#endif

//#define __TEST_ACTIVE_CARGO__

#ifdef __TEST_ACTIVE_CARGO__
	if ( !isNil "m113" ) then
	{
		_grp = createGroup west;
		[m113, _grp, "ACE_SoldierWB_A"] call SYG_populateVehicle;

		// add cargomen

		[m113, _grp,  "ACE_SoldierWB_A"]call SYG_populateVehicle;
		_cnt = (m113 emptyPositions "Cargo") min 6;
		_pos = getPos m113;
		if ( _cnt > 0 ) then
		{
			for "_i" from 1 to _cnt do
			{
				_unit=_grp createUnit ["ACE_SoldierWB_A", _pos, [], 0, "FORM"];
				_unit setSkill 0.8 + random 0.2;
				[_unit] joinSilent _grp;
				_unit assignAsCargo m113;
				_unit moveInCargo m113;
			};
		};
		player groupChat format["Cargo count assigned to m113 is %1", _cnt];
		
		[leader _grp, "ups_main"] execVM "scripts\UPS.sqf";
	};
#else
	{
		deleteVehicle _x;
	}
	forEach  (crew m113) + [m113];
#endif

//#define __TEST_BILLBOARD_RETEXTURE__

#ifdef __TEST_BILLBOARD_RETEXTURE__
_nObject = getPos player nearestObject 1253; 
if ( isNil "_nObject" || isNull _nObject ) then
{
	player groupChat format["Billboard %16 not found at map", 1253];
}
else
{
	player groupChat format["Billboard %1 found at %2, type %3, dir %4", _nObject, getPos _nObject, typeOf _nObject, getDir _nObject];
	hint localize  format["Billboard %1 found at %2, typeName %3, dir %4", _nObject, getPos _nObject, typeOf _nObject, getDir _nObject];
	//[_nObject,0,"s:\Mmedia\Images\Картинки\Военные\Texture (текстуры для Arma)\billboard_su30.jpg"] call SYG_setTexture;
	_nObject setObjectTexture [0,"img\Mi-24attack_1.paa"];
};

#endif

//#define __TEST_NEW_YEAR__

#ifdef __TEST_NEW_YEAR__

SYG_mission_start = [2015,12,26,1,1,1];
player groupChat format["test NEW YEAR check: %1", SYG_mission_start];
_ny = call SYG_isNewYear;
if ( isNil "_ny" ) then {player groupChat "_ny is nil";};
if ( isNil "SYG_isNewYear" ) then {player groupChat "SYG_isNewYear is nil";}
else
{
	if ( _ny ) then {player groupChat format["%1: today is A NEW YEAR",SYG_mission_start]}
	else {player groupChat format["%1 today is NOT A NEW YEAR",SYG_mission_start]};
};

if ( call SYG_isNewYear ) then
{
	player groupChat "Set sound and ""killed"" event handler";
	private ["_vec","_snd"];
	_vec = "Radio" createVehicle [0, 0, 0];
	 // set radio on top of the table
	 _pos = getPos player;
	_vec setPos [ _pos select 0, (_pos select 1) + 3, 1.5];
	_vec setDir 90;	
	_snd = createSoundSource ["Music", (getPos _vec), [], 0];// only one source on the server should be created
//	hint localize format["SoundSource created: %1, typeOf %2", _snd, typeOf _snd];
	_vec setVariable ["SoundSource", _snd];
//	_vec addAction ["Switch off","scripts\radio_off.sqf",_snd,6,true];
	
//	_id = _camp addAction ["Обследовать", "campcheck.sqf" , [_i + 1 , floor random 5, floor random 6, floor random 6], 0, true];
	_vec addEventHandler ["Killed", { _this = _this select 0; deleteVehicle (_this getVariable "SoundSource"); _this setVariable ["SoundSource", nil]; _this removeAllEventHandlers "Killed";hint localize "N.Y. music killed"}];
	
};

#endif


//#define __FIRE_RANGE__
#ifdef __FIRE_RANGE__
	_pos = getPos player;
	_pos set [1, (_pos select 1) + 5];
	_obj = "Land_strelecky_post_new" createVehicle _pos;
	_obj setDir 90;
	
	// unit, causedBy, damage
	[trg1,trg1_1] execVM "scripts\fireRange.sqf";
//	trg1 addEventHandler ["Hit", { player groupChat format["Hit %1", _this select 2];}];
	trg1 addEventHandler ["Killed", { player groupChat "Killed";}];
	trg1_1 addEventHandler ["Killed", { player groupChat "Killed";}];
//	trg2 addEventHandler ["Hit", { player groupChat format["Hit %1", _this select 2];}];
//	trg2 addEventHandler ["Killed", { player groupChat "Killed";}];
#endif

//#define __BARGATE_ANIM__
#ifdef 	__BARGATE_ANIM__

[] spawn {
	_pos = [9621,9874,0];
	//player groupChat format["getPos barrier_point = %1", _pos];
	//hint localize format["getPos barrier_point = %1", _pos];
	// remove mission bar gates
	{
		_zav = _pos nearestObject _x;
		_zav setDammage 1.1;
		sleep 0.01;
		//deleteCollection _zav;
	}forEach [353,355,362/* ,367 */];
	//sleep 0.01;
	// add new bar gates
	_arr = [];
	{
		_zav = createVehicle ["ZavoraAnim", [0,0,0],[],0, "CAN_COLLIDE"];
		sleep 0.01;
		if ( (_x select 1) != 0) then { _zav setDir (_x select 1)};
		_zav setPos (_x select 0);
		_arr = _arr + [_zav];
	} forEach [ 
		[[9532.405273,9760.648438,0.3],270],
		[[9524.4,9925.8,0.3],90],
		[[9759.660156,9801.615234,0.3]] 
		      ];
			  
	sleep 0.1;
	_cnt = [ _arr, 1] call SYG_execBarrierAction;
//	player groupChat format["gates up count %1", _cnt];
	sleep 6;
	_cnt = [ _arr, 0] call SYG_execBarrierAction;
//	player groupChat format["gates down count %1", _cnt];
};
#endif

// test functionality nearestObject

// #define __TEST_NEARESTOBJECT__

#ifdef __TEST_NEARESTOBJECT__
[] spawn{
	private ["_pos", "_step", "_dist"];
	for "_step" from 4 to 15 step 2 do
	{
		_pos = getPos player;
		_pos set [0, (_pos select 0) +  _step];
		//_dist1 = _pos distance (getPos player);
		//hint localize format[ "step is %1 m, dist %2 m", _step, _dist1 ];
		_nobj = nearestObject [ _pos, "CAManBase" ];
		_dist = _pos distance _nobj;
		_driver_near = ((side _nobj) == east) && ((_nobj distance _pos) < 10);
		if ( !_driver_near ) then { hint localize format["*** CAManBase not detected at radius %1 meters", _step]; }
		else { hint localize format[ "*** side %2 %1 found at dist %3", typeOf _nobj, side _nobj, round(_dist) ] };
		sleep 3;
	};
};
#endif

// test dammage handler
#define __TEST_DAMMAGE_HANDLER__

#ifdef __TEST_DAMMAGE_HANDLER__

hint localize "__TEST_DAMMAGE_HANDLER__";

player call SYG_handlePlayerDammage;
civ call SYG_handlePlayerDammage;

#endif

//#define __TEST_SYG_findGroupAtTargets__

#ifdef __TEST_SYG_findGroupAtTargets__

if (isNil "FLAG_BASE") then
{
	hint localize "*** FLAG_BASE is nil";
};

_grp = [leader1, 1000, 3] call SYG_findGroupAtTargets;
if ( isNull _grp ) then
{
	hint localize format["*** [leader1, 1000, 3] call SYG_findGroupAtTargets == %1", _grp];
}
else
{
	hint localize format["*** [leader1, 1000, 3] call SYG_findGroupAtTargets == %1, count %2, leader %3", _grp, count (units _grp), name (leader _grp)];
};

#endif

//#define __TEST_SCRIPTS_FINDING__

#ifdef __TEST_SCRIPTS_FINDING__

_hnd = [] execVM "\srvtime.sqf"; // is situated in Arma/scripts directory
//hint localize format["init.sqf: non exsting script execution handler is %1", _hnd];
waitUntil {scriptDone _hnd};
hint localize format["SYG_mission_start = %1",SYG_mission_start];
#endif

//#define __TEST_MISSION_START_CONTROL__

#ifdef __TEST_MISSION_START_CONTROL__

[] spawn {
	private ["_time"];
	_time = daytime;
	hint localize format["__TEST_MISSION_START_CONTROL__: sleep %1 secs at %2", 10, _time];
	player groupChat format["daytime %1, time %2", daytime, time];
	sleep 10;
	hint localize format["__TEST_MISSION_START_CONTROL__: time after sleep %1 secs must be %2, real is %3", 10, _time + 10, daytime];
	player groupChat format["daytime %1, time %2", daytime, time];
	for "_i" from 1 to 10 do
	{
		sleep 5;
		player groupChat format["daytime %1, time %2", daytime, time];
	};
};
hint localize format["__TEST_MISSION_START_CONTROL__: daytime %1, time %2", daytime, time];
skipTime (10/3600);
player groupChat format["daytime %1, time %2", daytime, time];
hint localize format["__TEST_MISSION_START_CONTROL__: daytime %1, time %2", daytime, time];

#endif

//#define __TEST_SERVER_TIME__

#ifdef __TEST_SERVER_TIME__
hint localize "**** __TEST_SERVER_TIME__ ****";

SYG_mission_start = [2015,12,23,23,12,13];

{
	hint localize " ";
	_ret = _x call SYG_getServerDate;
	hint localize format["init.sqf: missionStart = %1, synchroTime = %2, time = %3, server date = %4", SYG_mission_start, SYG_timeStart, _x, _ret];
} forEach [15, 3700, (3600*5 + 60*12 + 36),3600*25 + 60*46 + 28];

#endif

//player groupChat localize "**** __TEST_COMPUTER__ ****";

//#define __TEST_COMPUTER__

#ifdef __TEST_COMPUTER__

_targetTown = call SYG_getTargetTown;

player groupChat localize "**** __TEST_COMPUTER__ ****";
[] spawn {

	hint localize "**** __TEST_COMPUTER__ ****";

	_pos = getPos computer;
	_dir = getDir computer;
	hint localize format["Computer: pos %1, dir %2", _pos, _dir];

//			position[]={9709.503906,144.311691,9961.215820};

	//_pos set [2, (_pos select 2) + 1.2];
	_pos set [2, 1.35];
	computer setPos _pos;


	hint localize ("MHQ hiddenSelections: " + str (getArray (configFile >> "CfgVehicles" >> typeOf mhq >> "hiddenSelections")));

	hint localize ("MHQ hiddenSelections: " + str (getArray (configFile >> "CfgVehicles" >> "Wallmap" >> "hiddenSelections")));
	hint localize ("MHQ hiddenSelections: " + str (getArray (configFile >> "CfgVehicles" >> "RahmadiMap" >> "hiddenSelections")));
	
	computer addAction ["Взять задание", "scripts\computer.sqf"];

	_pos = getPos wallmap;
	_dir = getDir wallmap;
	_pos set [2, 0.6];

	hint localize format["Wallmap: pos %1, dir %2", _pos, _dir];
	
	wallmap setPos _pos;
/* 
	_type = typeOf computer;
	{
		_pos = getPos computer;
		_vec =  _type createVehicle [0,0,0];
		_pos set [1, (_pos select 1) + _x];
		_pos set [2, (_pos select 2) + 1.2];
		_vec setPos _pos;
		_vec setDir _dir;
		sleep 0.01;
	}	forEach [3, 2,1,-1,-2,-3,-4];
	 */
};
#endif

//#define __TEST_MAP__

//#define __TEST_INTEL_TELEPORT__

#ifdef __TEST_INTEL_TELEPORT__
hint localize "#define __TEST_INTEL_TELEPORT__";

//+++ Sygsky: handle GRU computer
[] spawn {
	waitUntil { sleep 1; current_target_index >= 0 };
	while { true } do
	{
		call SYG_updateIntelBuilding; // update all available objects
		sleep (30 + (random 60));
	};
};

// check all town buildings to be suitable as teleport destination on intel task start

#define STATIC_SCORE 15
teleactid = player addAction [format["GRU-port to %1", (target_names select current_target_index) select 1],
            "scripts\nearBuilding.sqf",
            ["TELEPORT_NEXT"/*"TELEPORT_TARGET_TOWN"*/,[],150,STATIC_SCORE,-(round(STATIC_SCORE/2))]
            ];
//player addAction ["About Paraiso", "scripts\nearBuilding.sqf",["INFO",getPos paraiso_center, 300]];

#endif

//#define __TEST_DIALOG__

#ifdef __TEST_DIALOG__
dialogid = player addAction ["Диалог","GRU_scripts\dlg.sqf"];

[] execVM "GRU_scripts\GRUMissionSetup.sqf";

#endif


// check some GRU objects
/*
// Ids of houses GRU can use as computer link center, 82124 is house near airfield and base building
SYG_intelHouseIds = [82124,220,354,356,360];
SYG_intelObjects =
[
	[[9709.46,9960.43,1.4], 155, "Computer", "GRU_scripts\computer.sqf", "STR_COMP_ENTER"],
	[[9712.41,9960,0.6], 90, "Wallmap", ""]
];
*/

//#define __KING_ESCAPE__

#ifdef __KING_ESCAPE__
_newgroup = createGroup west;
_poss = [10269.6,7353.71,0];
king = _newgroup createUnit ["King", _poss, [], 0, "FORM"];

_new_pos_arr = [[10412.7,7732.9,0],[10329.0,7621.2],[10513.5,7834.5,0]];
_ind = floor random (count _new_pos_arr);
_kulna = createVehicle ["Land_kulna", _new_pos_arr select _ind, [], 0, "CAN_COLLIDE"];
sleep 0.5;
_kulna setDir random 360;
_pos = _kulna buildingPos 0;
king setPos _pos;
king call SYG_rearmPistolero;
hint localize format["King is relaxing in kulna # %1 with pos %2", _ind, _pos];

sleep 5;

Hide_king = {
	sleep 5;
	private ["_center","_nbarr","_ind","_house","_pos"];
	_center = [10750,7363,0]; 
	_nbarr = nearestObjects [_center, ["Land_hlaska","Land_bouda2_vnitrek"], 400];
	if ( (count _nbarr) == 0) exitWith {localize format["_hide_king: no building %1 in range of %2 m. near %3",["Land_hlaska","Land_bouda2_vnitrekw"],200, _center]};
	_ind = floor random (count _nbarr);
	_house = _nbarr select _ind;
	_pos = [_house,"RANDOM",_this] call SYG_teleportToHouse;
	localize format["_hide_king: king teleported to house type %1", typeOf _house];
	player groupChat format["_hide_king: king teleported to house type %1 at pos %2", typeOf _house, _pos];
};

 	//player groupChat format["king_trigger is %1", king_trigger];
	
    _trigger = objNull;
    _trigger = createTrigger["EmptyDetector",[10270.306641,7384.357422,69.139999]];
    _trigger setTriggerArea [21.0, 20.5, -1, true];
    _trigger setTriggerActivation ["EAST", "PRESENT", false];
    _trigger setTriggerStatements["this", "player groupChat ""Trigger"";deleteVehicle thisTrigger; king execVM ""GRU_scripts\king_escape.sqf""", ""];
    -trigger setTriggerText
	sleep 1;
	player groupChat format["trigger is %1", _trigger];
#endif

//#define __AIR_LIGHTS__
#ifdef __AIR_LIGHTS__
[] spawn {
	_n1 = getPos player nearestObject 488506;
	_n2 = getPos player nearestObject 488514;
	_n3 = getPos player nearestObject 582677; // first light
	_dist = _n1 distance _n2;
	player groupChat format["+++ Air light1 is %1, 2 %2, 3 %3, dist %4", (getPos _n3), getPos _n2, getPos _n1, _n1 distance _n2];
	hint localize format["+++ Air light1 is %1, 2 %2, 3 %3, dist %4", (getPos _n3), getPos _n2, getPos _n1, _n1 distance _n2];
	_x = (getPos _n3) select 0;
	_y = (getPos light1) select 1;
	_l = "Logic" createVehicleLocal [0,0,0] ;
	_pos = getPosASL light1;
	_pos set [2,0];
	_l setPos _pos;
	_lz = (getPosASL _l select 2) - 9.23;
	//_z = -9.27;
	_zl = _lz - (getPosASL _l select 2);
	hint localize format["lz = %1, lz = %2", _lz, _zl];

    _i = 1;
	while {_zl < 0} do
	{
		_l setPos [_x, _y, 0];
		_zl = _lz - (getPosASL _l select 2);
		player groupChat format ["%1 Z %2 dZ %3", _i, _lz, _zl ];
		_i = _i + 1;
		_obj = "Land_NavigLight" createVehicle  [0,0,0];
		_obj setPosASL [_x, _y, _lz];
		_obj setDir 180;
		_x = _x - _dist;
	};

    _pos = getPosASL light3; // eastern point of next light chain
	player groupChat format["+++ Air light3 is %1", _pos];
	hint localize format["+++ Air light3 is %1", _pos];
    _pos set [2, 0];
    _pos set [1, _y];
    _x = _pos select 0;
    _l setPos _pos;
    _lz = (getPosASL _l select 2) - 9.23; // Z coord for start light
    //_z = -9.27;
    _zl = _lz - (getPosASL _l select 2);
	hint localize format["lz = %1, lz = %2", _lz, _zl];

    _i = 1;
    while {_zl < 0} do
    {
        _l setPos [_x, _y, 0];
        _zl = _lz - (getPosASL _l select 2);
        player groupChat format ["%1 Z %2 dZ %3", _i, _lz, _zl ];
        hint localize format ["%1 Z %2 dZ %3", _i, _lz, _zl ];
        _i = _i + 1;
        _obj = "Land_NavigLight" createVehicle  [0,0,0];
        _obj setPosASL [_x, _y, _lz];
        _obj setDir 180;
        _x = _x - _dist;
    };

};
#endif
	
//#define __TEST_RESURRECT_DIALOG__
#ifdef __TEST_RESURRECT_DIALOG__
resurrect_dialog_id = player addAction ["Восст. в R 50 м.)","dlg\do_resurrect.sqf",[50,5]];
#endif


#define __TEST_BUILDINGPOS__
#ifdef __TEST_BUILDINGPOS__
player addAction ["<t color='#FF0000'>list building pos</t>", "listPoses.sqf"];
player addAction ["<t color='#00FF00'>man to rnd pos</t>", "move2HousePos.sqf"];
#endif

//#define __TEST_VES_ROPA__
#ifdef  __TEST_VES_ROPA__

[] spawn {
_obj = Land_vez_ropa; //(getPos player) nearestObject 310;
_obj setDammage 1.1;
player groupChat format["Назначаем качалке %1 at %2 damage 1.1", typeOf _obj,  getPos _obj];
_pos = getPos _obj;

sleep 0.1;
_obj setVectorUp [random 1, random 1, random 1];
player groupChat format["Крутим качалку %1", vectorUp _obj];

sleep 1.0;
_pos = getPos _obj;
_pos1 =[ _pos select 0, _pos select 1, -6];
_obj setPos _pos1;
sleep 0.1;
_obj setVectorUp [0,0,-1];
player groupChat format["Убираем качалку вниз (%1) на 10 метров (%2)", vectorUp _obj, getPos _obj];

//sleep 1.6;
//deleteCollection _obj;
//player groupChat format["Уничтожаем качалку %1", _obj];

};


#endif


/* _trigger spawn {
	if ( isNull _this) exitWith { player groupChat "trigger is empy, exiting loop"};
	sleep 1.0;
	player groupChat format["trigger is %1", _this];
};
 */
//call _hide_king;
/*
 player groupChat "Civilian would say VoteForNewCommander";
civ say "VoteForNewCommander";
 */
 
/* "Instructions" hintC [
	"Press W to move forward.",
	"Press S to move backwards.",
	"Use the mouse to turn right or left.",
	"Press V for weapon sights."
];
 */


//#define __TEST_ARMA_LANDING__
#ifdef __TEST_ARMA_LANDING__

/*
dc3 = dc3civ;

dc3 addEventHandler ["LandedTouchDown",
    {
        hint "Touched down";  player groupChat format["TouchDown at %1", _this select 1];
        touched_down = true;
        sleep 5;
        dc3 setFuel 0;
        stopped_down = true;
    }
];
dc3 addEventHandler ["Gear",
    {
        player groupChat format["Gear ON = %1",_this select 1];
        if (!(_this select 1)) then  { dc3 flyInHeight 100};
    }
];

waitUntil {sleep 1.0; (!alive dc3) || (damage dc3  > 0.1) || (!alive player) || touched_down};
sleep 2;
pilot doMove (getMarkerPos "mk_align");
//player groupChat "Touched down";
waitUntil {!alive dc3 || (speed dc3 < 1) || !alive player};
if ( alive player) then
{
    player groupChat "Я жив и здоров!";
    player action ["eject", dc3];
    player groupChat "Вылезай быстренько. Некогда нам! У тебя 5 секунд, камарад!";
    dc3 engineOn false;
    dc3 setFuel 1;
    sleep 5;
    pilot stop false;
    [dc3, false, 30, 130, 200, 10, 0.11, [ getMarkerPos "mk_align", getMarkerPos "mk_takeoff", getMarkerPos "mk_land" ], 0, 2, 3, true, ""]execVM "scripts\mando_takeoff2.sqf";
*/
/*

    unassignVehicle pilot;
    //pilot action ["eject", dc3];
    dc3 engineOn false;
    sleep 3;
    pilot assignAsDriver dc3;
    pilot moveInDriver dc3;
    [pilot] orderGetIn true;
     sleep 3;
    _pos = getMarkerPos "mk_out";
    _pos0 =  getMarkerPos "mk_align";
    player groupChat format["Pilot ordered to move to %1", _pos];
    pilot landAt 0;
    dc3 flyInHeight 100;
};
*/

msg = format [" DC3 Empty positions Commander=%1, Driver=%2, Gunner=%3, Cargo=%4", dc3civ emptyPositions "Commander",dc3civ emptyPositions "Driver", dc3civ emptyPositions "Gunner", dc3civ emptyPositions "Cargo"];

player groupChat msg;

hint localize msg;
player moveInCargo dc3civ;


dc3civ execVM "scripts\dclanding.sqf";

//#else
// no landing simply test gear off/on event
_pos = getPos player;
_pos set [0, (_pos select 0) + 10];
_pos set [1, (_pos select 1) + 15];
dc3 = createVehicle [ "DC3", _pos, [], 0, "NONE"];
dc3 setDir (getDir player);

dc3 addEventHandler ["Gear",
    {
        player groupChat format["Шасси %1", if(_this select 1) then {"выпустил, буду садиться..."} else {"убрал.. улета.ю... куда?"}];
    }
];
dc3 addEventHandler ["LandedTouchDown",
    {
        if ( ((getPos dc3) select 2)  > -0.5) then
        {
            hint "Touched down";  player groupChat format["Приземлился, кажись (судорожно вздыхаю)... Не люблю летать! (%1 м.)", (getPos dc3) select 2];
        };
    }
];

#endif


//#define __TEST_MANDO_LANDING__
#ifdef __TEST_MANDO_LANDING__

state_to_text = {
    switch (_this) do
    {
        case 1: {"moving to first landing sequence point"};
        case 2: {" moving to second landing secuence point"};
        case 3: {"final aproach"};
        case 4: {"touch down"};
        case 5: {"taxiing"};
        case 6: {"end of landing procedure"};
        case 7: {"Plane damaged, landing procedure aborted"};
        default {format["<unknown %1>", _this]};
    };
};

[] spawn {

    [dc3, false, [getMarkerPos "mk_land", getMarkerPos "mk_takeoff", getMarkerPos "mk_align"], 130, 30, 168, true] execVM "scripts\mando_land.sqf";
    sleep 1;
    _state = dc3 getVariable "mando_land";
    _state_now = -1;
    while {alive dc3} do
    {
        _state_now =  dc3 getVariable "mando_land";
        if ( _state_now != _state) then
        {
            player groupChat (_state_now call state_to_text);
            _state = _state_now;
        };
        if ( _state_now >= 6 ) exitWith {player groupChat "--- Exit monitoring land loop"};
        sleep 0.5;
    };
    player groupChat format["dc3 alive(%1), last state %2", alive dc3, _state, _state_now ];
    [dc3, false, 30, 130, 200, 10, 0.11, [ getMarkerPos "mk_align", getMarkerPos "mk_takeoff", getMarkerPos "mk_land" ], 0, 2, 3, true, ""]execVM "scripts\mando_takeoff2.sqf";

    _state = dc3 getVariable "mando_land";
    _state_now = -1;
    while {alive dc3} do
    {
        _state_now =  dc3 getVariable "mando_land";
        if ( _state_now != _state) then
        {
            player groupChat (_state_now call state_to_text);
            _state = _state_now;
        };
        if ( _state_now >= 56 ) exitWith
        {
            player groupChat "--- Exit monitoring takeoff loop";
            player move [20000, 20000, 100];
            player flyInHeight 100;
        };
        sleep 0.5;
    };
    player groupChat format["dc3 alive(%1), last state %2", alive dc3, _state, _state_now ];

};

#endif

//#define __PROCESS_GRU_OBJECT_COORDS__
#ifdef __PROCESS_GRU_OBJECT_COORDS__

[] execVM "scripts\checkGRUHouse.sqf";
#endif


//#define __ANIM__
#ifdef __ANIM__
// проверка анимаций
player addAction ["Анимация 1","scripts\anim1.sqf"];
#endif

//#define __DRAW_BONUS_POS__
#ifdef __DRAW_BONUS_POS__

sm_bonus_positions =
	[                           // any number of positions
		[[9560,9890,0], 270], 	// position and direction 
		[[9550,9890,0], 270], 	// position and direction
		[[9560,9875,0], 270], 	// position and direction
		[[9550,9875,0], 270], 	// position and direction
		[[9560,9860,0], 270], 	// position and direction
		[[9550,9860,0], 270], 	// position and direction
		[[9560,9850,0], 270], 	// position and direction
		[[9550,9850,0], 270], 	// position and direction
		[[9513,9895,0], 90], 	// position and direction
		[[9513,9885,0], 90], 	// position and direction
		[[9513,9875,0], 90], 	// position and direction
		[[9513,9865,0], 90], 	// position and direction
		[[9513,9855,0], 90], 	// position and direction
		[[9513,9845,0], 90] 	// position and direction
	];

sm_bonus_vehicle_array =
	[
		"ACE_BRDM2_ATGM",	// 0-13 (14 vehicles total)
		"ACE_BRDM2",	    // 1
		"ACE_T64_BV",	    // 2
		"ACE_UAZ_MG",       // 3
		"ACE_UAZ_AGS30",    // 4
		"ACE_BMP2_D",       // 5
		"ACE_T55_AMV",      // 6
		"ACE_BRDM2_ATGM",	// 7
		"ACE_BMP3_M",       // 8
		"ACE_BRDM2_SA9",    // 9
		"ACE_BMP1_D",       // 10
		"ACE_BMD1p",        // 11
		"ACE_T80_U",        // 12
		"ACE_T72_BM"        // 13
	];

for "_i" from 0 to 55 do
{
	_vec_type = sm_bonus_vehicle_array select (_i % (count sm_bonus_vehicle_array));
	_pos_a = sm_bonus_positions select (_i % (count sm_bonus_positions));
	_pos = _pos_a select 0;
	_dir = _pos_a select 1;
	_vehicle = (_vec_type) createVehicle ( _pos) ;
	_vehicle setDir _dir;
	sleep 0.2;
};
#endif

//#define __PATROL_NORMAL__
#ifdef __PATROL_NORMAL__
player groupChat format["*** Patrol normalization SYG_generatePatrolList isNil == %1***", isNil "SYG_generatePatrolList"];
{
    _list = _x call SYG_generatePatrolList;
    _str = format["%1: %2", _x, _list];
    player groupChat _str;
    hint localize _str;
}forEach [
//"SP","SP","SP","SP","SP","SP","SP","SP"
"FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP","FP"
];
#endif

target_names =
//	#ifdef __DEFAULT__
	[
		[[8262,9017,0],   "Chantico"  ,180, 5],  //  3
		[[9170,8309,0],   "Somato"    ,230, 6],  //  4
		[[9349,5893,0],   "Cayo"      ,210, 2],  //  0
		[[10693,4973,0],  "Iguana"    ,270, 3],  //  1
		[[7613,6424,0],   "Arcadia"   ,235, 4],  //  2
//		[[8262,9017,0],   "Chantico"  ,180, 5],  //  3
//		[[9170,8309,0],   "Somato"    ,230, 6],  //  4
		[[10550,9375,0],  "Paraiso"   ,405, 7],  //  5 * for big town
		[[12399,7141,0],  "Ortego"    ,280, 8],  //  6 *
		[[11450,6026,0],  "Dolores"   ,350, 9],  //  7 *
		[[13302,8937,0],  "Corazol"   ,450, 10], //  8 *
		[[14470,10774,0], "Obregan"   ,240, 11], //  9
		[[13172,11320,0], "Mercalillo",210, 12], // 10
		[[14233,12545,0], "Bagango"   ,350, 13], // 11 *
		[[17271,14193,0], "Masbete"   ,180, 14], // 12
		[[18984,13764,0], "Pita"      ,250, 15], // 13
		[[12508,15004,0], "Eponia"    ,270, 16], // 14
		[[16596,9358,0],  "Everon"    ,200, 17], // 15
		[[9773,14436,0],  "Pacamac"   ,150, 18], // 16
		[[7722,15802,0],  "Hunapu"    ,150, 19], // 17
		[[10593,16194,0], "Mataredo"  ,150, 20], // 18 - for small town
		[[12387,13388,0], "Carmen"    ,200, 21], // 19
		[[2826,2891,0],   "Rahmadi"   ,180, 22], // 20
		[[14444,8554,0],  "Gaula"     ,180, 23], // 21 -
		[[6850,8069,0],   "Estrella"  ,200, 24], // 22 -
		[[15404,13829,0], "Benoma"    ,279, 25], // 23 -
		[[9321,5275,0],   "Tiberia"   ,279, 26], // 24 -
        [[14351,9461,0],  "Modesta"   ,279, 27], // 25 -
		[[11502.5,9152,0],"Corinto"   ,200, 28], // 26 -
		[[8868,7907,0],   "Gulan"     ,220, 29]  // 27 -
	];

//#define __HELI_TEST__
#ifdef __HELI_TEST__
setViewDistance 8000;
//player groupChat "[] execVM ""scripts\showEnemyInfo.sqf""";
//player groupChat "[] execVM ""scripts\showEnemyInfo.sqf""";
//[] execVM "scripts\showEnemyInfo.sqf";
#endif

//#define __JAIL__
#ifdef __JAIL__
//playSound "Recall1";

_pos = position jail;
_marker_jail = createMarkerLocal ["marker_jail", _pos];
_marker_jail setMarkerShapeLocal "ICON";
_marker_jail setMarkerTypeLocal "Flag";
//_marker_jail setMarkerTextLocal "Destroy Radio Tower";
_marker_jail setMarkerSizeLocal [0.5, 0.5];

_hotel_pos = [10269.6,7353.71,0];
_hotel = _hotel_pos nearestObject 172902;
//pos_near_hotel
if ( isNull _hotel) exitWith {player groupChat "--- No hotel found"};
// pos_near_hotel
next_pos_in_hotel = 0;
//player addAction ["next room", "scripts\hotel_next_room.sqf",[_hotel]];
//player addAction ["near hotel", "scripts\hotel_near_pos.sqf",[getPos pos_near_hotel]];
player addAction ["1st floor pos", "scripts\hotel_next_room.sqf",[0,_hotel]]; // pos on 1st floor
//player addAction ["to jail", "scripts\hotel_next_room.sqf",[_pos,_hotel]];
player addAction ["to jail", "scripts\jail.sqf",[]];
player addAction ["3 m ahead", "scripts\next_step.sqf",[3]];
player addAction ["store RELPOS", "scripts\hotel_next_room.sqf",["MAKE_REL", _hotel]];
player addAction ["GO TO RELPOS", "scripts\hotel_next_room.sqf",["USE_REL", _hotel]];
player addAction ["GO TO BASE", "scripts\hotel_next_room.sqf",["BASE",_hotel]];

#endif

/* Not work with static map object
_shooting_range = (getPos player) nearestObject 8701;
_str = format["Shooting range ""%1""", typeOf _shooting_range];
player groupChat _str;
hint localize _str;
*/

//#define __UNDERGROUND_HOUSE__
#ifdef __UNDERGROUND_HOUSE__
_house = [9560,9890,0] nearestObject 78793;
if (isNull _house) exitWith { player groupChat "No repstation found!"};
player groupChat format["Repstation %1 at %2 found!", _house, getPos _house];
player addAction ["rep st info", "scripts\rep_station_info.sqf",[_house]];
player addAction ["del ruins", "scripts\rep_station_info.sqf",["DEL_RUINS",_house]];
#endif

//#define __NEW_NIGHT__
#ifdef __NEW_NIGHT__

_date = date;
_date  set [3, 21];
_date  set [4, 0];
setDate _date;
player groupChat format["+++++ __NEW_NIGHT__  time is %1 +++++", date];
player addAction ["skip time", "scripts\skip_time.sqf",[]];

#endif

// not work!
//#define __WRECK_MAKER__
#ifdef __WRECK_MAKER__
player addAction ["Wreck it!", "scripts\wreck_it.sqf",[]];
#endif

//#define __KILLER__
#ifdef __KILLER__

player groupChat "+++ AIR KILLER SCRIPT EXECUTED +++";

[o4, h1] execVM "scripts\AirKiller.sqf"; // scripts/AirKiller.sqf


#endif

_location = createLocation [ "ViewPoint"  , getPos h1, 10, 10];
_location attachObject h1;
_location setText (name h1);

#define __MT_BONUS__
#ifdef __MT_BONUS__

mt_bonus_vehicle_array =
[
"ACE_BRDM2_SA9", 		 // 0
"ACE_BRDM2_ATGM",        // 1

"ACE_BMP3",
"ACE_BMP3_M", 		    // 2 - ordinal vehicles list

"ACE_ZSU",          	// 3
"ACE_ZSU",				// 4

"ACE_T55_AMV",          // 5
"ACE_T64_BV",			// 6
"ACE_T72_BM", 			// 7
"ACE_T80_UM1",     		// 8

"ACE_Mi24D", 			// 9
"ACE_Mi24V",     	    //10
"ACE_Mi24P",	        //11
"ACE_KA52",  			//12
"ACE_Mi17", 		    //13
"ACE_Su30Mk_R27_R73",	//14
"ACE_Su34B"             //15
];

mt_big_bonus_vehicle_array = [
"ACE_Ka50", 		    // 0 - first big bonus vehicle (heli + plane + big tank)
"ACE_Ka50_N", 	        // 1
"ACE_Su30Mk_Kh29T",     // 2
"ACE_Su30Mk_KAB500KR",  // 3
"ACE_T90",              // 4
"ACE_T90A"              // 5
];

sm_bonus_received_vehicle_array = [];
sm_bonus_vehicle_array =
[
"ACE_BRDM2_ATGM",	// 0-13 (14 vehicles total)
"ACE_BRDM2",	    // 1
"ACE_T64_BV",	    // 2
"ACE_UAZ_MG",       // 3
"ACE_UAZ_AGS30",    // 4
"ACE_BMP2_D",       // 5
"ACE_T55_AMV",      // 6
"ACE_BRDM2_ATGM",	// 7
"ACE_BMP3_M",       // 8
"ACE_BRDM2_SA9",    // 9
"ACE_BMP1_D",       // 10
"ACE_BMD1p",        // 11
"ACE_T80_U",        // 12
"ACE_T72_BM"        // 13
];
#endif

#ifdef __OLD__
_param = [ mt_bonus_vehicle_array, [], mt_bonus_vehicle_array];
for "_i" from 1 to 28 do {
    bonus_number = _param call SYG_findTargetBonusIndex;
    player sideChat (format["bonus %1 %2", _i, mt_bonus_vehicle_array  select bonus_number]);
    hint   localize (format["bonus %1 %2", _i, mt_bonus_vehicle_array  select bonus_number]);
    sleep 0.5;
};

_param = [sm_bonus_vehicle_array, [], sm_bonus_vehicle_array];
for "_i" from 1 to 55 do {
    bonus_number = _param call SYG_findTargetBonusIndex;
    player sideChat (format["bonus %1 %2", _i, sm_bonus_vehicle_array  select bonus_number]);
    hint   localize (format["bonus %1 %2", _i, sm_bonus_vehicle_array  select bonus_number]);
    sleep 0.5;
};
#endif

//#define __CHECK_DESERT__
#ifdef __CHECK_DESERT__

player groupChat "__CHECK_DESERT__";
hint localize "__CHECK_DESERT__";

/*
player groupChat format["--- SYG_pointInRect is %1 ---",typeName SYG_pointInRect];
hint localize format["--- SYG_pointInRect is %1 ---", typeName SYG_pointInRect];
hint localize format["--- SYG_pointInRect: %1 ---", SYG_pointInRect];
*/
_somato = target_names select 4;
_somato_point = _somato select 0;
_desert = _somato_point call SYG_isDesert;
player groupChat format["*** Somato %1 is desert = %2 ***", _somato_point, _desert];
hint localize format["*** Somato %1 is desert = %2 ***", _somato_point, _desert];

_pnt = getPos pnt_desert;
_desert = _pnt call SYG_isDesert;
player groupChat format["*** desert point %1 is desert = %2 ***", _pnt, _desert];
hint localize format["*** desert point %1 is desert = %2 ***", _pnt, _desert];

#endif

//#define __FILL_OEVRTURNED_VEHICLES__
#ifdef __FILL_OEVRTURNED_VEHICLES__

player addAction ["turnout nearest", "scripts\turnout.sqf", []];
_res = t90 call SYG_preventTurnOut; // addEventHandler["GetOut", {_this spawn SYG_getOutEvent}];
if (! _res) then {
    player groupChat "Failure to add event ""GetOut"" to t90"
} else {
    _str = format["+++ event ""GetOut"" assigned to %1 with id %2", t90, t90 getVariable "AntiTurnIdx"];
    player groupChat _str;
    hint    localize _str;

};

_res = t90 call SYG_preventTurnOut; // addEventHandler["GetOut", {_this spawn SYG_getOutEvent}];
if (! _res) then {
    player groupChat "Failure to add event ""GetOut"" to t90";
} else {
    _str = format["+++ event ""GetOut"" assigned to %1 with id %2", t90, t90 getVariable "AntiTurnIdx"];
    player groupChat _str;
    hint    localize _str;

};

#endif

//#define __PRINT_IDS__
#ifdef __PRINT_IDS__
    _churh = getPos player nearestObject 1806;
    _house =  getPos player nearestObject 554947;
    player groupChat format[ "Suitable building are %1 and %2", typeOf _churh, typeOf _house ];
#endif

//#define __CHECK_HILLS__
#ifdef __CHECK_HILLS__
player addAction ["check nearest hill point", "scripts\checkhill.sqf", []];
player addAction ["3 m ahead", "scripts\next_step.sqf",[3]];

#endif

//#define __WRECK_TIMER__
#ifdef __WRECK_TIMER__

_pos_merk = (target_names select 10) select 0;
_pos_flag = getPos FLAG_BASE;
_dist = [_pos_merk, _pos_flag] call SYG_distance2D;
_str = format["+++ BASE <-> Mercallilo distance %1 m", round _dist];
player groupChat _str;
hint localize _str;

{
    _dist = _x;
    _time = ceil (((300 * _dist / (3754 / 2)) + 30) / 60); // new time in minutes, simplest formula: 100 seconds per 1 kilometers
    _part = (_time * 0.2) max 1.0; // one part in minutes
    _marker_stage_arr = [ round(_part  * 60), [round(_part * 120), "ColorRed"], [round(_part * 120), "ColorRedAlpha"] ];
    _str = format["+++ dist %1 m, time %2 min, part %3 min, marker steps %4", _dist, _time, _part, _marker_stage_arr];
    player groupChat _str;
    hint localize _str;
} forEach [2000, 4000, 5000, 7000, 8000, 10000, 12000, 15000];

#endif

//#define __MANDO_TEXT__
#ifdef __MANDO_TEXT__
[getPos lg_pos1,270,10,15,0,180,["H","E","L","L","O"],[10,10,5,5],"\ca\data\koulesvetlo",false,[[0,0,0,0],[1,1,0,1],[0,1,1,1],[0,0,0,0]],10,0] exec"scripts\mando3dwrite.sqs";
#endif

//#define __TEST_BUDKA__
#ifdef __TEST_BUDKA__
//		if ( (random 1) < 0.5 ) then {
    // "ACE_Scorpion", "ACE_20Rnd_765x17_vz61", 4]
    _obj = budka;
    _cnt = _obj call SYG_housePosCount;
    _pos = floor (random _cnt);
    _pos = _obj buildingPos _pos;
    _pos set [2, (_pos select 2) + 0.55];
//    _pos set [0, (_pos select 0) - 0.25];
    _weaponHolder = "WeaponHolder" createVehicleLocal [0,0,0];
    _weaponHolder setPos _pos;// [_weaponHolderPos, [], 0, "CAN_COLLIDE"];
    _wpnCnt = ceil (2);
    _item = (SYG_PISTOL_WPN_SET_WEST) call XfRandomArrayVal;
    _wpn = _item select 1;
    _mag = _item select 2;
    _weaponHolder addWeaponCargo [_wpn, 1];
    _weaponHolder addMagazineCargo [_mag, 4 ];
    hint localize format["+++ %1: building pos %2, wpn %3", typeOf _obj, _pos, _wpn];
//		};
#endif

//#define __TEST_NEAR_BOATS__
#ifdef __TEST_NEAR_BOATS__

_marker = getMarkerType "#$unknown_in_system_marker^";
hint localize format["+++ type ""%1"", name %2, count target_names %3", _marker, typeName _marker, count target_names];
_pos = (target_names select 0) select 0;
_marker = _pos call  SYG_nearestBoatsMarker;
hint localize format["+++ Near boats port for %1 is ""%2"" at dist %3 m.", (target_names select 0) select 1, _marker, round ((getMarkerPos _marker) distance _pos) ];

{
    // [[9349,5893,0],"Cayo", 210],     // 0
    _marker = (_x select 0) call SYG_nearestBoatsMarker;
    hint localize format["+++ Near boats port for %1 is ""%2"" at dist %3 m.", _x select 1, _marker, round ((getMarkerPos _marker) distance (_x select 0 )) ];
    sleep 0.1;
} forEach target_names;
#endif

//#define __SABOTAGE_STASH__
#ifdef __SABOTAGE_STASH__

[] execVM "scripts\sabstash\createStashMenus.sqf";

#endif

// #define __CALC_TREE__
#ifdef __CALC_TREE__
player addAction ["Calc. trees around", "scripts\calcTreesAround.sqf", [20]];

#endif

//#define __WHOLER__
#ifdef __WHOLER__

X_Client = true;
[daytime+2/60, daytime +5] execVM "scripts\SYG_lighthouses.sqf"; // from now and to + 10 min
X_Client = nil;

_str1= localize "STR_NEVER_EXISTS";
_str2= localize "STR_SYS_00";

player groupChat format["+++ Localize ""STR_NEVER_EXISTS"" => ""%1"", ""STR_SYS_00"" => ""%2""", _str1, _str2 ];

#endif

#define __LIGHTHOUSE__
#ifdef __LIGHTHOUSE__

_diff_pos = [1.06738,-0.278809,-8.07489];
_diff_dir = -66.116;
// add computer to majak: _majak call _add_comp;
addComputer2Majak = {
	private [ "_comp", "_pos" ];
	if (isNull _this) exitWith { hint localize "--- scripts\SYG_lighthouses.sqf: majak not found within 50 meters" };
	if (!(_this isKindOf "Land_majak")) exitWith { hint localize format[ "--- scripts\SYG_lighthouses.sqf: _this (%1) is not kind of Land_majak", typeOf _this] };
	_comp = nearestObject[_this, "Computer"];
	if (!isNull _comp)  exitWith {}; // allready added
	_pos = _this modelToWorld [1.06738,-0.278809,-8.07489] ;
//	_comp = createVehicleLocal ["Computer", _pos, [], 0, "CAN_COLLIDE"];
	_comp = "Computer" createVehicleLocal  [0,0,0];
	_comp setDir ((getDir _this)  + 66.116);
	_pos1 = + _pos;
	_pos1 set [0, (_pos select 0) + 5];
	_pos1 set [2, 1];
	_comp  setVehiclePosition [ _pos1, [], 0, "CAN_COLLIDE"] ;
	hint localize format["+++ comp modelToWorld = %1, real pos %2", _pos, getPos _comp];
};

// remove computer from majak: _majak call _remove_comp;
removeComputerFromMajak = {
	private [ "_comp", "_pos" ];
	if (isNull _this) exitWith { hint localize "--- scripts\SYG_lighthouses.sqf: majak not found within 50 meters" };
	if (!(_this isKindOf "Land_majak")) exitWith { hint localize format[ "--- scripts\SYG_lighthouses.sqf: _this (%1) is not kind of Land_majak", typeOf _this] };
	_comp = nearestObject[_this, "Computer"];
	if (isNull _comp)  exitWith {}; // not preset
	deleteVehicle _comp;
};


checkLighthouse = {
	private ["_majak","_computer"];
	_majak = nearestObject [player , "Land_majak"];
	if (isNull _majak) exitWith{ player groupChat "--- No majak found near"; };
	if ((_majak distance player) > 10) exitWith{player groupChat format[ "--- Majak more then 10 meters away (%1)", round(_majak distance player)] };
	_computer = nearestObject[_majak, "Computer"];
	if (isNull _computer) exitWith{ player groupChat "--- No computer found near"; };
	_diff_pos = _majak worldToModel (getPos _computer);
	_str = format["diff pos = %1, dir %2", _diff_pos, (direction _majak) - (direction _computer) ];
	hint localize _str;
	player groupChat _str;
};

//majak_comp addAction["Проверить маяк","scripts\checkLighthouse.sqf"];
//majak_comp addAction["Убрать компьютер","scripts\removeComputer.sqf"];
player addAction ["Добавить комп","scripts\addComp.sqf", nearestObject [player , "Land_majak"]];
_majak = nearestObject [start1_3 , "Land_majak"];
if (!isNull _majak) then{
	_id = _majak addEventHandler["killed", { player groupChat "Killed"; hint localize format["+++ Majak killed with %1", _this]}];
	player groupChat format[ "+++ killed event set as %1", _id ];
} else {
	 player groupChat "--- No majak found near";
};
#endif

//#define __TEST_TREE_BB__
#ifdef __TEST_TREE_BB__
player groupChat "+++ __TEST_TREE_BB__ +++";
player addAction ["test vegetation BB", "scripts\tree_bb_check.sqf", 20];
#endif

#define __NEW_BONUS__
#ifdef __NEW_BONUS__

call compile preprocessFileLineNumbers "scripts\bonuses\x_netinit.sqf";	// Weapons, re-arming etc
//player groupChat format["+++ file name ""%1""",__FILE__];

[] execVM "scripts\bonuses\createBonus.sqf";

/*
hint localize "++++++++++++++++++++++++++ Generate air positions +++++++++++++++++++++++++++";
hint localize "_air_pos_arr = [";
_cnt = 0;
_str = "";
for "_i" from 1 to 50 do {
	_marker = format["air%1", _i];
	_markerType = getMarkerType _marker;
	if (_markerType == "") exitWith { _cnt = _i - 1; hint localize _str };
	if (_str != "") then {
		hint localize (_str + ",");
	};
	_str = format[ "  [%1,%2]", markerPos _marker, markerDir _marker ];
};
hint localize "];";
hint localize format[ "+++ %1 air position[s] generated", _cnt ];
*/

#endif

// #define __TEST_VICTORIA__
#ifdef __TEST_VICTORIA__
hint localize "/* +++ GENERATION of MG OFFSETS and angles +++ */";
_veh = prison3;
{
	_pos = _veh worldToModel (getPos _x);
	hint localize format["%1 pos    = %2", typeOf _x, _pos];
	hint localize format["%1 azimut = %2", typeOf _x, ((getDir _veh) - (getDir _x)) mod 360];

} forEach [mg1,mg2,mg3,zsu1,zsu2];

#endif
player groupChat "--------------- END of init.sqf ---------------";

