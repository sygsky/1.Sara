//
// Script to show info about nearest object
//

#define ROUND2(val) (floor((val)*100.0)/100.0)
#define ROUND3(val) (floor((val)*1000.0)/1000.0)

// direction from one object/position to another
// parameters: object1 or position1, object2 or position2 
// example: _dir = [pos1, obj2] call XfDirToObj;
//         _dir = [tank1, pos2] call XfDirToObj;
XfDirToObj = {
	private ["_o1","_o2""_deg"];
	_o1 = _this select 0;_o2 = _this select 1;
	if ( typeName _o1 != "ARRAY" ) then { _o1 = position _o1};
	if ( typeName _o2 != "ARRAY" ) then { _o2 = position _o2};
	_deg = ((_o2 select 0) - (_o1 select 0)) atan2 ((_o2 select 1) - (_o1 select 1));
	if (_deg < 0) then {_deg = _deg + 360};
	_deg
};


while { true } do {

	if ( vehicle player == player ) then { // show info only if player not in vehicle
		//_objlist = nearestObjects [player, ["AllVehicles", "Building" ,"House", "Man" ], 15];
		_objlist = nearestObjects [player, [], 15];
		//_objlist = nearestObjects [player, [], 15];
		_found = format["Found %1 objs", count _objlist];

		_obj = objNull;
		{
			if (
				 (_x != player) 
				      and 
			     ( not ( ((typeOf _x) in [ "Camera", /**"", "#slop",*/ "#crater", "#crateronvehicle", "#mark" ,"#track",
				     "HoneyBee","HouseFly", "ButterFly", "DragonFly", "Mosquito"]) 
					  //or (_x isKindof "rocko_556")
					  )
				 ) 
			   ) exitWith { _obj = _x;	};
		} forEach _objlist;
		scopeName "main";
		if ( !isNull _obj ) then {
			_lasttime = time;
			_dist = player distance _obj;
			_side = side _obj;
			_found = _found + format[". 1st at %1 (z=%2)",  ROUND2(_dist),  ROUND3(getPos _obj select 2)];
			_lstobj = _obj;
			_cn = typeOf _obj;
			if (_cn == "") then { _cn = format["%1", _obj]; };
			_dir = getDir _obj;
			_dn = getText (configFile >> "CfgVehicles" >> typeOf _obj >> "displayName");
			_str = "";
			_str1 = "";
			_name = "";
			if ( _obj isKindOf "Man" ) then 
			{
	//			_str = format["z=%1, mags:", getPos _obj]
				_str = "mags: ";
				_magcnt = 1;
				_lastmag = "";
				{
					if 	(_x != _lastmag ) then // add last one and count next
					{
						if ( _lastmag != "" ) then
						{
							_str= _str + _lastmag + format["(%1)\n",_magcnt];
						};
						_lastmag = _x;
						_magcnt = 1;
					}
					else
					{
						_magcnt = _magcnt + 1;
					};
				} forEach magazines _obj;
				
				if ( _lastmag == "" ) then
				{
					_str = "empty";
				}
				else
				{
					_str= _str + _lastmag + format["(%1)", _magcnt];
				};	

				// report weapon and its kind
				_wpn = primaryWeapon _obj;
				_str2 = "<UNDEF>";
				if ( _wpn != "" ) then 
				{
					if ( _wpn call SYG_isSniperRifle ) then
					{
						_str2 = "SNP";
					} 
					else 
					{
						if ( _wpn call SYG_isMG ) then
						{
							_str2 = "MG";
						}else
						{
							if ( _wpn call SYG_isSMG ) then
							{
								_str2 =  "SMG";
							};
						};
					};
					if ( _obj call SYG_hasLauncher ) then
					{
						_str = _str + "+ Has Launcher +";
					};
					if ( _wpn call SYG_isSupressed ) then {_str2 = _strw + ", Supressed"};
					_str2 = _str2 + format[", size %1", sizeOf _wpn];
				}
				else {_wpn = "empty"};
				_str = _str + format["\nPrim. wpn = '%1' : %2", _wpn, _str2];
				if ( _obj call SYG_hasPistol ) then
				{
					_str = _str + "\nHas Pistol";
				};
				_astate = animationState _obj;
				if ( _astate != "" ) then
				{
					_str = _str + format["\nanimSt %1",_astate];
				};
				//breakTo "main";
				_name = name _obj;
			};
			if ( _obj isKindOf "LandVehicle" ) then
			{
				_fcap = getNumber (configFile >> "CfgVehicles" >> typeof _obj >> "fuelCapacity");
				_str = format["Fuel %1/%2", (fuel _obj) * _fcap, _fcap];
				if ( _obj call SYG_isCivicMGCar )
				then {_str = _str + ", is Civic MG car";};
				_ec = effectiveCommander _obj;
				{
					_name = _x getVariable "name";
					if ( !isNil "_name" ) then {_str = _str + format ["; %1%2", if (_x == _ec) then {"*"} else {""}, _name]};
				} forEach crew _obj;
				//breakTo "main";
			};
			_str = _str + format[" dir %1", round (_dir)];
			if ( _obj isKindOf "House" ) then
			{	
				_cnt = _obj call SYG_housePosCount;
				if ( _cnt > 0 ) then {	_str = _str + format["\npos count %1", _cnt]; };
			};
			_unc = true;
			if (format["%1",_obj getVariable "ACE_unconscious"] == "<null>") then { _unc = false; } else { _unc = _obj getVariable "ACE_unconscious"; };
			
			// calculate wind
			_wind = wind;
			_wind_speed = (round((_wind distance [0,0,0]) * 100))/100;
			_wind_dir  = round([[0,0,0],_wind] call XfDirToObj);
			_st = "";
            if ( surfaceIsWater  position (vehicle player) ) then { _st = _st + " in water" };

            _st = _st + format[" %1, %2", getPos _obj, _obj modelToWorld [0,0,0]];
//            player groupChat _st;
			hint format["%7\nDispName: %1\nCls:""%2"", side %11\ndmg %5, alv %6, mov %9, unc %10\nName %3\nUName %8\n%4\nwind %12 m/s, %13 deg, %14",
			_dn, _cn, _name, _str,  ROUND3(getDammage _obj),
			alive _obj, _found,  format["%1",_obj], canMove _obj, _unc,
			_side,_wind_speed, _wind_dir, _st ];
		};
	};
	sleep 1.0;
};

if (true) exitWith {};