/*
             *     ,MMM8&&&.            *
                  MMMM88&&&&&    .
                 MMMM88&&&&&&&
     *           MMM88&&&&&&&&
                 MMM88&&&&&&&&
                 'MMM88&&&&&&'
                   'MMM8&&&'      *
          |\___/|
          )     (             .              '
         =\     /=
           )===(       *
          /     \
          |     |
         /       \
         \       /
  _/\_/\_/\__  _/_/\_/\_/\_/\_/\_/\_/\_/\_/\_
  |  |  |  |( (  |  |  |  |  |  |  |  |  |  |
  |  |  |  | ) ) |  |  |  |  |  |  |  |  |  |
  |  |  |  |(_(  |  |  |  |  |  |  |  |  |  |
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  -----------SHOUTOUT TO MEOWMEOW------------
	**********************************************************************************************************************************
	*	CHANGE LOG
	*
	* Done:
	* 0.6.1b - Minor performance improvement. (Constantly checking if the map had regen on every player profile loaded. Changed to check once per map.)
	*
	* 0.6.2b - JumpAssist NOW REQUIRES SDKHOOKS to be installed.
	* 0.6.2b - Fixed !superman not displaying the correct text/action after a team/class change.
	* 0.6.2b - Re-did the ammo resupply. Correctly supports both jumper weapons now, and other unlocks (Not all weapons added yet).
	* 0.6.2b - Fixed a typo in CreatePlayerProfile where it defaulted the FOV to 90 instead of 70.
	* 0.6.2b - Fixed a couple bugs in LoadPlayerProfile. Everything should load correctly now.
	* 0.6.2b - Fixed a few missing pieces of text in the jumpassist translations file.
	* 0.6.2b - Removed "battle protection" (server admins should make use of !mapset team <red|blu>)
	*
	* 0.6.3b - Re-worked the cap message stuff. Should be 99% better.
	* 0.6.3b - Removed some unreleased stuff I was working on in JA.
	*
	* 0.6.4b - Players using the jumper weapons can no longer use !hardcore.
	* 0.6.4b - Added more to the translations file.
	*
	* 0.6.5b - Added SteamTools
	* 0.6.5b - Added ja_url make your own custom help file.
	*
	* 0.6.6b - Random bug fix
	*
	* 0.6.7b - Better error checking
	*
	* 0.6.8 - Added auto updating to jumpassist. Which makes SteamTools a solid requirement.
	*
	* 0.6.9 - Changed the code around to be more easily maintained.
	*
	* 0.7.0 - Added both options for sqlite and mysql data storage.
	*
	* UNOFFICIAL UPDATES BY TALKINGMELON
	* 0.7.1 - Regen is working better and skeys has less delay. Control points should work properly.
	*       - JA can now be used without a database configured.
	*       - Restart works properly.
	*       - The system for saving locations for admins is now working properly
	*       - Also general bugfixes
	*
	* 0.7.2 - Moved skeys and added m1/m2 support
	*       - Changed how commands are recognized to the way that is normally supported
	*       - General bugfixes
	*
	* 0.7.3 - Added support for updater plugin
	*
	* 0.7.4 - Added race functionality
	*
	* 0.7.5 - Fixed a number of racing bugs
	*
	* 0.7.6 - Racing now displays time in HH:MM:SS:MS or just MM:SS:MS if the time is short enough
	*       - Reorganized code to make it more readable and understandable
	*       - Spectators now get race alerts if they are spectating someone in a race
	*       - r_inv now works with argument targeting - ex !r_inv talkingmelon works now
	*       - restart no longer displays twice
	*       - When a player loads into a map, their previous caps will no longer be remembered - should fix the notification issue
	*       - Sounds should play properly
	*       - r_info added
	*       - r_spec added
	*       - r_set added
	*
	* 0.7.7 - Can invite multiple people at once with the r_inv command
	*       - Fixed server_race bug
	*       - Tried to fix sounds (pls)
	*       - r_list command added
	*
	* 0.7.8 - Ammo regen after plugin reload working
	*       - skeys_loc now allows you to set the location of skeys on the screen
	*       - Actually fixed no alert on cp problem
	*       - r_list and r_info now work for spectators of a race
	*
	* 0.7.9 - Fixed undo bug that let you change classes and teams and still have your old teleport
	*       - Timer sould work in all time zones properly now
	*       - Fixed calling for medic giving regen during race
	*
	* 0.7.10 - Added !spec command
	*        - Fixed potential for tele notification spam
	*        - Improved the usability of the help menu
	*
	* 0.7.11 - Fixed timer team bug
	*        - Fixed SQL ReloadPlayerData bug (maybe?)
	*
	* 0.8.0 - Moved upater to github repository
	*	  - imported jumptracer
	*	  - added cvar ja_update_branch for server operators to select updating from
	*	  - from dev or master.  Must be set in server.cfg.
	*
	* 0.8.0+ - See GitHub logs for future changes
	*
	**********************************************************************************************************************************
	* TODO:
	* give race a better UI
	* R_LIST TIMES AFTER PLAYER DC
	*LOG TO SERVER WHEN THE MAPSET COMMAND IS USED
	* STARTING A SECOND RACE WITH THE FIRST ONE STILL IN PROGRESS OFTEN GIVES - YOU ARE NOT THE RACE LOBBY LEADER if everyone types !r_leave it works
	*
	* maybe leave race when not leader of old race to start new one not work?
	* Plugin cvar enabled for all functions
	* ADD CVAR TO TOGGLE FINISH ALERT TO SERVER / FIX SPAM POSSIBLITY - SPEC POINTS REACHED BUG THING
	* PLAYER GOT TO CP IN TIME NOT JUST PLAYER GOT TO CP - WOULD MAKE THE TIME PART GOODOODOOODOD
	* TEST RACE SPEC AND ADD FUNCTIONALITY FOR ONLY SHOWING PEOPLE IN A RACE WHEN ATTACK1 AND 2 ARE USED
	* rematch typa thing
	* save pos before start of race then restore after
	* Polish for release.
	* Support for jtele with one argument
	* Support for sequence of cps
	**********************************************************************************************************************************
	* BUGS:
	* I'm sure there are plenty
	*   eventPlayerChangeTeam throws error on dc
	*   Dropped <name> from server (Disconnect by user.)
	*   L 12/02/2014 - 23:07:57: [SM] Native "ChangeClientTeam" reported: Client 2 is not in game
	*   L 12/02/2014 - 23:07:57: [SM] Displaying call stack trace for plugin "jumpassist.smx":
	*   L 12/02/2014 - 23:07:57: [SM]   [0]  Line 1590, scripting\jumpassist.sp::timerTeam()
	* Change to spec during race
	*
	* Race with 3 people - 2 finish - leader is one of them and starts new race inviting the other finisher and starts
	* Race keeps other person in it - may not have transfered leadership/may not leave race on !race if you are in one    --- I think i fixed this bug but is is difficult to test
	*
	* TESTERS
	* - Froyo
	* - Zigzati
	* - Elie
	* - Fossiil
	* - Melon
	* - AI
	* - Jondy
	* - Fractal
	* - Torch
	* - Velks
	* - Jondy
	* - Pizza Butt 8)
	* - 0beezy
	* - JoinedSenses
	**********************************************************************************************************************************
	*NOTES
	*
	* You must have a mysql or sqlite database named jumpassist and configure it in /addons/sourcemod/configs/databases.cfg
	* Once the database is set up, an example configuration would look like:
	*
	* "jumpassist"
	*     {
	*             "driver"				"default"
	*             "host"				"127.0.0.1"
	*             "database"			"jumpassist"
	*             "user"				"tf2server"
	*             "pass"				"tf2serverpassword"
	*             //"timeout"			"0"
	*             //"port"				"0"
	*     }
	*
	**********************************************************************************************************************************
*/
#pragma semicolon 1
#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <morecolors>

#if !defined REQUIRE_PLUGIN
#define REQUIRE_PLUGIN
#endif

#if !defined AUTOLOAD_EXTENSIONS
#define AUTOLOAD_EXTENSIONS
#endif

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_NAME "[TF2] Jump Assist"
#define PLUGIN_AUTHOR "rush - Updated by nolem, happs, joinedsenses"
#define cDefault	0x01
#define cLightGreen 0x03
/*
	Core Includes
*/
	//1 - inviting players
	//2 - 3 2 1 countdown
	//3 - racing
	//4 - waiting for players to finish
	//	- Only updated for the lobby host
int
	g_bRace[MAXPLAYERS+1]
	, g_bRaceStatus[MAXPLAYERS+1]
	, g_bRaceFinishedPlayers[MAXPLAYERS+1][MAXPLAYERS]
	, g_bRaceEndPoint[MAXPLAYERS+1] = {-1, ...}
	, g_bRaceInvitedTo[MAXPLAYERS+1]
	, g_bRaceSpec[MAXPLAYERS+1]
	, g_iLastTeleport[MAXPLAYERS+1];
float
	g_bRaceStartTime[MAXPLAYERS+1]
	, g_bRaceTime[MAXPLAYERS+1]
	, g_bRaceTimes[MAXPLAYERS+1][MAXPLAYERS]
	, g_bRaceFirstTime[MAXPLAYERS+1];
bool
	g_bRaceLocked[MAXPLAYERS+1]
	, g_bRaceAmmoRegen[MAXPLAYERS+1]
	, g_bRaceClassForce[MAXPLAYERS+1]
	, waitingInvite[MAXPLAYERS+1];
ConVar
	g_hWelcomeMsg
	, g_hCriticals
	, g_hSuperman
	, g_hAmmoCheat
	, waitingForPlayers;
char
	szWebsite[128] = "http://www.jump.tf/"
	, szForum[128] = "http://tf2rj.com/forum/"
	, szJumpAssist[128] = "http://tf2rj.com/forum/index.php?topic=854.0";
Handle hArray_NoFuncRegen;

#include "jumpassist/skeys.sp"
#include "jumpassist/database.sp"
#include "jumpassist/sound.sp"

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Tools to run a jump server with ease.",
	version = PLUGIN_VERSION,
	url = "http://jump.tf"
}

