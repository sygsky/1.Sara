// mando automatic land script for ArmA 1.05 or above
// mando_land.sqf v1.3
// Jun 2007 Mandoble
// 
// Purpose: Forces a plane to land. If the player is the pilot, ISL marks are added to the HUD to help him aproach the first two landing
//          positions before switching on the automatic landing procedure.
// 
// Arguments:
// plane (not really necessary to be a plane)
// Vertical land? true/false
// Array of land and taxi positions (first is landing position, touch down for non vertical landing, and final brake for vertical one)
// Final aproach speed in Km/h
// Taxi max speed in km/h (> 0 and < 31 Km/h)
// Landing direction in degrees (from where the plane will aproach the first landing position)
// Radio comms: true/false
//
// Examples:
//
// [su270, false, [getMarkerPos "mk_land", getMarkerPos "mk_takeoff", getMarkerPos "mk_align", getMarkerPos "mk_su270"], 170, 30, 180, true]execVm"mando_land.sqf"
//
// [harrier, true, [getMarkerPos "mk_land", getMarkerPos "mk_takeoff", getMarkerPos "mk_align"], 170, 30, 180, true]execVm"mando_land.sqf"
//
// vehicle variable "mando_land" informs about current landing status, you may use it to sync multiple landings:
//   1 = moving to first landing sequence point
//   2 = moving to second landing secuence point
//   3 = final aproach
//   4 = touch down
//   5 = taxiing
//   6 = end of landing procedure
//   7 = Plane damaged, landing procedure aborted
//
// for example:
//   if ((planeA getVariable "mando_land") > 2) then {order plane B to proceed with landing sequence};
//


private["_plane", "_vertical", "_wps", "_landspd", "_taxispd", "_landdir", "_radio", "_drop", "_particle", "_pilot", "_initdmg", "_distance", "_distanceold", "_accelfact", "_speed0", "_vx", "_vy", "_vz", "_up", "_emergency", "_log", "_ground", "_pos", "_extra", "_color", "_colorvu", "_colorvd", "_colorhl","_colorhr", "_ang"];

_plane    = _this select 0;
_vertical = _this select 1;
_wps      = _this select 2;
_landspd  = _this select 3;
_taxispd  = _this select 4;
_landdir  = _this select 5;
_radio    = _this select 6;

Sleep 2;

_land = _wps select 0;
_landspd = _landspd / 3.6;
_taxispd = _taxispd / 3.6;
if (_vertical) then
{
   _accelfact = 0.4;
}
else
{
   _accelfact = 0.18;
};
_log = "logic" createVehicleLocal [0,0,0];
_target = "logic" createVehicleLocal [0,0,0];
_ground = "logic" createVehicleLocal [0,0,0];

_pilot = driver _plane;
group _pilot lockWP true;
group _pilot setBehaviour "CARELESS";

if (_radio) then
{
   if ((damage _plane < 0.5) && ((vehicle _pilot) == _plane)) then
   {
      [side _pilot,"base"] sidechat format["%1, you are cleared to land", name driver _plane];
      _pilot sidechat "Roger, proceeding to landing sequence";
   };
};


_log setPos [_land select 0, _land select 1, 0];
_extra = (getPosASL _log select 2);

_aligns = [];
if (!_vertical) then
{
   _pos = [(_land select 0)+sin(_landdir-180)*4000, (_land select 1)+cos(_landdir-180)*4000, 150 + _extra];
   _log setPos _pos;
   _aligns = _aligns + [getPosASL _log];


   _pos = [(_land select 0)+sin(_landdir-180)*2000, (_land select 1)+cos(_landdir-180)*2000, 150 + _extra];
   _log setPos _pos;
   _aligns = _aligns + [getPosASL _log];


   _pos = [(_land select 0)+sin(_landdir-180)*1000, (_land select 1)+cos(_landdir-180)*1000, 100 + _extra];
   _log setPos _pos;
   _aligns = _aligns + [getPosASL _log];


   _pos = [(_land select 0)+sin(_landdir-180)*500, (_land select 1)+cos(_landdir-180)*500, 50 + _extra];
   _log setPos _pos;
   _aligns = _aligns + [getPosASL _log];
}
else
{
   _landdir = ((_land select 0)-(getPos _plane select 0)) atan2 ((_land select 1)-(getPos _plane select 1));
   _pos = [(_land select 0)+sin(_landdir-180)*3000, (_land select 1)+cos(_landdir-180)*3000, 150 + _extra];
   _log setPos _pos;
   _aligns = _aligns + [getPosASL _log];


   _pos = [(_land select 0)+sin(_landdir-180)*1500, (_land select 1)+cos(_landdir-180)*1500, 150 + _extra];
   _log setPos _pos;
   _aligns = _aligns + + [getPosASL _log];


   _pos = [(_land select 0)+sin(_landdir-180)*1000, (_land select 1)+cos(_landdir-180)*1000, 200 + _extra];
   _log setPos _pos;
   _aligns = _aligns + [getPosASL _log];


   _pos = [(_land select 0)+sin(_landdir-180)*800, (_land select 1)+cos(_landdir-180)*800, 150 + _extra];
   _log setPos _pos;
   _aligns = _aligns + [getPosASL _log];
};


