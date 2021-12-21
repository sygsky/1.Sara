// Control types
#define CT_STATIC 0
#define CT_BUTTON 1
#define CT_EDIT 2
#define CT_SLIDER 3
#define CT_COMBO 4
#define CT_LISTBOX 5
#define CT_TOOLBOX 6
#define CT_CHECKBOXES 7
#define CT_PROGRESS 8
#define CT_HTML 9
#define CT_STATIC_SKEW 10
#define CT_ACTIVETEXT 11
#define CT_TREE 12
#define CT_STRUCTURED_TEXT 13
#define CT_CONTEXT_MENU 14
#define CT_CONTROLS_GROUP 15
#define CT_XKEYDESC 40
#define CT_XBUTTON 41
#define CT_XLISTBOX 42
#define CT_XSLIDER 43
#define CT_XCOMBO 44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT 80
#define CT_OBJECT_ZOOM 81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK 98
#define CT_USER 99
#define CT_MAP 100
#define CT_MAP_MAIN 101 // Static styles
#define ST_POS 0x0F
#define ST_HPOS 0x03
#define ST_VPOS 0x0C
#define ST_LEFT 0x00
#define ST_RIGHT 0x01
#define ST_CENTER 0x02
#define ST_DOWN 0x04
#define ST_UP 0x08
#define ST_VCENTER 0x0c
#define ST_TYPE 0xF0
#define ST_SINGLE 0
#define ST_MULTI 16
#define ST_TITLE_BAR 32
#define ST_PICTURE 48
#define ST_FRAME 64
#define ST_BACKGROUND 80
#define ST_GROUP_BOX 96

#define ST_GROUP_BOX2 112
#define ST_HUD_BACKGROUND 128
#define ST_TILE_PICTURE 144
#define ST_WITH_RECT 160
#define ST_LINE 176
#define FontM "Zeppelin32"
#define Size_Main_Small 0.027
#define Size_Main_Normal 0.04
#define Size_Text_Default Size_Main_Normal
#define Size_Text_Small Size_Main_Small
#define Color_White {1, 1, 1, 1}
#define Color_Main_Foreground1 Color_White
#define Color_Text_Default Color_Main_Foreground1

#define true 1
#define false 0

// ####
class GRU_RscText
{
	type = CT_STATIC;
	idc = -1;
	style = ST_LEFT;
	x = 0.0;
	y = 0.0;
	w = 0.3;
	h = 0.03;
	sizeEx = 0.023;
	colorBackground[] = {0.5, 0.5, 0.5, 0.75};
	colorText[] = { 0, 0, 0, 1 };
	font = FontM;
	text = "";
};

class MyHelloWorldDialog {
	idd = 12000;                      // set to -1, because we don't require a unique ID
//	movingEnable = true;           // the dialog can be moved with the mouse (see "moving" below)
	movingEnable = false;           // the dialog can be moved with the mouse (see "moving" below)
	enableSimulation = true;      // freeze the game
	controlsBackground[] = { GRU_BackGround };    // no background controls needed
	objects[] = { };               // no objects needed
	controls[] = { GRU_Map, GRU_AcceptButton, GRU_EscapeButton, GRU_Picture, GRU_MainText, GRU_Task1Text, 
				   GRU_Task2Text, GRU_Task3Text};

// ####	
	class GRU_BackGround : GRU_RscText
	{
		x = 0.1;
		y = 0.1;
		w = 0.8;
		h = 0.8;
		colorBackground[] = {0.5, 0.5, 0.5, 0.5};
	};

// ####
	class GRU_AcceptButton
	{
		idc = -1;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.03;
		colorText[] = { 0, 0, 0, 1 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 0, 0, 1, 0.7 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.5 };
		//colorBackground[] = { 1, 0.5, 0.5, 0.5 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.3 }; // background color for disabled state
		colorBackgroundActive[] = { 1, 1, 1, 0.7 }; // background color for active state
		offsetX = 0.003;
		offsetY = 0.003;
		offsetPressedX = 0.002;
		offsetPressedY = 0.002;
		colorShadow[] = { 0, 0, 0, 0.5 };
		colorBorder[] = { 0, 0, 0, 1 };
		borderSize = 0;
		soundEnter[] = { "", 0, 1 }; // no sound
		soundPush[] = { "\ca\ui\data\sound\new1", 0.1, 1 };
		soundClick[] = { "", 0, 1 }; // no sound
		soundEscape[] = { "", 0, 1 }; // no sound
		x = 0.62;
		y = 0.82;
		w = 0.2;
		h = 0.05;
		text = "Выполнить задание!"; //"Закрыть"
		action = "closeDialog 0; dialog_ret = 1;";
	};

	class GRU_EscapeButton : GRU_AcceptButton
	{
		idc = 12003;
		default = true;
		y = 0.74;
		text = "Закрыть и уйти"; //
		action = "closeDialog 0; dialog_ret = -1;";
	};
	
	class GRU_Map : RscMapControl
	{
		idc = 12002;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.9 };
		x = 0.12;
		y = 0.55;
		w = 0.3;
		h = 0.4;
		default = false;
		showCountourInterval = false;
	};
	
 	class GRU_Picture : RscPicture
	{
		idc = 12001;
		x=0.05; y=0.05; w=0.05; h=0.05;
		text="";
		sizeEx = 256;
		colorText[] = { 0, 0, 0, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
	};
	
	class GRU_MainText : GRU_RscText
	{
		idc = 12100;
		x = 0.1;
		y = 0.1;
		w = 0.45;
		h = 0.1;
		sizeEx = 0.035;
		colorText[] = { 0, 0.5, 0, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "Задания ГРУ в наличии";
	};

	class GRU_Task1Text : GRU_RscText
	{
		idc = 12101;
		x = 0.1;
		y = 0.2;
		w = 0.3;
		h = 0.02;
		lineSpacing = 1;
		sizeEx = 0.02;
		colorText[] = { 0.0, 1, 0.0, 1 };
		colorBackground[] = {1, 1, 1, 0.05};
		text = "1. Доставка развединформации из %1";
		action = "xhandle = [1] execVM ""GRU_scripts\selecttask.sqf"";";

	};
	class GRU_Task2Text : GRU_Task1Text
	{
		idc = 12102;
		y = 0.23;
		text = "2. Секретная операция в тылу противника";
		action = "xhandle = [2] execVM ""GRU_scripts\selecttask.sqf"";";
	};

	class GRU_Task3Text : GRU_Task1Text
	{
		idc = 12103;
		y = 0.23;
		text = "3. Поиск на территории острова";
		action = "xhandle = [3] execVM ""GRU_scripts\selecttask.sqf"";";
	};

};