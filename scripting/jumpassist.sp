/*
	NOTES:
 
	You must have a mysql or sqlite database named jumpassist and configure it in /addons/sourcemod/configs/databases.cfg
	Once the database is set up, an example configuration would look like:

	"jumpassist"
	{
		"driver"			"default"
		"host"				"127.0.0.1"
		"database"			"jumpassist"
		"user"				"username"
		"pass"				"password"
		//"timeout"			"0"
		//"port"			"0"
	}
*/

#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <color_literals>
#include <clientprefs>
#include "smlib/math.inc"

#define COLORREDTEAM "\x07ba5353"
#define COLORBLUETEAM "\x0782b6ff"

enum RaceStatus {
	STATUS_NONE = 0,
	STATUS_INVITING,
	STATUS_COUNTDOWN,
	STATUS_RACING,
	STATUS_WAITING
}

enum {
	TEAM_UNASSIGNED = 0,
	TEAM_SPECTATOR,
	TEAM_RED,
	TEAM_BLUE
}

bool
	  g_bLateLoad
	, g_bHideMessage[MAXPLAYERS+1]
	, g_bAmmoRegen[MAXPLAYERS+1]
	, g_bHardcore[MAXPLAYERS+1]
	, g_bCPTouched[MAXPLAYERS+1][32]
	, g_bJustSpawned[MAXPLAYERS+1]
	, g_bUsedReset[MAXPLAYERS+1]
	, g_bBeatTheMap[MAXPLAYERS+1]
	, g_bUnkillable[MAXPLAYERS+1]
	, g_bMapSetUsed;
char
	  g_sWebsite[128] = "http:// www.jump.tf/"
	, g_sForum[128] = "http:// tf2rj.com/forum/"
	, g_sJumpAssist[128] = "http://tf2rj.com/forum/index.php?topic=854.0"
	, g_sCurrentMap[64]
	, g_sClientSteamID[MAXPLAYERS+1][32];
int
	  g_iLastTeleport[MAXPLAYERS+1]
	, g_iClientTeam[MAXPLAYERS+1]
	, g_iClientWeapons[MAXPLAYERS+1][3]
	, g_iClientPreRaceTeam[MAXPLAYERS+1]
	, g_iClientPreRaceCPsTouched[MAXPLAYERS+1];
float
	  g_fOrigin[MAXPLAYERS+1][3]
	, g_fAngles[MAXPLAYERS+1][3]
	, g_fLastSavePos[MAXPLAYERS+1][3]
	, g_fLastSaveAngles[MAXPLAYERS+1][3]
	, nullVector[3];
TFClassType
	  g_TFClientClass[MAXPLAYERS+1];
ConVar
	  g_cvarHostname
	, g_cvarPluginEnabled
	, g_cvarWelcomeMsg
	, g_cvarCriticals
	, g_cvarSuperman
	, g_cvarAmmoCheat
	, g_cvarWaitingForPlayers;
Handle
	  g_hJAMessageCookie;
ArrayList
	  g_AL_NoFuncRegen;
Database
	  g_Database;

#define PLUGIN_VERSION "2.0.0"
#define PLUGIN_NAME "[TF2] Jump Assist"
#define PLUGIN_AUTHOR "rush - Updated by nolem, happs, joinedsenses"
#define cDefault 0x01
#define cLightGreen 0x03
#define cTheme1 "\x0769cfbc"
#define cTheme2 "\x07a4e8dc"
#define cHardcore "\x07FF4500"
#include "jumpassist/skeys.sp"
#include "jumpassist/database.sp"
#include "jumpassist/race.sp"

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Tools to run a jump server with ease.",
	version = PLUGIN_VERSION,
	url = "https:// github.com/JoinedSenses/TF2-ECJ-JumpAssist"
}