if (!_vertical) then
{
   _log setPos [_land select 0, _land select 1, 0];
}
else
{
   _log setPos [_land select 0, _land select 1, 20];
};

_aligns = _aligns + [[(_land select 0), (_land select 1), (getPosASL _log select 2)]];


Sleep 1;
group _pilot setSpeedMode "LIMITED";
_align1 = (_aligns select 0);
_align2 = (_aligns select 1);
group _pilot move _align1;
Sleep 3;

_plane setVariable ["mando_land", 1];
_timeini = dayTime * 3600;
_target setPosASL _align1;
while {((_plane distance _align1)>500) &&
 (damage _plane < 0.5) && (vehicle _pilot == _plane) && ((dayTime*3600) < (_timeini + 180))} do
{
   if (_pilot == player) then
   {
      _posu = getPosASL _plane;
      _vdir = vectorDir _plane;
      _post = getPosASL _target;

      _dir = (_vdir select 0) atan2 (_vdir select 1);
      _ang = ((_post select 0)-(_posu select 0)) atan2 ((_post select 1)-(_posu select 1));

      _log setDir (_ang - _dir);
      _difh = getDir _log;
      if (_difh > 180) then {_difh = _difh - 360;};

      _altuasl = _posu select 2;
      _alttasl = _post select 2;
      _distance  = _plane distance _target;

      _angu = asin(_vdir select 2);
      _angv = asin((_alttasl - _altuasl)/_distance);
      _difv = _angv - _angu;

      hint format["First landing position\n(Get H:0 degs, V:0 degs)\nH:%1 degs, V:%2 degs\nDist:%3 m", floor _difh, floor _difv, _distance];
      hint localize format["+++ First landing position\n(Get H:0 degs, V:0 degs)\nH:%1 degs, V:%2 degs\nDist:%3 m", floor _difh, floor _difv, _distance];

      if ((abs(_difh) < 5) && (abs(_difv) < 5)) then
      {
         _rad = (100 min _distance);
         _pz = (_posu select 2)+sin(_angu + _difv)*_rad;
         _radh = cos(_angu + _difv)*_rad;
 
         _px = (_posu select 0)+sin(_dir + _difh)*_radh;
         _py = (_posu select 1)+cos(_dir + _difh)*_radh;

         _posASL = [_px,_py,_pz];
         _log setPosASL _posASL;
         _log setDir _ang;
         
         _color = [[0,1,0,1]];
         _colorhl = [[0,1,0,1]];
         _colorhr = [[0,1,0,1]];
         if (_difh < -2) then
         {
            _colorhl = [[1,1,0,1]];
            _colorhr = [[1,0,0,1]]; 
         };
         if (_difh > 2) then
         {
            _colorhl = [[1,0,0,1]];
            _colorhr = [[1,1,0,1]];
         };

         _colorvu = [[0,1,0,1]];
         _colorvd = [[0,1,0,1]];
         if (_difv < -2) then
         {
            _colorvu = [[1,0,0,1]];
            _colorvd = [[1,1,0,1]]; 
         };
         if (_difv > 2) then
         {
            _colorvu = [[1,1,0,1]];
            _colorvd = [[1,0,0,1]];
         };

         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[0,0,0],[0,0,0],0,1.27,1.0,0.05,[2],_color,[0],0,0,"","",_log]; 
         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[-2,0,0],[0,0,0],0,1.27,1.0,0.05,[2],_colorhl,[0],0,0,"","",_log]; 
         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[2,0,0],[0,0,0],0,1.27,1.0,0.05,[2],_colorhr,[0],0,0,"","",_log]; 
         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[0,0,2],[0,0,0],0,1.27,1.0,0.05,[2],_colorvu,[0],0,0,"","",_log]; 
         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[0,0,-2],[0,0,0],0,1.27,1.0,0.05,[2],_colorvd,[0],0,0,"","",_log]; 
      };

      _plane action ["CANCELLAND", _plane];
      Sleep 0.02;
   }
   else
   {
      _plane action ["CANCELLAND", _plane];
      Sleep 1;
   };
};


