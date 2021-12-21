/*
	author: Sygsky
	description: test code to help visit ALL positions in the hotel building to define their suitability for any quests in hotel building
        Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
        target (_this select 0): Object - the object which the action is assigned to
        caller (_this select 1): Object - the unit that activated the action
        ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
        arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
	returns: nothing
*/

#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))

#define X_POS 0
#define Y_POS 1
#define Z_POS 2

_house = (_this select 3) select 0;

hint localize "<<<<< ----- scripts/hotel_next_room.sqf ----- >>>>>>";

if ( typeName _house == "ARRAY") exitWith // point designated
{
    _str = format["+++ Jail pos %1!", _house];
    if (count (_this select 3) < 2 ) exitWith {player groupChat format["--- hotel_next_room.sqf: On jail expected 1st param pos, 2nd hotel, but count is %1", count (_this select 3) ]};

    _pos  = + _house;
    _pos1 = + _house;

    _house = (_this select 3) select 1;
    if ( typeOf _house != "Land_Hotel") exitWith {player groupChat format["--- hotel_next_room.sqf: expected ""Land_Hotel"" found ""%1""", typeOf _house]};

    player globalChat _str;
    hint localize _str;
    _time = daytime;
    _dt = 20 - _time;
    _pos1 set [1, 10];
    _pos1 set [2,  2];

    _light = "#lightpoint" createVehicleLocal (_pos1);
    _light setLightBrightness 0.8;
    _light setLightAmbient [0.6, 0.5, 0.6];
    _light setLightColor [0.8, 0.8, 0.8];
    _light lightAttachObject [ jail, [0,10,2]];

    player setPos _pos;
    sleep 0.1;
    _player_World = player modelToWorld [0,0,0];
    // get relative vector to hotel base pos
    _hotel_World = _house modelToWorld [0,0,0];
    _hotel_dir = direction _house;
    _helipad = "HeliHEmpty" createVehicle getPos _house;
    sleep 0.1;
    _helipad_World = _helipad modelToWorld [0,0,0];
    _str = format["PL WLD:%1, HTL WLD %2 ANG %3, HELY WLD %4", _player_World, _hotel_World, _hotel_dir, _helipad_World ];
    player groupChat _str;
    hint localize _str;
    _pos_rel = [_player_World,_hotel_World] call SYG_vectorSub3D;

    // calc relative point according not rotated hotel
    _rotpnt = [_hotel_World, _player_World, -_hotel_dir] call SYG_rotatePointAroundPoint;
    _diff_pnt = _house worldToModel (_player_World);
    //_str = format["ROT POINT %1", _rotpnt ];
    //hint localize _str;

    _pos_rel = [_rotpnt,_hotel_World] call SYG_vectorSub3D;

    _relarr = [_house, [ _pos_rel, getDir player]] call SYG_calcRelArr;
    _str = format["POS REL: %1, REL ARR:%2, DEF PNT %3", _pos_rel, _relarr, _diff_pnt ];
    player groupChat _str;
    hint localize _str;
    skipTime _dt;
    player groupChat "15 seconds night";
    sleep 15;
    skipTime - _dt;
    deleteVehicle _light;
    setDate _date;
};

_spec_id = [86,87,88,89,148,149,150,151,210,211,212,213,262,263,264,265]; // no door positions
_king_id = [55,57,58,59,60,67,69,70,71,80,81,82,94,96,98,118,120,129,131,142,144,158,160,180,182,184,191,195,204,206,218,220,221,224]; // good pos for king

// hotel
_small_room_jail = [[-5.7666,-6.92871,-7.7478],275.321]; // room near lifts
_lift_room_jail  = [[-2.84912,5.97559,-7.73027],3.49676]; // lift interior
_evo_jail        = [[-1.46631,-13.4297,-7.74679],91.3221]; // room at 1st floor of western wall of hotel
// 3 floor house (e.g. Eponia cottage area)

