// mando automatic take off script for ArmA 1.05 or above
// mando_takeoff2.sqf v2.5
// Jun 2007 Mandoble
// 
// Purpose: Forces a plane to take off following indicated positions array before starting the final run and then takes it off.
// 
// Arguments:
// plane (not really necessary to be a plane)
// Vertical takeoff? true/false
// Taxi max speed in km/h (> 0 and < 31 Km/h)
// speed in Km/h to reach before raising the nose 
// Final speed in Km/h to reach after climb starts
// Max nose up angle while climbing in degrees (10 ~ 89)
// acceleration factor (use values between 0.05 and 0.2)
// Array of taxi positions (last one is take off one, at least one must exist)
// Take off direction in degrees (Direction the plane will use for final take off run)
// Number of crew members inside the plane before starting take off procedure
// Number of seconds to wait idle after all crew is inside
// Radio comms: true/false
// Ejection SQF script or "" if none, any script receiving a single argument, the plane. 
//
// Examples:
// Flanker waiting for two crew members, then waiting idle foe 3 seconds before moving to mk_su270 pos, 
// then moving to mk_aling position, then to mk_takeoff position and then taking off.
// [su270, false, 30, 170, 350, 10, 0.11, [getMarkerPos "mk_su270",getMarkerPos "mk_align", getMarkerPos "mk_takeoff"], 0, 2, 3, true, ""]execVM"mando_takeoff2.sqf"
//
// Harrier waiting for one pilot, then waiting 0 secs before moving to mk_takeoff position and then taking off.
// [harrier, true, 30, 160, 300, 45, 0.1, [getMarkerPos "mk_takeoff"], 0, 1, 0, false, "myeject.sqf"]execVM"mando_takeof2f.sqf"
// To sync several takeoffs, you may check "mando_takeoff" internal vehicle variable of the taking off planes:
// 1 - Waiting for takeoff clearance
// 2 - Taxiing to takeoff position
// 3 - Aligning for take off run
// 4 - Taking off
// 5 - takeoff end
// 6 - Plane damaged, take off aborted
//
// for example if ((plane_a getVariable "mando_takeoff") > 2) then {allow another plane to start taking off procedure};



private["_plane", "_vertical", "_speed0", "_speed1", "_speed2", "_maxclimb", "_acc", "_wps", "_tdir", "_ncrew", "_wait", "_radio", "_eject", "_delay", "_deltah", "_vh", "_turn", "_dir", "_ang", "_dif", "_difabs", "_posp", "_post", "_climb", "_crew", "_state", "_pilot", "_timeini", "_vdir", "_i", "_vx", "_vy", "_vz", "_speed", "_up", "_ur", "_ux", "_uy", "_uz", "_particle", "_drop"];

_plane    = _this select 0;
_vertical = _this select 1;
_speed0   = _this select 2;
_speed1   = _this select 3;
_speed2   = _this select 4;
_maxclimb = _this select 5;
_acc      = _this select 6;
_wps      = _this select 7;
_tdir     = _this select 8;
_ncrew    = _this select 9;
_wait     = _this select 10;
_radio    = _this select 11;
_eject    = _this select 12;

if (_maxclimb > 89) then
{
   _maxclimb = 89;
};

if (_maxclimb < 10) then
{
   _maxclimb = 10;
};

if (_speed0 > 30) then
{
   _speed0 = 30;
};

if (_speed1 > _speed2) then
{
   _speed2 = _speed1 + 10;
};

_speed0   = _speed0 / 3.6;
_speed1   = _speed1 / 3.6;
_speed2   = _speed2 / 3.6;

_delay    = 0.002;
_deltah   = 120 * 4 * _delay;
_vh       = 0;
_turn     = 0;
_dir      = 0;
_ang      = 0;
_dif      = 0;
_difabs   = 0;
_posp     = [0,0,0];
_post     = [0,0,0];
_climb    = 0;
_crew     = [];
_state    = "WAITCREW";
_log = "logic" createVehicleLocal [0,0,0];


waitUntil {(count crew _plane) == _ncrew};
Sleep 0.5;
waitUntil {!isNull driver _plane};

_pilot = driver _plane;
_plane engineOn true;
_pilot action ["ENGINEON", _plane];
_plane action ["LIGHTON", _plane];

if ((_wait > 0) && (_radio)) then
{
   _pilot sidechat "Waiting for take off allowance"
};

