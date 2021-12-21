/*
	scripts\bonuses\bonusKilledEvent.sqf.sqf
	author: Sygsky
	description: Triggered when the unit is killed.

                 Local.

                 Passed array: [unit, killer]

                 unit: Object - Object the event handler is assigned to
                 killer: Object - Object that killed the unit
                 Contains the unit itself in case of collisions.
	returns: nothing
*/

#include "bonus_def.sqf"

//
// Sends info to the enterer or his leader if enterer is not the player
//
_sendInfoToPlayer = {
    player groupChat _this;
    hint localize _this;
};

//
// Sends info in form of format script command ... array parameters
// parameters for format, e.g. ["STR_BONUS_1_1", typeOf _veh] // STR_BONUS_1_1,"Your squad has detected %1! The one who delivered the find to the base will receive points, and the car will be able to fully restore on the service."
//
_sendInfo = {
    (format _this) call _sendInfoToPlayer;
};

_removeEvents = {
	// remove all event handler assigned
	_this removeAllEventHandlers "getin";
	_this removeAllEventHandlers "getout";
	_this removeAllEventHandlers "killed";
    deleteMarker BONUS_MARKER_NAME; // remove marker in any case
    _this setVariable ["bonus", nil];
};

_is_onBase = [ getPos _veh, d_base_array ] call SYG_pointInRect ; // is vehicle on base (true) or not (false)

_veh = _this select 0;
_killer = _this select 1;
_name = "<Unknown>";
if ( _killer != _veh ) then { _name = name _killer };
[ format[localize "STR_BONUS_DEL_0", typeOf ( _this select 0 ),  _name] ] call _sendInfo;

// remove all event handlers assigned
_veh call _removeEvents;