public void OnPluginStart() {
	JA_CreateForward();
	// Skillsrank uses me!
	RegPluginLibrary("jumpassist");
	// ConVars
	CreateConVar("jumpassist_version", PLUGIN_VERSION, "Jump assist version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_hPluginEnabled = CreateConVar("ja_enable", "1", "Turns JumpAssist on/off.", FCVAR_NOTIFY);
	g_hWelcomeMsg = CreateConVar("ja_welcomemsg", "1", "Show clients the welcome message when they join?", FCVAR_NOTIFY);
	g_hAmmoCheat = CreateConVar("ja_ammocheat", "1", "Allows engineers infinite sentrygun ammo.", FCVAR_NOTIFY);
	g_hCriticals = CreateConVar("ja_crits", "0", "Allow critical hits.", FCVAR_NOTIFY);
	g_hSuperman = CreateConVar("ja_superman", "0", "Allows everyone to be invincible.", FCVAR_NOTIFY);

	RegConsoleCmd("ja_help", cmdJAHelp, "Shows JA's commands.");
	RegConsoleCmd("sm_hardcore", cmdToggleHardcore, "Sends you back to the beginning without deleting your save..");
	RegConsoleCmd("sm_r", cmdReset, "Sends you back to the beginning without deleting your save..");
	RegConsoleCmd("sm_reset", cmdReset, "Sends you back to the beginning without deleting your save..");
	RegConsoleCmd("sm_restart", cmdRestart, "Deletes your save, and sends you back to the beginning.");
	RegConsoleCmd("sm_setmy", cmdSetMy, "Saves player settings.");
	RegConsoleCmd("sm_s", cmdSave, "Saves your current position.");
	RegConsoleCmd("sm_save", cmdSave, "Saves your current position.");
	RegConsoleCmd("sm_undo", cmdUndo, "Restores your last saved position.");
	RegConsoleCmd("sm_t", cmdTele, "Teleports you to your current saved location.");
	RegConsoleCmd("sm_regen", cmdToggleAmmo, "Regenerates weapon ammunition");
	RegConsoleCmd("sm_ammo", cmdToggleAmmo, "Regenerates weapon ammunition");
	RegConsoleCmd("sm_tele", cmdTele, "Teleports you to your current saved location.");
	RegConsoleCmd("sm_skeys", cmdGetClientKeys, "Toggle showing a clients key's.");
	RegConsoleCmd("sm_skeys_color", cmdChangeSkeysColor, "Changes the color of the text for skeys."); //cannot whether the database is configured or not
	RegConsoleCmd("sm_skeys_loc", cmdChangeSkeysLoc, "Changes the color of the text for skeys.");
	RegConsoleCmd("sm_superman", cmdUnkillable, "Makes you strong like superman.");
	RegConsoleCmd("sm_jumptf", cmdJumpTF, "Shows the jump.tf website.");
	RegConsoleCmd("sm_forums", cmdJumpForums, "Shows the jump.tf forums.");
	RegConsoleCmd("sm_jumpassist", cmdJumpAssist, "Shows the forum page for JumpAssist.");
	RegConsoleCmd("sm_race_list", cmdRaceList, "Lists players and their times in a race.");
	RegConsoleCmd("sm_r_list", cmdRaceList, "Lists players and their times in a race.");
	RegConsoleCmd("sm_race", cmdRaceInitialize, "Initializes a new race.");
	RegConsoleCmd("sm_r_inv", cmdRaceInvite, "Invites players to a new race.");
	RegConsoleCmd("sm_race_invite", cmdRaceInvite, "Invites players to a new race.");
	RegConsoleCmd("sm_r_start", cmdRaceStart, "Starts a race if you have invited people");
	RegConsoleCmd("sm_race_start", cmdRaceStart, "Starts a race if you have invited people");
	RegConsoleCmd("sm_r_leave", cmdRaceLeave, "Leave the current race.");
	RegConsoleCmd("sm_race_leave", cmdRaceLeave, "Leave the current race.");
	RegConsoleCmd("sm_r_spec", cmdRaceSpec, "Spectate a race.");
	RegConsoleCmd("sm_race_spec", cmdRaceSpec, "Spectate a race.");
	RegConsoleCmd("sm_r_set", cmdRaceSet, "Change a race's settings.");
	RegConsoleCmd("sm_race_set", cmdRaceSet, "Change a race's settings.");
	RegConsoleCmd("sm_r_info", cmdRaceInfo, "Display information about the race you are in.");
	RegConsoleCmd("sm_race_info", cmdRaceInfo, "Display information about the race you are in.");
	RegAdminCmd("sm_server_race", cmdRaceInitializeServer, ADMFLAG_GENERIC, "Invite everyone to a server wide race");
	RegAdminCmd("sm_s_race", cmdRaceInitializeServer, ADMFLAG_GENERIC, "Invite everyone to a server wide race");
	// Admin Commands
	RegAdminCmd("sm_mapset", cmdMapSet, ADMFLAG_GENERIC, "Change map settings");
	RegAdminCmd("sm_send", cmdSendPlayer, ADMFLAG_GENERIC, "Send target to another target.");

	HookEvent("player_team", eventPlayerChangeTeam);
	HookEvent("player_changeclass", eventPlayerChangeClass);
	HookEvent("player_spawn", eventPlayerSpawn);
	HookEvent("player_death", eventPlayerDeath);
	HookEvent("controlpoint_starttouch", eventTouchCP);
	HookEvent("teamplay_round_start", eventRoundStart);
	HookEvent("post_inventory_application", eventInventoryUpdate);
	
	// ConVar Hooks
	HookConVarChange(g_hAmmoCheat, cvarAmmoCheatChanged);
	HookConVarChange(g_hWelcomeMsg, cvarWelcomeMsgChanged);
	HookConVarChange(g_hSuperman, cvarSupermanChanged);
	
	HookUserMessage(GetUserMessageId("VoiceSubtitle"), HookVoice, true);

	LoadTranslations("jumpassist.phrases");
	LoadTranslations("common.phrases");
	g_hHostname = FindConVar("hostname");
	HudDisplayForward = CreateHudSynchronizer();
	HudDisplayASD = CreateHudSynchronizer();
	HudDisplayDuck = CreateHudSynchronizer();
	HudDisplayJump = CreateHudSynchronizer();
	HudDisplayM1 = CreateHudSynchronizer();
	HudDisplayM2 = CreateHudSynchronizer();
	waitingForPlayers = FindConVar("mp_waitingforplayers_time");
	hArray_NoFuncRegen = CreateArray();
	for (int i = 0; i < MAXPLAYERS+1; i++) {
		if (IsValidClient(i)) {
			g_iClientWeapons[i][0] = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
			g_iClientWeapons[i][1] = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			g_iClientWeapons[i][2] = GetPlayerWeaponSlot(i, TFWeaponSlot_Melee);
		}
		g_iLastTeleport[i] = 0;
	}
	SetAllSkeysDefaults();
	ConnectToDatabase();
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("JA_ClearSave", Native_JA_ClearSave);
	CreateNative("JA_GetSettings", Native_JA_GetSettings);
	CreateNative("JA_ReloadPlayerSettings", Native_JA_ReloadPlayerSettings);
	g_bLateLoad = late;
	return APLRes_Success;
}

void TF2_SetGameType() {
	GameRules_SetProp("m_nGameType", 2);
}

public void OnGameFrame() {
	SkeysOnGameFrame();
}

// Support for beggers bazooka
void Hook_Func_regenerate() {
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "func_regenerate")) != INVALID_ENT_REFERENCE)
		// Support for concmap*, and quad* maps that are imported from TFC.
		HookFunc(entity);
}

void HookFunc(int entity) {
#if defined DEBUG
	LogMessage("Hooked entity %d", entity);
#endif
	SDKUnhook(entity, SDKHook_StartTouch, OnPlayerStartTouchFuncRegenerate);
	SDKUnhook(entity, SDKHook_Touch, OnPlayerStartTouchFuncRegenerate);
	SDKUnhook(entity, SDKHook_EndTouch, OnPlayerStartTouchFuncRegenerate);
	SDKHook(entity, SDKHook_StartTouch, OnPlayerStartTouchFuncRegenerate);
	SDKHook(entity, SDKHook_Touch, OnPlayerStartTouchFuncRegenerate);
	SDKHook(entity, SDKHook_EndTouch, OnPlayerStartTouchFuncRegenerate);
}

public void OnMapStart() {
	if (g_hPluginEnabled.BoolValue) {
		for (int i = 0; i < MAXPLAYERS+1 ; i++) {
			ResetRace(i);
			g_iLastTeleport[i] = 0;
		}
		if (g_hDatabase != null)
			LoadMapCFG();
		SetConVarInt(waitingForPlayers, 0);
		PrecacheSound("misc/freeze_cam.wav");
		PrecacheSound("misc/killstreak.wav");
		TF2_SetGameType();
		int iCP = -1;
		g_iCPs = 0;
		while ((iCP = FindEntityByClassname(iCP, "trigger_capture_area")) != -1)
			g_iCPs++;
		Hook_Func_regenerate();
	}
}

public void OnClientDisconnect(int client) {
	if (g_hPluginEnabled.BoolValue) {
		g_bHardcore[client] = false, g_bLoadedPlayerSettings[client] = false, g_bBeatTheMap[client] = false;
		g_bGetClientKeys[client] = false, g_bUnkillable[client] = false, Format(g_sCaps[client], sizeof(g_sCaps), "\0");
		EraseLocs(client);
	}
	if (g_bRace[client] != 0)
		LeaveRace(client);
	SetSkeysDefaults(client);
	int idx;
	if ((idx = FindValueInArray(hArray_NoFuncRegen, client)) != -1)
		RemoveFromArray(hArray_NoFuncRegen, idx);
}

public void OnClientPutInServer(int client) {
	if (g_hPluginEnabled.BoolValue) {
		// Hook the client
		if (IsValidClient(client))
			SDKHook(client, SDKHook_WeaponEquipPost, SDKHook_OnWeaponEquipPost);
		// Load the player profile.
		char sSteamID[64];
		GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
		LoadPlayerProfile(client, sSteamID);
		// Welcome message. 15 seconds seems to be a good number.
		if (g_hWelcomeMsg.BoolValue)
			CreateTimer(15.0, WelcomePlayer, client);
		g_bHardcore[client] = false;
		g_bLoadedPlayerSettings[client] = false;
		g_bBeatTheMap[client] = false;
		g_bGetClientKeys[client] = false;
		g_bUnkillable[client] = false;
		Format(g_sCaps[client], sizeof(g_sCaps), "\0");
	}
}
/*****************************************************************************************************************
												Functions
*****************************************************************************************************************/
//I SHOULD MAKE THIS DO A PAGED MENU IF IT DOESNT ALREADY IDK ANY MAPS WITH THAT MANY CPS ANYWAY
public Action cmdRaceInitialize(int client, int args) {
	if (!IsValidClient(client))
		 return Plugin_Handled;
	if (view_as<int>(TF2_GetClientTeam(client)) < 3 || !IsPlayerAlive(client)) {
		ReplyToCommand(client, "Must be alive and on a team to use this command.");
		return Plugin_Handled;
	}
	if (g_iCPs == 0) {
		PrintToChat(client, "\x01[\x03JA\x01] You may only race on maps with control points.");
		return Plugin_Handled;
	}
	if (IsPlayerFinishedRacing(client))
		LeaveRace(client);

	if (IsClientRacing(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] You are already in a race. Type /r_leave to leave.");
		return Plugin_Handled;
	}
	g_bRace[client] = client;
	g_bRaceStatus[client] = 1;
	g_bRaceClassForce[client] = true;
	char
		cpName[32]
		, buffer[32];
	Menu menu = new Menu(ControlPointSelector, MENU_ACTIONS_DEFAULT);
	menu.SetTitle("Select End Control Point");
	int entity;
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1) {
		int pIndex = GetEntProp(entity, Prop_Data, "m_iPointIndex");
		GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
		IntToString(pIndex, buffer, sizeof(buffer));
		menu.AddItem(buffer, cpName);
	}
	menu.Display(client, 300);
	return Plugin_Handled;
}

