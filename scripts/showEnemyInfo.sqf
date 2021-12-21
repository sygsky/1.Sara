/*
	author: Sygsky
	description: none
	returns: nothing
*/

private ["_str","_enemyW", "_enemyE"];
//
//
// _enemy = _unit call _nearEnemy;
//
/*
Syntax:
unit nearTargets range
Parameters:
unit: Object
range: Number
Return Value: Array - nested; consisting of:
    0: Position (perceived, includes judgment and memory errors),
    1: Type (perceived, gives only what was recognized),
    2: Side (perceived side),
    3: Subjective Cost (positive for enemies, more positive for more important or more dangerous enemies),
    4: Object (object type, can be used to get more information if needed)
*/
_nearEnemy = {
    _enemy = objNull;
    _ecost = -10000;
    _side = side _this;
    _arr =  _this nearTargets 5000;
    {
        if ( isNull _enemy) then
        {
            _enemy = _x select 4;
            _ecost = _x select 3;
        }
        else
        {
            _type = _x select 1;
            _side1 = _x select 2;
            _cost = _x select 3;
            _enemy1 = _x select 4;
            if ( _side1 != _side && _cost > _ecost && ({alive _x } count (crew _enemy1) > 0)) then
            {
                _enemy = _enemy1;
                _ecost = _cost;
            };
        };
    }forEach _arr;
    _enemy
};

_enemy = objNull;
_grp1 = group o4;
player groupChat format["+++ START scripts/showEnemyInfo.sqf, grp %1 (%2), heli %3 +++", _grp1, count units _grp1, typeOf h1];

{deleteVehicle _x} forEach crew h1;
sleep 0.2;
deleteVehicle h1;
_grp = createGroup west;

h1 = createVehicle ["ACE_AH64_AGM_HE", [1500,13000,1000], [], 100, "FLY"];

[h1, _grp, "ACE_SoldierWPilot_WDL", 1] call SYG_populateVehicle;
h1 flyInHeight 1000;

_pos = getPos h1;
//h1 setPos [_pos select 0, _pos select 1, 1000];

if ( alive h1 ) then {

    _loc = createLocation ["ViewPoint",[0,0,0],10,10];
    _location setText "AH64";
    _loc attachObject h1;
    _str = format["Loc: ""%1"", pos %2, attached %3", _loc, locationPosition _loc, attachedObject _loc];
    hint localize _str;
    player groupChat _str;
    _grp = (group (driver h1));
    //_grp move (getPos player);
    //_grp setBehaviour "CARELESS";
    _grp setBehaviour "AWARE";
    _grp setCombatMode "RED";
    _wp = _grp addWayPoint [getPos player, 0];
    _wp setWaypointType "SAD";
    [_grp, 1] setWaypointStatements ["never", ""];
};

while {(alive h1) && (({alive _x}count crew h1) > 0)} do {
    _enemy = h1 findNearestEnemy (getPos h1);
    _str = "";
    if ( !isNull _enemy ) then
    {
        _dist1 = floor(_enemy distance h1);
        _dist2 = floor([_enemy, player] call SYG_distance2D);
        _knowsW = h1 knowsAbout _enemy;
        _str = format["H: %1, [ %2], %3 m; ", typeOf (vehicle _enemy), _knowsW, round(_dist1)];
    };
    _vec = objNull;
    {if (alive _x)exitWith {_vec = _x;};} forEach units _grp1;
    if (!isNull _vec) then
    {
        _enemy =  _vec findNearestEnemy (getPos _vec);
        if ( !isNull _enemy ) then
        {
            _dist1 = _enemy distance _vec;
            _dist2 = [_enemy, _vec] call SYG_distance2D;
            _knows = _grp knowsAbout _enemy;
            _str =  _str + format["S(%5): %1 [%2]; %3/%4 m", typeOf _enemy, _knows,   round(_dist1), round(_dist2), typeOf vehicle _vec];
        };
    };

    if ( _str != "") then { player groupChat _str; hint localize _str;}
    else
    {
        _enemy = h1 call _nearEnemy;
        if ( isNull _enemy) then
        {
            player groupChat format["Heli dist %1 m, height %2 m", floor(player distance h1), floor(getPos h1 select 2)]
        }
        else
        {
            player groupChat format["Heli enemy: %1, knows: %2", typeOf vehicle  _enemy, h1 knowsAbout m_enemy];
        };
    };
    sleep 1;
    /*
    if ( time > _time2watch) then
    {
        h1 doWatch o4;
    };
    if ( time > _timeStopWatch ) then
    {
        h1 doWatch objNull;
        _watch = "no watch";
        _timeStopWatch = time + 20;
        _timeStartWatch = time + 10;
    }
    else {
        if ( time > _timeStartWatch ) then
        {
            _watch = "watch";
            h1 doWatch o4;
        };
    };
    */
};
player groupChat "--- Heli is dead!";
