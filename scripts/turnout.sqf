// by Sygsky, scripts\turnout.sqf to check turnout event with "GetOut" event procedure
//
//  Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//    target (_this select 0): Object - the object which the action is assigned to
//    caller (_this select 1): Object - the unit that activated the action
//    ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//    arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
//

_veh = nearestObjects [player, ["Car","Tank"], 150];

if (count _veh == 0) exitWith {player groupChat "No any car near <= 50 m"};
_veh = _veh select 0;

//if ( side _veh != side player) exitWith { player groupChat (format["Found %1 on %2 side, need %3", typeOf _veh, side _veh, side player])};

_veh setVectorUp [0.5,0.5,0.7];
sleep 0.02;
_veh setVectorUp [0.3,0.3,0.3];
sleep 0.02;
_veh setVectorUp [0.7,0.7,0.0];
sleep 0.02;
_veh setVectorUp [0.3,0.3,-0.3];
sleep 0.02;
_veh setVectorUp [0,0,-1];