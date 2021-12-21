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
_house = (_this select 3) select 0;

if ((typeName _house) == "STRING") exitWith {
    switch _house do
    {
        case "DEL_RUINS";
        default {
            _ruins = nearestObjects[getPos player, ["Ruins"], 100];
            if ( count _ruins == 0) exitWith {player groupChat "No ruins to delete nearby"};
            deleteVehicle (_ruins select 0);
            player groupChat "Ruins deleted";

            _arr = _this select 3;
            if ( count _arr > 1 ) then
            {
                sleep 1;
                _house = (_this select 3) select 1;
                _pos = getPos _house;
                _pos set [2,0];
                _dir = direction _house;
                _newhouse = createVehicle [typeOf _house, _pos, [],0,"NONE"];
            }
        };
    };
};

_str = format["rep statio %1, dmg %2, pos %3, dir %4", _house, damage _house, getPos _house, direction _house];

_ruins =  nearestObjects[getPos _house, ["Ruins","Land_repair_center_ruins"], 100];
if ( count _ruins > 0) then
{
    _ruins = _ruins select 0;
    _str = format["%1, ruins %2, pos %3, dir %4", _str, _ruins, getPos _ruins, direction _house ];
    _ruins removeAction 0;
    //_ruins addAction["Восстановить", "script\rep_station_info.sqf"]
}
else
{
    _str = _str + ", no ruins";
};
hint localize _str;
player globalChat _str;


