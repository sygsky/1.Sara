
_id = _this select 2;
_snd = _this select 3;
if ( isNil "_snd" ) exitWith {"radio_off.sqf: No sound designated at 3rd param position, exit"};
_this = _this select 0; // 1 is for actor

_this removeAction _id;

player groupChat format["Deleting found ""%1""", typeOf _snd];
deleteVehicle _snd; sleep 0.1; _this setVariable [_arg, nil];sleep 0.1;
sleep 0.1415926;
if ( alive _this ) then
{
	_this addAction ["Switch on", "scripts\radio_on.sqf", _snd, 6, true];
}
else {	player groupChat "Radio is destroyed, no more action"; };