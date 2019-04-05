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

#define PLUGIN_VERSION "2.3.6"
#define PLUGIN_NAME "[TF2] Jump Assist"
#define PLUGIN_AUTHOR "JoinedSenses (Original author: rush, with previous updates from nolem and happs)"
#define PLUGIN_DESCRIPTION "Tools to run a jump server with ease."
#define MAX_CAP_POINTS 32

#include <sourcemod>
#include <jumpassist>
#include <tf2_stocks>
#include <sdkhooks>
#include <color_literals>
#include <clientprefs>
#include "smlib/math.inc"
#undef REQUIRE_PLUGIN
#include "saveloc.inc"
#define REQUIRE_PLUGIN

enum {
	  TEAM_UNASSIGNED = 0
	, TEAM_SPECTATOR
	, TEAM_RED
	, TEAM_BLUE
}

enum {
	  INTEL_PICKEDUP = 1
	, INTEL_CAPTURED
	, INTEL_DEFENDED
	, INTEL_DROPPED
	, INTEL_RETURNED
}

bool
	  g_bLateLoad
	, g_bFeaturesEnabled[MAXPLAYERS+1]
	, g_bCPFallback
	, g_bHideMessage[MAXPLAYERS+1]
	, g_bIsPreviewing[MAXPLAYERS+1]
	, g_bAmmoRegen[MAXPLAYERS+1]
	, g_bHardcore[MAXPLAYERS+1]
	, g_bCPTouched[MAXPLAYERS+1][MAX_CAP_POINTS]
	, g_bJustSpawned[MAXPLAYERS+1]
	, g_bTelePaused[MAXPLAYERS+1]
	, g_bUsedReset[MAXPLAYERS+1]
	, g_bBeatTheMap[MAXPLAYERS+1]
	, g_bUnkillable[MAXPLAYERS+1]
	, g_bMapSetUsed
	, g_bSaveLoc;
char
	  g_sWebsite[128] = "http:// www.jump.tf/"
	, g_sForum[128] = "http://tf2rj.com/forum/"
	, g_sJumpAssist[128] = "http://tf2rj.com/forum/index.php?topic=854.0"
	, g_sCurrentMap[64]
	, g_sClientSteamID[MAXPLAYERS+1][32];
int
	  g_iLastTeleport[MAXPLAYERS+1]
	, g_iClientTeam[MAXPLAYERS+1]
	, g_iClientWeapons[MAXPLAYERS+1][3]
	, g_iIntelCarrier
	, g_iCPCount
	, g_iForceTeam = 1
	, g_iCPsTouched[MAXPLAYERS+1];
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
	  g_hJAMessageCookie
	, g_hForwardSKeys;
ArrayList
	  g_aNoFuncRegen;
Database
	  g_Database;
StringMap
	  g_smCapturePoint
	, g_smCapturePointName
	, g_smCaptureArea
	, g_smCaptureAreaName;

#include "jumpassist/skeys.sp"
#include "jumpassist/database.sp"
#include "jumpassist/race.sp"
#include "jumpassist/spec.sp"
#include "jumpassist/preview.sp"
#include "jumpassist/teleporting.sp"
#include "jumpassist/hide.sp"
#include "jumpassist/sl.sp"

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "https://github.com/JoinedSenses/TF2-ECJ-JumpAssist"
}

