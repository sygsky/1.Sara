
_id = _this select 2;
_snd = _this select 3;
if ( isNil "_snd" ) exitWith { _arg = "SoundSource";};
_this = _this select 0; // 1 is for actor

_this removeAction _id;

if ( alive _this) then
{
/*
	_snd = createSoundSource ["Music", (getpos _vec), [], 0];// only one source on the server should be created
	_vec setVariable ["SoundSource", _snd];
	_vec addAction ["Switch off","scripts\radio_off.sqf","SoundSource",6,true];

*/
	_snd = createSoundSource ["Music", (getpos _this), [], 0]; // only one source on the server should be created
	player groupChat format[ "_vec setVariable [""%1"", %2]", _arg, typeof _snd];
	_vec setVariable [_arg, _snd];
	player groupChat format[ "test seeting: ""%1"" == %2", _arg, typeof _snd];
	_this addAction ["Switch off", "scripts\radio_off.sqf", _arg, 6, true];
}
else
{
	player groupChat "Radio is destroyed, no more action";
};