if ((damage _plane < 0.5) && (vehicle _pilot == _plane)) then
{
   group _pilot setSpeedMode "LIMITED";
   group _pilot move _align2;
   if (_radio) then
   {
      _pilot sidechat "First landing sequence position reached, proceeding with second one";
      hint localize "--- First landing sequence position reached, proceeding with second one";
   };

   if (_pilot == player) then
   {
      hint "First landing position reached";
      hint localize "--- First landing position reached";

   };
};

_plane setVariable ["mando_land", 2];
Sleep 3;
_timeini = dayTime * 3600;
_target setPosASL _align2;
while {((_plane distance _align2)>350) &&
 (damage _plane < 0.5) && (vehicle _pilot == _plane) && ((dayTime*3600) < (_timeini + 180))} do
{
   if (_pilot == player) then
   {
      _posu = getPosASL _plane;
      _vdir = vectorDir _plane;
      _post = getPosASL _target;

      _dir = (_vdir select 0) atan2 (_vdir select 1);
      _ang = ((_post select 0)-(_posu select 0)) atan2 ((_post select 1)-(_posu select 1));

      _log setDir (_ang - _dir);
      _difh = getDir _log;
      if (_difh > 180) then {_difh = _difh - 360;};

      _altuasl = _posu select 2;
      _alttasl = _post select 2;
      _distance  = _plane distance _target;

      _angu = asin(_vdir select 2);
      _angv = asin((_alttasl - _altuasl)/_distance);
      _difv = _angv - _angu;

      _speedmsg = "";
      _color = [[0,1,0,1]];
      if ((speed _plane) > 400) then
      {
         _speedmsg = ">> Keep speed below 400 Kmh <<";
         _color = [[1,0,0,1]];
      };
      hint format["Second landing position\n(Get H:0 degs, V:0 degs)\nH:%1 degs, V:%2 degs\nDist:%3 m\n%4", floor _difh, floor _difv, _distance, _speedmsg];

      if ((abs(_difh) < 5) && (abs(_difv) < 5)) then
      {
         _rad = (100 min _distance);
         _pz = (_posu select 2)+sin(_angu + _difv)*_rad;
         _radh = cos(_angu + _difv)*_rad;
 
         _px = (_posu select 0)+sin(_dir + _difh)*_radh;
         _py = (_posu select 1)+cos(_dir + _difh)*_radh;

         _posASL = [_px,_py,_pz];
         _log setPosASL _posASL;
         _log setDir _ang;
         
         _colorhl = [[0,1,0,1]];
         _colorhr = [[0,1,0,1]];
         if (_difh < -2) then
         {
            _colorhl = [[1,1,0,1]];
            _colorhr = [[1,0,0,1]]; 
         };
         if (_difh > 2) then
         {
            _colorhl = [[1,0,0,1]];
            _colorhr = [[1,1,0,1]];
         };

         _colorvu = [[0,1,0,1]];
         _colorvd = [[0,1,0,1]];
         if (_difv < -2) then
         {
            _colorvu = [[1,0,0,1]];
            _colorvd = [[1,1,0,1]]; 
         };
         if (_difv > 2) then
         {
            _colorvu = [[1,1,0,1]];
            _colorvd = [[1,0,0,1]];
         };

         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[0,0,0],[0,0,0],0,1.27,1.0,0.05,[2],_color,[0],0,0,"","",_log]; 
         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[-2,0,0],[0,0,0],0,1.27,1.0,0.05,[2],_colorhl,[0],0,0,"","",_log]; 
         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[2,0,0],[0,0,0],0,1.27,1.0,0.05,[2],_colorhr,[0],0,0,"","",_log]; 
         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[0,0,2],[0,0,0],0,1.27,1.0,0.05,[2],_colorvu,[0],0,0,"","",_log]; 
         drop ["\ca\data\koulesvetlo","","Billboard",100,0.05,[0,0,-2],[0,0,0],0,1.27,1.0,0.05,[2],_colorvd,[0],0,0,"","",_log]; 
      };

      _plane action ["CANCELLAND", _plane];
      Sleep 0.02;
   }
   else
   {
      _plane action ["CANCELLAND", _plane];
      Sleep 1;
   };
};


