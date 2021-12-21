/*
	author: Sygsky
	description: mail system for Arma-1, send mail, keep it under set conditions, show in Status
	returns: nothing
*/

// Store type mail flags

#define MAIL_STORE_HOURS             20
#define MAIL_STORE_VEH_ALIVE         21
#define MAIL_STORE_VEH_NOT_VISITED   22
#define MAIL_STORE_CHANGE_SM         23
#define MAIL_STORE_CHANGE_MT         24

// mail type
//#define MAIL_TYPE_VEHICLE_ALIVE     1   // type depends on designated vehicle is alive
//#define MAIL_TYPE_BONUS_NOT_VISITED	2	// is send  after player login if designated bonus vehicle still not visited
//#define MAIL_TYPE_SM                3   // depends on Side Mission change, is killed only when current SM number is bumped
//#define MAIL_TYPE_MT                4   // depends on Main Target Mission change, is killed only when current town is changed

//#define MAIL_TYPE_HOURS             5   // type depends on designated time to live for

#define MAIL_TYPE_SEND_ONCE         6   // type is send one time per player, may be combined with MAIL_TYPE_HOURS to exit after long period
//#define MAIL_TYPE_SEND_ON_LOGIN     7   // type is send on each player login one time, may be combined with MAIL_TYPE_HOURS, MAIL_TYPE_SM, MAIL_TYPE_MT

#define MAIL_TYPE_SHOW_IN_STATUS    8   // this mail is printed somewhere in Status dialog
#define MAIL_TEXT                   9   // contains text of mail

#define MAIL_ADDRESS               10   // May be [ player, name player, "*" | "", _vehicle]
//#define MAIL_ADDRESS_TO_SOME       11

// example of post parameters:
// [MAIL_TYPE_SEND_ON_LOGIN,]
//
//