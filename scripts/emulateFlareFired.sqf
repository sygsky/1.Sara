//
// ACE flare script modified to use on server by Sygsky
//
// call as: [_pos, _height, _flare_color (may be "Red","Green","Yellow","White"), _dist_to_observer] spawn "emulateFlareFired.sqf"
//
private ["_col","_fx_flare","_fx_smoke","_factor","_pos","_flare","_pos","_flare_type","_die_away_height"];

#define __POS    (_this select 0)
#define __HEIGHT ((_this select 1)-5+(random 10))
#define __COL    (_this select 2)
#define __DIST   ((_this select 3)/1600)

#define __DEBUG__

//#define __R [[1,0,0,1],[1,0,0,0.8],[1,0,0,1],[1,0,0,0.9]]
#define __R [[1,0,0,0.7],[1,0,0,0.5],[1,0,0,0.7],[1,0,0,0.6]]
#define __G [[0,1,0,1],[0,1,0,0.8],[0,1,0,1],[0,1,0,0.9]]
//#define __W [[1,1,1,1],[1,1,1,1.8],[1,1,1,1],[1,1,1,1.9]]
#define __W [[1,1,1,0.7],[1,1,1,0.5],[1,1,1,0.7],[1,1,1,0.9]]
#define __Y [[1,1,0,1],[1,1,0,0.8],[1,1,0,1],[1,1,0,0.9]]
#define __VEL velocity _flare
#define __I .025

//#define __DIST ( (player distance _flare) / 400 )

#define __FX_FLARE _fx_flare setParticleParams [["\Ca\Data\sunHalo.p3d", 1, 0, 0],"", "Billboard", \
10, 0.5, [0,0,0.1], \
__VEL, \
1, 1.275, 1, 0, \
[_factor,(_factor/2),(_factor/4)], \
_col, \
[0.08], 1, 0, "", "", _flare]

#define __FX_SMOKE _fx_smoke setParticleParams [["\Ca\data\ParticleEffects\ROCKETSMOKE\RocketSmoke", 1, 0, 0],"", "Billboard", \
10, 0.5, [0,0,0.1], \
[0,0,8], \
1, 1.275, 1, 0, \
[(_factor/4),(_factor/8),(_factor/16)], \
__W, \
[0.08], 1, 0, "", "", _flare]

_col = __COL;
_flare_type = "F_40mm_White";
switch (toUpper(_col)) do
{
	case "WHITE":  { _col = __W; _flare_type = "F_40mm_White";  };
	case "RED":    { _col = __R; _flare_type = "F_40mm_Red";    };
	case "GREEN":  { _col = __G; _flare_type = "F_40mm_Green";  };
	case "YELLOW": { _col = __Y; _flare_type = "F_40mm_Yellow"; };
};

_pos = __POS;
if ( typeName _pos == "OBJECT" ) then {_pos = getPos _pos;};
_pos set [ 2, __HEIGHT ];

_factor = __DIST max 12.5; // if (_factor > 12.5) then { _factor = 12.5; };

hint localize format[ "emulateFlareFired.sqf: pos %1 col %2 fact %3 ftype %4", _pos, __COL, _factor, _flare_type ];

//play sound of starting
//_soundSource = createSoundSource [ "\ace_sys_flares\snd\flare.wss", _pos, [], 0];

_flare = objNull;
_flare = _flare_type createVehicle _pos;
if ( isNull _flare ) then { hint localize "emulateFlareFired.sqf: flare object not created" };

sleep 1.0;
//while { alive _flare && (__VEL select 2 > 0) } do { sleep 1; };

//hint localize format[ "emulateFlareFired.sqf: flare vel %1", __VEL ];

// Flare
_fx_flare = "#particleSource" createVehicleLocal (getPos _flare);
_fx_flare setParticleRandom [0.5,[0.1,0.1,0.1],[0,0,0],0,0.1,[0.1,0.1,0.1,0.05],0,0];
_fx_flare setDropInterval __I;

// Smoke
_fx_smoke = "#particleSource" createVehicleLocal (getPos _flare);
_fx_smoke setParticleRandom [0.5,[0.1,0.1,0.1],[0,0,0],0,0.1,[0.1,0.1,0.1,0.05],0,0];
_fx_smoke setDropInterval __I;

_die_away_height = 15 + random 15;
	
	__FX_FLARE;
	__FX_SMOKE;
	
while { alive _flare && ((getPos _flare) select 2 > _die_away_height) } do { sleep 0.5; };

//if ( !isNull _flare ) then {hint localize format["emulateFlareFired.sqf: flare drop speed %1. Fog %2, fogForecast %3, weather change %4", velocity _flare, fog, fogForecast,nextWeatherChange]; 
if ( !isNull _flare ) then { /* hint localize format["emulateFlareFired.sqf: flare drop speed %1", velocity _flare];*/ deleteVehicle _flare;};
	