/* ======================================================================
   ------------------------------- SM API
*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	g_bLateLoad = late;
	RegPluginLibrary("jumpassist");
	CreateNative("JA_IsClientHiding", Native_IsClientHiding);
	CreateNative("JA_IsClientHardcore", Native_IsClientHardcore);
	CreateNative("JA_IsClientRacing", Native_IsClientRacing);
	CreateNative("JA_ToggleKeys", Native_ToggleKeys);
	CreateNative("JA_PauseTeleport", Native_PauseTeleport);
	CreateNative("JA_PrintMessage", Native_PrintMessage);
	CreateNative("JA_PrintMessageAll", Native_PrintMessageAll);
	return APLRes_Success;
}

public void OnPluginStart() {
	// CONVAR
	CreateConVar("jumpassist_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD).SetString(PLUGIN_VERSION);
	g_cvarHostname = FindConVar("hostname");
	g_cvarWaitingForPlayers = FindConVar("mp_waitingforplayers_time");
	g_cvarPluginEnabled = CreateConVar("ja_enable", "1", "Turns JumpAssist on/off.", FCVAR_NONE);
	g_cvarWelcomeMsg = CreateConVar("ja_welcomemsg", "1", "Show clients the welcome message when they join?", FCVAR_NONE);
	g_cvarAmmoCheat = CreateConVar("ja_ammocheat", "1", "Allows engineers infinite sentrygun ammo?", FCVAR_NONE);
	g_cvarCriticals = CreateConVar("ja_crits", "0", "Allow critical hits?", FCVAR_NONE);
	g_cvarSuperman = CreateConVar("ja_superman", "1", "Allows everyone to be invincible?", FCVAR_NONE);
	g_cvarExplosions = CreateConVar("sm_hide_explosions", "1", "Enable/Disable hiding explosions.", 0);

	g_cvarAmmoCheat.AddChangeHook(cvarAmmoCheatChanged);
	g_cvarWelcomeMsg.AddChangeHook(cvarWelcomeMsgChanged);
	g_cvarSuperman.AddChangeHook(cvarSupermanChanged);

	// HELP
	RegConsoleCmd("ja_help", cmdJAHelp, "Shows JA's commands.");
	RegConsoleCmd("sm_jumptf", cmdJumpTF, "Shows the jump.tf website.");
	RegConsoleCmd("sm_forums", cmdJumpForums, "Shows the jump.tf forums.");
	RegConsoleCmd("sm_jumpassist", cmdJumpAssist, "Shows the forum page for JumpAssist.");

	// GENERAL
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

	// HIDE
	RegConsoleCmd("sm_hide", cmdHide, "Show/Hide Other Players");

	// PREVIEW
	RegConsoleCmd("sm_preview", cmdPreview, "Enables noclip, allowing preview of a map");

	// TELEPORT
	RegAdminCmd("sm_bring", cmdBring, ADMFLAG_ROOT, "Bring a client or group to your position.");
	RegAdminCmd("sm_goto", cmdGoTo, ADMFLAG_RESERVATION, "Go to a client's position.");
	RegAdminCmd("sm_send", cmdSendPlayer, ADMFLAG_GENERIC, "Send target to another target.");

	// SKEYS
	RegConsoleCmd("sm_skeys", cmdGetClientKeys, "Toggle showing a client's keys.");
	RegConsoleCmd("sm_skeyscolor", cmdChangeSkeysColor, "Changes the color of the text for skeys.");
	RegConsoleCmd("sm_skeyscolors", cmdChangeSkeysColor, "Changes the color of the text for skeys.");
	RegConsoleCmd("sm_skeyspos", cmdChangeSkeysLoc, "Changes the location of the text for skeys.");
	RegConsoleCmd("sm_skeysloc", cmdChangeSkeysLoc, "Changes the location of the text for skeys.");

	// SPEC
	RegConsoleCmd("sm_spec", cmdSpec, "sm_spec <target> - Spectate a player.");
	RegConsoleCmd("sm_spec_ex", cmdSpecLock, "sm_spec_ex <target> - Consistently spectate a player, even through their death");
	RegConsoleCmd("sm_speclock", cmdSpecLock, "sm_speclock <target> - Consistently spectate a player, even through their death");
	RegAdminCmd("sm_fspec", cmdForceSpec, ADMFLAG_GENERIC, "sm_fspec <target> <targetToSpec>.");

	// RACE
	RegConsoleCmd("sm_race", cmdRace, "Initializes a new race.");
	RegConsoleCmd("sm_leaverace", cmdRaceLeave, "Leave the current race.");
	RegConsoleCmd("sm_r_leave", cmdRaceLeave, "Leave the current race.");
	RegConsoleCmd("sm_specrace", cmdRaceSpec, "Spectate a race.");
	RegConsoleCmd("sm_racelist", cmdRaceList, "Display race list");
	RegConsoleCmd("sm_raceinfo", cmdRaceInfo, "Display information about the race you are in.");
	RegAdminCmd("sm_serverrace", cmdRaceServer, ADMFLAG_GENERIC, "Invite everyone to a server wide race");

	// ADMIN
	RegAdminCmd("sm_mapset", cmdMapSet, ADMFLAG_GENERIC, "Change map settings");

	// HOOKS
	HookEvent("player_team", eventPlayerChangeTeam);
	HookEvent("player_changeclass", eventPlayerChangeClass);
	HookEvent("player_spawn", eventPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_death", eventPlayerDeath);
	HookEvent("controlpoint_starttouch", eventTouchCP);
	HookEvent("teamplay_round_start", eventRoundStart);
	HookEvent("post_inventory_application", eventInventoryUpdate);
	HookEvent("player_disconnect", eventPlayerDisconnect);
	HookEvent("teamplay_flag_event", eventIntelPickedUp, EventHookMode_Pre);

	HookUserMessage(GetUserMessageId("VoiceSubtitle"), hookVoice, true);

	AddCommandListener(listenerJoinTeam, "jointeam");
	AddCommandListener(listenerJoinClass, "joinclass");
	AddCommandListener(listenerJoinClass, "join_class");

	// HIDE
	AddNormalSoundHook(hookSound);

	AddTempEntHook("TFExplosion", hookTempEnt);
	AddTempEntHook("TFBlood", hookTempEnt);
	AddTempEntHook("TFParticleEffect", hookTempEnt);

	g_hForwardSKeys = CreateGlobalForward("OnClientKeys", ET_Event, Param_Cell, Param_CellByRef);

	// SKEYS Objects
	g_hHudDisplayForward = CreateHudSynchronizer();
	g_hHudDisplayASD = CreateHudSynchronizer();
	g_hHudDisplayJump = CreateHudSynchronizer();
	g_hHudDisplayAttack = CreateHudSynchronizer();

	g_aNoFuncRegen = new ArrayList();

	g_smCapturePoint = new StringMap();
	g_smCapturePointName = new StringMap();
	g_smCaptureArea = new StringMap();
	g_smCaptureAreaName = new StringMap();

	LoadTranslations("common.phrases");

	g_hJAMessageCookie = RegClientCookie("JAMessage_cookie", "Jump Assist Message Cookie", CookieAccess_Protected);

	SetAllSkeysDefaults();
	ConnectToDatabase();

	// GOTO
	CreateGoToArrays();
	
	// LATELOAD
	if (g_bLateLoad) {
		PrintJAMessageAll("%sJumpAssist\x01 has been%s reloaded.", cTheme2, cTheme2);
		GetCurrentMap(g_sCurrentMap, sizeof(g_sCurrentMap));
		for (int i = 1; i <= MaxClients; i++) {
			if (IsValidClient(i)) {
				g_iClientTeam[i] = GetClientTeam(i);
				g_TFClientClass[i] = TF2_GetPlayerClass(i);
				if (GetClientAuthId(i, AuthId_Steam2, g_sClientSteamID[i], sizeof(g_sClientSteamID[]))) {
					g_bFeaturesEnabled[i] = true;
				}
				SDKHook(i, SDKHook_WeaponEquipPost, hookOnWeaponEquipPost);
				SDKHook(i, SDKHook_SetTransmit, hookSetTransmitClient);
				GetClientWeapons(i);
			}
			else if (IsClientConnected(i) && IsClientInGame(i) && IsFakeClient(i)) {
				SDKHook(i, SDKHook_SetTransmit, hookSetTransmitClient);
			}
		}
		// HIDE
		int ent = -1;
		while((ent = FindEntityByClassname(ent, "item_teamflag")) != INVALID_ENT_REFERENCE) {
			SDKHook(ent, SDKHook_SetTransmit, hookSetTransmitIntel);
		}
	}
}

public void OnAllPluginsLoaded() {
	g_bSaveLoc = LibraryExists("saveloc");
}

public void OnPluginEnd() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientPreviewing(i)) {
		   DisablePreview(i, IsClientInGame(i));
		   PrintJAMessage(i, "Plugin reloading: Restoring location");
		}
	}
}

public void OnMapStart() {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}

	g_bCPFallback = false;
	GetCurrentMap(g_sCurrentMap, sizeof(g_sCurrentMap));

	for (int i = 1; i <= MaxClients; i++) {
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

	HookFuncRegenerate();
	SetUpCapturePoints();
}

void SetUpCapturePoints() {
	g_iCPCount = 0;

	g_smCapturePoint.Clear();
	g_smCapturePointName.Clear();
	g_smCaptureArea.Clear();
	g_smCaptureAreaName.Clear();

	int entity;
	int cpCount;
	int idx;
	char name[64];
	char areaidx[3];
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != INVALID_ENT_REFERENCE) {
		GetEntPropString(entity, Prop_Data, "m_iszPrintName", name, sizeof(name));
		idx = GetEntProp(entity, Prop_Data, "m_iPointIndex");
		Format(areaidx, sizeof(areaidx), "%i", idx);

		g_smCapturePoint.SetValue(name, idx);
		g_smCapturePointName.SetString(areaidx, name);

		cpCount++;
	}

	while ((entity = FindEntityByClassname(entity, "trigger_capture_area")) != INVALID_ENT_REFERENCE) {
		SDKHook(entity, SDKHook_StartTouchPost, hookCPStartTouchPost);

		GetEntPropString(entity, Prop_Data, "m_iszCapPointName", name, sizeof(name));
		g_smCaptureArea.SetValue(name, g_iCPCount);

		Format(areaidx, sizeof(areaidx), "%i", g_iCPCount);
		g_smCaptureAreaName.SetString(areaidx, name);

		SetVariantString("2 0");
		AcceptEntityInput(entity, "SetTeamCanCap");
		SetVariantString("3 0");
		AcceptEntityInput(entity, "SetTeamCanCap");
		g_iCPCount++;
	}
	//PrintToChatAll("CPCount = %i trigger count = %i", cpCount, g_iCPCount);
	if (cpCount < g_iCPCount) {
		g_bCPFallback = true;
	}
}

public void OnConfigsExecuted() {
	FindConVar("mp_respawnwavetime").SetInt(0);
	FindConVar("sv_noclipspeed").SetFloat(2.5);
	FindConVar("tf_weapon_criticals").SetInt(g_cvarCriticals.BoolValue, true, false);
	FindConVar("tf_sentrygun_ammocheat").SetInt(g_cvarAmmoCheat.BoolValue);
}

public void OnClientCookiesCached(int client) {
	char sValue[8];
	GetClientCookie(client, g_hJAMessageCookie, sValue, sizeof(sValue));
	g_bHideMessage[client] = (sValue[0] != '\0' && StringToInt(sValue));
}

public void OnClientPostAdminCheck(int client) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}

	SDKHook(client, SDKHook_SetTransmit, hookSetTransmitClient);

	if (IsFakeClient(client)) {
		return;
	}
	
	SetPlayerDefaults(client);

	SDKHook(client, SDKHook_WeaponEquipPost, hookOnWeaponEquipPost);

	// Welcome message.
	if (g_cvarWelcomeMsg.BoolValue) {
		CreateTimer(15.0, WelcomePlayer, client);
	}

	if (!GetClientAuthId(client, AuthId_Steam2, g_sClientSteamID[client], sizeof(g_sClientSteamID[]))) {
		LogError("[JumpAssist] Unable to retrieve steam id on %N", client);
		return;
	}
	g_bFeaturesEnabled[client] = true;
	LoadPlayerProfile(client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	g_iButtons[client] = buttons;
	
	if (!IsValidClient(client)) {
		return Plugin_Continue;
	}
	// FOR SKEYS
	
	int observerMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
	int clientToShow = IsClientObserver(client) ? GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") : client;
	if (IsValidClient(clientToShow, true) && (g_bSKeysEnabled[client] || IsFakeClient(clientToShow)) && !(buttons & IN_SCORE) && observerMode != 7) {
		bool isEditing;
		if (g_iSkeysMode[client] == EDIT) {
			isEditing = true;
			g_fSkeysPos[client][XPOS] = Math_Clamp(g_fSkeysPos[client][XPOS] + 0.0005 * mouse[0], 0.0, 0.85);
			g_fSkeysPos[client][YPOS] = Math_Clamp(g_fSkeysPos[client][YPOS] + 0.0005 * mouse[1], 0.0, 0.90);

			if (buttons & (IN_ATTACK|IN_ATTACK2)) {
				g_iSkeysMode[client] = DISPLAY;
				SaveKeyPos(client, g_fSkeysPos[client][XPOS], g_fSkeysPos[client][YPOS]);

				CreateTimer(0.2, timerUnfreeze, client);
			}
			else if (buttons & (IN_ATTACK3|IN_JUMP)) {
				g_fSkeysPos[client][XPOS] = XPOSDEFAULT;
				g_fSkeysPos[client][YPOS] = YPOSDEFAULT;
				
				g_iSkeysMode[client] = DISPLAY;
				SaveKeyPos(client, g_fSkeysPos[client][XPOS], g_fSkeysPos[client][YPOS]);

				CreateTimer(0.2, timerUnfreeze, client);
			}
		}

		int btns = g_iButtons[clientToShow];

		Action result = Plugin_Continue;
		Call_StartForward(g_hForwardSKeys);
		Call_PushCell(client);
		Call_PushCellRef(btns);
		Call_Finish(result);

		int buttonsToShow;
		switch (result) {
			case Plugin_Changed: {
				buttonsToShow = btns;
			}
			case Plugin_Handled, Plugin_Stop: {
				buttonsToShow = 0;
			}
			case Plugin_Continue: {
				buttonsToShow = isEditing ? ALLKEYS : g_iButtons[clientToShow];
			}
		}

		int
			  R = g_iSkeysColor[client][RED]
			, G = g_iSkeysColor[client][GREEN]
			, B = g_iSkeysColor[client][BLUE]
			, alpha = 255;
		bool
			  W = !!(buttonsToShow & IN_FORWARD)
			, A = !!(buttonsToShow & IN_MOVELEFT)
			, S = !!(buttonsToShow & IN_BACK)
			, D = !!(buttonsToShow & IN_MOVERIGHT)
			, Duck = !!(buttonsToShow & IN_DUCK)
			, Jump = !!(buttonsToShow & IN_JUMP)
			, M1 = !!(buttonsToShow & IN_ATTACK)
			, M2 = !!(buttonsToShow & IN_ATTACK2);
		float
			  hold = 0.3
			, X = g_fSkeysPos[client][XPOS]
			, Y = g_fSkeysPos[client][YPOS];

		SetHudTextParams(X+(W?0.047:0.052), Y, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayForward, (W?"W":"-"));

		SetHudTextParams(X+0.04-(A?0.0042:0.0)-(S?0.0015:0.0), Y+0.04, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayASD, "%c %c %c", (A?'A':'-'), (S?'S':'-'), (D?'D':'-'));

		SetHudTextParams(X+0.08, Y, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayJump, "%s\n%s", (Duck?" Duck":""), (Jump?"Jump":""));

		SetHudTextParams(X, Y, hold, R, G, B, alpha, .fadeIn=0.0, .fadeOut=0.0);
		ShowSyncHudText(client, g_hHudDisplayAttack, "%s\n%s", (M1?"M1":""), (M2?"M2":""));

		//.54 x def and .4 y def
	}

	if (IsClientPreviewing(client) && (buttons & IN_ATTACK)) {
		DisablePreview(client, true, true);
	}

	if (g_bAmmoRegen[client] && buttons & (IN_ATTACK|IN_ATTACK2) && !IsClientObserver(client)) {
		for (int i = 0; i <= 2; i++) {
			ReSupply(client, g_iClientWeapons[client][i]);
		}
	}

	if (g_bRaceLocked[client]) {
		vel = nullVector;
		buttons = 0;
	}

	int iMaxHealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	if (!IsClientObserver(client) && GetClientHealth(client) < iMaxHealth) {
		SetEntityHealth(client, iMaxHealth);
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

/* ======================================================================
   ------------------------------- Natives
*/

