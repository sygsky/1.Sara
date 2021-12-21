private [ "_unit", "_dist", "_objlist", "_mlist", "_wlist","_bomb" ];

#define ROUND2(val) (round((val)*100.0)/100.0)
#define ROUND4(val) (round((val)*10000.0)/10000.0)
#define ROUND0(val) (round(val))
#define arg(num) (_this select(num))
#define argp(arr,num) ((arr)select(num))
#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})
#define inc(x) x=x+1

_unit = _this select 0;
_this = _this select 3;

_dist   = argopt(0,50);
_height = argopt(1,100);
//_height = 200;
_color = argopt(2,"Red"); // "F_40mm_Red", "ACE_Flare_40mm_White", "ACE_Flare_40mm_Red", "ACE_Flare_Arty_White"

_vdir = vectorDir _unit;
_pos  = getPos _unit;
_dx      = (_vdir select 0) * _dist;
_dy      = (_vdir select 1) * _dist;
_x =  (_pos select 0) + _dx;
_y =  (_pos select 1) + _dy;
_dist2flare = [_x,_y, 0] distance _pos;

//player globalChat format[ "launchflare.sqf: dist %1, height %2, pos %3, vdir [%5,%6], type %7, dx %8, dy %9, dist %10", ROUND2(_dist), ROUND2(_height), _pos,_pos, ROUND2(_vdir select 0), ROUND2(_vdir select 1),_color, ROUND0(_dx), ROUND0(_dy),ROUND0(_dist2flare)];
//hint localize format[ "launchflare.sqf: dist %1, height %2, pos %3, vdir [%5,%6], type %7, dx %8, dy %9, dist %10", ROUND2(_dist), ROUND2(_height), _pos,_pos, ROUND2(_vdir select 0), ROUND2(_vdir select 1),_color, ROUND0(_dx), ROUND0(_dy),ROUND0(_dist2flare)];

_pos set [2, _height];
[ [_x, _y, 0], _height, "Red", 100 ] execVM "scripts\emulateFlareFired.sqf"; // "flareAid.sqs","ace_sys_flares\s\Fired.sqf"

/*
_flare = objNull;
_flare = _color createVehicle [_x, _y, _height];

if (isNull _flare) then {player globalChat "launchflare.sqf: flare object is <null>"};


sleep (_height/10)  + random 30;
if (!isNull _flare) then {deleteVehicle _flare};
 */
if ( true ) exitWith {_cnt};