_state    = "WAITTOTAKEOFF";
_plane setVariable ["mando_takeoff", 1];
_timeini = dayTime * 3600;
_vdir = vectorDir _plane;
while {(dayTime*3600) < (_timeini + _wait)} do
{
   _plane setVectorDir _vdir;
   _plane setVelocity [0,0,0];
   Sleep _delay;
};

if (_radio) then
{
   if ((damage _plane < 0.2) && ((vehicle _pilot) == _plane)) then
   {
      [side _pilot,"base"] sidechat format["%1, proceed to take off", name driver _plane];
      _pilot sidechat "Roger, taxiing to take off position";
   };
};

_plane setVariable ["mando_takeoff", 2];
_taxispd = _speed0;
for [{_i=0;},{_i < (count _wps)},{_i = _i+1;}] do
{
   _dir = getDir _plane;
   _post = _wps select _i;
   _log setPos _post;


   while {(   sqrt(((getPos _plane select 0)-(getPos _log select 0))^2 + ((getPos _plane select 1)-(getPos _log select 1))^2)>(4+accTime)) && (damage _plane < 0.2) && (vehicle _pilot == _plane)} do
   {
      if (!isEngineOn _plane) then 
      { 
         _plane engineOn true;
         _pilot action ["ENGINEON", _plane];
      };
      _state    = "TAXIING";
      if (_vh < _taxispd) then
      {
         _vh = _vh + (_acc * accTime) / 2.0;  
      };
      if (_vh > _taxispd) then
      {
         _vh = _vh - (_acc * accTime) / 2.0;  
      };

      _posp = getPos _plane;

      _ang = ((_post select 0)-(_posp select 0)) atan2 ((_post select 1)-(_posp select 1));
      _dif = (_ang - _dir);
      if (_dif < 0) then {_dif = 360 + _dif;};
      if (_dif > 180) then {_dif = _dif - 360;};
      _difabs = abs(_dif);
  
      if (_difabs > 0.01) then
      {
         _turn = _dif/_difabs;
      }
      else
      {
         _turn = 0;
      };

      if (_difabs > 45) then
      {
         _taxispd = _speed0 / 2;
      }
      else
      {
         _taxispd = _speed0;
      };

      _dir = _dir + (_turn * ((_deltah * accTime) min _difabs));
      _vx = (sin _dir)*_vh;
      _vy = (cos _dir)*_vh;
      _vz = -0.01;  
      _plane setVectorDir[_vx/_vh, _vy/_vh, _vz/_vh];
      _plane setVelocity [_vx, _vy, _vz];
      Sleep _delay;
   };
};


_post = [(getPos _plane select 0)+sin(_tdir)*10,(getPos _plane select 1)+cos(_tdir)*10, 0];
_dir = getDir _plane;
_posp = getPos _plane;
_ang = ((_post select 0)-(_posp select 0)) atan2 ((_post select 1)-(_posp select 1));
_dif = (_ang - _dir);
if (_dif < 0) then {_dif = 360 + _dif;};
if (_dif > 180) then {_dif = _dif - 360;};
_difabs = abs(_dif);
_turn = _dif/_difabs;
_vh = 1.0;

_plane setVariable ["mando_takeoff", 3];
while {(_difabs > 0.1)&&(damage _plane < 0.2)&&(vehicle _pilot == _plane)} do
{
   if (!isEngineOn _plane) then 
   { 
      _plane engineOn true;
      _pilot action ["ENGINEON", _plane];
   };

   _state    = "FINALALIGN";
   _dir = _dir + (_turn * ((_deltah * accTime) min _difabs));
   _dif = (_ang - _dir);
   if (_dif < 0) then {_dif = 360 + _dif;};
   if (_dif > 180) then {_dif = _dif - 360;};
   _difabs = abs(_dif);

   _vx = (sin _dir);
   _vy = (cos _dir);
   _vz = 0;  
   _plane setVectorDir[_vx, _vy, _vz];
   _plane setVelocity [_vx, _vy, _vz];
   Sleep _delay;
};


if (_radio) then
{
   if (damage _plane < 0.2) then
   {
      if (vehicle _pilot == _plane) then
      {  
         _pilot sidechat "Starting the take off run";
      };
   }
   else
   {
      if (alive _pilot) then
      {
         _pilot sidechat "We've got too much damage, aborting take off";
      };
   };
};