public int Native_IsClientHiding(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	if (!IsClientConnected(client)) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}
	return IsClientHiding(client);
}

public int Native_IsClientHardcore(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	if (!IsClientConnected(client)) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}
	return IsClientHardcore(client);
}

public int Native_IsClientRacing(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	if (!IsClientConnected(client)) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}
	return IsClientRacing(client);
}

public int Native_ToggleKeys(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	if (!IsClientConnected(client)) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}
	g_bSKeysEnabled[client] = GetNativeCell(2);
	return 1;
}

public int Native_PauseTeleport(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	if (!IsClientConnected(client)) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}

	PauseTeleport(client);
	return 1;
}

public int Native_PrintMessage(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (!IsValidClient(client)) {
		return 0;
	}
	char buffer[1024]; 
	int written;

	FormatNativeString(0, 2, 3, sizeof(buffer), written, buffer);

	PrintJAMessage(client, buffer);
	return 1;
}

public int Native_PrintMessageAll(Handle plugin, int numParams) {
	char buffer[1024]; 
	int written;

	FormatNativeString(0, 1, 2, sizeof(buffer), written, buffer);

	PrintJAMessageAll(buffer);
	return 1;
}

/* ======================================================================
   ------------------------------- CVAR Hook
*/

public void cvarAmmoCheatChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	FindConVar("tf_sentrygun_ammocheat").SetInt(!!StringToInt(newValue));
}