/* ======================================================================
   ------------------------------- SM API
*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart() {
	CreateConVar("jumpassist_version", PLUGIN_VERSION, "JumpAssist Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_cvarHostname = FindConVar("hostname");
	g_cvarWaitingForPlayers = FindConVar("mp_waitingforplayers_time");
	g_cvarPluginEnabled = CreateConVar("ja_enable", "1", "Turns JumpAssist on/off.", FCVAR_NOTIFY);
	g_cvarWelcomeMsg = CreateConVar("ja_welcomemsg", "1", "Show clients the welcome message when they join?", FCVAR_NOTIFY);
	g_cvarAmmoCheat = CreateConVar("ja_ammocheat", "1", "Allows engineers infinite sentrygun ammo?", FCVAR_NOTIFY);
	g_cvarCriticals = CreateConVar("ja_crits", "0", "Allow critical hits?", FCVAR_NOTIFY);
	g_cvarSuperman = CreateConVar("ja_superman", "1", "Allows everyone to be invincible?", FCVAR_NOTIFY);

	RegConsoleCmd("ja_help", cmdJAHelp, "Shows JA's commands.");
	RegConsoleCmd("sm_jumptf", cmdJumpTF, "Shows the jump.tf website.");
	RegConsoleCmd("sm_forums", cmdJumpForums, "Shows the jump.tf forums.");
	RegConsoleCmd("sm_jumpassist", cmdJumpAssist, "Shows the forum page for JumpAssist.");

	RegConsoleCmd("sm_s", cmdSave, "Saves your current position.");
	RegConsoleCmd("sm_save", cmdSave, "Saves your current position.");
	RegConsoleCmd("sm_t", cmdTele, "Teleports you to your current saved location.");
	RegConsoleCmd("sm_tele", cmdTele, "Teleports you to your current saved location.");
	RegConsoleCmd("sm_r", cmdReset, "Sends you back to the beginning without deleting your save.");
	RegConsoleCmd("sm_reset", cmdReset, "Sends you back to the beginning without deleting your save.");
	RegConsoleCmd("sm_restart", cmdRestart, "Deletes your save, and sends you back to the beginning.");
	RegConsoleCmd("sm_undo", cmdUndo, "Restores your last saved position.");

	RegConsoleCmd("sm_regen", cmdToggleAmmo, "Regenerates weapon ammunition");
	RegConsoleCmd("sm_ammo", cmdToggleAmmo, "Regenerates weapon ammunition");
	RegConsoleCmd("sm_superman", cmdUnkillable, "Makes you strong like superman.");
	RegConsoleCmd("sm_hardcore", cmdToggleHardcore, "Enables hardcore mode (No regen, no saves)");
	
	RegConsoleCmd("sm_hidemessage", cmdHideMessage, "Toggles display of JA messages, such as save and teleport");

	RegConsoleCmd("sm_skeys", cmdGetClientKeys, "Toggle showing a client's keys.");
	RegConsoleCmd("sm_skeyscolor", cmdChangeSkeysColor, "Changes the color of the text for skeys.");
	RegConsoleCmd("sm_skeyscolors", cmdChangeSkeysColor, "Changes the color of the text for skeys.");
	RegConsoleCmd("sm_skeyspos", cmdChangeSkeysLoc, "Changes the location of the text for skeys.");
	RegConsoleCmd("sm_skeysloc", cmdChangeSkeysLoc, "Changes the location of the text for skeys.");

	RegConsoleCmd("sm_race", cmdRaceInitialize, "Initializes a new race.");
	RegConsoleCmd("sm_leaverace", cmdRaceLeave, "Leave the current race.");
	RegConsoleCmd("sm_r_leave", cmdRaceLeave, "Leave the current race.");
	RegConsoleCmd("sm_specrace", cmdRaceSpec, "Spectate a race.");
	RegConsoleCmd("sm_racelist", cmdRaceList, "Display race list");
	RegConsoleCmd("sm_raceinfo", cmdRaceInfo, "Display information about the race you are in.");

	RegAdminCmd("sm_serverrace", cmdRaceInitializeServer, ADMFLAG_GENERIC, "Invite everyone to a server wide race");

	RegAdminCmd("sm_mapset", cmdMapSet, ADMFLAG_GENERIC, "Change map settings");
	RegAdminCmd("sm_send", cmdSendPlayer, ADMFLAG_GENERIC, "Send target to another target.");

	HookEvent("player_spawn", eventPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_death", eventPlayerDeath);
	HookEvent("controlpoint_starttouch", eventTouchCP);
	HookEvent("teamplay_round_start", eventRoundStart);
	HookEvent("post_inventory_application", eventInventoryUpdate);
	HookEvent("player_disconnect", eventPlayerDisconnect);

	AddCommandListener(listenerJoinTeam, "jointeam");
	AddCommandListener(listenerJoinClass, "joinclass");
	AddCommandListener(listenerJoinClass, "join_class");
	
	g_cvarAmmoCheat.AddChangeHook(cvarAmmoCheatChanged);
	g_cvarWelcomeMsg.AddChangeHook(cvarWelcomeMsgChanged);
	g_cvarSuperman.AddChangeHook(cvarSupermanChanged);
	
	HookUserMessage(GetUserMessageId("VoiceSubtitle"), VoiceHook, true);
	
	g_hJAMessageCookie = RegClientCookie("JAMessage_cookie", "Jump Assist Message Cookie", CookieAccess_Protected);

	LoadTranslations("common.phrases");

	g_hHudDisplayForward = CreateHudSynchronizer();
	g_hHudDisplayASD = CreateHudSynchronizer();
	g_hHudDisplayDuck = CreateHudSynchronizer();
	g_hHudDisplayJump = CreateHudSynchronizer();
	g_hHudDisplayM1 = CreateHudSynchronizer();
	g_hHudDisplayM2 = CreateHudSynchronizer();

	g_AL_NoFuncRegen = new ArrayList();

	SetAllSkeysDefaults();
	ConnectToDatabase();
	
	if (g_bLateLoad) {
		PrintColoredChatAll("[%sJA\x01]%s JumpAssist\x01 has been%s reloaded.", cTheme1, cTheme2, cTheme2);
		GetCurrentMap(g_sCurrentMap, sizeof(g_sCurrentMap));
		for (int client = 1; client <= MaxClients; client++) {
			if (IsValidClient(client)) {
				g_iClientTeam[client] = GetClientTeam(client);
				g_TFClientClass[client] = TF2_GetPlayerClass(client);
				GetClientAuthId(client, AuthId_Steam2, g_sClientSteamID[client], sizeof(g_sClientSteamID[]));
				SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
				for (int i = 0; i <= 2; i++) {
					g_iClientWeapons[client][i] = GetPlayerWeaponSlot(client, i);
				}
			}
		}
	}
}

public void OnMapStart() {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	GetCurrentMap(g_sCurrentMap, sizeof(g_sCurrentMap));

	for (int i = 1; i <= MaxClients ; i++) {
		ResetRace(i);
		g_iLastTeleport[i] = 0;
	}
	if (g_Database != null) {
		LoadMapCFG();
	}
	g_cvarWaitingForPlayers.SetInt(0);
	PrecacheSound("misc/freeze_cam.wav");
	PrecacheSound("misc/killstreak.wav");

	GameRules_SetProp("m_nGameType", 2);

	g_iCPs = 0;
	int iCP = -1;
	while ((iCP = FindEntityByClassname(iCP, "trigger_capture_area")) != -1) {
		g_iCPs++;
	}
	HookFuncRegenerate();
}

public void OnClientCookiesCached(int client) {
	char sValue[8];
	GetClientCookie(client, g_hJAMessageCookie, sValue, sizeof(sValue));
	g_bHideMessage[client] = (sValue[0] != '\0' && StringToInt(sValue));
}

public void OnClientPostAdminCheck(int client) {
	if (!g_cvarPluginEnabled.BoolValue || IsFakeClient(client)) {
		return;
	}
	SetPlayerDefaults(client);
	// Load the player profile.
	if (!GetClientAuthId(client, AuthId_Steam2, g_sClientSteamID[client], sizeof(g_sClientSteamID[]))) {
		KickClient(client, "Auth Error: Unable to retrieve steam id. Try reconnecting");
		LogError("[JumpAssist] Unable to retrieve steam id on %N", client);
		return;
	}
	// Hook and load info for client
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
	LoadPlayerProfile(client);
	
	// Welcome message.
	if (g_cvarWelcomeMsg.BoolValue) {
		CreateTimer(15.0, WelcomePlayer, client);
	}
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (!IsValidClient(client)) {
		return Plugin_Continue;
	}
	// FOR SKEYS
	g_iButtons[client] = buttons;
	switch (g_iSkeysMode[client]) {
		case EDIT: {
			g_fSkeysXLoc[client] = Math_Clamp(g_fSkeysXLoc[client] + 0.0005 * mouse[0], 0.0, 0.85);
			g_fSkeysYLoc[client] = Math_Clamp(g_fSkeysYLoc[client]+ 0.0005 * mouse[1], 0.0, 0.90);

			if (buttons & (IN_ATTACK|IN_ATTACK2)) {
				g_iSkeysMode[client] = DISPLAY;
				SaveKeyPos(client, g_fSkeysXLoc[client], g_fSkeysYLoc[client]);

				CreateTimer(0.2, timerUnfreeze, client);
			}
			else if (buttons & (IN_ATTACK3|IN_JUMP)) {
				g_fSkeysXLoc[client] = XPOSDEFAULT;
				g_fSkeysYLoc[client] = YPOSDEFAULT;
				
				g_iSkeysMode[client] = DISPLAY;
				SaveKeyPos(client, g_fSkeysXLoc[client], g_fSkeysYLoc[client]);

				CreateTimer(0.2, timerUnfreeze, client);
			}
		}
	}

	int observerMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
	int clientToShow = IsClientObserver(client) ? GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") : client;
	if (IsValidClient(clientToShow) && g_bSKeysEnabled[client] && !(buttons & IN_SCORE) && observerMode != 7) {
		int
			  buttonsToShow = g_iButtons[clientToShow]
			, R = g_iSkeysRed[client]
			, G = g_iSkeysGreen[client]
			, B = g_iSkeysBlue[client]
			, alpha = 255;
		bool
			  isEditing = (g_iSkeysMode[client] == EDIT)
			, W = (buttonsToShow & IN_FORWARD || isEditing)
			, A = (buttonsToShow & IN_MOVELEFT || isEditing)
			, S = (buttonsToShow & IN_BACK || isEditing)
			, D = (buttonsToShow & IN_MOVERIGHT || isEditing)
			, Duck = (buttonsToShow & IN_DUCK || isEditing)
			, Jump = (buttonsToShow & IN_JUMP || isEditing)
			, M1 = (buttonsToShow & IN_ATTACK || isEditing)
			, M2 = (buttonsToShow & IN_ATTACK2 || isEditing);
		float
			  hold = 0.1
			, X = g_fSkeysXLoc[client]
			, Y = g_fSkeysYLoc[client];

		SetHudTextParams(X+(W?0.047:0.052), Y, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayForward, (W?"W":"-"));

		SetHudTextParams(X+0.04-(A?0.0042:0.0)-(S?0.0015:0.0), Y+0.05, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayASD, "%s %s %s", (A?"A":"-"), (S?"S":"-"), (D?"D":"-"));

		SetHudTextParams(X+0.09, Y+0.05, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayDuck, (Duck?"Duck":""));

		SetHudTextParams(X+0.09, Y, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayJump, (Jump?"Jump":""));

		SetHudTextParams(X, Y, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayM1, (M1?"M1":""));

		SetHudTextParams(X, Y+0.05, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayM2, (M2?"M2":""));
		//.54 x def and .4 y def
	}

	if (g_bAmmoRegen[client] && buttons & (IN_ATTACK|IN_ATTACK2) && !IsClientObserver(client)) {
		for (int i = 0; i <= 2; i++) {
			ReSupply(client, g_iClientWeapons[client][i]);
		}
	}

	if (g_bRaceLocked[client]) {
		vel = nullVector;
	}

	int iMaxHealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	if (!IsClientObserver(client) && GetClientHealth(client) < iMaxHealth) {
		SetEntityHealth(client, iMaxHealth);
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

/* ======================================================================
   ------------------------------- CVAR Hook
*/

