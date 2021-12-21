/*
	1.Sara/scripts/bonuses/x_netinit.sqf
	author: Sygsky
	description: none
	returns: nothing
*/

// To ensure all clients receive this message
XSendNetStartScriptClientAll = {
	_this call XHandleNetStartScriptClient; // if sent from client, it should receive it too
};

XHandleNetStartScriptClient = {
	switch (_this select 0) do {

		// adds vehicle to the markered list of players
		case "bonus_veh" : { // [ "bonus_veh", _sub_command, player, _vehicle ]
			switch (_this select 1) do {

				// send vehicle to players to draw marker on it
				case "add_marker": {
				};
			};
		};

		default {};
	};
};

//
// call as: [] call XHandleNetStartScriptServer
//
XHandleNetStartScriptServer = {
	switch (_this select 0) do {

		// remove vehicle from markered list of bonus vehicles
		case "bonus_remove" : { // [ "bonus_veh", _sub_command, player, _vehicle ]
			switch (_this select 1) do {
				// vehicle is sent to any player to draw and control marker on it
				case "add_marker": {
					bonus_vehicle_arr = _this select 2;
				};
			};
		};

		default {};
	};
};