public void cvarWelcomeMsgChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	g_cvarWelcomeMsg.SetBool(!!StringToInt(newValue));
}

public void cvarSupermanChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	g_cvarSuperman.SetBool(!!StringToInt(newValue));
}

/* ======================================================================
   ------------------------------- Events/Listeners
*/

public Action listenerJoinClass(int client, const char[] command, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	if (IsClientPreviewing(client)) {
		PrintJAMessage(client, "You may not change class during%s preview mode\x01.", cTheme2);
		return Plugin_Handled;
	}
	if (IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client) && g_bRaceClassForce[g_iRaceID[client]]) {
		PrintJAMessage(client, "Cannot change class while racing.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action listenerJoinTeam(int client, const char[] command, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	if (IsClientPreviewing(client)) {
		PrintJAMessage(client, "You may not change team during%s preview mode\x01.", cTheme2);
		return Plugin_Handled;
	}
	// Get clients raceid for readability
	int raceID = g_iRaceID[client];
	// If raceid > 0 and player is in a race, prevent them from changing teams
	if (raceID && (g_iRaceStatus[raceID] == STATUS_COUNTDOWN || g_iRaceStatus[raceID] == STATUS_RACING)) {
		PrintJAMessage(client, "You may not change teams during a race.");
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

	g_fOrigin[client] = NULL_VECTOR;
	g_fAngles[client] = NULL_VECTOR;
	g_fLastSavePos[client] = NULL_VECTOR;

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

public void eventPlayerChangeTeam(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	int team = event.GetInt("team");
	g_iClientTeam[client] = team;
	if (g_iIntelCarrier == client) {
		int ent = -1;
		while((ent = FindEntityByClassname(ent, "item_teamflag")) != INVALID_ENT_REFERENCE) {
			AcceptEntityInput(ent, "ForceDrop");
			AcceptEntityInput(ent, "ForceReset");
			g_iIntelCarrier = 0;
		}	
	}
}

public void eventPlayerChangeClass(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	int class = event.GetInt("class");
	g_TFClientClass[client] = view_as<TFClassType>(class);
	if (IsPlayerAlive(client)) {
		TF2_RespawnPlayer(client);
	}
}

public Action eventPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (GetClientTeam(client) == g_iClientTeam[client] || g_bMapSetUsed) {
		RequestFrame(framerequestRespawn, client);
	}

	if (IsClientPreviewing(client)) {
		DisablePreview(client, IsClientInGame(client));
	}
	return Plugin_Handled;
}

public Action eventPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsFakeClient(client)) {
		return Plugin_Continue;
	}

	if (g_bJustSpawned[client]) {
		return Plugin_Continue;
	}

	// spec lock
	for (int i = 1; i <= MaxClients; i++) {
		if (g_iSpecTarget[i] == client) {
			FakeClientCommand(i, "spec_player #%i", GetClientUserId(client));
			FakeClientCommand(i, "spec_mode 1");
		}
	}
	g_iSpecTarget[client] = 0;
	g_bUnkillable[client] = false;
	g_fLastSavePos[client] = NULL_VECTOR;
	g_iRaceSpec[client] = 0;

	if (IsClientPreviewing(client)) {
		DisablePreview(client);
	}

	GetClientWeapons(client);

	// Disable func_regenerate if player is using beggers bazooka
	CheckBeggars(client);

	if (IsClientForcedSpec(client)) {
		RestoreFSpecLocation(client);
	}

	if (g_Database != null && g_bFeaturesEnabled[client]) {
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

	// spec lock
	g_iSpecTarget[client] = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (g_iSpecTarget[i] == client) {
			g_iSpecTarget[i] = 0;
		}
	}
	
	if (IsClientPreviewing(client)) {
		DisablePreview(client);
	}

	SetPlayerDefaults(client);
	
	if (g_iRaceID[client] != 0) {
		LeaveRace(client);
	}
	int idx;
	if ((idx = g_aNoFuncRegen.FindValue(client)) != -1) {
		g_aNoFuncRegen.Erase(idx);
	}

	g_bTelePaused[client] = false;
}