public void cvarAmmoCheatChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	FindConVar("tf_sentrygun_ammocheat").SetInt(!(StringToInt(newValue) == 0));
}

public void cvarWelcomeMsgChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	g_cvarWelcomeMsg.SetBool(!(StringToInt(newValue) == 0));
}

public void cvarSupermanChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	g_cvarSuperman.SetBool(!(StringToInt(newValue) == 0));
}

/* ======================================================================
   ------------------------------- Events/Listeners
*/

public Action listenerJoinClass(int client, const char[] command, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	if (IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client) && g_bRaceClassForce[g_iRaceID[client]]) {
		PrintColoredChat(client, "[%sJA\x01] Cannot change class while racing.", cTheme1);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action listenerJoinTeam(int client, const char[] command, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	// Get clients raceid for readability
	int raceID = g_iRaceID[client];
	// If raceid > 0 and player is in a race, prevent them from changing teams
	if (raceID && (g_iRaceStatus[raceID] == STATUS_COUNTDOWN || g_iRaceStatus[raceID] == STATUS_RACING)) {
		PrintColoredChat(client, "[%sJA\x01] You may not change teams during the race.", cTheme1);
		return Plugin_Handled;
	}

	int oldTeam = GetClientTeam(client);
	int newTeam;

	// arg is team client is attempting to join
	char arg[16];
	GetCmdArg(1, arg, sizeof(arg));

	// datapack containing client and new team. used during requestframe
	DataPack dp = new DataPack();
	dp.WriteCell(client);

	if (StrEqual(arg, "spectate", false)) {
		newTeam = TEAM_SPECTATOR;
	}
	else if (StrEqual(arg, "red", false)) {
		newTeam = TEAM_RED;
	}
	else if (StrEqual(arg, "blue", false)) {
		newTeam = TEAM_BLUE;
	}
	else if ((StrEqual(arg, "auto", false))) {
		// if they choose auto/random [if force team set to that team, else set to blue].
		newTeam = (g_iForceTeam > 1) ? g_iForceTeam : TEAM_BLUE;
		dp.WriteCell(newTeam);
		RequestFrame(framerequestChangeTeam, dp);
		if (TF2_GetPlayerClass(client) == TFClass_Unknown) {
			// if class is not chosen, let client choose
			return Plugin_Continue;
		}
		return Plugin_Handled;
	}
	else {
		// if unknown arg, do nothing.
		delete dp;
		return Plugin_Handled;
	}

	if (newTeam == oldTeam) {
		// if new team is old team, do nothing.
		delete dp;
		return Plugin_Handled;
	}

	g_fOrigin[client] = nullVector;
	g_fAngles[client] = nullVector;
	g_fLastSavePos[client] = nullVector;

	if (newTeam == TEAM_SPECTATOR || g_iForceTeam < 2 || newTeam == g_iForceTeam) {
		// if client joining spec, no team forced, or client joining already forced team,
		// change their team to their choice...
		dp.WriteCell(newTeam);
	}
	else {
		// ...otherwise force change their team.
		dp.WriteCell(g_iForceTeam);
	}
	
	RequestFrame(framerequestChangeTeam, dp);
	if (TF2_GetPlayerClass(client) == TFClass_Unknown) {
		// fallback: if class is not chosen, let client choose
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

public Action eventPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (GetClientTeam(client) == g_iClientTeam[client] || g_bMapSetUsed) {
		RequestFrame(framerequestRespawn, client);
	}
	return Plugin_Handled;
}

public Action eventPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (g_bJustSpawned[client]) {
		return Plugin_Continue;
	}

	g_bUnkillable[client] = false;
	g_fLastSavePos[client] = nullVector;
	for (int i = 0; i < 3; i++) {
		g_iClientWeapons[client][i] = GetPlayerWeaponSlot(client, i);
	}

	// Disable func_regenerate if player is using beggers bazooka
	g_TFClientClass[client] = TF2_GetPlayerClass(client);
	CheckBeggars(client);
	if (g_Database != null) {
		CreateTimer(0.3, timerSpawnedBool, client);
		g_bJustSpawned[client] = true;
		if (g_bUsedReset[client]) {
			ReloadPlayerData(client);
			g_bUsedReset[client] = false;
		}
		else {
			EraseLocs(client);
			LoadPlayerData(client);
		}
	}

	g_iRaceSpec[client] = 0;
	return Plugin_Continue;
}

public void eventInventoryUpdate(Event event, char[] strName, bool bDontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!IsValidClient(client)) {
		return;
	}
	CheckBeggars(client);
}