_eponia_jail     = [[-0.807129,-4.81445,0.0710754],186.022]; // 2nd floor house (in Eponia e.g.)
_eponia_jail2    = [[-0.835449,-4.91211,0.0709381],177.413];
_corazol_jail    = [[-0.115234,0.0288086,-10.816],174.61]; //  house Land_Panelak3

if ( typeName _house == "OBJECT") exitWith // HOTEL designated
{
    if ( typeOf _house != "Land_Hotel") exitWith {player groupChat format["--- hotel_next_room.sqf: expected ""Land_Hotel"" found ""%1""", typeOf _house]};


    //_house_pos = next_pos_in_hotel;
    if ( next_pos_in_hotel >= count _spec_id) exitWith {player groupChat format["--- Last close position index in building %1 is %2!", typeOf _house, next_pos_in_hotel - 1];};
    _house_pos = _spec_id select next_pos_in_hotel;
    _pos = _house buildingPos _house_pos;
    if ( (_pos select 0) == 0) exitWith
    {
        _str = format["--- Last existing position index in building %1 is %2!", typeOf _house, _house_pos - 1];
        player globalChat _str;
        hint localize _str;
    };

    _str = format["+++ Position index %1 in building %2 is %3!", _house_pos, typeOf _house, _pos];
    player globalChat _str;
    hint localize _str;
    player setPos _pos;
    next_pos_in_hotel = next_pos_in_hotel + 1;

};

if ( typeName _house == "SCALAR") exitWith // point in HOTEL designated
{
    if (count (_this select 3) < 2 ) exitWith {player groupChat format["--- hotel_next_room.sqf: after 1st scalar expected 2 params (2nd must be ""Land_Hotel"" object), found %1", count (_this select 3) ]};
    _posId = _house;
    _house = (_this select 3) select 1;
    if ( typeOf _house != "Land_Hotel") exitWith {player groupChat format["--- hotel_next_room.sqf: expected ""Land_Hotel"" found ""%1""", typeOf _house]};
    if ( (_posId < 0) || (_posId  >= 265)) exitWith {player groupChat format["--- hotel_next_room.sqf: Expected pos in hotel %1 is illegal, max is 265!", _house];};
    _pos = _house buildingPos _posId;
    player setPos _pos;
};

if ( (typeName _house) == "STRING") exitWith // point in HOTEL designated
{
    switch _house do
    {
        case "MAKE_REL":
        {
            // build relative array for current player pos
            //_houseWorld  = argp(1) modelToWorld [0,0,0];
            _house = nearestBuilding player;
            REL_ARR = [_house, player] call SYG_worldObjectToModel;
/*
            _playerWorld = player modelToWorld [0,0,0];
            _house = (getPos player) nearestObject "Building";
            _diffPos = _house worldToModel _playerWorld;
            REL_ARR = [ _diffPos, ((getDir player) - (getDir _house) + 360) mod 360];
*/
            _str = format["-------\nREL_ARR %1; // house type %2", REL_ARR, typeOf _house];
            hint localize _str;
            player groupChat _str;
        };
        case "USE_REL":
        {
            // use relative array to recreate new position
            //_houseWorld  = argp(1) modelToWorld [0,0,0];
            _house = [];

            if ( count REL_ARR >= 3) then
            {
                _house = REL_ARR select 2;
                if ( typeName _house == "ARRAY") then // this is center of building center
                {
                    _house = _house nearestObject "Building";
                };
            }
            else
            {
                _house = (getPos player) nearestObject "Building"
            };

            [_house, player, REL_ARR] call SYG_setObjectInHousePos;
/*
            _playerWorld = _house modelToWorld (REL_ARR select 0);
            player setDir (((REL_ARR select 1) + (getDir _house) + 360) mod 360);
            player setPos _playerWorld;
            _str = format["-------\USE_REL : new pos %1", _playerWorld];
            hint localize _str;
            player groupChat _str;
*/
        };
        case "BASE":
        {
            player setPos (getPos FLAG_BASE);
        };
        default {player groupChat format["Unknown command ""%s""",_house]};
    };
};
