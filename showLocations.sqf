/*
	List of available locations in Arma 1:
	Name
    NameMarine
    NameCityCapital
    NameCity
    NameVillage
    NameLocal
    Hill
	Mount
    ViewPoint
    RockArea
    BorderCrossing
    VegetationBroadleaf
    VegetationFir
    VegetationPalm
    VegetationVineyard
*/

private ["_dir", "_o1", "_o2", "_deg", "_dist", "_flag", "_oldlocpos", "_locs", "_loc", "_locpos", "_flgdist", "_playerHeading", "_dirFromNorth2Loc", "_direction", "_relDir2Loc", "_pos1", "_pos2"];

#define DELTA(a,b) ((a)-(b))

#define DIR2DIR(a, b) (if (DELTA(a,b)>180) then { 360 - DELTA(a,b) } else { -DELTA(a,b)})

#define DIR_FROM_DIR(a,b) (if ((a) > (b)) then { DIR2DIR(a,b) } else {-DIR2DIR(b,a)})

// direction from one object to another, starting from north as clockwise angle
// parameters: object1, object2
// example: _dir = [tank1, apc1] call XfDirToObj;
DirToObj = {
 	private ["_o1","_o2","_deg"];
	_o1 = _this select 0;_o2 = _this select 1;
	_deg = ((position _o2 select 0) - (position _o1 select 0)) atan2 ((position _o2 select 1) - (position _o1 select 1));
	if (_deg < 0) then {_deg = _deg + 360};
	_deg
 };

#define ROUND2(val) (floor( (val) * 100.0)/100.0)
#define ROUND0(val) (round(val))

Round2 = {
	floor (_this * 100.0) / 100.0
};

if ( count _this > 0 ) then { _dist = _this select 0;} else {_dist = 100;};
player globalChat format["*** spawned info report on locations at radius %1", _dist];

_flag =  objNull;
_oldlocpos = [0,0,0];
while { true } do
{
	sleep 1;
	_locs = nearestLocations [ position player, [/*"BorderCrossing","Hill",*/"Mount","Name","NameCity","NameCityCapital","NameLocal", /*"NameMarine", */ "NameVillage"/*,  "RockArea", 
	 "VegetationBroadleaf", "VegetationFir", "VegetationPalm", "VegetationVineyard",  "ViewPoint"*/], _dist];

	if ( (count _locs) == 0 ) then
	{ 
		hint format["No locations in radius %1", _dist];
	}
	else
	{
		_loc = _locs select 0;
		_locpos = position _loc;
		_locpos set [2, 0]; // zero Z coordinate
		_flgdist = (_locpos distance _oldlocpos); // dist to previous location flag
		
		if ( _flgdist > 1.0 ) then  {
			_oldlocpos = _locpos;
			if ( !isNull _flag ) then {	deleteVehicle _flag;};
			
			_flag = "FlagCarrierNorth" createVehicle  _oldlocpos;
			if ( isNull _flag ) then {player globalChat "--- flag creation failure"} 
			else {player globalChat format["+++ flag set to pos %1, init dist %3", _locpos, ROUND2(player distance _flag)]};
		};
		_playerHeading = direction (vehicle player);

		_dirFromNorth2Loc =  [player, _flag] call DirToObj; //_direction from  player north to location
		
		_relDir2Loc  = DIR_FROM_DIR( _playerHeading, _dirFromNorth2Loc );
		_pos1 = position player;
		_pos1 set [2, 0];
		_pos2 = position _loc;
		_pos2 set [2, 0];
		_txt = text _loc;
		if ( (type _loc) == "Mount" ) then {_txt = format["%1", round ((getPosASL _flag) select 2)]};
		
		hint format["%1['%2']:\n facing to - %3\ndist=%4, dir to loc=%5\nPL. facing %6", 
		type _loc, 
		//text _loc, 
		_txt,
		ROUND0(_relDir2Loc), 
		ROUND0(_pos1 distance _pos2), 
		ROUND0(_dirFromNorth2Loc),
		ROUND0(_playerHeading)];
	};
};