public void eventPlayerDisconnect(Event event, char[] strName, bool bDontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	if (event.GetBool("bot")) {
		return;
	}
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	SetPlayerDefaults(client);
	
	if (g_iRaceID[client] != 0) {
		LeaveRace(client);
	}
	int idx;
	if ((idx = g_AL_NoFuncRegen.FindValue(client)) != -1) {
		g_AL_NoFuncRegen.Erase(idx);
	}
}

public Action eventRoundStart(Handle event, const char[] name, bool dontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	if (g_iLockCPs == 1) {
		LockCPs();
	}
	HookFuncRegenerate();
	if (!g_cvarCriticals.BoolValue) {
		FindConVar("tf_weapon_criticals").SetInt(0, true, false);
	}
	if (g_cvarAmmoCheat.BoolValue) {
		FindConVar("tf_sentrygun_ammocheat").SetInt(1);
	}
}

public Action eventTouchCP(Event event, const char[] name, bool dontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	int client = event.GetInt("player");
	int area = event.GetInt("area");
	
	char g_sClass[33];
	char cpName[32];

	if (g_bCPTouched[client][area] && g_iRaceID[client] == 0) {
		return Plugin_Continue;
	}
	
	Format(g_sClass, sizeof(g_sClass), "%s", GetClassname(g_TFClientClass[client]));

	int entity;
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1) {
		int pIndex = GetEntProp(entity, Prop_Data, "m_iPointIndex");
		int raceID = g_iRaceID[client];
		if (pIndex != area) {
			continue;
		}
		if (g_iRaceEndPoint[raceID] == pIndex && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)) {
			char timeString[255];
			char buffer[128];
				
			float time = GetEngineTime();
			g_fRaceTime[client] = time;
			float timeTaken = time - g_fRaceStartTime[raceID];
			timeString = TimeFormat(timeTaken);

			if (RoundToNearest(g_fRaceFirstTime[raceID]) == 0) {
				Format(buffer, sizeof(buffer), "[%sJA\x01]%s %N\x01 won the race in%s %s\x01!", cTheme1, cTheme2, client, cTheme2, timeString);
				g_fRaceFirstTime[raceID] = time;
				g_iRaceStatus[raceID] = STATUS_WAITING;
				for (int i = 0; i < MaxClients; i++) {
					if (g_iRaceFinishedPlayers[raceID][i] == 0) {
						g_iRaceFinishedPlayers[raceID][i] = client;
						g_fRaceTimes[raceID][i] = time;
						break;
					}
				}
				for (int j = 1; j <= MaxClients; j++) {
					if (g_iRaceID[j] == raceID) {
						EmitSoundToClient(j, "misc/killstreak.wav");
					}
				}
			}
			else {
				char diffFormatted[255];

				float firstTime = g_fRaceFirstTime[raceID];
				float diff = time - firstTime;
				diffFormatted = TimeFormat(diff);
				
				for (int i = 0; i < MaxClients; i++) {
					if (g_iRaceFinishedPlayers[raceID][i] == 0) {
						g_iRaceFinishedPlayers[raceID][i] = client;
						g_fRaceTimes[raceID][i] = time;
						break;
					}
				}
				Format(buffer, sizeof(buffer), "[%sJA\x01]%s %N\x01 finished the race in%s %s \x01(%s+%s\x01)!", cTheme1, cTheme2, client, cTheme2, timeString, cTheme2, diffFormatted);
				for (int j = 1; j <= MaxClients; j++) {
					if (g_iRaceID[j] == raceID) {
						EmitSoundToClient(j, "misc/freeze_cam.wav");
					}
				}				

			}
			if (RoundToZero(g_fRaceFirstTime[raceID]) == 0) {
				g_fRaceFirstTime[raceID] = time;
			}
			PrintToRace(raceID, buffer);
			if (GetPlayersStillRacing(raceID) == 0) {
				PrintToRace(raceID, "[%sJA\x01] Everyone has finished the race.", cTheme1);
				for (int player = 1; player <= MaxClients; player++) {
					if (g_iRaceID[player] == raceID || IsClientSpectatingRace(player, raceID)) {
						displayRaceTimesMenu(player, player);
					}
				}
				ResetRace(raceID);
				g_iRaceStatus[raceID] = STATUS_NONE;
			}
		}
		// If client has not yet touched the cap and also if they haven't used the teleport command within 10 seconds.
		else if (!g_bCPTouched[client][area] && ((RoundFloat(GetEngineTime()) - g_iLastTeleport[client]) > 10)) {
			GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i)) {
					PrintColoredChat(i, "[%sJA\x01] %s%s%N\x01 has reached %s%s\x01 as %s%s\x01.", cTheme1, g_bHardcore[client] ? "[\x07FF4500Hardcore\x01] " : "", cTheme2, client, cTheme2, cpName, cTheme2, g_sClass);
					EmitSoundToClient(i, "misc/freeze_cam.wav");
				}
			}
			if (g_iCPsTouched[client] == g_iCPs) {
				g_bBeatTheMap[client] = true;
			}
		}
	}
	g_bCPTouched[client][area] = true;
	g_iCPsTouched[client]++;
	return Plugin_Continue;
}