public int ControlPointSelector(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		g_bRaceEndPoint[param1] = StringToInt(info);
		cmdRaceInvite(param1, 0);
		delete menu;
	}
	else if (action == MenuAction_Cancel) {
		if (!IsClientConnected(param1)) return;
		g_bRace[param1] = 0;
		PrintToChat(param1, "\x01[\x03JA\x01] The race has been cancelled.");
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action cmdRaceInvite(int client, int args) {
	if (!IsValidClient(client))
		 return Plugin_Handled;
	if (view_as<int>(TF2_GetClientTeam(client)) < 3 || !IsPlayerAlive(client)) {
		ReplyToCommand(client, "Must be alive and on a team to use this command.");
		return Plugin_Handled;
	}
	if (!IsClientRacing(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] You have not started a race.");
		return Plugin_Handled;
	}
	if (!IsRaceLeader(client, g_bRace[client])) {
		PrintToChat(client, "\x01[\x03JA\x01] You are not the race lobby leader.");
		return Plugin_Handled;
	}
	if (HasRaceStarted(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] The race has already started.");
		return Plugin_Handled;
	}
	if (args == 0) {
		Menu g_PlayerMenu = PlayerMenu(client);
		g_PlayerMenu.Display(client, MENU_TIME_FOREVER);
	}
	else {
		char
			arg1[32]
			, clientName[128]
			, client2Name[128]
			, buffer[128];
		Panel panel;
		GetClientName(client, clientName, sizeof(clientName));
		int target;
		for (int i = 1; i < args+1; i++) {
			GetCmdArg(i, arg1, sizeof(arg1));
			target = FindTarget(client, arg1, true, false);
			GetClientName(target, client2Name, sizeof(client2Name));
			if (target != -1 && g_bRace[target] == 0 && !waitingInvite[target] && g_bRaceEndPoint[client] != -1 ) {
				PrintToChat(client, "\x01[\x03JA\x01] You have invited %s to race.", client2Name);
				Format(buffer, sizeof(buffer), "You have been invited to race to %s by %s", GetCPNameByIndex(g_bRaceEndPoint[client]), clientName);
				
				panel = new Panel();
				panel.SetTitle(buffer);
				panel.DrawItem("Accept");
				panel.DrawItem("Decline");
				g_bRaceInvitedTo[target] = client;
				panel.Send(target, InviteHandler, 15);
				
				delete panel;
			}
			if (g_bRaceEndPoint[client] == -1) {
				ReplyToCommand(client, "You must select a point first with /race before inviting others");
			}
			else if (g_bRace[target]) {
				ReplyToCommand(client, "%s is already in a race", client2Name);
			}
			else if (waitingInvite[target]) {
				ReplyToCommand(client, "%s has a pending race invite.", client2Name);
			}
		}
	}
	return Plugin_Handled;
}

char[] GetCPNameByIndex(int index) {
	int entity;
	char cpName[32];
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1) {
		if (GetEntProp(entity, Prop_Data, "m_iPointIndex") == index)
			GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
	}
	return cpName;
}

Menu PlayerMenu(int client) {
	Menu menu = new Menu(Menu_InvitePlayers, MenuAction_Select|MenuAction_End);
	char buffer[128], clientName[128];
	SetMenuExitBackButton(menu, true);	
	menu.AddItem("*[Begin Race]*","*[Begin Race]*");
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i) && client != i && !waitingInvite[i] && g_bRace[i] == 0) {
			IntToString(i, buffer, sizeof(buffer));
			GetClientName(i, clientName, sizeof(clientName));
			menu.AddItem(buffer, clientName);
		}
		menu.SetTitle("Select Players to Invite:");
	}
	return menu;
}

public int Menu_InvitePlayers(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char clientName[128], client2Name[128], buffer[128], info[32];
		GetClientName(param1, clientName, sizeof(clientName));
		menu.GetItem(param2, info, sizeof(info));
		if (StrEqual(info, "*[Begin Race]*"))
		{
			cmdRaceStart(param1, 0);
			delete menu;
			return;
		}
		GetClientName(StringToInt(info), client2Name, sizeof(client2Name));
		menu.RemoveItem(param2);
		if (waitingInvite[StringToInt(info)])
		{
			ReplyToCommand(param1, "%s has already been invited", client2Name);
			menu.DisplayAt(param1, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
			return;
		}
		PrintToChat(param1, "\x01[\x03JA\x01] You have invited %s to race.", client2Name);
		Format(buffer, sizeof(buffer), "You have been invited to race to %s by %s", GetCPNameByIndex(g_bRaceEndPoint[param1]), clientName);
		
		Panel panel = new Panel();
		panel.SetTitle(buffer);
		panel.DrawItem("Accept");
		panel.DrawItem("Decline");
		
		g_bRaceInvitedTo[StringToInt(info)] = param1;
		panel.Send(StringToInt(info), InviteHandler, 15);
		waitingInvite[StringToInt(info)] = true;
	}
	else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack){
		g_bRace[param1] = 0;
		cmdRaceInitialize(param1, 0);
		return;
	}
	else if (action == MenuAction_End)
		return;
	menu.DisplayAt(param1, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
}

public int InviteHandler(Menu menu, MenuAction action, int param1, int param2) {
	// if (action == MenuAction_Select)
	// {
		// PrintToConsole(param1, "You selected item: %d", param2);
		// g_bRaceInvitedTo[param1] = 0;
	// }
		// else if (action == MenuAction_Cancel) {
		// PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
		// g_bRaceInvitedTo[param1] = 0;
	// }
	AlertInviteAcceptOrDeny(g_bRaceInvitedTo[param1], param1, param2);
}
public void AlertInviteAcceptOrDeny(int client, int client2, int choice) {
	char clientName[128];
	GetClientName(client2, clientName, sizeof(clientName));
	if (choice == 1) {
		waitingInvite[client2] = false;
		if (HasRaceStarted(client)) {
			PrintToChat(client, "\x01[\x03JA\x01] This race has already started.");			
			return;
		}
		LeaveRace(client2);
		g_bRace[client2] = client;
		PrintToChat(client, "\x01[\x03JA\x01] %s has accepted your request to race", clientName);
	}
	else if (choice < 1)
		PrintToChat(client, "\x01[\x03JA\x01] %s failed to respond to your invitation", clientName);
	else
		PrintToChat(client, "\x01[\x03JA\x01] %s has declined your request to race", clientName);
	waitingInvite[client2] = false;
}
//THE WORST WORKAROUND YOU'VE EVER SEEN
char
	sAsterisk[] = "****************************"
	, sTab[] = "				"
	, sMessage[256];

public Action RaceCountdown(Handle timer, any raceID) {
	Format(sMessage, sizeof(sMessage), "%s\n%s  3\n%s", sAsterisk, sTab, sAsterisk);
	PrintToRace(raceID, sMessage);
	CreateTimer(1.0, RaceCountdown2, raceID);
}

public Action RaceCountdown2(Handle timer, any raceID) {
	Format(sMessage, sizeof(sMessage), "%s\n%s  2\n%s", sAsterisk, sTab, sAsterisk);
	PrintToRace(raceID, sMessage);
	CreateTimer(1.0, RaceCountdown1, raceID);
}

public Action RaceCountdown1(Handle timer, any raceID) {
	Format(sMessage, sizeof(sMessage), "%s\n%s  1\n%s", sAsterisk, sTab, sAsterisk);
	PrintToRace(raceID, sMessage);
	CreateTimer(1.0, RaceCountdownGo, raceID);
}

public Action RaceCountdownGo(Handle timer, any raceID) {
	Format(sMessage, sizeof(sMessage), "\n%s\n%sGO!\n%s", sAsterisk, sTab, sAsterisk);
	UnlockRacePlayers(raceID);
	PrintToRace(raceID, sMessage);
	sMessage = "";
	float time = GetEngineTime();
	g_bRaceStartTime[raceID] = time;
	g_bRaceStatus[raceID] = 3;
}

public Action cmdRaceList(int client, int args) {
	if (!IsValidClient(client))
		 return;
	//WILL NEED TO ADD && !ISCLINETOBSERVER(CLIENT) WHEN I ADD SPEC SUPPORT FOR THIS
	int iClientToShow, iObserverMode;
	if (!IsClientRacing(client)) {
		if (IsClientObserver(client)) {
			iObserverMode = GetEntPropEnt(client, Prop_Send, "m_iObserverMode");
			iClientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if (!IsClientRacing(iClientToShow)) {
				PrintToChat(client, "\x01[\x03JA\x01] This client is not in a race!");
				return;
			}
			if (!IsValidClient(client) || !IsValidClient(iClientToShow) || iObserverMode == 6)
				return;
		}
		else {
			PrintToChat(client, "\x01[\x03JA\x01] You are not in a race!");
			return;
		}
	}
	else
		iClientToShow = client;
	int race = g_bRace[iClientToShow];
	char
		leader[32]
		, leaderFormatted[32]
		, racerNames[32]
		, racerEntryFormatted[255]
		, racerTimes[128]
		, racerDiff[128];
	Panel panel = new Panel();
	bool space;
	
	GetClientName(g_bRace[iClientToShow], leader, sizeof(leader));
	Format(leaderFormatted, sizeof(leaderFormatted), "%s's Race", leader);
	
	panel.DrawText(leaderFormatted);
	panel.DrawText(" ");
	
	for (int i = 0; i < MAXPLAYERS; i++) {
		if (g_bRaceFinishedPlayers[race][i] == 0)
			break;
		space = true;
		GetClientName(g_bRaceFinishedPlayers[race][i], racerNames, sizeof(racerNames));
		racerTimes = TimeFormat(g_bRaceTimes[race][i] - g_bRaceStartTime[race]);
		if (g_bRaceFirstTime[race] != g_bRaceTimes[race][i])
			racerDiff = TimeFormat(g_bRaceTimes[race][i] - g_bRaceFirstTime[race]);
		else
			racerDiff = "00:00:000";
		Format(racerEntryFormatted, sizeof(racerEntryFormatted), "%d. %s - %s[-%s]", (i+1), racerNames, racerTimes, racerDiff);
		panel.DrawText(racerEntryFormatted);
	}
	if (space)
		panel.DrawText(" ");

	char name[32];
	for (int i = 0; i < MAXPLAYERS; i++) {
		if (IsClientInRace(i, race) && !IsPlayerFinishedRacing(i)) {
			GetClientName(i, name, sizeof(name));
			panel.DrawText(name);
		}
	}
	panel.DrawText(" ");
	panel.DrawItem("Exit");
	panel.Send(client, InfoHandler, 30);
	delete panel;
}

