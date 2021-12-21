// Sygsky

X_MP = true;
X_Client = true;

#define __DEBUG_NET(a,b) player globalChat format["%1: %2", (a), (b) ];

XPlayersNumber = { (playersNumber east) + (playersNumber east) + 1};

#define _PRINT(a) hint localize a; player groupChat a

//#ifdef __RANKED__
d_ranked_a = [
	10, 		// 0 очков необходимо инженеру для ремонта
	[4,3,2,1], 	// 1 очков начисляется инженеру за ремонт авиа, танки, машины, другое
	2, 			// 2 очков вычитается за 1 залп
	0, 		    // 3 points in the AI version for recruiting one soldier
	1, 			// 4 очков вычитается за AAHALO parajump
	2, 			// 5 очков вычитается за создание техники из MHQ
	40, 		// 6 очков необходимо для создания техники из MHQ
	2, 			// 7 очков начисляется медику за лечение игроков в его палатке
	["Sergeant", "Lieutenant", "Captain", "Major"], // 8  ранги необходимые для управления различной техникой легкая броня, танки, боевые верты, самолеты
	20, 		// 9 очков начисляется за взятие города
	400, 		//10 дистанция находясь в которой начисляются очки за взятие города
	20, 		//11 очков за дополнительную миссию
	250, 		//12 дистанция находясь в которой начисляются очки за допку
	5,  		//13 очков требуется для починки разрушенных сервисов на базе
	10, 		//14 очков необходимо для развертывания пулеметного гнезда
	5, 	        //15 points needed in AI Ranked to call in an airtaxi
	80,			//16 очков необходимо для вызова снабжения
	5, 			//17 очков начисляются медику за лечение других игроков
	5, 			//18 очки получаемые за перевозку других игроков
	20,			//19 очков необходимо для вызова артиллерийского удара
	10,			//20 очков вычитается за ремонт разрушенных сервисов на базе
	10,			//21 очков вычитается за развертывание пулеметного гнезда
	20,			//22 очков вычитается за вызов снабжения
	1,			//23 очков добавляется за посещение неизвестной до того палатки
	20			//24 очков добавляется за посещение самой первой палатки в миссии
];
//#endif

//	#endif
current_counter = 5;
number_targets = count target_names;
current_target_index = 5;
target_clear = false;

d_own_side = "EAST";
d_side_enemy = west;
d_side_player = east;

// get a random number, floored, from count array
// parameters: array
// example: _randomarrayint = _myarray call XfRandomFloorArray;
XfRandomFloorArray = {
	floor (random (count _this))
};

// get a random item from an array
// parameters: array
// example: _randomval = _myarray call XfRandomArrayVal;
XfRandomArrayVal = {
	_this select (_this call XfRandomFloorArray);
};

XCheckForMap = {
	private ["_retval", "_ruckmags"];
	_retval = false;
	if (player hasWeapon "ACE_Map") then {
		_retval = true
	} else {
		if (player call ACE_Sys_Ruck_HasRucksack) then {
			_ruckmags = [];
			if (format["%1",player getVariable "ACE_Ruckmagazines"] != "<null>") then {
				_ruckmags = player getVariable "ACE_Ruckmagazines";
			};
			if (count _ruckmags > 0) then {
				{
					if ((_x select 0) == "ACE_Map_PDM") exitWith {_retval = true};
				} forEach _ruckmags;
			};
		}
	};
	_retval
};
