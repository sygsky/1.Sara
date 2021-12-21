/*
    scripts\bonuses\assignAsBonus.sqf
	author: Sygsky
	description: handlers assigned to the vehicle to check bonus in/kill events
	returns: nothing
*/

#include "bonus_def.sqf"

if (typeName _this == "OBJECT") then {_this = [_this]};
if (typeName _this != "ARRAY") exitWith {hint localize format["--- assignAsBonus.sqf, found %1",typeName _this]};
{
	if ( ! (_x isKindOf "Landvehicle" || _z isKindOf "Air" || _x isKindOf "Ship") ) exitWith {
		hint localize format["--- assignAsBonus.sqf: expected type Landvehicle|Air|Ship, detected ""%1"", EXIT ON ERROR !!!", typeOf _x];
	};

	_x call SYG_addEventsAndDispose; // add all std mission-driven events here
	_x addEventHandler ["getin", {_this execVM "scripts\bonuses\bonusGetInEvent.sqf"}];
	_x addEventHandler ["killed", {_this execVM "scripts\bonuses\bonusKilledEvent.sqf"}];
	_id = _x addAction [ localize "STR_CHECK_ITEM", "scripts\bonuses\bonusInspectAction.sqf", [] ];
	_x setVariable ["INSPECT_ACTION_ID", _id];
	hint localize format["--- assignAsBonus.sqf: ""getin"" and ""killed"" events and ""explore"" action  added to %1", typeOf _x];
} forEach _this;