public Action cmdRaceInfo(int client, int args) {
	if (!IsValidClient(client))
		 return;
	//WILL NEED TO ADD && !ISCLINETOBSERVER(CLIENT) WHEN I ADD SPEC SUPPORT FOR THIS
	int
		iClientToShow
		, iObserverMode;
	if (!IsClientRacing(client)) {
		if (IsClientObserver(client)) {
			iObserverMode = GetEntPropEnt(client, Prop_Send, "m_iObserverMode");
			iClientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if (!IsClientRacing(iClientToShow)) {
				PrintToChat(client, "\x01[\x03JA\x01] This client is not in a race!");
				return;
			}
			if (!IsValidClient(client) || !IsValidClient(iClientToShow) || iObserverMode == 6)
				return;
		}
		else {
			PrintToChat(client, "\x01[\x03JA\x01] You are not in a race!");
			return;
		}
	}
	else
		iClientToShow = client;
	char
		leader[32]
		, leaderFormatted[64]
		, status[64]
		, ammoRegen[32]
		, classForce[32];
	GetClientName(g_bRace[iClientToShow], leader, sizeof(leader));
	Format(leaderFormatted, sizeof(leaderFormatted), "Race Host: %s", leader);

	if (GetRaceStatus(iClientToShow) == 1)
		status = "Race Status: Waiting for start";
	else if (GetRaceStatus(iClientToShow) == 2)
		status = "Race Status: Starting";
	else if (GetRaceStatus(iClientToShow) == 3)
		status = "Race Status: Racing";
	else if (GetRaceStatus(iClientToShow) == 4)
		status = "Race Status: Waiting for finshers";
	if (g_bRaceClassForce[g_bRace[iClientToShow]])
		classForce = "Class Force: Enabled";
	else
		classForce = "Class Force: Disabled";
		
	Panel panel = new Panel();
	panel.DrawText(leaderFormatted);
	panel.DrawText(status);
	panel.DrawText("---------------");
	panel.DrawText(ammoRegen);
	panel.DrawText("---------------");
	panel.DrawText(classForce);
	panel.DrawText(" ");
	panel.DrawText("Exit");
	panel.Send(client, InfoHandler, 30);
	delete panel;
}

public int InfoHandler(Menu menu, MenuAction action, int param1, int param2) {
	// if (action == MenuAction_Select)
	// {
		// PrintToConsole(param1, "You selected item: %d", param2);
		// g_bRaceInvitedTo[param1] = 0;
	// }
	// else if (action == MenuAction_Cancel) {
		// PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
		// g_bRaceInvitedTo[param1] = 0;
	// }
}

public Action cmdRaceStart(int client, int args) {
	if (!IsValidClient(client))
		 return;
	if (g_bRace[client] == 0) {
		PrintToChat(client, "\x01[\x03JA\x01] You are not hosting a race!");
		return;
	}
	if (!IsRaceLeader(client, g_bRace[client])) {
		PrintToChat(client, "\x01[\x03JA\x01] You are not the race lobby leader.");
		return;
	}
	//RIGHT HERE I SHOULD CHECK TO MAKE SURE THERE ARE TWO OR MORE PEOPLE
	if (HasRaceStarted(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] The race has already started.");
		return;
	}
	LockRacePlayers(client);
	ApplyRaceSettings(client);
	TFClassType class = TF2_GetPlayerClass(client);
	int team = GetClientTeam(client);
	g_bRaceStatus[client] = 2;
	CreateTimer(1.0, RaceCountdown, client);
	SendRaceToStart(client, class, team);
	PrintToRace(client, "Teleporting to race start!");
}

void PrintToRace(int raceID, char[] message) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInRace(i, raceID) || IsClientSpectatingRace(i, raceID))
			PrintToChat(i, message);
	}
}

void SendRaceToStart(int raceID, TFClassType class, int team) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInRace(i, raceID)) {
			if (g_bRaceClassForce[raceID])
				TF2_SetPlayerClass(i, class);
			ChangeClientTeam(i, team);
			SendToStart(i);
		}
	}
}

void LockRacePlayers(int raceID) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInRace(i, raceID))
			g_bRaceLocked[i] = true;
	}
}

void UnlockRacePlayers(int raceID) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInRace(i, raceID))
			g_bRaceLocked[i] = false;
	}
}

public Action cmdRaceLeave(int client, int args) {
	if (!IsClientRacing(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] You are not in a race.");
		return Plugin_Handled;
	}
	LeaveRace(client);
	PrintToChat(client, "\x01[\x03JA\x01] You have left the race.");
	return Plugin_Handled;
}

public Action cmdRaceInitializeServer(int client, int args) {
	if (!IsValidClient(client))
		 return Plugin_Handled;
	if (view_as<int>(TF2_GetClientTeam(client)) < 3 || !IsPlayerAlive(client)) {
		ReplyToCommand(client, "Must be alive and on a team to use this command.");
		return Plugin_Handled;
	}
	if (g_iCPs == 0) {
		PrintToChat(client, "\x01[\x03JA\x01] You may only race on maps with control points.");
		return Plugin_Handled;
	}
	if (IsPlayerFinishedRacing(client))
		LeaveRace(client);

	if (IsClientRacing(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] You are already in a race. Type /r_leave to leave.");
		return Plugin_Handled;
	}
	g_bRace[client] = client;
	g_bRaceStatus[client] = 1;
	g_bRaceClassForce[client] = true;
	char cpName[32];
	Menu menu = new Menu(ControlPointSelectorServer, MENU_ACTIONS_DEFAULT);
	menu.SetTitle("Select End Control Point");
	menu.AddItem("*[Begin Race]*","*[Begin Race]*");
	int entity;
	char buffer[32];
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1) {
		int pIndex = GetEntProp(entity, Prop_Data, "m_iPointIndex");
		GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
		IntToString(pIndex, buffer, sizeof(buffer));
		menu.AddItem(buffer, cpName);
	}
	menu.Display(client, 300);
	return Plugin_Handled;
}

public int ControlPointSelectorServer(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32]
			, buffer[128]
			, clientName[128];
		menu.GetItem(param2, info, sizeof(info));
		if (StrEqual(info, "*[Begin Race]*"))
		{
			cmdRaceStart(param1, 0);
			delete menu;
		}
		g_bRaceEndPoint[param1] = StringToInt(info);
		GetClientName(param1, clientName, sizeof(clientName));
		for (int i = 1; i <= MaxClients; i++) {
			if (IsValidClient(i) && param1 != i && !waitingInvite[i] && g_bRace[i] == 0) {
				Format(buffer, sizeof(buffer), "You have been invited to race to %s by %s", GetCPNameByIndex(g_bRaceEndPoint[param1]), clientName);
				
				Panel panel = new Panel();
				panel.SetTitle(buffer);
				panel.DrawItem("Accept");
				panel.DrawItem("Decline");
				g_bRaceInvitedTo[i] = param1;
				panel.Send(i, InviteHandler, 15);
				delete panel;
			}
		}
	}
	else if (action == MenuAction_Cancel) {
		g_bRace[param1] = 0;
		PrintToChat(param1, "\x01[\x03JA\x01] The race has been cancelled.");
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action cmdRaceSpec(int client, int args) {
	if (!IsValidClient(client))
		return Plugin_Handled;
	if (args == 0) {
		PrintToChat(client, "\x01[\x03JA\x01] No target race selected.");
		return Plugin_Handled;
	}
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	int target = FindTarget(client, arg1, true, false);
	if (target == -1)
		return Plugin_Handled;
	else {
		if (target == client) {
			PrintToChat(client, "\x01[\x03JA\x01] You may not spectate yourself.");
			return Plugin_Handled;
		}
		if (!IsClientRacing(target)) {
			PrintToChat(client, "\x01[\x03JA\x01] Target client is not in a race.");
			return Plugin_Handled;
		}
		if (IsClientObserver(target)) {
			PrintToChat(client, "\x01[\x03JA\x01] You may not spectate a spectator.");
			return Plugin_Handled;
		}
		if (IsClientRacing(client))
			LeaveRace(client);
	
		if (!IsClientObserver(client)) {
			ChangeClientTeam(client, 1);
			ForcePlayerSuicide(client);
		}
		g_bRaceSpec[client] = g_bRace[target];
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", g_bRace[target]);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
	}
	return Plugin_Continue;
}

public Action cmdRaceSet(int client, int args) {
	if (!IsValidClient(client))
		return Plugin_Handled;
	if (!IsClientRacing(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] You are not in a race.");
		return Plugin_Handled;
	}
	if (!IsRaceLeader(client, g_bRace[client])) {
		PrintToChat(client, "\x01[\x03JA\x01] You are not the leader of this race.");
		return Plugin_Handled;
	}
	if (HasRaceStarted(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] The race has already started.");
		return Plugin_Handled;
	}
	if (args != 2) {
		PrintToChat(client, "\x01[\x03JA\x01] This number of arguments is not supported.");
		return Plugin_Handled;
	}
	char
		arg1[32]
		, arg2[32];
	bool toSet;
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	PrintToServer(arg2);
	if (!(StrEqual(arg2, "on", false) || StrEqual(arg2, "off", false))) {
		PrintToChat(client, "\x01[\x03JA\x01] Your second argument is not valid.");
		return Plugin_Handled;
	}
	else {
		toSet = (StrEqual(arg2, "on", false));
	}
	if (StrEqual(arg1, "ammo", false)) {
		g_bRaceAmmoRegen[client] = toSet;
		PrintToChat(client, "\x01[\x03JA\x01] Ammo regen has been set.");
	}
	else if (StrEqual(arg1, "cf", false) || StrEqual(arg1, "classforce", false)) {
		g_bRaceClassForce[client] = toSet;
		PrintToChat(client, "\x01[\x03JA\x01] Class force has been set.");
	}
	else {
		PrintToChat(client, "\x01[\x03JA\x01] Invalid setting.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

void ApplyRaceSettings(int race) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInRace(i, race))
			g_bAmmoRegen[i] = g_bRaceAmmoRegen[g_bRace[i]];
	}
}

int GetPlayersInRace(int raceID) {
	int players;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInRace(i, raceID))
			players++;
	}
	return players;
}

int GetPlayersStillRacing(int raceID) {
	int players;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInRace(i, raceID) && !IsPlayerFinishedRacing(i))
			players++;
	}
	return players;
}

