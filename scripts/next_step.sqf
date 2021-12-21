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

_step_size = (_this select 3) select 0;

_model2World = player modelToWorld [0,0,0]; // player coords of model center

//_cam = nearestObject [getPos player, "#camera"];
//if ( isNull _cam) then {player groupChat "--- no camera"};
//else {player groupChat format["camera found at dist %1 m",player distance _cam]};

_posASL = getPosASL player;
//hint localize "<<<<< ----- next_step.sqf ----- >>>>>>";
//hint localize format["step %1 ASL %2 World %3",_step_size, _posASL, _model2World];

_vecDir =  vectorDir player;
//hint localize format["_vecDir %1",_vecDir];

_vecDirNew = [_vecDir,_step_size] call SYG_multiplyPoint3D; // shift for step
//hint localize format["_stepVector %1",_vecDirNew];

_pnt = _vecDir;
_coeff = _step_size;
_vecDirNew =  [argp(_pnt,X_POS) * _coeff, argp(_pnt,Y_POS) * _coeff, argp(_pnt,Z_POS) * _coeff - 1.0];
//_vecDirNew set [Z_POS, _model2World select Z_POS];
//hint localize format["_vecDirNew %1",_vecDirNew];

_newPos = [_posASL,_vecDirNew] call SYG_vectorAdd3D;
//hint localize format["_newPos %1",_newPos];
//player setPosASL _newPos;
player setPos [argp(_newPos,X_POS),argp(_newPos,Y_POS),argp(_model2World,Z_POS)];
sleep 0.05;
hint localize format["player pos %1(%2), bb %3",getPos player, getPosASL player, boundingBox player];



