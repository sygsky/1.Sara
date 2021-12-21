/*
	scripts\bonuses\bonusInspectAction.sqf
	author: Sygsky at 17-NOV-2021
	description:
        Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
        target (_this select 0): Object - the object which the action is assigned to
        caller (_this select 1): Object - the unit that activated the action
        ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
        arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax

	this method removes called action from vehicle and emulate "getin" event for the "driver"
	returns: nothing
*/
hint localize format ["+++ bonusInspectAction.sqf: %1", _this];
_veh = _this select 0;
hint localize format ["+++ bonusInspectAction.sqf: action ""Inspect"" called and removed for the %1", typeOf _veh ];
[_veh, "driver", _this select 1] execVM "scripts\bonuses\bonusGetInEvent.sqf"; // Passed array: [vehicle, position, unit]
