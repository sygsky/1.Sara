/*
	author: Sygsky
	description: none
	returns: nothing
*/

anim_list =
[

/*
"AinvPknlMstpSnonWnonDnon_healed_1",
"AinvPknlMstpSnonWnonDnon_healed_2",
"AinvPknlMstpSnonWnonDnon_medic_1",
"AinvPknlMstpSnonWnonDnon_medic_2"
*/

/*
"AinvPknlMstpSlayWrflDnon",
"AinvPknlMstpSlayWrflDnon_1",
*/

//Сидел на коленях около ящика с оружием, потом встает немного по разному

/*
"AinvPknlMstpSlayWrflDnon_AmovPercMstpSnonWnonDnon",
"AinvPknlMstpSlayWrflDnon_AmovPercMstpSrasWrflDnon",
"AinvPknlMstpSlayWrflDnon_AmovPknlMstpSrasWrflDnon"
*/
/*
"AmovPercMstpSnonWnonDnon_AinvPknlMstpSnonWnonDnon",
"AmovPercMstpSrasWpstDnon_AinvPknlMstpSnonWnonDnon",
"AmovPercMstpSrasWpstDnon_AinvPknlMstpSnonWnonDnon_end",
"AmovPercMstpSrasWpstDnon_AmovPercMstpSnonWnonDnon",
"AmovPercMstpSrasWpstDnon_AmovPercMstpSnonWnonDnon_end",
"AmovPercMstpSrasWpstDnon_AmovPercMstpSrasWrflDnon",
"AmovPercMstpSrasWpstDnon_AmovPercMstpSrasWrflDnon_end",
"AmovPercMstpSrasWpstDnon_AmovPknlMstpSrasWpstDnon",
"AmovPercMstpSrasWpstDnon_AmovPpneMstpSrasWpstDnon",
"AmovPercMstpSrasWpstDnon_AwopPercMstpSoptWbinDnon",
"AmovPercMstpSrasWpstDnon_AwopPercMstpSoptWbinDnon_end",
"AmovPercMstpSrasWpstDnon_AwopPercMstpSoptWbinDnon_mid"
*/

/*
"AinvPknlMstpSnonWnonDnon_1",
"AinvPknlMstpSnonWnonDnon_2",
"AinvPknlMstpSnonWnonDnon_3",
"AinvPknlMstpSnonWnonDnon_4"*/

/*
"ActsPercMstpSnonWnonDnon_DancingDuoIvan",
"ActsPercMstpSnonWnonDnon_DancingDuoStefan",
"ActsPercMstpSnonWnonDnon_DancingStefan"
*/

/*
"ActsPercMstpSnonWpstDnon_InterrogationSoldier", //	p	Interrogating someone, used with 'ActsPercMstpSnonWnonDnon_InterrogationVictim'
"ActsPercMstpSnonWnonDnon_InterrogationVictim"
*/

"ActsPercMwlkSlowWrflDnon_PatrolingBase1",
//"ActsPercMwlkSlowWrflDnon_PatrolingBase2",
//"ActsPercMwlkSlowWrflDnon_PatrolingBase3",
"ActsPercMwlkSlowWrflDnon_PatrolingBase4"
];

if ( isNil "animId") then
{
    animId = 0;
};
animId = animId % (count  anim_list);

player playMove (anim_list select animId);
player groupChat format["%1, %2",(anim_list select animId), animId];
animId = animId +1;