if ((damage _plane < 0.5) && (vehicle _pilot == _plane)) then
{
   if (_radio) then
   {
      _pilot sidechat "Second landing sequence position reached, proceeding with final aproach";
      hint localize "--- Second landing sequence position reached, proceeding with final aproach";
   };

   if (_pilot == player) then
   {
      hint "Second landing position reached\nEnganging autopilot";
      hint localize "--- Second landing position reached\nEnganging autopilot";
   };
};

_plane setVariable ["mando_land", 3];
_mis = _plane;
_post = [0,0,0];
_dir = getDir _mis;
_finish = false;
_speed = 0;
_climb = asin(vectorDir _plane select 2);
_climb2 = _climb;
_climbdir = 1;
_delay = 0.002;
_hdegreessec2 = 120*4;
_vdegreessec2 = 120*3;
_deltah = _hdegreessec2 * _delay;
_deltav = _vdegreessec2 * _delay;
_maxclimbup = 85;
_maxclimbdown = -85;
_ang     = 0;
_dif     = 0;
_difabs  = 0;
_angv    = 0;
_difang  = 0;
_altmasl = 0;
_almmasl = 0;
_turn    = 0;
_posm    = [0,0,0];
_topspd  = 0;
_landgear = false;
for [{_i=0},{_i < 3},{_i=_i+1}] do
{
   _speed = (speed _plane) / 3.6;
   _post = _aligns select (_i + 2);
   if (_i < 2) then
   {
      _topspd = _landspd*2;
   }
   else
   {
      _topspd = _landspd;
   };

   _finish = false;
   _distanceold = 999999;

   while {!_finish} do
   {
      if ((damage _plane > 0.5) || (vehicle _pilot != _plane)) then
      {
         _finish = true;
      } 
      else
      {
         _log setPosASL _post;
         _altmasl = getPosASL _mis select 2;
         _alttasl = getPosASL _log select 2;
         _distance = _log distance _mis;
         _angv = asin((_alttasl - _altmasl)/_distance);
         _posm = getPos _mis;


         if (_vertical && (_i == 2)) then
         {
            _topspd = _landspd - _landspd * (2000 - _distance)/2000;
            if (_distance > 100) then
            {
               if (_topspd < _taxispd*2) then
               {
                  _topspd = _taxispd*2;
               };
            }
            else
            {
               if (_topspd < _taxispd) then
               {
                  _topspd = _taxispd;
               };
            };

            if (_distance < _taxispd*2) then
            {
               _topspd = 2;
            };
         };


         if ((_speed +_accelfact*accTime) < _topspd) then {_speed = _speed + _accelfact*accTime;};
         if ((_speed -_accelfact*accTime) > _topspd) then {_speed = _speed - _accelfact*accTime;};

         _difang = abs(_climb - _angv);
 
         _climbdir = 1;
         if (_angv - _climb < 0) then {_climbdir = -1;};
         if (_difang < 1) then {_climbdir = 0;};

         _emergency = false;
         _ground setPos [(_posm select 0)+sin(_dir)*100, (_posm select 1)+cos(_dir)*100, 0];
         if ( (((getPosASL _ground select 2)+30) > _altmasl)&&(_i < 2)) then 
         {
            _climbdir = 1;
            _emergency = true;
         };

         _ground setPos [(_posm select 0)+sin(_dir)*50, (_posm select 1)+cos(_dir)*50, 0];
         if ( (((getPosASL _ground select 2)+30) > _altmasl)&&(_i < 2)) then 
         {
            _climbdir = 1;
            _emergency = true;
         };

         _ang = ((_post select 0)-(_posm select 0)) atan2 ((_post select 1)-(_posm select 1));
         _dif = (_ang - _dir);
         if (_dif < 0) then {_dif = 360 + _dif;};
         if (_dif > 180) then {_dif = _dif - 360;};
         _difabs = abs(_dif);
  
         if (_difabs > 0.1) then
         {
            if (_i == 2) then
            {
               if (_difabs < 20) then
               {
                  _turn = _dif/_difabs;
               }
               else
               {
                  _turn = 0; 
               };
            }
            else
            {
               if (_difabs < 180) then
               {
                  _turn = _dif/_difabs;
               }
               else
               {
                  _turn = 0; 
               };
            };
         }
         else
         {
            _turn = 0;
         };


         _dir = _dir + (_turn * ((_deltah * accTime) min _difabs));

         if (((_climbdir > 0) && (_climb < _maxclimbup) && ((_climb < _angv)||_emergency)) ||
             ((_climbdir < 0) && (_climb > _maxclimbdown) && (_climb > _angv)) ) then
         {
            _climb = _climb + (_climbdir * _deltav * accTime);
         };
   

         if ( ((_climbdir > 0) && (_climb > _angv) && !_emergency) ||
              ((_climbdir < 0) && (_climb < _angv)) ) then 
         {
            _climb = _angv;
         };


         if (_i == 0) then
         {
            _climb2 = _climb;
         }
         else
         {
            if ((_climb2 < 8/accTime) && ((_climb2 + _deltav*accTime/2.0) <= 8/accTime)) then
            {
               _climb2 = _climb2 + _deltav*accTime/2.0;
            }
            else
            {
               if ((_climb2 > 8/accTime) && ((_climb2 - _deltav*accTime/2.0) >= 8/accTime)) then
               {
                  _climb2 = _climb2 - _deltav*accTime/2.0;
               };
            };
         };

         _vz = (sin _climb)*_speed;
         _vh = (cos _climb)*_speed;
         _vx = (sin _dir)*_vh;
         _vy = (cos _dir)*_vh;
  
         _mis setVectorDir[_vx/_speed, _vy/_speed, _vz/_speed];
         _uz = sin(_climb2+90);
         _ur = cos(_climb2+90);
         _ux = sin(_dir)*_ur;
         _uy = cos(_dir)*_ur;
         _mis setVectorUp[_ux, _uy, _uz];
         _mis setVelocity [_vx, _vy, _vz];
      
         if (!_landgear && ((getPos _mis select 2) < 60) && (_speed <= (_landspd+2*accTime))) then
         {
            _pilot action ["LANDGEAR", _mis];
            _pilot action ["FLAPSDOWN", _mis];
            _plane action ["LIGHTON", _plane];
            _mis land "LAND";
            _landgear = true;
         };
         if (_i < 2) then
         {
            if ((_distance < 15) || (_distanceold < _distance)) then
            {
              _finish = true;
              _initdmg = damage _plane;
            };
         }
         else
         {
            if (!_vertical) then 
            {
               if (((getPos _plane select 2) < (0.2*accTime)) || (_distanceold < _distance)) then
               {
                  _finish = true;
               };
            }
            else
            {
               if (_distance < 5+accTime) then
               {
                  _finish = true;
               };
            };
         };
         Sleep _delay;
         _distanceold = _distance;
      };
   };
};
deleteVehicle _log;
deleteVehicle _ground;
deleteVehicle _target;