public void eventRoundStart(Handle event, const char[] name, bool dontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}

	HookFuncRegenerate();
	SetUpCapturePoints();
}

public Action eventIntelPickedUp(Event event, const char[] name, bool dontBroadcast) {
	event.BroadcastDisabled = true;
	int client = event.GetInt("player");
	int eventType = event.GetInt("eventtype");

	switch (eventType) {
		case INTEL_PICKEDUP: {
			g_iIntelCarrier = client;
			g_bIntelPickedUp = true;
		}
		case INTEL_DROPPED: {
			g_iIntelCarrier = 0;
			g_bIntelPickedUp = false;
		}
	}

	return Plugin_Continue;
}

public Action eventTouchCP(Event event, const char[] name, bool dontBroadcast) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	int client = event.GetInt("player");

	if (IsFakeClient(client) || IsClientPreviewing(client) || g_bSaveLoc && SL_IsClientPracticing(client)) {
		return Plugin_Continue;
	}

	int area = event.GetInt("area");

	if (g_bCPTouched[client][area] && g_iRaceID[client] == 0) {
		return Plugin_Continue;
	}

	int raceID = g_iRaceID[client];

	if (g_iRaceEndPoint[raceID] == area && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)) {
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
		char cpName[32];
		char areaidx[3];
		Format(areaidx, sizeof(areaidx), "%i", area);
		(g_bCPFallback ? g_smCaptureAreaName : g_smCapturePointName).GetString(areaidx, cpName, sizeof(cpName));

		char className[33];
		GetClassName(g_TFClientClass[client], className, sizeof(className));

		char color[8];
		strcopy(color, sizeof(color), (g_iClientTeam[client] == TEAM_RED) ? cRedTeam : cBlueTeam);

		PrintJAMessageAll("%s%s%N\x01 has reached %s%s\x01 as %s%s\x01.", g_bHardcore[client] ? "[\x07FF4500Hardcore\x01] " : "", color, client, cTheme2, cpName, color, className);
		EmitSoundToAll("misc/freeze_cam.wav");
	
		if (g_iCPsTouched[client] == g_iCPCount) {
			g_bBeatTheMap[client] = true;
		}
	}

	g_bCPTouched[client][area] = true;
	g_iCPsTouched[client]++;
	return Plugin_Continue;
}