void LeaveRace(int client) {
	int race = g_bRace[client];
	if (race == 0)
		return;
	if (GetPlayersInRace(race) == 0)
		ResetRace(race);
	if (client == race) {
		if (GetPlayersInRace(race) == 1)
			ResetRace(race);
		else {
			if (HasRaceStarted(race)) {
					for (int i = 1; i <= MaxClients; i++) {
						if (IsClientInRace(i, race) && IsClientRacing(i) && !IsRaceLeader(i, race)) {
							int newRace = i, a[32];
							float b[32];
							g_bRaceStatus[i] = g_bRaceStatus[race];
							g_bRaceEndPoint[i] = g_bRaceEndPoint[race];
							g_bRaceStartTime[i] = g_bRaceStartTime[race];
							g_bRaceFirstTime[i] = g_bRaceFirstTime[race];
							g_bRaceAmmoRegen[i] = g_bRaceAmmoRegen[race];
							g_bRaceClassForce[i] = g_bRaceClassForce[race];
							g_bRaceTimes[i] = g_bRaceTimes[race];
							g_bRaceFinishedPlayers[i] = g_bRaceFinishedPlayers[race];
							g_bRace[client] = 0;
							g_bRaceTime[client] = 0.0;
							g_bRaceLocked[client] = false;
							g_bRaceFirstTime[client] = 0.0;
							g_bRaceEndPoint[client] = -1;
							g_bRaceStartTime[client] = 0.0;
							g_bRaceFinishedPlayers[client] = a;
							g_bRaceTimes[client] = b;
							for (int j = 1; j <= MaxClients; j++) {
								if (IsClientRacing(j) && !IsRaceLeader(j, race))
									g_bRace[j] = newRace;
							}
							return;
						}
					}
			}
			else {
				PrintToRace(race, "The race has been cancelled.");
				ResetRace(race);
			}
		}
	}
	else {
		g_bRace[client] = 0;
		g_bRaceTime[client] = 0.0;
		g_bRaceLocked[client] = false;
		g_bRaceFirstTime[client] = 0.0;
		g_bRaceEndPoint[client] = -1;
		g_bRaceStartTime[client] = 0.0;
	}
	char clientName[128], buffer[128];
	GetClientName(client, clientName, sizeof(clientName));
	Format(buffer, sizeof(buffer), "%s has left the race.", clientName);
	PrintToRace(race, buffer);
}

void ResetRace(int raceID) {
	for (int i = 0; i <= MaxClients; i++) {
		if (IsClientInRace(i, raceID)) {
			g_bRace[i] = 0;
			g_bRaceStatus[i] = 0;
			g_bRaceTime[i] = 0.0;
			g_bRaceLocked[i] = false;
			g_bRaceFirstTime[i] = 0.0;
			g_bRaceEndPoint[i] = -1;
			g_bRaceStartTime[i] = 0.0;
			g_bRaceAmmoRegen[i] = false;
			g_bRaceClassForce[i] = true;
		}
		g_bRaceTimes[raceID][i] = 0.0;
		g_bRaceFinishedPlayers[raceID][i] = 0;
	}
}

void EmitSoundToRace (int raceID, char[] sound) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInRace(i, raceID) || IsClientSpectatingRace(i, raceID))
			EmitSoundToClient(i, sound);
	}
}

void EmitSoundToNotRace (int raceID, char[] sound) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInRace(i, raceID) && !IsClientSpectatingRace(i, raceID) && IsValidClient(i))
			EmitSoundToClient(i, sound);
	}
}

bool IsClientRacing(int client) {
	return (g_bRace[client] != 0);
}

bool IsClientInRace(int client, int race) {
	return (g_bRace[client] == race);
}

bool IsRaceLeader(int client, int race) {
	return (client == race);
}

int GetRaceStatus(int client) {
	return g_bRaceStatus[g_bRace[client]];
}

bool HasRaceStarted(int client) {
	return (g_bRaceStatus[g_bRace[client]] > 1);
}

bool IsPlayerFinishedRacing(int client) {
	return (g_bRaceTime[client] != 0.0);
}

bool IsClientSpectatingRace(int client, int race) {
	if (!IsValidClient(client) || !IsClientObserver(client))
		return false;

	int
		iClientToShow
		, iObserverMode;
	iObserverMode = GetEntPropEnt(client, Prop_Send, "m_iObserverMode");
	iClientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	if (!IsValidClient(client) || !IsValidClient(iClientToShow) || iObserverMode == 6)
		return false;
	if (IsClientInRace(iClientToShow, race))
		return true;
	return false;
}

char[] TimeFormat(float timeTaken) {
	int
		intTimeTaken
		, seconds
		, minutes
		, hours;
	float ms;
	char
		msFormat[128]
		, msFormatFinal[128]
		, final[128]
		, secondsString[128]
		, minutesString[128]
		, hoursString[128];
	
	ms = timeTaken-RoundToZero(timeTaken);
	Format(msFormat, sizeof(msFormat), "%.3f", ms);
	strcopy(msFormatFinal, sizeof(msFormatFinal), msFormat[2]);
	
	intTimeTaken = RoundToZero(timeTaken);
	seconds = intTimeTaken % 60;
	minutes = (intTimeTaken-seconds)/60;
	hours = (intTimeTaken-seconds - minutes * 60)/60;
	secondsString = FormatTimeComponent(seconds);
	minutesString = FormatTimeComponent(minutes);
	hoursString = FormatTimeComponent(hours);
	
	if (hours != 0)
		Format(final, sizeof(final), "%s:%s:%s:%s", hoursString, minutesString, secondsString, msFormatFinal);
	else
		Format(final, sizeof(final), "%s:%s:%s", minutesString, secondsString, msFormatFinal);
	return final;
}

char[] FormatTimeComponent(int time) {
	char final[8];
	Format(final, sizeof(final), (time > 9) ? "%d" : "0%d", time);
	return final;
}

public Action cmdToggleAmmo(int client, int args) {
	if (!IsValidClient(client))
		 return;
	if (IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)) {
		ReplyToCommand(client, "\x01[\x03JA\x01] You may not change regen during a race");
		return;
	}
	SetRegen(client, "Ammo");
}

public Action cmdToggleHardcore(int client, int args) {
	if (!IsValidClient(client))
		return Plugin_Handled;
	if (IsUsingJumper(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Jumper_Command_Disabled");
		return Plugin_Handled;
	}
	Hardcore(client);
	return Plugin_Handled;
}

public Action cmdJAHelp(int client, int args) {
	if (IsUserAdmin(client)) {
		ReplyToCommand(client, "**********ADMIN COMMANDS**********\nmapset - Change map settings\naddtele - Add a teleport location\njatele - Teleport a user to a location");
	}
	Panel panel = new Panel();
	panel.SetTitle("Help Menu:");
	panel.DrawItem("Saving and Teleporting");
	panel.DrawItem("Regen");
	panel.DrawItem("Skeys");
	panel.DrawItem("Racing");
	panel.DrawItem("Miscellaneous");
	panel.DrawText(" ");
	panel.DrawItem("Exit");
	panel.Send(client, JAHelpHandler, 15);
	delete panel;
	return Plugin_Handled;
}

public int JAHelpHandler(Menu menu, MenuAction action, int param1, int param2) {
	//1 is client
	//2 is choice
	int client = param1;
	if (param2 < 1 || param2 == 6)
		return;
	Panel panel = new Panel();
	if (param2 == 1) {
		panel.SetTitle("Save Help");
		panel.DrawText("!save or !s - Saves your position\n!tele or !t - Teleports you to your saved position\n!undo - Reverts your last save\n!reset or !r - Restarts you on the map\n!restart - Deletes your save and restarts you");
	}
	else if (param2 == 2) {
		panel.SetTitle("Regen Help");
		panel.DrawText("!ammo - Toggles ammo regen");
	}
	else if (param2 == 3) {
		panel.SetTitle("Skeys Help");
		panel.DrawText("!skeys - Shows key presses on the screen\n!skeys_color <R> <G> <B> - Skeys color\n!skeys_loc <X> <Y> - Sets skeys location with x and y values from 0 to 1");
	}
	else if (param2 == 4) {
		panel.SetTitle("Racing Help");
		panel.DrawText("!race - Initialize a race and select final CP.\n!r_info - Provides info about the current race.\n!r_inv - Invite players to the race.\n!r_set - Change settings of a race.");
		panel.DrawText("	   <classforce|cf|ammo");
		panel.DrawText("	   <on|off>");
		panel.DrawText("!r_list - Lists race players and their times");
		panel.DrawText("!r_spec - Spectates a race.");
		panel.DrawText("!r_start - Start the race.");
		panel.DrawText("!r_leave - Leave a race.");
	}
	else if (param2 == 5) {
		panel.DrawText("!jumpassist - Shows the JumpAssist forum page.");
		panel.DrawText("!jumptf - Shows the Jump.tf website.");
		panel.DrawText("!forums - Shows the Jump.tf forums.");
	}
	panel.DrawText(" ");
	panel.DrawItem("Back");
	panel.DrawItem("Exit");
	panel.Send(client, HelpMenuHandler, 15);
	CloseHandle(panel);
}

public int HelpMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (param2 == 1)
		cmdJAHelp(param1, 0);
}

bool IsUsingJumper(int client) {
	if (!IsValidClient(client))
		 return false;
	if (TF2_GetPlayerClass(client) == TFClass_Soldier) {
		if (!IsValidWeapon(g_iClientWeapons[client][0]))
			 return false;
		int sol_weap = GetEntProp(g_iClientWeapons[client][0], Prop_Send, "m_iItemDefinitionIndex");
		switch (sol_weap) {
			case 237:
				return true;
		}
		return false;
	}
	if (TF2_GetPlayerClass(client) == TFClass_DemoMan) {
		if (!IsValidWeapon(g_iClientWeapons[client][1]))
			 return false;
		int dem_weap = GetEntProp(g_iClientWeapons[client][1], Prop_Send, "m_iItemDefinitionIndex");
		switch (dem_weap) {
			case 265:
				return true;
		}
		return false;
	}
	return false;
}

void CheckBeggers(int client) {
	int iWeapon = GetPlayerWeaponSlot(client, 0);
	int index = FindValueInArray(hArray_NoFuncRegen, client);
	if (IsValidEntity(iWeapon) &&
	GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex") == 730) {
		if (index == -1) {
			PushArrayCell(hArray_NoFuncRegen, client);
#if defined DEBUG
			LogMessage("Preventing player %d from touching func_regenerate");
#endif
		}
	}
	else if (index != -1) {
	RemoveFromArray(hArray_NoFuncRegen, index);
#if defined DEBUG
		LogMessage("Allowing player %d to touch func_regenerate");
#endif
	}
}

int IsStringNumeric(const char[] MyString) {
	int n = 0;
	while (MyString[n] != '\0') {
		if (!IsCharNumeric(MyString[n]))
			return false;
		n++;
	}
	return true;
}

public Action RunQuery(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\x01[\x03JA\x01] More parameters are required for this command.");
		return Plugin_Handled;
	}
	char query[1024];
	GetCmdArgString(query, sizeof(query));
	SQL_TQuery(g_hDatabase, SQL_OnPlayerRanSQL, query, client);
	return Plugin_Handled;
}