if (damage _plane < 0.8) then
{
   _plane setDamage _initdmg;
};


group _pilot lockWP false;
_speed = (speed _plane) / 3.6;
if (_vertical) then
{
   _climb = 0;
}
else
{
   _climb = -2/accTime;
};

if (_vertical) then
{
   _particle = ["\Ca\Data\ParticleEffects\FireAndSmokeAnim\SmokeAnim.p3d", 8, 3, 1];
   _drop = "#particlesource" createVehicle [0,0,0];
   _drop setParticleCircle [5, [0,10,0]];
   _drop setParticleParams [_particle,"","Billboard",100,3,[0,0,0],[0,0,0],2,25.50,20,1,[10,15,20],[[0.5,0.5,0.5,0],[0.5,0.5,0.4,0.5],   [0.5,0.4,0.4,0.3],[0.5,0.4,0.4,0]],[1,1],0,0,"","", ""];
   _drop setDropInterval 0.05;
}
else
{
   if (_radio && (damage _plane < 0.5) && (vehicle _pilot == _plane)) then
   {
      _pilot sidechat "Touch down!";
      hint localize "--- Touch down!";
   }
};

if (damage _plane > 0.1) then
{
   cutText[format["%1 DAMAGE!!!!", damage _plane], "PLAIN"];
};

_plane setVariable ["mando_land", 4];
if (!_vertical) then
{
   _dir = _landdir;
};