public void hookCPStartTouchPost(int entity, int other) {
	if (!g_bCPFallback || !IsValidClient(other)) {
		return;
	}

	char name[64];
	GetEntPropString(entity, Prop_Data, "m_iszCapPointName", name, sizeof(name));

	int area;
	if (!g_smCaptureArea.GetValue(name, area)) {
		return;
	}

	Event event = CreateEvent("controlpoint_starttouch");
	event.SetInt("player", other);
	event.SetInt("area", area);
	event.Fire();
}

public Action hookStartTouchFuncRegenerate(int entity, int other) {
	if (other <= MaxClients && g_aNoFuncRegen.Length && g_aNoFuncRegen.FindValue(other) != -1) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void hookOnWeaponEquipPost(int client, int weapon) {
	if (IsValidClient(client)) {
		GetClientWeapons(client);
	}
}

public Action hookVoice(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	int client = bf.ReadByte();

	if (IsClientPreviewing(client)) {
		return Plugin_Handled;
	}

	int vMenu1 = bf.ReadByte();
	int vMenu2 = bf.ReadByte();

	if (IsValidClient(client) && IsPlayerAlive(client)) {
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
	if (g_bSaveLoc && SL_IsClientPracticing(client)) {
		PrintJAMessage(client, "Can't save while using saveloc. Type%s /practice\x01 to disable", cTheme2);
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

	if (IsClientPreviewing(client)) {
		DisablePreview(client);
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
		PrintJAMessage(client, "You have been%s restarted\x01.", cTheme2);
	}

	if (IsClientPreviewing(client)) {
		DisablePreview(client);
	}

	g_iLastTeleport[client] = 0;
	return Plugin_Handled;
}

public Action cmdUndo(int client, int args) {
	if (IsZeroVector(g_fLastSavePos[client])) {
		PrintJAMessage(client, "%sNo save\x01 to restore\x01.", cTheme2);
		return Plugin_Handled;
	}

	g_fOrigin[client] = g_fLastSavePos[client];
	g_fAngles[client] = g_fLastSaveAngles[client];
		
	g_fLastSavePos[client] = NULL_VECTOR;
	g_fLastSaveAngles[client] = NULL_VECTOR;
		
	PrintJAMessage(client, "Previous save has been%s restored\x01.", cTheme2);
	return Plugin_Handled;
}

public Action cmdToggleAmmo(int client, int args) {
	if (client == 0) {
		return Plugin_Handled;
	}
	if (IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)) {
		PrintJAMessage(client, "You may not change regen during a race");
		return Plugin_Handled;
	}
	if (g_bHardcore[client]) {
		PrintJAMessage(client, "Cannot toggle ammo with %sHardcore\x01 enabled", cTheme2);
		return Plugin_Handled;
	}
	g_bAmmoRegen[client] = !g_bAmmoRegen[client];
	PrintJAMessage(client, "Ammo regen%s %s\x01.", cTheme2, g_bAmmoRegen[client]?"enabled":"disabled");
	return Plugin_Handled;
}

public Action cmdUnkillable(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Handled;
	}
	if (!g_cvarSuperman.BoolValue && !IsUserAdmin(client)) {
		PrintJAMessage(client, "Command disabled by server admin.", cTheme1);
		return Plugin_Handled;
	}
	g_bUnkillable[client] = !g_bUnkillable[client];
	SetEntProp(client, Prop_Data, "m_takedamage", g_bUnkillable[client]?1:2, 1);
	PrintJAMessage(client, "Superman%s %s", cTheme2, g_bUnkillable[client]?"enabled":"disabled");
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
	PrintJAMessage(client, "Messages will now be%s %s", cTheme2, g_bHideMessage[client]?"hidden":"displayed");
	SetClientCookie(client, g_hJAMessageCookie, g_bHideMessage[client]?"1":"0");
	return Plugin_Handled;
}

public Action cmdMapSet(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Handled;
	}
	if (g_Database == null) {
		PrintJAMessage(client, "This feature is not supported without a database configuration");
		return Plugin_Handled;
	}
	if (args < 2) {
		PrintJAMessage(client, "%sUsage\x01: !mapset <team|class|lockcps> <team color|class|on off>", cTheme2);
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

void PauseTeleport(int client) {
	g_bTelePaused[client] = true;
	CreateTimer(5.0, timerUnpauseTeleport, client);
}

bool IsTeleportPaused(int client) {
	return g_bTelePaused[client];
}

void SetPlayerDefaults(int client) {
	g_bFeaturesEnabled[client] = false;
	g_bIsPreviewing[client] = false;
	g_bAmmoRegen[client] = false;
	g_bHardcore[client] = false;
	g_bBeatTheMap[client] = false;
	g_bSKeysEnabled[client] = false;
	g_bUnkillable[client] = false;
	g_sClientSteamID[client][0] = '\0';
	g_iRaceID[client] = 0;

	EraseLocs(client);
	SetSkeysDefaults(client);
	ClearGoToArray(client);
}

void SaveLoc(int client) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return;
	}
	if (!g_bFeaturesEnabled[client]) {
		PrintJAMessage(client, "Feature disabled: Unable to retrieve steamid. Reconnect or try again in a few minutes.");
		return;
	}
	if (g_bHardcore[client]) {
		PrintJAMessage(client, "%sHardcore:\x01 Saves are%s disabled\x01.", cHardcore, cTheme2);
		return;
	}
	if (!IsPlayerAlive(client) || IsClientObserver(client)) {
		PrintJAMessage(client, "Must be%s alive\x01 to save.", cTheme2);
		return;
	}
	int flags = GetEntityFlags(client);
	if (!(flags & FL_ONGROUND)) {
		PrintJAMessage(client, "Unable to save while%s in the air\x01.", cTheme2);
		return;
	}
	if ((flags & FL_DUCKING)) {
		PrintJAMessage(client, "Unable to save while%s ducked\x01.", cTheme2);
		return;
	}
	if ((GetEntityMoveType(client) == MOVETYPE_NOCLIP)) {
		PrintJAMessage(client, "Unable to save while%s noclipped\x01.", cTheme2);
		return;
	}

	g_fLastSavePos[client] = g_fOrigin[client];
	g_fLastSaveAngles[client] = g_fAngles[client];

	GetClientAbsOrigin(client, g_fOrigin[client]);
	GetClientAbsAngles(client, g_fAngles[client]);
	if (g_Database != null && IsClientInGame(client)) {
		GetPlayerData(client);
	}
}