public Action cmdUnkillable(int client, int args) {
	if (!g_hPluginEnabled.BoolValue)
		 return Plugin_Handled;
	if (!g_hSuperman.BoolValue && !IsUserAdmin(client)) {
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Command_Locked");
		return Plugin_Handled;
	}
	if (!g_bUnkillable[client]) {
		SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_UnkillableOn");
		g_bUnkillable[client] = true;
	}
	else {
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_UnkillableOff");
		g_bUnkillable[client] = false;
	}
	return Plugin_Handled;
}

public Action cmdUndo(int client, int args) {
	if (g_fLastSavePos[client][0] == 0.0) {
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Save_UndoCant");
		return Plugin_Handled;
	}
	else {
		g_fOrigin[client][0] = g_fLastSavePos[client][0];
		g_fAngles[client][0] = g_fLastSaveAngles[client][0];
		g_fOrigin[client][1] = g_fLastSavePos[client][1];
		g_fAngles[client][1] = g_fLastSaveAngles[client][1];
		g_fOrigin[client][2] = g_fLastSavePos[client][2];
		g_fAngles[client][2] = g_fLastSaveAngles[client][2];
		g_fLastSavePos[client][0] = 0.0;
		g_fLastSavePos[client][1] = 0.0;
		g_fLastSavePos[client][2] = 0.0;
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Save_Undo");
		return Plugin_Handled;
	}
}

public Action cmdSendPlayer(int client,int args) {
	if (!databaseConfigured) {
		PrintToChat(client, "This feature is not supported without a database configuration");
		return Plugin_Handled;
	}
	if (g_hPluginEnabled.BoolValue) {
		if (args < 2) {
			ReplyToCommand(client, "\x01[\x03JA\x01] %t", "SendPlayer_Help", LANG_SERVER);
			return Plugin_Handled;
		}
		char arg1[MAX_NAME_LENGTH];
		char arg2[MAX_NAME_LENGTH];
		GetCmdArg(1, arg1, sizeof(arg1));
		GetCmdArg(2, arg2, sizeof(arg2));
		int target1 = FindTarget2(client, arg1, true, false);
		int target2 = FindTarget2(client, arg2, true, false);
		if (target1 < 0 || target2 < 0)
			return Plugin_Handled;
		if (target1 == client) {
			ReplyToCommand(client, "\x01[\x03JA\x01] %t", "SendPlayer_Self", cLightGreen, cDefault);
			return Plugin_Handled;
		}
		if (!target1 || !target2)
			return Plugin_Handled;
		float TargetOrigin[3];
		float pAngle[3];
		float pVec[3];
		GetClientAbsOrigin(target2, TargetOrigin);
		GetClientAbsAngles(target2, pAngle);
		pVec[0] = 0.0;
		pVec[1] = 0.0;
		pVec[2] = 0.0;
		TeleportEntity(target1, TargetOrigin, pAngle, pVec);
		char target1_name[MAX_NAME_LENGTH];
		char target2_name[MAX_NAME_LENGTH];
		GetClientName(target1, target1_name, sizeof(target1_name));
		GetClientName(target2, target2_name, sizeof(target2_name));
		ShowActivity2(client, "\x01[\x03JA\x01] ", "%t", "Send_Player", target1_name, target2_name);
	}
	return Plugin_Handled;
}

public Action cmdReset(int client, int args) {
	if (g_hPluginEnabled.BoolValue) {
		if (IsClientObserver(client))
			return Plugin_Handled;
		g_iLastTeleport[client] = 0;
		SendToStart(client);
		g_bUsedReset[client] = true;
	}
	return Plugin_Handled;
}

public Action cmdTele(int client, int args) {
	if (!g_hPluginEnabled.BoolValue)
		 return Plugin_Handled;
	Teleport(client);
	g_iLastTeleport[client] = RoundFloat(GetEngineTime());
	return Plugin_Handled;
}

public Action cmdSave(int client, int args) {
	if (!g_hPluginEnabled.BoolValue)
		 return Plugin_Handled;
	SaveLoc(client);
	return Plugin_Handled;
}

void Teleport(int client) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	if (!IsValidClient(client))
		 return;
	if (g_bRace[client] && (g_bRaceStatus[g_bRace[client]] == 2 || g_bRaceStatus[g_bRace[client]] == 3) ) {
		PrintToChat(client, "\x01[\x03JA\x01] Cannot teleport while racing.");
		return;
	}
	int g_iClass = view_as<int>(TF2_GetPlayerClass(client)), g_iTeam = GetClientTeam(client);
	char g_sClass[32], g_sTeam[32];
	float g_vVelocity[3];
	g_vVelocity[0] = 0.0;
	g_vVelocity[1] = 0.0;
	g_vVelocity[2] = 0.0;
	Format(g_sClass, sizeof(g_sClass), "%s", GetClassname(g_iClass));
	if (g_iTeam == 2)
		Format(g_sTeam, sizeof(g_sTeam), "%T", "Red_Team", LANG_SERVER);
	else if (g_iTeam == 3)
		Format(g_sTeam, sizeof(g_sTeam), "%T", "Blu_Team", LANG_SERVER);
	if (g_bHardcore[client])
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Teleports_Disabled");
	else if (!IsPlayerAlive(client))
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Teleport_Dead");
	else if (g_fOrigin[client][0] == 0.0)
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Teleport_NoSave", g_sClass, g_sTeam, cLightGreen, cDefault, cLightGreen, cDefault);
	else {
		TeleportEntity(client, g_fOrigin[client], g_fAngles[client], g_vVelocity);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Teleport_Self");
	}
}

void SaveLoc(int client) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	if (g_bHardcore[client])
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_Disabled");
	else if (!IsPlayerAlive(client))
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_Dead");
	else if (!(GetEntityFlags(client) & FL_ONGROUND))
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_InAir");
	else if (GetEntProp(client, Prop_Send, "m_bDucked") == 1)
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_Ducked");
	else {
		g_fLastSavePos[client][0] = g_fOrigin[client][0];
		g_fLastSaveAngles[client][0] = g_fAngles[client][0];
		g_fLastSavePos[client][1] = g_fOrigin[client][1];
		g_fLastSaveAngles[client][1] = g_fAngles[client][1];
		g_fLastSavePos[client][2] = g_fOrigin[client][2];
		g_fLastSaveAngles[client][2] = g_fAngles[client][2];
		GetClientAbsOrigin(client, g_fOrigin[client]);
		GetClientAbsAngles(client, g_fAngles[client]);
		if (databaseConfigured)
			GetPlayerData(client);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_Location");
	}
}

void ResetPlayerPos(int client) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	if (!IsClientInGame(client) || IsClientObserver(client))
		return;
	DeletePlayerData(client);
	return;
}

void Hardcore(int client) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	if (!IsClientInGame(client))
		return;
	else if (IsClientObserver(client))
		return;

	if (!g_bHardcore[client]) {
		g_bHardcore[client] = true;
		g_bAmmoRegen[client] = false;
		EraseLocs(client);
		TF2_RespawnPlayer(client);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Hardcore_On", cLightGreen, cDefault);
	}
	else {
		g_bHardcore[client] = false;
		LoadPlayerData(client);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Hardcore_Off");
	}
}

void SetRegen(int client, char[] RegenType) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	if (StrEqual(RegenType, "Ammo", false)) {
		if (g_bHardcore[client])
			 g_bHardcore[client] = false;
		if (!g_bAmmoRegen[client]) {
			g_bAmmoRegen[client] = true;
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_AmmoOnlyOn");
			return;
		}
		else {
			g_bAmmoRegen[client] = false;
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_AmmoOnlyOff");
			return;
		}
	}
	else
		LogError("Unknown regen settings.");
	return;
}

public Action cmdJumpTF(int client, int args) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	ShowMOTDPanel(client, "Jump Assist Help", szWebsite, MOTDPANEL_TYPE_URL);
	return;
}

public Action cmdJumpAssist(int client, int args) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	ShowMOTDPanel(client, "Jump Assist Help", szJumpAssist, MOTDPANEL_TYPE_URL);
	return;
}

