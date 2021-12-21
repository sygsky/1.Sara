// GRU_removedoc.sqf, created by Sygsky on 10-DEC-2015
// removes ACE_map object from user
//
// added as follow:
// _menu_id = player addAction ["Уничтожить документ", "GRU_scripts\GRU_removedoc.sqf",[], 1000]; // to be the top item in menu
// player setVariable ["remove_doc_id", _menu_id];
//
// Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]

#define arg(x) (_this select(x))

private ["_cnt", "_ruckmags"];

// remove ACE_Map
player removeWeapon "ACE_Map";

if (player call ACE_Sys_Ruck_HasRucksack) then {
	_ruckmags = [];
	if (format["%1",player getVariable "ACE_Ruckmagazines"] != "<null>") then 
	{
		_ruckmags = player getVariable "ACE_Ruckmagazines";
	};
	if ((count _ruckmags) > 0) then {
		_cnt = count _ruckmags;
		_ruckmags = _ruckmags - ["ACE_Map_PDM"];
		if ( (count _ruckmags) != _cnt ) then { player setVariable ["ACE_Ruckmagazines", _ruckmags] };
	};
};

// check if player has item to remove
if (format["%1",player getVariable "remove_doc_id"] != "<null>") then
{
	player  removeAction (player getVariable "remove_doc_id");
	player setVariable [ "remove_doc_id", nil];
	hint localize "GRU_removedoc.sqf: action removed";
}
else
{
	hint localize "GRU_removedoc.sqf: no added Action found";
};