void Teleport(int client) {
	if (!g_cvarPluginEnabled.BoolValue || !IsValidClient(client)) {
		return;
	}
	if (!g_bFeaturesEnabled[client]) {
		PrintJAMessage(client, "Feature disabled: Unable to retrieve steamid. Reconnect or try again in a few minutes.");
		return;
	}
	if (g_iRaceID[client] && (g_iRaceStatus[g_iRaceID[client]] == STATUS_COUNTDOWN || g_iRaceStatus[g_iRaceID[client]] == STATUS_RACING)) {
		PrintJAMessage(client, "Cannot teleport while racing.");
		return;
	}
	if (g_bHardcore[client]) {
		PrintJAMessage(client, "%sHardcore:\x01 Teleports are%s disabled\x01.", cHardcore, cTheme2);
		return;
	}
	if (!IsPlayerAlive(client)) {
		PrintJAMessage(client, "Unable to teleport while%s dead\x01.", cTheme2);
		return;
	}

	char teamName[32];
	char teamColor[16];

	strcopy(teamName, sizeof(teamName), (g_iClientTeam[client] == TEAM_RED) ? "Red Team" : "Blue Team");
	teamColor = (g_iClientTeam[client] == TEAM_RED) ? cRedTeam : cBlueTeam;

	if (IsZeroVector(g_fOrigin[client])) {
		char className[33];
		GetClassName(g_TFClientClass[client], className, sizeof(className));
		PrintJAMessage(client, "You don't have a save for%s %s\x01 on the%s %s\x01.", teamColor, className, teamColor, teamName);
		return;
	}

	TeleportEntity(client, g_fOrigin[client], g_fAngles[client], nullVector);
	if (!g_bHideMessage[client]) {
		PrintJAMessage(client, "You have been%s teleported\x01.", cTheme2);
	}
}

