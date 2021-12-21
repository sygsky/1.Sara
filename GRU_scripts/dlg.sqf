//player groupChat

dialog_ret = 0;

_ok = createDialog "MyHelloWorldDialog";
sleep 0.1;
_GRU_display = findDisplay 12000;

_ctrl = _GRU_display displayCtrl 12001; // picture control

_ctrl ctrlSetText "img\red_star_64x64.paa";

waitUntil { sleep 0.5; !dialog || !alive player};

switch dialog_ret do
{
	case -1: {	titleText[ "Ты не готов сегодня! Иди и готовься к выполнению", "PLAIN DOWN" ];};
	case 1: 
	{
		titleText [ "Всё будет на самом деле, сынок ты или генерал армии!", "PLAIN DOWN"];
		
		// TODO: teleport to town
	};
	default {titleText [ "непонятно что приключилось","PLAIN DOWN" ];};
};
if (!alive player) then {
	closeDialog 12000;
};
