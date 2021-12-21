/*
	author: Sygsky
	description: _hnd = _plane execVM "scripts\dclanding.sqf";
	returns: nothing
*/

player groupChat format ["_this = %1", typeOf _this];
_pilot = driver _this;
_this landAt 3;
_this lock true;
_this addEventHandler ["LandedTouchDown",
    {
        hint "Touched down";  player groupChat format["Приземлились, кажись (судорожно вздыхаю)... Не люблю летать!"];
    }
];
_this addEventHandler ["Gear",
    {
        player groupChat format["Шасси %1", if(_this select 1) then {"выпустил, будет садиться..."} else {"убрал.. улетает... куда?"}];
        if (!(_this select 1)) then  { (_this select 0) flyInHeight 100};
    }
];

waitUntil { sleep 1.0; (!alive _this) || (damage _this  > 0.1) || (!alive player) || (speed _this < 3.0) || (isNull driver _this)};

_pilot globalChat "Вылезай быстренько. Некогда нам! У тебя 5 секунд, камарад!";
sleep 2.0;
if ((vehicle _pilot) != _pilot) then
{
    player groupChat "Пилот почему-то вышел...";
};

if ( alive player && (vehicle player == _this) ) then
{
    player groupChat "Ха-ха-ха-а-а... ! Я жив и здоров...!";
    player action ["eject", _this];
//    _this lock true;
    aborigen lookAt player;
}
else
{
    player groupChat "Ты был хорошим человеком и верным товарищем, солдат! Покойся с миром!";
};

sleep 10;
_this engineOn false;
_this setFuel 1;
if ((vehicle _pilot) == _pilot) then
{
    player groupChat format["Поднимаем пилота, он назначен на %1, DC3 %2", assignedVehicle _pilot, if (locked dc3civ ) then {"заблокирован"} else {"открыт"}];
    dc3civ setVehicleLock "UNLOCKED";
    sleep 0.1;
    player groupChat format["DC3 %1", if (locked dc3civ ) then {"заблокирован"} else {"открыт"}];

    group _pilot setBehaviour "CARELESS";
    sleep 0.1;
    group _pilot setCombatMode "BLUE";
    _pilot setUnitPos "UP";
    sleep 1.1;
    _pos = getPos _pilot;
    _pos set [0, (_pos select 0) - 20];
    _pilot doMove _pos;
    player groupChat format["Приказываем пилоту отойти"];
    sleep 10;

    //player groupChat format["pilot pose = %1", unitPos _pilot];
    player groupChat format["Приказываем пилоту сесть в самолёт"];
    [_pilot] allowGetIn true;
    _pilot assignAsDriver _this;
    [_pilot] orderGetIn true;
    _pilot moveInDriver dc3civ;
};

sleep 1;

if ( ((vehicle _pilot) != _pilot) && (canStand _pilot) && (alive player) && (canMove _this) && (fuel _this > 0 ) ) then
{
    _pilot doMove (SYG_RahmadiIslet select 1);
    dc3civ landAt 1; // Rahmadi
    addWaypoint

//    _this landAt 1;
    player groupChat "Даём задание на отлёт подальше";
    dc3civ flyInHeight 1000;
}
else
{
    player groupChat format["Что-то с самолётом/пилотом неладно... %1, %2, %3",canStand _pilot, canMove _this, fuel _this];
};


