// Remastered jail from Evolution

#define JAIL_START_PERIOD 30
scopeName "main";

//===================================== FIND AND PREPARE PLAYER =========================
if ( !alive player ) then
{
    waitUntil 
    {
        sleep 0.05;
        if  (isNull player) then  {  breakOut "main"; };
        alive player
    };
};

#include "x_macros.sqf"

//============================================ INIT JAIL PLACES ===========================
if (isNil "jail_places") then
{
    jail_buildings = [[10270.2,7384.86,8.01088],[8274.52,9045.37,7.85906],[7610.99,6363.07,7.86087]];
/*
    {
        _arr =  nearestObjects [getPos _x,["Land_Hotel"], 50];
        _hotel = objNull;
        if ( count _arr > 0 ) then { _hotel = _arr select 0 };
        if (!isNull _hotel) then
        {
            jail_buildings set [count jail_buildings, _hotel modelToWorld [0,0,0]];
        };
        hint localize format["_arr %1",_arr];
    } forEach [jail,jail_1,jail_2];

    hint localize format["+++ jail_buildings = %1; +++", jail_buildings];
*/
    // jail rooms
    jail_places = [
        [[-5.26367,-6.39551,-7.74754],0,[10270.2,7384.86,8.01088]], // behind the logotype of the 1st hotel
        [[-2.8457,2.97168,-7.73003],-270,[10270.2,7384.86,8.01088]] // in lift cabine
    ];
};

// ============================= FIND HOTEL ===========================

// select one of existing hotels
_hotel = objNull;
_hotelP = [];
for "_i" from 0 to count jail_buildings -1 do {
    _id = jail_buildings call  XfRandomFloorArray;
    _hotelP = jail_buildings select _id;
    _hotel = _hotelP nearestObject "Land_Hotel";
    if (  !isNull _hotel) exitWith {};
    jail_buildings set [_id, "RM_ME"];
};

jail_buildings = jail_buildings - ["RM_ME"];

if (isNull _hotel) exitWith {
    hint localize format["--- jail.sqf: No jail building (%2) found for %1", name player, jail_buildings];
};

//hint localize format[ "jail: %1", _jailArr ];
_jailArr = jail_places call XfRandomArrayVal;
_jailArr set [2, _hotelP]; // set hotel position

hint localize format[ "jail: hotel %1", _hotel ];

//=================================== START JAIL PROCEDURE =====================
disableUserInput true;
player setDamage 0;
player setVelocity [0,0,0];
player playMove "AmovPercMstpSnonWnonDnon";

_wpn = weapons player;
_mags = magazines player;
removeAllWeapons player; // TODO: remove ACE backpack too

_orig_pos = getPos player;
_new_pos = [_hotel, _jailArr select 0 ] call SYG_modelObjectToWorld;
_cam = "camera" camCreate getPos player;
showCinemaBorder true;
player switchCamera "INTERNAL";
_can camPreload 0;
waitUntil {camPreloaded _cam};

//preloadCamera _new_pos;// prepare environment for player first glance

_pos = [_hotel, player, _jailArr] call SYG_setObjectInHousePos; // player position in the jail
_weaponHolderPos = player modelToWorld [0, 2.5, 0.2];

player globalChat format["holder %1", _weaponHolderPos];

_weaponHolder = "WeaponHolder" createVehicleLocal [0,0,0];
_weaponHolder setPos _weaponHolderPos;// [_weaponHolderPos, [], 0, "CAN_COLLIDE"];
{
    _weaponHolder addWeaponCargo [_x,1];
}forEach _wpn;
_weaponHolder addWeaponCargo ["Phone",1];

{
    _weaponHolder addMagazineCargo [_x,1];
}forEach _mags;
sleep 0.05;
_cam camSetTarget _weaponHolder;
_cam camCommit 0;

_str = format["jail.sqf: pos %1, hld %2, model %3", getPos player, getPos _weaponHolder, player worldToModel (getPos _weaponHolder)];
player groupChat _str;
hint localize _str;

//if (bancount > 2) exitWith {hint "press Alt + F4 to exit"};

_score = -((score player)-JAIL_START_PERIOD);

_msg_arr = [
   localize "STR_JAIL_1",//"Hint: You have been punished for having a negitive score",
   format[localize "STR_JAIL_2",_score], //format["You will regain control after you have served your sentence of %1 seconds",
   localize "STR_JAIL_3"//"Or you can press  Alt + F4 to exit"
];

player say "Recall";
_sound = nearestObject [player, "#soundonvehicle"];
if (isNull _sound) then {player groupChat "--- No Sound detected!"};

for "_i" from 1 to _score do
{
    if ( (_i mod 10) == 0 ) then
    {
        _id = (floor(_i / 10)) mod (count _msg_arr);
        //player groupChat format["Prepare sound with _i = %1",_i];
        cutText [_msg_arr select _id, "PLAIN"];
    };

    titleText [format ["%1",_i - _score],"PLAIN DOWN"];

	{
	    sleep 0.5;
        if (isNull _sound) then
        {
            player say "Recall";
            _sound = (getPos player) nearestObject "#soundonvehicle";
        };
	} forEach [1,2];
};
titleText ["", "PLAIN DOWN"];
cutText ["", "PLAIN"];

player setDamage 1;

if (!isNull _sound) then  {deleteVehicle _sound;};
showCinemaBorder false;
camDestroy _cam;

player setPos _orig_pos;

disableUserInput false;
deleteVehicle _weaponHolder;