public Action OnPlayerStartTouchFuncRegenerate(int entity, int other) {
	if (other <= MaxClients && g_AL_NoFuncRegen.Length > 0 && g_AL_NoFuncRegen.FindValue(other) != -1) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void OnWeaponEquipPost(int client, int weapon) {
	if (IsValidClient(client)) {
		for (int i = 0; i <= 2; i++) {
			g_iClientWeapons[client][i] = GetPlayerWeaponSlot(client, i);
		}
	}
}

public Action VoiceHook(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init) {
 	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	int client = bf.ReadByte();
	int vMenu1 = bf.ReadByte();
	int vMenu2 = bf.ReadByte();

	if (g_cvarPluginEnabled.BoolValue && IsValidClient(client) && IsPlayerAlive(client)) {
		if ((vMenu1 == 0) && (vMenu2 == 0) && !g_bHardcore[client] && (!g_iRaceID[client] || g_fRaceTime[client] != 0.0)) {
			for (int i = 0; i <= 2; i++) {
				ReSupply(client, g_iClientWeapons[client][i]);
			}
			if (g_TFClientClass[client] == TFClass_Engineer) {
				SetEntProp(client, Prop_Data, "m_iAmmo", 200, 4, 3);
			}
		}
	}
	return Plugin_Continue;
}

/* ======================================================================
   ------------------------------- Commands
*/

public Action cmdSave(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Handled;
	}
	SaveLoc(client);
	return Plugin_Handled;
}

public Action cmdTele(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Handled;
	}
	Teleport(client);
	g_iLastTeleport[client] = RoundFloat(GetEngineTime());
	return Plugin_Handled;
}

public Action cmdReset(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue || IsClientObserver(client)) {
		return Plugin_Handled;
	}
	g_iLastTeleport[client] = 0;
	SendToStart(client);
	g_bUsedReset[client] = true;

	return Plugin_Handled;
}

public Action cmdRestart(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue || !IsValidClient(client) || IsClientObserver(client)) {
		return Plugin_Handled;
	}
	EraseLocs(client);
	if (g_Database != null) {
		ResetPlayerPos(client);
	}
	TF2_RespawnPlayer(client);
	if (!g_bHideMessage[client]) {
		PrintColoredChat(client, "[%sJA\x01] You have been%s restarted\x01.", cTheme1, cTheme2);
	}
	g_iLastTeleport[client] = 0;
	return Plugin_Handled;
}

public Action cmdUndo(int client, int args) {
	if (!IsValidPosition(g_fLastSavePos[client])) {
		PrintColoredChat(client, "[%sJA\x01]%s No save\x01 to restore\x01.", cTheme1, cTheme2);
		return Plugin_Handled;
	}
	else {
		for (int i = 0; i <= 2; i++) {
			g_fOrigin[client][i] = g_fLastSavePos[client][i];
			g_fAngles[client][i] = g_fLastSaveAngles[client][i];
		}
		
		g_fLastSavePos[client] = nullVector;
		
		PrintColoredChat(client, "[%sJA\x01] Previous save has been%s restored\x01.", cTheme1, cTheme2);
		return Plugin_Handled;
	}
}

public Action cmdToggleAmmo(int client, int args) {
	if (client == 0) {
		return Plugin_Handled;
	}
	if (IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)) {
		PrintColoredChat(client, "[%sJA\x01] You may not change regen during a race", cTheme1);
		return Plugin_Handled;
	}
	if (g_bHardcore[client]) {
		PrintColoredChat(client, "[%sJA\x01] Cannot toggle ammo with %sHardcore\x01 enabled", cTheme1, cTheme2);
		return Plugin_Handled;
	}
	g_bAmmoRegen[client] = !g_bAmmoRegen[client];
	PrintColoredChat(client, "[%sJA\x01] Ammo regen%s %s\x01.", cTheme1, cTheme2, g_bAmmoRegen[client]?"enabled":"disabled");
	return Plugin_Handled;
}

public Action cmdUnkillable(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Handled;
	}
	if (!g_cvarSuperman.BoolValue && !IsUserAdmin(client)) {
		PrintColoredChat(client, "[%sJA\x01] Command disabled by server admin.", cTheme1);
		return Plugin_Handled;
	}
	g_bUnkillable[client] = !g_bUnkillable[client];
	SetEntProp(client, Prop_Data, "m_takedamage", g_bUnkillable[client]?1:2, 1);
	PrintColoredChat(client, "[%sJA\x01] Superman%s %s", cTheme1, cTheme2, g_bUnkillable[client]?"enabled":"disabled");
	return Plugin_Handled;
}

public Action cmdToggleHardcore(int client, int args) {
	if (!IsValidClient(client)) {
		return Plugin_Handled;
	}
	Hardcore(client);
	return Plugin_Handled;
}

public Action cmdHideMessage(int client, int args) {
	g_bHideMessage[client] = !g_bHideMessage[client];
	PrintColoredChat(client, "[%sJA\x01] Messages will now be%s %s", cTheme1, cTheme2, g_bHideMessage[client]?"hidden":"displayed");
	SetClientCookie(client, g_hJAMessageCookie, g_bHideMessage[client]?"1":"0");
	return Plugin_Handled;
}

public Action cmdSendPlayer(int client,int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Handled;
	}	
	if (g_Database == null) {
		PrintColoredChat(client, "[%sJA\x01] This feature is not supported without a database configuration", cTheme1);
		return Plugin_Handled;
	}
	if (args < 2) {
		PrintColoredChat(client, "[%sJA\x01] %sUsage\x01: sm_send <playerName> <targetName>", cTheme1, cTheme2);
		return Plugin_Handled;
	}
	char arg1[MAX_NAME_LENGTH];
	char arg2[MAX_NAME_LENGTH];

	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));

	int target1 = FindTarget2(client, arg1, false, false);
	int target2 = FindTarget2(client, arg2, false, false);

	if (target1 < 1 || target2 < 1) {
		return Plugin_Handled;
	}

	float TargetOrigin[3];
	float pAngle[3];

	GetClientAbsOrigin(target2, TargetOrigin);
	GetClientAbsAngles(target2, pAngle);
	TeleportEntity(target1, TargetOrigin, pAngle, nullVector);
	
	PrintColoredChat(client, "[%sJA\x01] Sent%s %N\x01 to%s %N\x01.", cTheme1, cTheme2, target1, cTheme2, target2);
	PrintColoredChat(target1, "[%sJA\x01]%s %N\x01 sent you to%s %N\x01.", cTheme1, cTheme2, client, cTheme2, target2);
	return Plugin_Handled;
}

public Action cmdMapSet(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Handled;
	}
	if (g_Database == null) {
		PrintColoredChat(client, "[%sJA\x01] This feature is not supported without a database configuration", cTheme1);
		return Plugin_Handled;
	}
	if (args < 2) {
		PrintColoredChat(client, "[%sJA\x01] %sUsage\x01: !mapset <team|class|lockcps> <team color|class|on off>", cTheme1, cTheme2);
		return Plugin_Handled;
	}

	char arg1[16];
	char arg2[16];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));

	SaveMapSettings(client, arg1, arg2);
	return Plugin_Handled;
}

