/*
	author: Sygsky
	description:
        Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
        target (_this select 0): Object - the object which the action is assigned to
        caller (_this select 1): Object - the unit that activated the action
        ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
        arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
	returns: nothing
*/

#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))

#define X_POS 0
#define Y_POS 1
#define Z_POS 2


// find nearest hill top
//player groupChat format["SYG_nearestHeight %1", SYG_nearestHeight];

//_loc = (getPos player) call SYG_nearestHeight;
//_loc = (getPos player) call SYG_nearestForest;
_loc = nearestLocation [ player, "Mount" ];
//player groupChat format["Location: %1",  _loc ];

_h = _loc call SYG_heightValue;
//_veh = createVehicle ["HeliHEmpty", locationPosition _loc, [], 0, "CAN_COLLIDE"];
//_pos =  getPosASL _veh;
//_height1 = _pos select Z_POS;

//_veh = "HeliHEmpty" createVehicleLocal locationPosition _loc;
//_pos1 =  getPosASL _veh;
//_height2 = _pos1 select Z_POS;

_isGood = _loc call SYG_heightIsGood;
//_obs_arr =  nearestLocations [locationPosition _loc,["RockArea","VegetationBroadleaf","VegetationFir","VegetationPalm","VegetationVineyard"],15];
//_isGood = count _obj_arr == 0;
_dist = (locationPosition _loc) distance player;
player groupChat format["nearest mount is %1 m height, dist %2 m, pos is %3", _h, round(_dist),  if (_isGood) then {"GOOD"} else {"BAD"}];
