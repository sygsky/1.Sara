//
// delete nearest camp
//

// distance to find camp to delete
_dist = 10;
if ( count (_this select 3) > 0 ) then {_dist = (_this select 3) select 0;};

_unit  = _this select 1; // player
_arr = nearestObjects [_unit, ["ACamp"], _dist];
if ( count _arr == 0 ) exitWith { player groupChat "delcamp.sqf: --- No camp found at radious 10 meters ---" };

_camp = _arr select 0;
_pos = getPos _camp;
if ( alive _camp ) then
{
	player groupChat "delcamp.sqf: Alive camp is removed"
}
else
{
	player groupChat "delcamp.sqf: Dead camp is removed";
};

deleteVehicle _camp;



