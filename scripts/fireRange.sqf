// fireRange.fsq: by sygsky, serve fire range targets. 06-NOV-2015
// XfGlobalChat

//
// call with input params:
// [_trg1, ... , trgN] execVM "scripts\fireRange.sqf";
//   or
// _target execVM "scripts\fireRange.sqf";
//


if (typeName _this != "ARRAY") then { _this = [_this]};

hint localize format["fireRange.sqf: input params are %1", _this];

{
	//hint localize format["fireRange.sqf: addEventHandler to ""%1""", typeOf _x];

	if ( _x isKindOf "TargetEpopup" ) then
	{
		// Input params for "Hit" event
		//unit: Object - Object the event handler is assigned to
		//causedBy: Object - Object that caused the damage.   Contains the unit itself in case of collisions.
		//damage: Number - Level of damage caused by the hit
		/*
		_x addEventHandler ["Hit",
			{
				private ["_causedBy","_dist","_dmg"];
				_causedBy = _this select 1;
				_dist = "?";
				if (!isNull _causedBy) then
				{
					if (_causedBy != _this select 0) then
					{
						_dist = round(_causedBy distance (_this select 0));
					};
				};
				_dmg = (round((_this select 2) *10000))/100;
				player globalChat (format[localize "STR_SYS_334", _dist, _dmg]);
				//hint localize format[ localize "STR_SYS_334", _wpn, _dist, _dmg];
			}
		];
		*/
		/*
		Dammaged
        Triggered when the unit is damaged. In ArmA works with all vehicles not only men like in OFP.
        (Does not fire if damage is set via setDammage.) (If simultaneous damage occured (e.g. via grenade) EH might be triggered several times.)
                Global
                Passed array: [unit, selectionName, damage]
                    unit: Object - Object the event handler is assigned to
                    selectionName: String - Name of the selection where the unit was damaged
                    damage: Number - Resulting level of damage
        */
		_id = _x addEventHandler ["Dammaged",
			{
				private ["_selName","_dist","_dmg"];
				_selName = _this select 1;
                _dist = round(player distance (_this select 0));
				_dmg = (round((_this select 2) *10000))/100;
				player globalChat (format[localize "STR_SYS_334_1", _dist, _selName, _dmg]);
				//hint localize format[ localize "STR_SYS_334", _wpn, _dist, _dmg];
			}
		];

/*
		_str = format[ "+++Events handler added to target at %1, event id %2", getPos _x, _id ];
		player groupChat _str;
		hint localize _str;
*/
	}
	else 
	{
		hint localize format["fireRange.sqf: Error! Expected base type is ""TargetEpopup"", found ""%1""", typeOf _x];
	};
} forEach _this;