void ResetPlayerPos(int client) {
	if (!g_cvarPluginEnabled.BoolValue || !IsClientInGame(client) || IsClientObserver(client) || !g_bFeaturesEnabled[client]) {
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
		PrintJAMessage(client, "%sHardcore%s enabled\x01.", cHardcore, cTheme2);
		return;
	}

	g_bHardcore[client] = false;
	LoadPlayerData(client);
	PrintJAMessage(client, "%sHardcore%s disabled\x01.", cHardcore, cTheme2);
}

bool IsClientHardcore(int client) {
	return g_bHardcore[client];
}

// Support for beggar's bazooka
void CheckBeggars(int client) {
	int weapon = GetPlayerWeaponSlot(client, 0);
	int index = g_aNoFuncRegen.FindValue(client);
	if (IsValidEntity(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 730) {
		if (index == -1) {
			g_aNoFuncRegen.Push(client);
		}
	}
	else if (index != -1){
		g_aNoFuncRegen.Erase(index);
	}
}

void HookFuncRegenerate() {
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "func_regenerate")) != INVALID_ENT_REFERENCE) {
		// Support for concmap*, and quad* maps that are imported from TFC.
		SDKUnhook(entity, SDKHook_StartTouch, hookStartTouchFuncRegenerate);
		SDKUnhook(entity, SDKHook_Touch, hookStartTouchFuncRegenerate);
		SDKUnhook(entity, SDKHook_EndTouch, hookStartTouchFuncRegenerate);
		SDKHook(entity, SDKHook_StartTouch, hookStartTouchFuncRegenerate);
		SDKHook(entity, SDKHook_Touch, hookStartTouchFuncRegenerate);
		SDKHook(entity, SDKHook_EndTouch, hookStartTouchFuncRegenerate);
	}
}

void GetClientWeapons(int client) {
	for (int i = 0; i <= 2; i++) {
		g_iClientWeapons[client][i] = GetPlayerWeaponSlot(client, i);
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
	else if (StrEqual(className, "tf_weapon_syringegun_medic")) {
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
	
	g_fOrigin[client] = NULL_VECTOR;
	g_fAngles[client] = NULL_VECTOR;

	for (int j = 0; j < MAX_CAP_POINTS; j++) {
		g_bCPTouched[client][j] = false;
	}

	g_iCPsTouched[client] = 0;
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
		PrintJAMessage(i, "Your team has been%s switched\x01.", cTheme2);
	}
}

void SendToStart(int client) {
	if (!g_cvarPluginEnabled.BoolValue || !IsValidClient(client) || IsClientObserver(client)) {
		return;
	}
	
	g_bUsedReset[client] = true;
	TF2_RespawnPlayer(client);

	if (!g_bHideMessage[client] && g_iRaceID[client] < 1) {
		PrintJAMessage(client, "You have been%s sent to map start\x01.", cTheme2);
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

void GetClassName(TFClassType class, char[] buffer, int size) {
	switch(class) {
		case TFClass_Scout: strcopy(buffer, size, "Scout");
		case TFClass_Sniper: strcopy(buffer, size, "Sniper");
		case TFClass_Soldier: strcopy(buffer, size, "Soldier");
		case TFClass_DemoMan: strcopy(buffer, size, "Demoman");
		case TFClass_Medic: strcopy(buffer, size, "Medic");
		case TFClass_Heavy: strcopy(buffer, size, "Heavy");
		case TFClass_Pyro: strcopy(buffer, size, "Pyro");
		case TFClass_Spy: strcopy(buffer, size, "Spy");
		case TFClass_Engineer: strcopy(buffer, size, "Engineer");
	}
}

bool IsValidClient(int client, int bot = false) {
	return (0 < client <= MaxClients && IsClientInGame(client) && (bot || !IsFakeClient(client)));
}

bool IsUserAdmin(int client) {
	return GetUserAdmin(client).HasFlag(Admin_Generic);
}

bool IsValidWeapon(int entity) {
	char strClassname[128];
	return (IsValidEntity(entity) && GetEntityClassname(entity, strClassname, sizeof(strClassname)) && StrContains(strClassname, "tf_weapon", false) != -1);
}

bool IsZeroVector(float vector[3]) {
	return vector[0] == 0.0 && vector[1] == 0.0 && vector[2] == 0.0;
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

void PrintJAMessage(int client, char[] message, any ...) {
	if (!IsValidClient(client)) {
		return;
	}

	char output[1024];
	VFormat(output, sizeof(output), message, 3);

	PrintColoredChatEx(client, CHAT_SOURCE_SERVER, "[%sJA\x01] %s", cTheme1, output);
}

void PrintJAMessageAll(char[] message, any...) {
	char output[1024];
	VFormat(output, sizeof(output), message, 2);

	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i)) {
			PrintColoredChatEx(i, CHAT_SOURCE_SERVER, "[%sJA\x01] %s", cTheme1, output);
		}
	}
}

/* ======================================================================
   ------------------------------- Timers
*/

void framerequestChangeTeam(DataPack dp) {
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
	if (IsClientConnected(data) && GetClientTeam(data) > 1) {
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

Action timerUnpauseTeleport(Handle timer, int client) {
	g_bTelePaused[client] = true;
}