public Action cmdJAHelp(int client, int args) {
	if (IsUserAdmin(client)) {
		ReplyToCommand(
			client,
			"**********ADMIN COMMANDS**********\n"
			... "mapset - Change map settings"
		);
	}
	JAHelpMenu(client);
	return Plugin_Handled;
}

public Action cmdJumpTF(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	ShowMOTDPanel(client, "Jump Assist Help", g_sWebsite, MOTDPANEL_TYPE_URL);
	return;
}

public Action cmdJumpForums(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	ShowMOTDPanel(client, "Jump Assist Help", g_sForum, MOTDPANEL_TYPE_URL);
	return;
}

public Action cmdJumpAssist(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	ShowMOTDPanel(client, "Jump Assist Help", g_sJumpAssist, MOTDPANEL_TYPE_URL);
	return;
}

/* ======================================================================
   ------------------------------- Internal Functions
*/

void SetPlayerDefaults(int client) {
	g_bAmmoRegen[client] = false;
	g_bHardcore[client] = false;
	g_bLoadedPlayerSettings[client] = false;
	g_bBeatTheMap[client] = false;
	g_bSKeysEnabled[client] = false;
	g_bUnkillable[client] = false;
	g_sClientSteamID[client] = "";
	EraseLocs(client);
	g_iRaceID[client] = 0;
	SetSkeysDefaults(client);
}

void SaveLoc(int client) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	if (g_bHardcore[client]) {
		PrintColoredChat(client, "[%sJA\x01]%s Hardcore:\x01 Saves are%s disabled\x01.", cTheme1, cHardcore, cTheme2);
		return;
	}
	else if (!IsPlayerAlive(client) || IsClientObserver(client)) {
		PrintColoredChat(client, "[%sJA\x01] Must be%s alive\x01 to save.", cTheme1, cTheme2);
		return;
	}
	else if (!(GetEntityFlags(client) & FL_ONGROUND)) {
		PrintColoredChat(client, "[%sJA\x01] Unable to save while in the%s air\x01.", cTheme1, cTheme2);
		return;
	}
	else if (GetEntProp(client, Prop_Send, "m_bDucked")) {
		PrintColoredChat(client, "[%sJA\x01] Unable to save while%s ducked\x01.", cTheme1, cTheme2);
		return;
	}
	else {
		g_fLastSavePos[client] = g_fOrigin[client];
		g_fLastSaveAngles[client] = g_fAngles[client];

		GetClientAbsOrigin(client, g_fOrigin[client]);
		GetClientAbsAngles(client, g_fAngles[client]);
		if (g_Database != null && IsClientInGame(client)) {
			GetPlayerData(client);
		}
	}
}

void Teleport(int client) {
	if (!g_cvarPluginEnabled.BoolValue || !IsValidClient(client)) {
		return;
	}
	if (g_iRaceID[client] && (g_iRaceStatus[g_iRaceID[client]] == STATUS_COUNTDOWN || g_iRaceStatus[g_iRaceID[client]] == STATUS_RACING)) {
		PrintColoredChat(client, "[%sJA\x01] Cannot teleport while racing.", cTheme1);
		return;
	}
	if (g_bHardcore[client]) {
		PrintColoredChat(client, "[%sJA\x01]%s Hardcore:\x01 Teleports are %sdisabled\x01.", cTheme1, cHardcore, cTheme2);
		return;
	}
	else if (!IsPlayerAlive(client)) {
		PrintColoredChat(client, "[%sJA\x01] Unable to teleport while%s dead\x01.", cTheme1, cTheme2);
		return;
	}

	char teamName[32];
	char teamColor[16];

	Format(teamName, sizeof(teamName), (g_iClientTeam[client] == TEAM_RED) ? "Red Team" : "Blue Team");
	teamColor = (g_iClientTeam[client] == TEAM_RED) ? COLORREDTEAM : COLORBLUETEAM;

	if (g_fOrigin[client][0] == 0.0) {
		PrintColoredChat(client, "[%sJA\x01] You don't have a save for%s %s\x01 on the%s %s\x01.", cTheme1, teamColor, GetClassname(g_TFClientClass[client]), teamColor, teamName);
		return;
	}

	TeleportEntity(client, g_fOrigin[client], g_fAngles[client], nullVector);
	if (!g_bHideMessage[client]) {
		PrintColoredChat(client, "[%sJA\x01] You have been%s teleported\x01.", cTheme1, cTheme2);
	}
}

void ResetPlayerPos(int client) {
	if (!g_cvarPluginEnabled.BoolValue || !IsClientInGame(client) || IsClientObserver(client)) {
		return;
	}
	DeletePlayerData(client);
}

void Hardcore(int client) {
	if (!g_cvarPluginEnabled.BoolValue || !IsClientInGame(client) || IsClientObserver(client)) {
		return;
	}

	if (!g_bHardcore[client]) {
		g_bHardcore[client] = true;
		g_bAmmoRegen[client] = false;
		EraseLocs(client);
		TF2_RespawnPlayer(client);
		PrintColoredChat(client, "[%sJA\x01]%s Hardcore%s enabled\x01.", cTheme1, cHardcore, cTheme2);
	}
	else {
		g_bHardcore[client] = false;
		LoadPlayerData(client);
		PrintColoredChat(client, "[%sJA\x01]%s Hardcore%s disabled\x01.", cTheme1, cHardcore, cTheme2);
	}
}

// Support for beggar's bazooka
void CheckBeggars(int client) {
	int weapon = GetPlayerWeaponSlot(client, 0);
	int index = g_AL_NoFuncRegen.FindValue(client);
	if (IsValidEntity(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 730) {
		if (index == -1) {
			g_AL_NoFuncRegen.Push(client);
			// LogMessage("Preventing player %d from touching func_regenerate");
		}
	}
	else if (index != -1){
		g_AL_NoFuncRegen.Erase(index);
		// LogMessage("Allowing player %d to touch func_regenerate");
	}
}

void HookFuncRegenerate() {
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "func_regenerate")) != INVALID_ENT_REFERENCE) {
		// Support for concmap*, and quad* maps that are imported from TFC.
		SDKUnhook(entity, SDKHook_StartTouch, OnPlayerStartTouchFuncRegenerate);
		SDKUnhook(entity, SDKHook_Touch, OnPlayerStartTouchFuncRegenerate);
		SDKUnhook(entity, SDKHook_EndTouch, OnPlayerStartTouchFuncRegenerate);
		SDKHook(entity, SDKHook_StartTouch, OnPlayerStartTouchFuncRegenerate);
		SDKHook(entity, SDKHook_Touch, OnPlayerStartTouchFuncRegenerate);
		SDKHook(entity, SDKHook_EndTouch, OnPlayerStartTouchFuncRegenerate);
	}
}