public Action cmdJumpForums(int client, int args) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	ShowMOTDPanel(client, "Jump Assist Help", szForum, MOTDPANEL_TYPE_URL);
	return;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
	if (!IsValidClient(client))
		return Plugin_Continue;
	g_iButtons[client] = buttons; //FOR SKEYS AS WELL AS REGEN
	int iMaxHealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	if (GetClientHealth(client) < iMaxHealth) {
		SetEntityHealth(client, iMaxHealth);
		return Plugin_Changed;
	}
	if ((g_iButtons[client] & IN_ATTACK) == IN_ATTACK || IN_ATTACK2) {
		if (g_bAmmoRegen[client] || TF2_GetPlayerClass(client) == TFClass_Engineer) {
			ReSupply(client, g_iClientWeapons[client][0]);
			ReSupply(client, g_iClientWeapons[client][1]);
			ReSupply(client, g_iClientWeapons[client][2]);
		}
	}
	if (g_bRaceLocked[client]) {
		buttons &= ~IN_ATTACK;
		buttons &= ~IN_ATTACK2;
		if (buttons & IN_BACK)
			return Plugin_Handled;
		if (buttons & IN_FORWARD)
			return Plugin_Handled;
		if (buttons & IN_MOVERIGHT)
			return Plugin_Handled;
		if (buttons & IN_MOVELEFT)
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void SDKHook_OnWeaponEquipPost(int client, int weapon) {
	if (IsValidClient(client)) {
		g_iClientWeapons[client][0] = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		g_iClientWeapons[client][1] = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		g_iClientWeapons[client][2] = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	}
}

bool IsValidWeapon(int entity) {
	char strClassname[128];
	if (IsValidEntity(entity) && GetEntityClassname(entity, strClassname, sizeof(strClassname)) && StrContains(strClassname, "tf_weapon", false) != -1) return true;
	return false;
}

void ReSupply(int client, int weapon) {
	if (!g_hPluginEnabled.BoolValue) return;
	if (!IsValidWeapon(weapon)) return;
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return;	//Check if the client is valid and alive

	int iWepIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");	//Grab the weapon index
	char szClassname[128];
	GetEntityClassname(weapon, szClassname, sizeof(szClassname));				//Grab the weapon's classname

	//Rocket Launchers
	if (!StrContains(szClassname, "tf_weapon_rocketlauncher") || !StrContains(szClassname, "tf_weapon_particle_cannon")) { //Check for Rocket Launchers
		switch (iWepIndex) {
			case 441: //The Cow Mangler 5000
				SetEntPropFloat(weapon, Prop_Send, "m_flEnergy", 100.0);	//Cow Mangler uses Energy instead of ammo.
			case 228, 1085:  //Black Box
				SetEntProp(weapon, Prop_Send, "m_iClip1", 3);
			case 414:  //Liberty Launcher
				SetEntProp(weapon, Prop_Send, "m_iClip1", 5);
			case 730: {} //Beggar's Bazooka - This is here so we don't keep refilling its clip infinitely.
			default: //The default action for Rocket Launchers. This basically future proofs it for any new Rocket Launchers unless they have a totally different classname like the CM5K. {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4); //Technically we don't need to make extra cases for different clip sizes, since players are constantly ReSupply()'d, but whatever.
		}
		GivePlayerAmmo(client, 100, view_as<int>(TFWeaponSlot_Primary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	//Grenade Launchers
	if (!StrContains(szClassname, "tf_weapon_grenadelauncher") || !StrContains(szClassname, "tf_weapon_cannon")) { //Check for Stickybomb Launchers
		switch (iWepIndex) {
			case 308:  // Loch-n-Load
				SetEntProp(weapon, Prop_Send, "m_iClip1", 3);
			default:  //The default action for Grenade Launchers
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
		}
		GivePlayerAmmo(client, 100, view_as<int>(TFWeaponSlot_Primary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	//MiniGuns
	if (!StrContains(szClassname, "tf_weapon_minigun")) { //Check for Minigun
		switch(iWepIndex) {
			default:
				SetAmmo(client, weapon, 200);
		}
	}
	//Stickybomb Launchers
	if (!StrContains(szClassname, "tf_weapon_pipebomblauncher")) { //Check for Stickybomb Launchers
		switch (iWepIndex) {
			case 1150:  //Quickiebomb Launcher
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
			default:  //The default action for Stickybomb Launchers
				SetEntProp(weapon, Prop_Send, "m_iClip1", 8);
		}
		GivePlayerAmmo(client, 100, view_as<int>(TFWeaponSlot_Secondary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	//Shotguns
	if (!StrContains(szClassname, "tf_weapon_shotgun") || !StrContains(szClassname, "tf_weapon_sentry_revenge")) { //Check for Shotguns
		switch (iWepIndex) {
			case 415: // Reserve Shooter
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
			case 425:  //Family Business
				SetEntProp(weapon, Prop_Send, "m_iClip1", 8);
			case 997: { //Rescue Ranger, 
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
				SetEntProp(client, Prop_Data, "m_iAmmo", 200, _, 3);
			}
			case 141, 1004:  //Frontier Justice
				SetEntProp(weapon, Prop_Send, "m_iClip1", 3);
			case 527: { //Widowmaker
				SetEntProp(client, Prop_Data, "m_iAmmo", 200, _, 3); //Sets Metal count to 200
			}
			default:  //The default action for Shotguns
				SetEntProp(weapon, Prop_Send, "m_iClip1", 6);
		}
		if (TF2_GetPlayerClass(client) == TFClass_Engineer)
			GivePlayerAmmo(client, 100, view_as<int>(TFWeaponSlot_Primary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
		else
			GivePlayerAmmo(client, 100, view_as<int>(TFWeaponSlot_Secondary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	//FlameThrower
	if (!StrContains(szClassname, "tf_weapon_flamethrower")) { //Check for FlameThrowers
		switch (iWepIndex) {
			default:  //The default action for FlameThrowers
				SetAmmo(client, weapon, 200);
		}
	}
	if (!StrContains(szClassname, "tf_weapon_flaregun")) { // Check for Flare Guns
		switch (iWepIndex) {
			default:
				SetAmmo(client, weapon, 16);
		}
	}
	//ScatterGuns
	if (!StrContains(szClassname, "tf_weapon_scattergun")) { //Check for Scatter Guns
		switch (iWepIndex) {
			case 45, 448:
				  //Force-A-Nature, Soda Popper
				SetEntProp(weapon, Prop_Send, "m_iClip1", 2);
			case 220, 772, 1103:
				  //Shortstop, Babyface, BackScatter
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
			default:  //The default action for Scatter Guns
				SetEntProp(weapon, Prop_Send, "m_iClip1", 6);
		}
		GivePlayerAmmo(client, 100, view_as<int>(TFWeaponSlot_Primary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	// Ullapool caber
	if (!StrContains(szClassname, "tf_weapon_stickbomb")) {
		SetEntProp(weapon, Prop_Send, "m_bBroken", 0);
		SetEntProp(weapon, Prop_Send, "m_iDetonated", 0);
	}
}

void SetAmmo(int client, int weapon, int ammo) {
	int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammoType != -1) SetEntProp(client, Prop_Data, "m_iAmmo", ammo, _, ammoType);
}

void EraseLocs(int client) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	g_fOrigin[client][0] = 0.0;
	g_fOrigin[client][1] = 0.0;
	g_fOrigin[client][2] = 0.0;
	g_fAngles[client][0] = 0.0;
	g_fAngles[client][1] = 0.0;
	g_fAngles[client][2] = 0.0;
	for (int j = 0; j < 8; j++) {
		g_bCPTouched[client][j] = false;
		g_iCPsTouched[client] = 0;
	}
	g_bBeatTheMap[client] = false;
	Format(g_sCaps[client], sizeof(g_sCaps), "\0");
}

void CheckTeams() {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	int maxplayers = MaxClients;
	for (int i = 1; i <= maxplayers; i++) {
		if (!IsClientInGame(i) || IsClientObserver(i))
			continue;
		else if (GetClientTeam(i) == g_iForceTeam)
			continue;
		else {
			ChangeClientTeam(i, g_iForceTeam);
			PrintToChat(i, "\x01[\x03JA\x01] %t", "Switched_Teams");
		}
	}
}

void LockCPs() {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	int iCP = -1;
	g_iCPs = 0;
	while ((iCP = FindEntityByClassname(iCP, "trigger_capture_area")) != -1) {
		SetVariantString("2 0");
		AcceptEntityInput(iCP, "SetTeamCanCap");
		SetVariantString("3 0");
		AcceptEntityInput(iCP, "SetTeamCanCap");
		g_iCPs++;
	}
}

public Action cmdRestart(int client, int args) {
	if (!IsValidClient(client) || IsClientObserver(client) || !g_hPluginEnabled.BoolValue)
		return Plugin_Handled;
	EraseLocs(client);
	if (databaseConfigured)
		ResetPlayerPos(client);

	TF2_RespawnPlayer(client);
	PrintToChat(client, "\x01[\x03JA\x01] %t", "Player_Restarted");
	g_iLastTeleport[client] = 0;
	return Plugin_Handled;
}

void SendToStart(int client) {
	if (!IsValidClient(client) || IsClientObserver(client) || !g_hPluginEnabled.BoolValue)
		return;
	g_bUsedReset[client] = true;
	TF2_RespawnPlayer(client);
	PrintToChat(client, "\x01[\x03JA\x01] %t", "Player_SentToStart");
}

char[] GetClassname(int class) {
	char buffer[128];
	switch(class) {
		case 1:
			 Format(buffer, sizeof(buffer), "%T", "Class_Scout", LANG_SERVER);
		case 2:
			 Format(buffer, sizeof(buffer), "%T", "Class_Sniper", LANG_SERVER);
		case 3:
			 Format(buffer, sizeof(buffer), "%T", "Class_Soldier", LANG_SERVER);
		case 4:
			 Format(buffer, sizeof(buffer), "%T", "Class_Demoman", LANG_SERVER);
		case 5:
			 Format(buffer, sizeof(buffer), "%T", "Class_Medic", LANG_SERVER);
		case 6:
			 Format(buffer, sizeof(buffer), "%T", "Class_Heavy", LANG_SERVER);
		case 7:
			 Format(buffer, sizeof(buffer), "%T", "Class_Pyro", LANG_SERVER);
		case 8:
			 Format(buffer, sizeof(buffer), "%T", "Class_Spy", LANG_SERVER);
		case 9:
			 Format(buffer, sizeof(buffer), "%T", "Class_Engineer", LANG_SERVER);
	}
	return buffer;
}

bool IsValidClient(int client) {
	if (!(1 <= client <= MaxClients ) || !IsClientInGame(client) || IsFakeClient(client))
		return false;
	return true;
}

int FindTarget2(int client, const char[] target, bool nobots = false, bool immunity = true) {
	char target_name[MAX_TARGET_LENGTH];
	int
		target_list[1]
		, target_count
		, flags = COMMAND_FILTER_NO_MULTI;
	bool tn_is_ml;
	if (nobots)
		flags |= COMMAND_FILTER_NO_BOTS;
	if (!immunity)
		flags |= COMMAND_FILTER_NO_IMMUNITY;
	if ((target_count = ProcessTargetString(target, client, target_list, 1, flags, target_name, sizeof(target_name), tn_is_ml)) > 0)
		return target_list[0];
	else {
		if (target_count == 0)
			 return -1;
		ReplyToCommand(client, "\x01[\x03JA\x01] %t", "No matching client");
		return -1;
	}
}

bool IsUserAdmin(int client) {
	return GetAdminFlag(GetUserAdmin(client), Admin_Generic);
}

void SetCvarValues() {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	if (!g_hCriticals.BoolValue)
		SetConVarInt(FindConVar("tf_weapon_criticals"), 0, true, false);
	if (g_hAmmoCheat.BoolValue)
		SetConVarInt(FindConVar("tf_sentrygun_ammocheat"), 1, false, false);
}
/*****************************************************************************************************************
													Natives
*****************************************************************************************************************/
public int Native_JA_GetSettings(Handle plugin, int numParams) {
	int
		setting = GetNativeCell(1)
		, client = GetNativeCell(2);
	if (client != -1) {
		// Client is only needed for all but 1 setting so far.
		if (client < 1 || client > MaxClients)
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
		if (!IsClientConnected(client))
			return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}
	switch (setting) {
		case 1:
			 return g_iMapClass;
		case 2:
			 return g_bAmmoRegen[client];
	}
	return ThrowNativeError(SP_ERROR_NATIVE, "Invalid setting param.");
}

public int Native_JA_ClearSave(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	EraseLocs(client);
	PrintToChat(client, "\x01[\x03JA\x01] %t", "Native_ClearSave");
	return true;
}

public int Native_JA_ReloadPlayerSettings(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if (databaseConfigured)
		ReloadPlayerData(client);
	return true;
}
/*****************************************************************************************************************
												Player Events
*****************************************************************************************************************/
public Action OnPlayerStartTouchFuncRegenerate(int entity, int other) {
	if (other <= MaxClients && GetArraySize(hArray_NoFuncRegen) > 0 && FindValueInArray(hArray_NoFuncRegen, other) != -1) {
#if defined DEBUG_FUNC_REGEN
		LogMessage("Entity %d touch %d Prevented", entity, other);
#endif
		return Plugin_Handled;
	}
#if defined DEBUG_FUNC_REGEN
	LogMessage("Entity %d touch %d Allowed", entity, other);
#endif
	return Plugin_Continue;
}

public Action eventRoundStart(Handle event, const char[] name, bool dontBroadcast) {
	char currentMap[32];
	GetCurrentMap(currentMap, sizeof(currentMap));
	if (!g_hPluginEnabled.BoolValue)
		 return;
	if (g_iLockCPs == 1)
		 LockCPs();
	Hook_Func_regenerate();
	SetCvarValues();
}

public Action eventTouchCP(Event event, const char[] name, bool dontBroadcast) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	int client = GetEventInt(event, "player"), area = GetEventInt(event, "area"), class = view_as<int>(TF2_GetPlayerClass(client)), entity;
	char g_sClass[33], playerName[64], cpName[32], s_area[32];

	if (!g_bCPTouched[client][area] || g_bRace[client] != 0) {
		Format(g_sClass, sizeof(g_sClass), "%s", GetClassname(class));
		GetClientName(client, playerName, 64);
		while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1) {
			int pIndex = GetEntProp(entity, Prop_Data, "m_iPointIndex");
			if (pIndex == area) {
				bool raceComplete;
				if (g_bRaceEndPoint[g_bRace[client]] == pIndex && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)) {
					raceComplete = true;
					float
						time
						, timeTaken;
					char
						timeString[255]
						, clientName[128]
						, buffer[128];
					time = GetEngineTime();
					g_bRaceTime[client] = time;
					timeTaken = time - g_bRaceStartTime[g_bRace[client]];
					timeString = TimeFormat(timeTaken);
					GetClientName(client, clientName, sizeof(clientName));
					if (RoundToNearest(g_bRaceFirstTime[g_bRace[client]]) == 0) {
						Format(buffer, sizeof(buffer), "%s won the race in %s!", clientName, timeString);
						g_bRaceFirstTime[g_bRace[client]] = time;
						g_bRaceStatus[g_bRace[client]] = 4;
						for (int i = 0; i < MAXPLAYERS; i++) {
							if (g_bRaceFinishedPlayers[g_bRace[client]][i] == 0) {
								g_bRaceFinishedPlayers[g_bRace[client]][i] = client;
								g_bRaceTimes[g_bRace[client]][i] = time;
								break;
							}
						}
						EmitSoundToRace(client, "misc/killstreak.wav");
					}
					else {
						float firstTime, diff;
						char diffFormatted[255];
						firstTime = g_bRaceFirstTime[g_bRace[client]];
						diff = time - firstTime;
						diffFormatted = TimeFormat(diff);
						for (int i = 0; i < MAXPLAYERS; i++) {
							if (g_bRaceFinishedPlayers[g_bRace[client]][i] == 0) {
								g_bRaceFinishedPlayers[g_bRace[client]][i] = client;
								g_bRaceTimes[g_bRace[client]][i] = time;
								break;
							}
						}
						Format(buffer, sizeof(buffer), "%s finished the race in %s[-%s]!", clientName, timeString, diffFormatted);
						EmitSoundToRace(client, "misc/freeze_cam.wav");
					}
					if (RoundToZero(g_bRaceFirstTime[g_bRace[client]]) == 0)
						g_bRaceFirstTime[g_bRace[client]] = time;
					PrintToRace(g_bRace[client], buffer);
					if (GetPlayersStillRacing(g_bRace[client]) == 0) {
						PrintToRace(g_bRace[client], "Everyone has finished the race.");
						PrintToRace(g_bRace[client], "\x01Type \x03!r_list\x01 to see all times.");
						g_bRaceStatus[g_bRace[client]] = 5;
					}
				}
				if (!g_bCPTouched[client][area] && ((RoundFloat(GetEngineTime()) - g_iLastTeleport[client]) > 10)) {
					GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
					if (g_bHardcore[client]) {
						CPrintToChatAll("{DEFAULT}[{LIGHTGREEN}JA{DEFAULT}] [{ORANGERED}Hardcore{DEFAULT}] {LIGHTGREEN}%s{DEFAULT} has reached {LIGHTGREEN}%s{DEFAULT} as {LIGHTGREEN}%s{DEFAULT}.", playerName, cpName, g_sClass);
						if (raceComplete)
							EmitSoundToNotRace(client, "misc/freeze_cam.wav");
						else
							EmitSoundToAll("misc/freeze_cam.wav");
					}
					else {
						// Normal mode
						PrintToChatAll("\x01[\x03JA\x01] %t", "Player_Capped", playerName, cpName, g_sClass, cLightGreen, cDefault, cLightGreen, cDefault, cLightGreen, cDefault);
						if (raceComplete)
							EmitSoundToNotRace(client, "misc/freeze_cam.wav");
						else
							EmitSoundToAll("misc/freeze_cam.wav");
					}
					if (g_iCPsTouched[client] == g_iCPs) {
						g_bBeatTheMap[client] = true;
						//PrintToChat(client, "\x01[\x03JA\x01] %t", "Goto_Avail");
					}
				}
			}
			//SaveCapData(client);
		}
		g_bCPTouched[client][area] = true;
		g_iCPsTouched[client]++;
		IntToString(area, s_area, sizeof(s_area));
		if (g_sCaps[client] != -1)
			 Format(g_sCaps[client], sizeof(g_sCaps), "%s%s", g_sCaps[client], s_area);
		else
			Format(g_sCaps[client], sizeof(g_sCaps), "%s", s_area);
	}
}

public Action eventPlayerChangeClass(Event event, const char[] name, bool dontBroadcast) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client) && g_bRaceClassForce[g_bRace[client]]) {
		TFClassType oldclass = TF2_GetPlayerClass(client);
		TF2_SetPlayerClass(client, oldclass);
		PrintToChat(client, "\x01[\x03JA\x01] Cannot change class while racing.");
		return;
	}
	char g_sClass[MAX_NAME_LENGTH], steamid[32];
	EraseLocs(client);
	TF2_RespawnPlayer(client);
	g_bUnkillable[client] = false;
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	int class = view_as<int>(TF2_GetPlayerClass(client));
	Format(g_sClass, sizeof(g_sClass), "%s", GetClassname(g_iMapClass));
	
	g_fLastSavePos[client][0] = 0.0;
	g_fLastSavePos[client][1] = 0.0;
	g_fLastSavePos[client][2] = 0.0;
	g_iClientWeapons[client][0] = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	g_iClientWeapons[client][1] = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	g_iClientWeapons[client][2] = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	
	if (g_iMapClass != -1 && class != g_iMapClass) {
		g_bAmmoRegen[client] = true;
		g_bHardcore[client] = false;
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Designed_For", cLightGreen, g_sClass, cDefault);
	}
}

public Action eventPlayerChangeTeam(Event event, const char[] name, bool dontBroadcast) {
	if (!g_hPluginEnabled.BoolValue)
		 return Plugin_Handled;
	int client = GetClientOfUserId(GetEventInt(event, "userid")), team = GetEventInt(event, "team");
	if (g_bRace[client] && (g_bRaceStatus[g_bRace[client]] == 2 || g_bRaceStatus[g_bRace[client]] == 3)) {
		PrintToChat(client, "\x01[\x03JA\x01] You may not change teams during the race.");
		return Plugin_Handled;
	}
	g_bUnkillable[client] = false;
	if (team == 1 || g_iForceTeam == 1 || team == g_iForceTeam) {
		g_fOrigin[client][0] = 0.0;
		g_fOrigin[client][1] = 0.0;
		g_fOrigin[client][2] = 0.0;
		g_fAngles[client][0] = 0.0;
		g_fAngles[client][1] = 0.0;
		g_fAngles[client][2] = 0.0;
	}
	else
		CreateTimer(0.1, timerTeam, client);
	g_fLastSavePos[client][0] = 0.0;
	g_fLastSavePos[client][1] = 0.0;
	g_fLastSavePos[client][2] = 0.0;
	return Plugin_Handled;
}

public void eventInventoryUpdate(Event event, char[] strName, bool bDontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client)) return;
	CheckBeggers(client);
}

public Action eventPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, timerRespawn, client);
}

public Action eventPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	if (!g_hPluginEnabled.BoolValue)
		 return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	// Check if they have the jumper equipped, and hardcore is on for some reason.
	if (IsUsingJumper(client) && g_bHardcore[client])
		g_bHardcore[client] = false;
	// Disable func_regenerate if player is using beggers bazooka
	CheckBeggers(client);
	if (g_bUsedReset[client]) {
		if (databaseConfigured)
			ReloadPlayerData(client);

		g_bUsedReset[client] = false;
		return;
	}
	if (databaseConfigured)
		LoadPlayerData(client);

	g_bRaceSpec[client] = 0;
}
/*****************************************************************************************************************
												Timers
*****************************************************************************************************************/
public Action timerTeam(Handle timer, any client) {
	if (client == 0)
		return;
	EraseLocs(client);
	if (IsClientInGame(client))
		ChangeClientTeam(client, g_iForceTeam);
}

public Action timerRespawn(Handle timer, any client) {
	if (IsValidClient(client))
		TF2_RespawnPlayer(client);
}

public Action WelcomePlayer(Handle timer, any client) {
	char sHostname[64];
	g_hHostname.GetString(sHostname, sizeof(sHostname));
	if (!IsClientInGame(client))
		return;
	CPrintToChat(client, "{LIGHTGREEN}----------------------------------------------------------------");
	CPrintToChat(client, "{DEFAULT}[{LIGHTGREEN}+{DEFAULT}] Welcome to {ZPURPLE}%s{DEFAULT}", sHostname);
	CPrintToChat(client, "{DEFAULT}[{LIGHTGREEN}+{DEFAULT}] For help with [{LIGHTGREEN}TF2{DEFAULT}] {LIGHTGREEN}JumpAssist{DEFAULT}, type {ORANGE}!ja_help{DEFAULT}");
	CPrintToChat(client, "{DEFAULT}[{LIGHTGREEN}+{DEFAULT}] For server information, type {ORANGE}!help{DEFAULT}");
	CPrintToChat(client, "{DEFAULT}[{LIGHTGREEN}+{DEFAULT}] {LightGreen}Be nice to fellow jumpers");
	CPrintToChat(client, "{DEFAULT}[{LIGHTGREEN}+{DEFAULT}] {LightGreen}No trade chat");
	CPrintToChat(client, "{DEFAULT}[{LIGHTGREEN}+{DEFAULT}] {LightGreen}No complaining");
	CPrintToChat(client, "{DEFAULT}[{LIGHTGREEN}+{DEFAULT}] {LightGreen}No chat/voice spam");
	CPrintToChat(client, "{LIGHTGREEN}----------------------------------------------------------------");
}
/*****************************************************************************************************************
											ConVars Hooks
*****************************************************************************************************************/
public void cvarAmmoCheatChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	SetConVarInt(FindConVar("tf_sentrygun_ammocheat"), (StringToInt(newValue) == 0) ? 0 : 1);
}

public void cvarWelcomeMsgChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	SetConVarBool(g_hWelcomeMsg, (StringToInt(newValue) == 0) ? false : true);
}

public void cvarSupermanChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	SetConVarBool(g_hSuperman, (StringToInt(newValue) == 0) ? false : true);
}