_plane setVariable ["mando_takeoff", 4];
if (_vertical) then
{
   _state    = "TAKINGOFF";
   _particle = ["\Ca\Data\ParticleEffects\FireAndSmokeAnim\SmokeAnim.p3d", 8, 3, 1];
   _drop = "#particlesource" createVehicle [0,0,0];
   _drop setParticleCircle [5, [0,10,0]];
   _drop setParticleParams [_particle,"","Billboard",100,3,[0,0,0],[0,0,0],2,25.50,20,1,[10,15,20],[[0.5,0.5,0.5,0],[0.5,0.5,0.4,0.5],   [0.5,0.4,0.4,0.3],[0.5,0.4,0.4,0]],[1,1],0,0,"","", ""];
   _drop setDropInterval 0.05;

   _up = vectorUp _plane;
   _vz = 0;
   while {((getPos _plane select 2) < 50) && (damage _plane < 0.2) && (vehicle _pilot == _plane)} do
   {
      if (!isEngineOn _plane) then 
      { 
         _plane engineOn true;
         _pilot action ["ENGINEON", _plane];
      };

      if (_vz < _speed0) then
      {
         _vz = _vz + (_acc * accTime) / 4.0;  
      };
      _vx = (sin _dir);
      _vy = (cos _dir);
      _plane setVectorDir[_vx, _vy,0];
      _plane setVectorUp _up;
      _plane setVelocity [0,0,_vz];
      _drop setPos [getPos _plane select 0, getPos _plane select 1, 0];
      Sleep 0.001;
   };
   while {(_vz > 0) && (damage _plane < 0.2) && (vehicle _pilot == _plane)} do
   {
      if (!isEngineOn _plane) then 
      { 
         _plane engineOn true;
         _pilot action ["ENGINEON", _plane];
      };

      if (_vz > 0) then
      {
         _vz = _vz - (_acc * accTime) * 2.0;  
      };
      _vx = (sin _dir);
      _vy = (cos _dir);
      _plane setVectorDir[_vx, _vy,0];
      _plane setVectorUp _up;
      _plane setVelocity [0,0,_vz];
      _drop setPos [getPos _plane select 0, getPos _plane select 1, 0];
      Sleep 0.001;
   };
   deleteVehicle _drop;
};

_dir = _tdir;
_climb = -1;
_speed = 0;
_up = vectorUp _plane;
while {(_speed < _speed1) && (damage _plane < 0.2) && (vehicle _pilot == _plane)} do
{
   if (!isEngineOn _plane) then 
   { 
      _plane engineOn true;
      _pilot action ["ENGINEON", _plane];
   };

   _state    = "TAKINGOFF";
   _speed = _speed + (_acc * accTime);
   _vz = (sin _climb)*_speed;
   _vh = (cos _climb)*_speed;
   _vx = (sin _dir)*_vh;
   _vy = (cos _dir)*_vh;

   _plane setVectorDir[_vx/_speed, _vy/_speed, _vz/_speed];
   _plane setVectorUp _up;
   _plane setVelocity [_vx, _vy, _vz];

   Sleep 0.001;
};


_climb = 0;
while {(_speed < _speed2) && (damage _plane < 0.2) && (vehicle _pilot == _plane)} do
{
   if (!isEngineOn _plane) then 
   { 
      _plane engineOn true;
      _pilot action ["ENGINEON", _plane];
   };

   _state    = "TAKINGOFF";
   _speed = _speed + (_acc * accTime);
   if (_climb < _maxclimb) then
   {
      _climb = _climb + 0.2*accTime;
   };
   _vz = (sin _climb)*_speed;
   _vh = (cos _climb)*_speed;
   _vx = (sin _dir)*_vh;
   _vy = (cos _dir)*_vh;

   _plane setVectorDir[_vx/_speed, _vy/_speed, _vz/_speed];
   _uz = sin(_climb+90);
   _ur = cos(_climb+90);
   _ux = sin(_dir)*_ur;
   _uy = cos(_dir)*_ur;
   _plane setVectorUp[_ux, _uy, _uz];
   _plane setVelocity [_vx, _vy, _vz];

   Sleep 0.001;
};

if (_radio) then
{
   if ((damage _plane < 0.2) && (vehicle _pilot == _plane)) then
   {
      _pilot sidechat "Take off finished";
   }
   else
   {
      if ((_state == "TAKINGOFF") && (damage _plane > 0.2)) then
      {
         if (_eject != "") then
         {
            [_plane]execVM _eject;
         };
      };
   };
};
if (damage _plane < 0.5) then
{
   _plane setVariable ["mando_takeoff", 5];
}
else
{
   _plane setVariable ["mando_takeoff", 6];
};

deleteVehicle _log;