void ReSupply(int client, int weapon) {
	if (!g_cvarPluginEnabled.BoolValue || !IsValidWeapon(weapon) || !IsValidClient(client) || !IsPlayerAlive(client)) {
		return;
	}

	int weapindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	char className[128];
	GetEntityClassname(weapon, className, sizeof(className));

	// Rocket Launchers
	if (StrEqual(className, "tf_weapon_rocketlauncher") || StrEqual(className, "tf_weapon_particle_cannon")) {
		switch (weapindex) {
			// The Cow Mangler 5000
			case 441: {
				// Cow Mangler uses Energy instead of ammo.
				SetEntPropFloat(weapon, Prop_Send, "m_flEnergy", 100.0);
			}
			// Black Box
			case 228, 1085: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 3);
			}
			// Liberty Launcher
			case 414: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 5);
			}
			// Beggar's Bazooka - This is here so we don't keep refilling its clip infinitely.
			case 730: {
			}
			default: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
			}
		}
		// Refill the player's ammo supply to whatever the weapon's max is.
		GivePlayerAmmo(client, 100, TFWeaponSlot_Primary+1, false);
	}
	// Grenade Launchers
	else if (StrEqual(className, "tf_weapon_grenadelauncher") || StrEqual(className, "tf_weapon_cannon")) {
		switch (weapindex) {
			// Loch-n-Load
			case 308: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 3);
			}
			default: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
			}
		}
		// Refill the player's ammo supply to whatever the weapon's max is.
		GivePlayerAmmo(client, 100, TFWeaponSlot_Primary+1, false);
	}
	// MiniGuns
	else if (StrEqual(className, "tf_weapon_minigun")) {
		switch(weapindex) {
			default: {
				SetAmmo(client, weapon, 200);
			}
		}
	}
	// Stickybomb Launchers
	else if (StrEqual(className, "tf_weapon_pipebomblauncher")) {
		switch (weapindex) {
			// Quickiebomb Launcher
			case 1150: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
			}
			default: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 8);
			}
		}
		// Refill the player's ammo supply to whatever the weapon's max is.
		GivePlayerAmmo(client, 100, TFWeaponSlot_Secondary+1, false);
	}
	// Shotguns
	else if (StrEqual(className, "tf_weapon_shotgun") || StrEqual(className, "tf_weapon_sentry_revenge")) {
		switch (weapindex) {
			// Reserve Shooter
			case 415: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
			}
			// Family Business
			case 425: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 8);
			}
			// Rescue Ranger,
			case 997: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
				SetEntProp(client, Prop_Data, "m_iAmmo", 200, _, 3);
			}
			// Frontier Justice
			case 141, 1004: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 3);
			}
			// Widowmaker
			case 527: {
				SetEntProp(client, Prop_Data, "m_iAmmo", 200, _, 3);
			}
			default: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 6);
			}
		}
		// Refill the player's ammo supply to whatever the weapon's max is.
		int slot = (g_TFClientClass[client] == TFClass_Engineer) ? TFWeaponSlot_Primary : TFWeaponSlot_Secondary;
		GivePlayerAmmo(client, 100, slot+1, false);
	}
	// FlameThrower
	else if (StrEqual(className, "tf_weapon_flamethrower")) {
		switch (weapindex) {
			default: {
				SetAmmo(client, weapon, 200);
			}
		}
	}
	// Flare Guns
	else if (!StrContains(className, "tf_weapon_flaregun")) {
		switch (weapindex) {
			default: {
				SetAmmo(client, weapon, 16);
			}
		}
	}
	// ScatterGuns
	else if (StrEqual(className, "tf_weapon_scattergun")) {
		switch (weapindex) {
			// Force-A-Nature, Soda Popper
			case 45, 448: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 2);
			}
			// Shortstop, Babyface, BackScatter
			case 220, 772, 1103: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 4);
			}
			default: {
				SetEntProp(weapon, Prop_Send, "m_iClip1", 6);
			}
		}
		// Refill the player's ammo supply to whatever the weapon's max is.
		GivePlayerAmmo(client, 100, TFWeaponSlot_Primary+1, false);
	}
	else if (StrEqual(className, "tf_weapon_syringegun_medic")){
		SetEntProp(weapon, Prop_Send, "m_iClip1", 40);
		SetEntProp(client, Prop_Data, "m_iAmmo", 150, _, 3);
		SetAmmo(client, weapon, 200);
	}
	// Ullapool caber
	else if (StrEqual(className, "tf_weapon_stickbomb")) {
		SetEntProp(weapon, Prop_Send, "m_bBroken", 0);
		SetEntProp(weapon, Prop_Send, "m_iDetonated", 0);
	}
}

void SetAmmo(int client, int weapon, int ammo) {
	int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammoType != -1) {
		SetEntProp(client, Prop_Data, "m_iAmmo", ammo, _, ammoType);
	}
}

void EraseLocs(int client) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	
	g_fOrigin[client] = nullVector;
	g_fAngles[client] = nullVector;

	for (int j = 0; j < 8; j++) {
		g_bCPTouched[client][j] = false;
		g_iCPsTouched[client] = 0;
	}
	g_bBeatTheMap[client] = false;
}

void CheckTeams() {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	CreateTimer(0.1, timerMapSetUsed);
	g_bMapSetUsed = true;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || IsClientObserver(i) || g_iClientTeam[i] == g_iForceTeam) {
			continue;
		}
		ChangeClientTeam(i, g_iForceTeam);
		g_iClientTeam[i] = g_iForceTeam;
		PrintColoredChat(i, "[%sJA\x01] Your team has been%s switched\x01.", cTheme1, cTheme2);
	}
}

