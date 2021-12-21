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

private ["_dir", "_o1", "_o2", "_deg", "_dist", "_flag", "_oldlocpos", "_locs", "_loc", "_locpos", "_flgdist", "_playerHeading", "_dirFromNorth2Loc", "_direction", "_relDir2Loc", "_plrpos", "_pos2"];

#define DELTA(a,b) ((a)-(b))

#define DIR2DIR(a, b) (if (DELTA(a,b)>180) then { 360 - DELTA(a,b) } else { -DELTA(a,b)})

#define DIR_FROM_DIR(a,b) (if ((a) > (b)) then { DIR2DIR(a,b) } else {-DIR2DIR(b,a)})

#define SEARCH_DIST 100
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

#define ROUND2(val)(floor((val)*100.0)/100.0)
#define ROUND0(val)(round(val))

Round2 = {
	floor (_this * 100.0) / 100.0
};

_fixGetPosASL = {
    _this modelToWorld [0, 0, ((getPosASL _this) select 2)- ((getpos _this)select 2)]
};

_locList = ["Name","NameMarine","NameCityCapital","NameCity","NameVillage","NameLocal","Hill",/*"Mount","ViewPoint",*/"VegetationBroadleaf"];
_reliefList = ["Hill", /*"Mount",*/"ViewPoint","RockArea"];

if ( isNil "SYG_UTILS_COMPILED" ) then  // generate some static information
{
	call compile preprocessFileLineNumbers "scripts\SYG_utils.sqf";
};

if ( count _this > 0 ) then { _dist = _this select 0;} else {_dist = SEARCH_DIST;};
player globalChat format["*** spawned info report on locations at radius %1", _dist];

_flag =  objNull;
_oldlocpos = [0,0,0];
_empty = "Logic" createVehicleLocal [0,0,0];
while { true } do
{
	//_dist = 9999999.9;
	sleep 1;
	 // nearestLocation
	_pos = getPos player;
	_loc = nearestLocation [_pos, ""];
	//hint format["loc=%1",_loc];
/**
	_locs = nearestLocations [_pos,_reliefList, _dist, _pos]; //objNull;
	if ( count _locs == 0) then
	{
        hint format["No loc at dist  %1 m", _dist]
	}
	else
*/
	//{
        //_loc = _locs select 0;
        _real_loc = _loc;
        _loc_type = type _loc;
        // Arma sometimes skips "Hill" and "ViewPoint" values in vicinity of "Mount" one
        _locpos = locationPosition _loc;

        //_locpos set [2, 0]; // zero Z coordinate

        _plrpos = position player;
        //_plrpos set [2, 0];

        _flgdist = (_locpos distance _oldlocpos); // dist to previous location flag
        if ( _flgdist > 1.0 ) then  {
            if ( !isNull _flag ) then {	deleteVehicle _flag;};

            _flag = createVehicle ["FlagCarrierNorth", _locpos, [], 0, "CAN_COLLIDE"];

            if ( isNull _flag ) then {player globalChat "--- flag creation failure"}
            else {player groupChat format["+++ flag set to pos %1/%2, init dist %3, real %4, view %5", _locpos, position _real_loc, ROUND2(_plrpos distance _locpos), _loc_type, type _loc]};
            _oldlocpos = _locpos;
        };
        _playerHeading = direction (vehicle player);
        _dirFromNorth2Loc =  [player, _loc] call DirToObj; //_direction from  player north to location
        _relDir2Loc  = DIR_FROM_DIR( _playerHeading, _dirFromNorth2Loc );

        //_txt = text _real_loc;
        _pos = +_locpos;
        _pos set [2, 0];
        _empty setPos _pos;
        _pos = getPosASL _empty;
        _txt = format["%1,%2,%3",ROUND2(_pos select 0),ROUND2(_pos select 1),ROUND2(_pos select 2)];
        _slope = [_pos, 5] call XfGetSlope;

        //_txt = format["[%1,%2,%3]%4", ROUND2(_locpos select 0),ROUND2(_locpos select 1),ROUND2(_locpos select 2), _txt];

        hint format["%1[%2]:\nfacing to %3\ndist=%4, dir to loc=%5\nPL. facing %6\nsize (%7x%8),dir %9,locpos %10, slope %11",
        _loc_type,
        _txt,
        ROUND0(_relDir2Loc),
        ROUND0(_plrpos distance _locpos),
        ROUND0(_dirFromNorth2Loc),
        ROUND0(_playerHeading),
        ROUND0((size _real_loc) select 0),
        ROUND0((size _real_loc) select 1),
        ROUND0(direction _real_loc),
        _locpos,
        ROUND2(_slope)
        ];
//	};
};