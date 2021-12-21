//
// Script to show info about nearest object
//
while { true } do {

	_objlist = nearestObjects [player, [/*"All","AllVehicles", "Building", "RoadCone", "House", "Man"*/ ], 15];
	_found = format["Objects %1", count _objlist];

	_obj = objNull;
	{
		if ( 
			 (_x != player) 
				  and 
			 ( not ( ((typeOf _x) in ["", "#crater", "#crateronvehicle", "#mark" ,"#track","HoneyBee","HouseFly", "ButterFly", "DragonFly", "Mosquito"]) or (_x isKindof "rocko_556") ) 	) 
		   ) exitWith { _obj = _x;	};
	} forEach _objlist;

	if ( !isNull _obj ) then {
		_lasttime = time;
		_dist = player distance _obj;
		_found = _found + format[". 1st at %1 (z=%2)", 
				(round(_dist * 100.0)) / 100, 
				(getPos _obj select 2)];
		_lstobj = _obj;
		_cn = typeOf _obj;
		_dir = getDir _obj;
		_dn = getText (configFile >> "CfgVehicles" >> typeof _obj >> "displayName");
		_str = "";
		_str1 = "";
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
		}
		else
		{ 
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
			} else
			{
				if ( _obj isKindOf "Building" ) then
				{
					_str = _str + format["dir %1", round (_dir)];
				};
			};
		};
		hint format["%7\nDispname: %1\nClsname: ""%2""\nDamage %5, alive %6\nName ""%3""\nUName %8\n%4\n%8", _dn, _cn, name _obj, _str,  getDammage _obj, alive _obj, _found,  format["%1",_obj] ];
	};
	sleep 1.0;
};

if (true) exitWith {};