void LockCPs() {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
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

void SendToStart(int client) {
	if (!g_cvarPluginEnabled.BoolValue || !IsValidClient(client) || IsClientObserver(client)) {
		return;
	}
	g_bUsedReset[client] = true;
	TF2_RespawnPlayer(client);
	if (!g_bHideMessage[client] && g_iRaceID[client] < 1) {
		PrintColoredChat(client, "[%sJA\x01] You have been%s sent to map start\x01.", cTheme1, cTheme2);
	}
}

void JAHelpMenu(int client) {
	Panel panel = new Panel();
	panel.SetTitle("Help Menu:");
	panel.DrawItem("Saving and Teleporting");
	panel.DrawItem("Regen");
	panel.DrawItem("Skeys");
	panel.DrawItem("Racing");
	panel.DrawItem("Miscellaneous");
	panel.DrawText(" ");
	panel.DrawItem("Exit");
	panel.Send(client, menuHandlerJAHelp, MENU_TIME_FOREVER);
	delete panel;
}

int menuHandlerJAHelp(Menu menu, MenuAction action, int client, int choice) {
	Panel panel = new Panel();
	switch (choice) {
		case 1: {
			panel.SetTitle("Save Help");
			panel.DrawText(
				"/save or /s - Saves your position\n"
			... "/tele or /t - Teleports you to your saved position\n"
			... "/undo - Reverts your last save\n"
			... "/reset or /r - Restarts you on the map\n"
			... "/restart - Deletes your save and restarts you"
			);
		}
		case 2: {
			panel.SetTitle("Regen Help");
			panel.DrawText("/ammo - Toggles ammo regen");
		}
		case 3: {
			panel.SetTitle("Skeys Help");
			panel.DrawText(
				"/skeys - Shows key presses on the screen\n"
			... "/skeyscolor <R> <G> <B> - Skeys color\n"
			... "/skeyspos - Sets skeys location with x and y values from 0 to 1"
			);
		}
		case 4: {
			panel.SetTitle("Racing Help");
			panel.DrawText(
				"/race - Initialize a race and select final CP.\n"
			... "/raceinfo - Provides info about the current race.\n"
			... "/racelist - Lists race players and their times\n"
			... "/specrace - Spectates a race.\n"
			... "/leaverace - Leave a race."
			);
		}
		case 5: {
			panel.DrawText(
				"/jumpassist - Shows the JumpAssist forum page.\n"
			... "/jumptf - Shows the Jump.tf website.\n"
			... "/forums - Shows the Jump.tf forums."
			);
		}
		default: {
			delete panel;
			return;
		}
	}

	panel.DrawText(" ");
	panel.DrawItem("Back");
	panel.DrawItem("Exit");
	panel.Send(client, menuHandlerJAHelpSubMenu, 15);
	delete panel;
}

int menuHandlerJAHelpSubMenu(Menu menu, MenuAction action, int param1, int param2) {
	switch (param2) {
		case 1: {
			cmdJAHelp(param1, 0);
		}
	}
}

char[] GetClassname(TFClassType class) {
	char buffer[128];
	switch(class) {
		case TFClass_Scout: Format(buffer, sizeof(buffer), "Scout");
		case TFClass_Sniper: Format(buffer, sizeof(buffer), "Sniper");
		case TFClass_Soldier: Format(buffer, sizeof(buffer), "Soldier");
		case TFClass_DemoMan: Format(buffer, sizeof(buffer), "Demoman");
		case TFClass_Medic: Format(buffer, sizeof(buffer), "Medic");
		case TFClass_Heavy: Format(buffer, sizeof(buffer), "Heavy");
		case TFClass_Pyro: Format(buffer, sizeof(buffer), "Pyro");
		case TFClass_Spy: Format(buffer, sizeof(buffer), "Spy");
		case TFClass_Engineer: Format(buffer, sizeof(buffer), "Engineer");
	}
	return buffer;
}

bool IsValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client));
}

bool IsUserAdmin(int client) {
	return GetUserAdmin(client).HasFlag(Admin_Generic);
}

bool IsValidPosition(const float vect[3]) {
	return (vect[0] != 0.0 || vect[1] != 0.0 || vect[2] != 0.0);
}

bool IsValidWeapon(int entity) {
	char strClassname[128];
	return (IsValidEntity(entity) && GetEntityClassname(entity, strClassname, sizeof(strClassname)) && StrContains(strClassname, "tf_weapon", false) != -1);
}

int FindTarget2(int client, const char[] target, bool nobots = false, bool immunity = true) {
	char target_name[MAX_TARGET_LENGTH];
	int target_list[1];
	int flags = COMMAND_FILTER_NO_MULTI;
	bool tn_is_ml;

	if (nobots) {
		flags |= COMMAND_FILTER_NO_BOTS;
	}
	if (!immunity) {
		flags |= COMMAND_FILTER_NO_IMMUNITY;
	}
	if ((ProcessTargetString(target, client, target_list, 1, flags, target_name, sizeof(target_name), tn_is_ml)) > 0) {
		return target_list[0];
	}
	return -1;
}

/* ======================================================================
   ------------------------------- Timers
*/

void framerequestChangeTeam(any data) {
	DataPack dp = view_as<DataPack>(data);
	dp.Reset();
	int client = dp.ReadCell();
	int team = dp.ReadCell();
	delete dp;
	if (GetClientTeam(client) < 2) {
		SetEntProp(client, Prop_Send, "m_lifeState", 1);
	}
	g_iClientTeam[client] = team;
	ChangeClientTeam(client, team);
}

void framerequestRespawn(any data) {
	if (GetClientTeam(data) > 1) {
		TF2_RespawnPlayer(data);
	}
}

Action WelcomePlayer(Handle timer, any client) {
	char sHostname[64];
	g_cvarHostname.GetString(sHostname, sizeof(sHostname));
	if (!IsClientInGame(client)) {
		return Plugin_Handled;
	}
	PrintColoredChat(client, "\n \x03--------------------------------------------------------");
	PrintColoredChat(client, "\x07FFA500[\x03+\x07FFA500]\x01 Welcome to\x079999FF %s", sHostname);
	PrintColoredChat(client, "\x07FFA500[\x03+\x07FFA500]\x01 For help with\x03 JumpAssist\x01, type\x07FFA500 !ja_help");
	PrintColoredChat(client, "\x07FFA500[\x03+\x07FFA500]\x01 For server information, type\x07FFA500 !help");
	PrintColoredChat(client, "\x07FFA500[\x03+\x07FFA500]\x03 Be nice to fellow jumpers");
	PrintColoredChat(client, "\x07FFA500[\x03+\x07FFA500]\x03 No trade chat");
	PrintColoredChat(client, "\x07FFA500[\x03+\x07FFA500]\x03 No complaining");
	PrintColoredChat(client, "\x07FFA500[\x03+\x07FFA500]\x03 No chat/voice spam");
	return Plugin_Handled;
}

Action timerSpawnedBool(Handle timer, int client) {
	g_bJustSpawned[client] = false;
}

Action timerMapSetUsed(Handle timer) {
	g_bMapSetUsed = false;
}

Action timerUnfreeze(Handle timer, int client) {
	SetEntityFlags(client, GetEntityFlags(client) & ~(FL_ATCONTROLS|FL_FROZEN));
}