while {(_speed > 0.00001) && (damage _plane < 0.5) && (vehicle _pilot == _plane)} do
{
   _speed = _speed - (_accelfact*accTime);
   if (_speed < 0.00001) then 
   {
      _speed = 0.00001;
   };
   _vz = (sin _climb)*_speed;
   _vh = (cos _climb)*_speed;
   _vx = (sin _dir)*_vh;
   _vy = (cos _dir)*_vh;
   _mis setVectorDir[_vx/_speed, _vy/_speed, _vz/_speed];
   if (_vertical) then
   {
      if (_climb2 > 0.00001) then
      {
         _climb2 = _climb2 - _deltav*accTime/2.0;
      };
      if (_climb2 < 0.00001) then
      {
         _climb2 = 0.00001;
      };
      _uz = sin(_climb2+90);
      _ur = cos(_climb2+90);
      _ux = sin(_dir)*_ur;
      _uy = cos(_dir)*_ur;
      _mis setVectorUp[_ux, _uy, _uz];
      _drop setPos [getPos _plane select 0, getPos _plane select 1, 0];   
   };
   _mis setVelocity [_vx, _vy, _vz];
   Sleep _delay;
};


if (_vertical) then
{
   _speed0 = _taxispd/4;
   _up = vectorUp _plane;
   _vz = 0;
   while {((getPos _plane select 2) > 0.7) && (damage _plane < 0.5) && (vehicle _pilot == _plane)} do
   {
      if (_vz < _speed0) then
      {
         _vz = _vz + (_accelfact*accTime);
      };
      _vx = (sin _dir);
      _vy = (cos _dir);
      _plane setVectorDir[_vx, _vy,0];
      if ((getPos _plane select 2) > 0.5) then
      {
         _plane setVectorUp _up;
      };
      _plane setVelocity [0,0,-_vz];
      _drop setPos [getPos _plane select 0, getPos _plane select 1, 0];
      Sleep 0.001;
   };
};

if (_vertical) then
{
   deleteVehicle _drop;
   if (_radio && (damage _plane < 0.5) && (vehicle _pilot == _plane)) then
   {
      _pilot sidechat "Touch down!"
   };
};

if (_radio && (damage _plane < 0.5) && (vehicle _pilot == _plane)) then
{
   _pilot sidechat "Taxiing";
   hint localize "--- Taxiing";
};

_plane setVariable ["mando_land", 5];
_speed0 = _taxispd;
_posp = [0,0,0];
_speed = 0;
_climb = -2;
for [{_i=1},{_i < (count _wps)},{_i = _i+1}] do
{
   _dir = getDir _plane;
   _post = _wps select _i;

   while {((_plane distance _post)>(4+accTime)) && (damage _plane < 0.5) && (vehicle _pilot == _plane)} do
   {
      _state    = "TAXIING";
      if (_speed < _speed0) then
      {
         _speed = _speed + _accelfact*accTime / 2.0;  
      };

      if (_speed > _speed0) then
      {
         _speed = _speed - _accelfact*accTime / 2.0;  
      };

      _posp = getPos _plane;

      _ang = ((_post select 0)-(_posp select 0)) atan2 ((_post select 1)-(_posp select 1));
      _dif = (_ang - _dir);
      if (_dif < 0) then {_dif = 360 + _dif;};
      if (_dif > 180) then {_dif = _dif - 360;};
      _difabs = abs(_dif);
  
      if (_difabs > 0.1) then
      {
         _turn = _dif/_difabs;
      }
      else
      {
         _turn = 0;
      };

      if (_difabs > 45) then
      {
         _speed0 = _taxispd / 2;
      }
      else
      {
         _speed0 = _taxispd;
      };

      _dir = _dir + (_turn * ((_deltah * accTime) min _difabs));

      _vz = (sin _climb)*_speed;
      _vh = (cos _climb)*_speed;
      _vx = (sin _dir)*_vh;
      _vy = (cos _dir)*_vh;

      _plane setVectorDir[_vx/_speed, _vy/_speed, _vz/_speed];
      _plane setVelocity [_vx, _vy, _vz];
      Sleep _delay;
   };
};
//_pilot disableAI "MOVE";
_plane action ["CANCELLAND", _plane];
_pilot action ["ENGINEOFF", _plane];

if (_radio && (damage _plane < 0.5) && (damage _pilot < 1.0)) then
{
   _pilot sidechat "Engine off";
   hint localize "--- Engine off";
};

_timeini = dayTime * 3600;
_vdir = vectorDir _plane;
while {(dayTime*3600) < (_timeini + 5)} do
{
   _plane setVectorDir _vdir;
   _plane setVelocity [0,0,-0.1];
   Sleep _delay;
};

if (damage _plane < 0.5) then
{
   _plane setVariable ["mando_land", 6];
}
else
{
   _plane setVariable ["mando_land", 7];
};

if (_radio && (damage _plane < 0.5) && (damage _pilot < 1.0)) then
{
   _pilot sidechat "Landed! Come out please";
   hint localize "--- Landed! Come out please";

};
