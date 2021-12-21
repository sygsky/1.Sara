// *****************************************************
// Script:  destroy_oil_pump.sqf
// Author:  johnnyboy
// Version: 0.2
// Arma version: 1.05
// Sample call:   dummy = [pump, true] execvm "destroy_oil_pump.sqf"
//
// Input parameter pump:    Pump object to destroy.
// Input Parameter boolean: If true, metal crashing sound FX played.
//
// If you want the "creaking/falling metal" sound effects, be sure to copy
// the sound file "metal_falling2.ogg" to your mission's sound directory, and
// add a sound entry to your mission Description file (copy the entry from the
// sample mission Description file).
//
// NOTE:  I believe this will only work on Oil Pumps placed via the
//        Editor.
//
// Script simulates pump destruction by placing a fuel station and a
// fuel truck beneath the pump, and exploding them.  Pump is then 
// sunk 4 meters, and leaned over using setVectorUp command.
//
_pump      = _this select 0;
_soundFXon = _this select 1;

//*** Create a fuel truck, blow it up before we setpos it to the oil pump,
//*** so we only have the one explosion from the fuel station blowing up.
;_fuel = "Truck5tRefuel" createVehicle [0,0,0];
_fuel = "Land_fuel_tank_big" createVehicle [0,0,0];
_fuel setdammage 1; 
sleep .2;

// Create a fuel station, place it under the pump, and blow it up.
// Initial big wad of fuel station smoke is enough to hide the immediate
// leaning of the oil pump.
_fuelStation = "Land_fuelStation_army" createVehicle [0,0,0];
sleep .2;
_fuelstation setpos (_pump modelToWorld [0,-2,-8.5]); 
_fuelstation setdammage 1; 

// Play the sound effect of metal rending.
if (_soundFXon) then {_pump say "metal_falling2";};

//*****************************************************
//*** Sink the pump using a loop so its sinks gracefully.
//*** Once sunk, it is low enough to hide the abrupt tilt
//*** within the smoke.

sleep .5;

_pos = getpos _pump;
_z = 0;
for "_x" from 1 to 10 do
{
  sleep .05;
  _z = _z -.25;
  _pump setpos [_pos select 0, _pos select 1, _z];
};
// Change angle of oil pump (tilt it over).
_pump setVectorUp [.7, .5, .8];

// Move burrning fuel tank under the pump.  We do it after adjusting setVectorUp and rePosing
// the pump to insure fire is UNDER the rig.
_fuel setpos [_pos select 0, (_pos select 1)-2, -4]; 
//*** Fuelstation stops producing smoke after about 40 seconds, but I'm
//*** deleting it sooner, as I prefer the smaller fire of the fuel truck so you can see the
//*** oil pump within the fire and smoke.
sleep 5;
deleteVehicle _fuelstation;
