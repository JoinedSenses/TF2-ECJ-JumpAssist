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
																TODO
	**********************************************************************************************************************************
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
	*
	* UNOFFICIAL UPDATES BY TALKINGMELON
	* 0.7.1 - Regen is working better and skeys has less delay. Control points should work properly.
	*		- JA can now be used without a database configured.
	*		- Restart works properly.
	*		- The system for saving locations for admins is now working properly
	*		- Also general bugfixes
	*
	* 0.7.2 - Moved skeys and added m1/m2 support
	*		- Changed how commands are recognized to the way that is normally supported
	*		- General bugfixes
	*
	* 0.7.3 - Added support for updater plugin
	*
	* 0.7.4 - Added race functionality
	*
	* 0.7.5 - Fixed a number of racing bugs
	*
	* 0.7.6 - Racing now displays time in HH:MM:SS:MS or just MM:SS:MS if the time is short enough
	*		- Reorganized code to make it more readable and understandable
	*		- Spectators now get race alerts if they are spectating someone in a race
	*		- r_inv now works with argument targeting - ex !r_inv talkingmelon works now
	*		- restart no longer displays twice
	*		- When a player loads into a map, their previous caps will no longer be remembered - should fix the notification issue
	*		- Sounds should play properly
	*		- r_info added
	*		- r_spec added
	* 		- r_set added
	*
	* 0.7.7 - Can invite multiple people at once with the r_inv command
	*		- Fixed server_race bug
	*		- Tried to fix sounds (pls)
	*		- r_list command added
	*
	* 0.7.8 - Ammo regen after plugin reload working
	*		- skeys_loc now allows you to set the location of skeys on the screen
	*		- Actually fixed no alert on cp problem
	*		- r_list and r_info now work for spectators of a race
	*
	* 0.7.9 - Fixed undo bug that let you change classes and teams and still have your old teleport
	*		- Timer sould work in all time zones properly now
	*		- Fixed calling for medic giving regen during race
	*
	* 0.7.10 - Added !spec command
	*		 - Fixed potential for tele notification spam
	*		 - Improved the usability of the help menu
	*
	* 0.7.11 - Fixed timer team bug
	*		 - Fixed SQL ReloadPlayerData bug (maybe?)
	*
	*
	* 0.8.0 - Moved upater to github repository
		  - imported jumptracer
		  - added cvar ja_update_branch for server operators to select updating from
		  - from dev or master.  Must be set in server.cfg.
	*
	* TODO:
	* give race a better UI
	* R_LIST TIMES AFTER PLAYER DC
	* LOG TO SERVER WHEN THE MAPSET COMMAND IS USED
	* STARTING A SECOND RACE WITH THE FIRST ONE STILL IN PROGRESS OFTEN GIVES - YOU ARE NOT THE RACE LOBBY LEADER if everyone types !r_leave it works
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
	*
	*
	*
	* BUGS:
	* I'm sure there are plenty
	*	eventPlayerChangeTeam throws error on dc
	*	Dropped <name> from server (Disconnect by user.)
	*	L 12/02/2014 - 23:07:57: [SM] Native "ChangeClientTeam" reported: Client 2 is not in game
	*	L 12/02/2014 - 23:07:57: [SM] Displaying call stack trace for plugin "jumpassist.smx":
	*	L 12/02/2014 - 23:07:57: [SM]   [0]  Line 1590, scripting\jumpassist.sp::timerTeam()
	* Change to spec during race
	*
	* Race with 3 people - 2 finish - leader is one of them and starts new race inviting the other finisher and starts
	* Race keeps other person in it - may not have transfered leadership/may not leave race on !race if you are in one    --- I think i fixed this bug but is is difficult to test
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
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
	**********************************************************************************************************************************
																	NOTES
	**********************************************************************************************************************************
	*
	* You must have a mysql or sqlite database named jumpassist and configure it in /addons/sourcemod/configs/databases.cfg
	*
	* Once the database is set up, an example configuration would look like:
	*
	* "jumpassist"
    *     {
    *             "driver"                        "default"
    *             "host"                          "127.0.0.1"
    *             "database"                      "jumpassist"
    *             "user"                          "tf2server"
    *             "pass"                          "tf2serverpassword"
    *             //"timeout"                     "0"
    *             //"port"                        "0"
    *     }
	*
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

#define PLUGIN_VERSION "0.8.14"
#define PLUGIN_NAME "[TF2] Jump Assist"
#define PLUGIN_AUTHOR "rush - Updated by nolem, happs"
#define cDefault    0x01
#define cLightGreen 0x03
/*
	Core Includes
*/
new g_bRace[MAXPLAYERS+1];
new g_bRaceStatus[MAXPLAYERS+1];
	//1 - inviting players
	//2 - 3 2 1 countdown
	//3 - racing
	//4 - waiting for players to finish
	//  - Only updated for the lobby host
new Float:g_bRaceStartTime[MAXPLAYERS+1];
new Float:g_bRaceTime[MAXPLAYERS+1];
new Float:g_bRaceTimes[MAXPLAYERS+1][MAXPLAYERS];
new g_bRaceFinishedPlayers[MAXPLAYERS+1][MAXPLAYERS];
new Float:g_bRaceFirstTime[MAXPLAYERS+1];
new g_bRaceEndPoint[MAXPLAYERS+1];
new g_bRaceInvitedTo[MAXPLAYERS+1];
new bool:g_bRaceLocked[MAXPLAYERS+1];
new bool:g_bRaceAmmoRegen[MAXPLAYERS+1];
new bool:g_bRaceHealthRegen[MAXPLAYERS+1];
new bool:g_bRaceClassForce[MAXPLAYERS+1];
new g_bRaceSpec[MAXPLAYERS+1];
new speedrunStatus[32];
new g_iLastTeleport[MAXPLAYERS+1];
#include "jumpassist/skeys.sp"
#include "jumpassist/skillsrank.sp"
#include "jumpassist/database.sp"
#include "jumpassist/sound.sp"
#include "jumpassist/speedrun.sp"
new Handle:g_hWelcomeMsg;
new Handle:g_hCriticals;
new Handle:g_hSuperman;
new Handle:g_hSentryLevel;
new Handle:g_hCheapObjects;
new Handle:g_hAmmoCheat;
new Handle:g_hFastBuild;
//new Handle:hCvarBranch;
new Handle:hArray_NoFuncRegen;
new Handle:waitingForPlayers;
new String:szWebsite[128] = "http://www.jump.tf/";
new String:szForum[128] = "http://tf2rj.com/forum/";
new String:szJumpAssist[128] = "http://tf2rj.com/forum/index.php?topic=854.0";
public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Tools to run a jump server with ease.",
	version = PLUGIN_VERSION,
	url = "http://jump.tf"
}
public OnPluginStart()
{
	JA_CreateForward();
	// Skillsrank uses me!
	RegPluginLibrary("jumpassist");
	// ConVars
	CreateConVar("jumpassist_version", PLUGIN_VERSION, "Jump assist version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_hPluginEnabled = CreateConVar("ja_enable", "1", "Turns JumpAssist on/off.", FCVAR_NOTIFY);
	g_hWelcomeMsg = CreateConVar("ja_welcomemsg", "1", "Show clients the welcome message when they join?", FCVAR_NOTIFY);
	g_hFastBuild = CreateConVar("ja_fastbuild", "1", "Allows engineers near instant buildings.", FCVAR_NOTIFY);
	g_hAmmoCheat = CreateConVar("ja_ammocheat", "1", "Allows engineers infinite sentrygun ammo.", FCVAR_NOTIFY);
	g_hCheapObjects = CreateConVar("ja_cheapobjects", "0", "No metal cost on buildings.", FCVAR_NOTIFY);
	g_hCriticals = CreateConVar("ja_crits", "0", "Allow critical hits.", FCVAR_NOTIFY);
	g_hSuperman = CreateConVar("ja_superman", "0", "Allows everyone to be invincible.", FCVAR_NOTIFY);
	//g_hSoundBlock = CreateConVar("ja_sounds", "0", "Block pain, regenerate, and ammo pickup sounds?", FCVAR_NOTIFY);
	g_hSentryLevel = CreateConVar("ja_sglevel", "1", "Sets the default sentry level (1-3)", FCVAR_NOTIFY);
	//char sDesc[128]="";
	//Format(sDesc,sizeof(sDesc),"Select a branch folder from %s to update from.", UPDATE_URL_BASE);
	//hCvarBranch = CreateConVar("ja_update_branch", UPDATE_URL_BRANCH, sDesc, FCVAR_NOTIFY);
	hSpeedrunEnabled = CreateConVar("ja_speedrun_enabled", "0", "Turns speedrunning on/off", FCVAR_NOTIFY);
	// Jump Assist console commands
	RegConsoleCmd("ja_help", cmdJAHelp, "Shows JA's commands.");
	RegConsoleCmd("sm_hardcore", cmdToggleHardcore, "Sends you back to the beginning without deleting your save..");
	RegConsoleCmd("sm_r", cmdReset, "Sends you back to the beginning without deleting your save..");
	RegConsoleCmd("sm_reset", cmdReset, "Sends you back to the beginning without deleting your save..");
	RegConsoleCmd("sm_restart", cmdRestart, "Deletes your save, and sends you back to the beginning.");
	RegConsoleCmd("sm_setmy", cmdSetMy, "Saves player settings.");
	//RegConsoleCmd("sm_goto", cmdGotoClient, "Goto <target>");
	RegConsoleCmd("sm_s", cmdSave, "Saves your current position.");
	RegConsoleCmd("sm_save", cmdSave, "Saves your current position.");
	RegConsoleCmd("sm_regen", cmdDoRegen, "Changes regeneration settings.");
	RegConsoleCmd("sm_undo", cmdUndo, "Restores your last saved position.");
	RegConsoleCmd("sm_t", cmdTele, "Teleports you to your current saved location.");
	RegConsoleCmd("sm_ammo", cmdToggleAmmo, "Regenerates weapon ammunition");
	RegConsoleCmd("sm_health", cmdToggleHealth, "Regenerates health");
	RegConsoleCmd("sm_tele", cmdTele, "Teleports you to your current saved location.");
	RegConsoleCmd("sm_skeys", cmdGetClientKeys, "Toggle showing a clients key's.");
	RegConsoleCmd("sm_skeys_color", cmdChangeSkeysColor, "Changes the color of the text for skeys."); //cannot whether the database is configured or not
	RegConsoleCmd("sm_skeys_loc", cmdChangeSkeysLoc, "Changes the color of the text for skeys.");
	RegConsoleCmd("sm_superman", cmdUnkillable, "Makes you strong like superman.");
	RegConsoleCmd("sm_jumptf", cmdJumpTF, "Shows the jump.tf website.");
	RegConsoleCmd("sm_forums", cmdJumpForums, "Shows the jump.tf forums.");
	RegConsoleCmd("sm_jumpassist", cmdJumpAssist, "Shows the forum page for JumpAssist.");
	//RegConsoleCmd("sm_spec", cmdSpec, "Sets you as spectator of a player.");
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
	RegAdminCmd("sm_server_race", cmdServerRace, ADMFLAG_GENERIC, "Invite everyone to a server wide race");
	RegAdminCmd("sm_s_race", cmdServerRace, ADMFLAG_GENERIC, "Invite everyone to a server wide race");
	// Admin Commands
	RegAdminCmd("sm_mapset", cmdMapSet, ADMFLAG_GENERIC, "Change map settings");
	RegAdminCmd("sm_send", cmdSendPlayer, ADMFLAG_GENERIC, "Send target to another target.");
	//RegAdminCmd("sm_jatele", SendToLocation, ADMFLAG_ROOT, "Sends a player to the spcified jump.");
	//RegAdminCmd("sm_addtele", cmdAddTele, ADMFLAG_ROOT, "Adds a teleport location for the current map");
	//RegAdminCmd("sm_removetele", cmdRemoveTele, ADMFLAG_ROOT, "Removes a teleport location for the current map");
	RegAdminCmd("sm_setstart", cmdSetStart, ADMFLAG_ROOT, "Sets the map start location for speedrunning");
	RegAdminCmd("sm_addzone", cmdAddZone, ADMFLAG_ROOT, "Adds a checkpoint or end zone for speedrunning");
	RegAdminCmd("sm_clearzones", cmdClearZones, ADMFLAG_ROOT, "Deletes all zones on the current map");
	RegAdminCmd("sm_cleartimes", cmdClearTimes, ADMFLAG_ROOT, "Deletes all times on the current map");
	RegAdminCmd("sm_sr_force_reload", cmdSpeedrunForceReload, ADMFLAG_ROOT, "Deletes all times on the current map");
	RegConsoleCmd("sm_showzones", cmdShowZones, "Shows all zones of the map");
	RegConsoleCmd("sm_rmtime", cmdRemoveTime, "Removes your time on the map");
	RegConsoleCmd("sm_showzone", cmdShowZone, "Shows the current zone and says what zone it is");
	RegConsoleCmd("sm_sz", cmdShowZone, "Shows the current zone and says what zone it is");
	RegConsoleCmd("sm_speedrun", cmdToggleSpeedrun, "Enables/disables speedrunning");
	RegConsoleCmd("sm_sr", cmdToggleSpeedrun, "Enables/disables speedrunning");
	RegConsoleCmd("sm_stopspeedrun", cmdDisableSpeedrun, "Disables speedrunning");
	RegConsoleCmd("sm_pr", cmdShowPR, "Shows your personal record");
	RegConsoleCmd("sm_wr", cmdShowWR, "Shows the map record");
	RegConsoleCmd("sm_top", cmdShowTop, "Shows the map record");
	RegConsoleCmd("sm_pi", cmdShowPlayerInfo, "Shows the player's runs");
	//RegConsoleCmd("sm_stest", cmdTest, "Shows the map record");
	RegConsoleCmd("sm_top", cmdShowTop, "Shows the top speedruns of the map");
	// ROOT COMMANDS, they're set to root users for a reason.
	//RegAdminCmd("sm_ja_query", RunQuery, ADMFLAG_ROOT, "Runs a SQL query on the JA database. (FOR TESTING)");
//#if defined DEBUG
	//RegAdminCmd("sm_ja_update_force", Command_Update, ADMFLAG_RCON, "Forces update check of plugin");
//#endif
	// Hooks
	HookEvent("player_team", eventPlayerChangeTeam);
	HookEvent("player_changeclass", eventPlayerChangeClass);
	HookEvent("player_spawn", eventPlayerSpawn);
	HookEvent("player_death", eventPlayerDeath);
	HookEvent("player_hurt", eventPlayerHurt);
	HookEvent("controlpoint_starttouch", eventTouchCP);
	HookEvent("player_builtobject", eventPlayerBuiltObj);
	HookEvent("player_upgradedobject", eventPlayerUpgradedObj);
	HookEvent("teamplay_round_start", eventRoundStart);
	HookEvent("post_inventory_application", eventInventoryUpdate);
	// ConVar Hooks
	HookConVarChange(g_hFastBuild, cvarFastBuildChanged);
	HookConVarChange(g_hCheapObjects, cvarCheapObjectsChanged);
	HookConVarChange(g_hAmmoCheat, cvarAmmoCheatChanged);
	HookConVarChange(g_hWelcomeMsg, cvarWelcomeMsgChanged);
	HookConVarChange(g_hSuperman, cvarSupermanChanged);
	HookConVarChange(g_hSentryLevel, cvarSentryLevelChanged);
	HookConVarChange(hSpeedrunEnabled, cvarSpeedrunEnabledChanged);
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
	for(new i = 0; i < MAXPLAYERS+1; i++){
		if (IsValidClient(i))
		{
			g_iClientWeapons[i][0] = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
			g_iClientWeapons[i][1] = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			g_iClientWeapons[i][2] = GetPlayerWeaponSlot(i, TFWeaponSlot_Melee);
		}
		g_iLastTeleport[i] = 0;
	}
	SetAllSkeysDefaults();

	ConnectToDatabase();
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("JA_ClearSave", Native_JA_ClearSave);
	CreateNative("JA_GetSettings", Native_JA_GetSettings);
	CreateNative("JA_PrepSpeedRun", Native_JA_PrepSpeedRun);
	CreateNative("JA_ReloadPlayerSettings", Native_JA_ReloadPlayerSettings);
	g_bLateLoad = late;
	return APLRes_Success;
}
public OnAllPluginsLoaded()
{
	skillsrank = LibraryExists("skillsrank");
}
enum TFGameType {
	TFGame_Unknown,
	TFGame_CaptureTheFlag,
	TFGame_CapturePoint,
	TFGame_Payload,
	TFGame_Arena,
};
TF2_SetGameType()
{
	GameRules_SetProp("m_nGameType", 2);
}

    enum TFExtObjectType
    {
        TFExtObject_Unknown = -1,
        TFExtObject_CartDispenser = 0,
        TFExtObject_Dispenser = 0,
        TFExtObject_Teleporter = 1,
        TFExtObject_Sentry = 2,
        TFExtObject_Sapper = 3,
        TFExtObject_TeleporterEntry,
        TFExtObject_TeleporterExit,
        TFExtObject_MiniSentry,
        TFExtObject_Amplifier,
        TFExtObject_RepairNode
    };
    stock const String:TF2_ObjectClassNames[TFExtObjectType][] =
    {
        "obj_dispenser",
        "obj_teleporter",
        "obj_sentrygun",
        "obj_sapper",
        "obj_teleporter", // _entrance
        "obj_teleporter", // _exit
        "obj_sentrygun",  // minisentry
        "obj_dispenser",  // amplifier
        "obj_dispenser"   // repair_node
    };
    stock const String:TF2_ObjectNames[TFExtObjectType][] =
    {
        "Dispenser",
        "Teleporter",
        "Sentry Gun",
        "Sapper",
        "Teleporter Entrance",
        "Teleporter Exit",
        "Mini Sentry Gun",
        "Amplifier",
        "Repair Node"
    };
    stock TF2_ObjectModes[TFExtObjectType] =
    {
        -1, // dispenser
        -1, // teleporter (either)
        -1, // sentrygun
        -1, // sapper
         0, // telporter_entrance
         1, // teleporter_exit
        -1, // minisentry
        -1, // amplifier
        -1  // repair_node
    };
    // Max Sentry Ammo for Level:         mini,   1,   2,   3, max
    stock const TF2_MaxSentryShells[]  = { 150, 100, 120, 144,  255 };
    stock const TF2_MaxSentryRockets[] = {   0,   0,   0,  20,   63 };
    stock const TF2_SentryHealth[]     = { 100, 150, 180, 216, 8191 };
    stock const TF2_MaxUpgradeMetal    = 200;
    stock const TF2_MaxDispenserMetal  = 400;
	
stock BuildSentry(hBuilder, const Float:fOrigin[3], const Float:fAngle[3], iLevel=1,
                  bool:bDisabled=false, bool:bMini=false, bool:bShielded=false,
                  iHealth=-1, iMaxHealth=-1, iShells=-1, iRockets=-1,
                  Float:flPercentage=1.0)
{
    static const Float:fBuildMaxs[3] = { 24.0, 24.0, 66.0 };
    //static const Float:fMdlWidth[3] = { 1.0, 0.5, 0.0 };
    new iTeam = GetClientTeam(hBuilder);
    new iSentryHealth;
    new iMaxSentryShells;
    new iMaxSentryRockets;
    if (iLevel < 1 || bMini)
    {
        iLevel = 1;
        iSentryHealth = TF2_SentryHealth[0];
        iMaxSentryShells = TF2_MaxSentryShells[0];
        iMaxSentryRockets = TF2_MaxSentryRockets[0];
    }
    else if (iLevel <= 3)
    {
        iSentryHealth = TF2_SentryHealth[iLevel];
        iMaxSentryShells = TF2_MaxSentryShells[iLevel];
        iMaxSentryRockets = TF2_MaxSentryRockets[iLevel];
    }
    else if (iLevel == 4)
    {
        iLevel = 3;
        iSentryHealth = TF2_SentryHealth[3]+40;
        iMaxSentryShells = (TF2_MaxSentryShells[3]+TF2_MaxSentryShells[4])/2;
        iMaxSentryRockets = (TF2_MaxSentryRockets[3]+TF2_MaxSentryRockets[4])/2;
    }
    else
    {
        iLevel = 3;
        iSentryHealth = TF2_SentryHealth[4];
        iMaxSentryShells = TF2_MaxSentryShells[4];
        iMaxSentryRockets = TF2_MaxSentryRockets[4];
    }
    if (iShells < 0)
        iRockets = iMaxSentryRockets;
    if (iShells < 0)
        iShells = iMaxSentryShells;
    if (iMaxHealth < 0)
        iMaxHealth = iSentryHealth;
    if (iHealth < 0 || iHealth > iMaxHealth)
        iHealth = iMaxHealth;
    new iSentry = CreateEntityByName(TF2_ObjectClassNames[TFExtObject_Sentry]);
    if (iSentry > 0 && IsValidEdict(iSentry))
    {
        DispatchSpawn(iSentry);
        TeleportEntity(iSentry, fOrigin, fAngle, NULL_VECTOR);
        decl String:sModel[64];
        if (bMini)
            strcopy(sModel, sizeof(sModel),"models/buildables/sentry1.mdl");
        else
            Format(sModel, sizeof(sModel),"models/buildables/sentry%d.mdl", iLevel);
        SetEntityModel(iSentry,sModel);
        // m_bPlayerControlled is set to make m_bShielded work,
        // but it gets reset almost immediately :(
        SetEntProp(iSentry, Prop_Send, "m_iMaxHealth", 				        iMaxHealth, 4);
        SetEntProp(iSentry, Prop_Send, "m_iHealth", 					    iHealth, 4);
        SetEntProp(iSentry, Prop_Send, "m_bDisabled", 				        bDisabled, 2);
        SetEntProp(iSentry, Prop_Send, "m_bShielded", 				        bShielded, 2);
        SetEntProp(iSentry, Prop_Send, "m_bPlayerControlled", 				bShielded, 2);
        SetEntProp(iSentry, Prop_Send, "m_bMiniBuilding", 				    bMini, 2);
        SetEntProp(iSentry, Prop_Send, "m_iObjectType", 				    _:TFExtObject_Sentry, 1);
        SetEntProp(iSentry, Prop_Send, "m_iUpgradeLevel", 			        iLevel, 4);
        SetEntProp(iSentry, Prop_Send, "m_iAmmoRockets", 				    iRockets, 4);
        SetEntProp(iSentry, Prop_Send, "m_iAmmoShells" , 				    iShells, 4);
        SetEntProp(iSentry, Prop_Send, "m_iState" , 				        (bShielded ? 2 : 0), 4);
        SetEntProp(iSentry, Prop_Send, "m_iObjectMode", 				    0, 2);
        SetEntProp(iSentry, Prop_Send, "m_iUpgradeMetal", 			        0, 2);
        SetEntProp(iSentry, Prop_Send, "m_bBuilding", 				        0, 2);
        SetEntProp(iSentry, Prop_Send, "m_bPlacing", 					    0, 2);
        SetEntProp(iSentry, Prop_Send, "m_iState", 					        1, 1);
        SetEntProp(iSentry, Prop_Send, "m_bHasSapper", 				        0, 2);
        SetEntProp(iSentry, Prop_Send, "m_nNewSequenceParity", 		        4, 4);
        SetEntProp(iSentry, Prop_Send, "m_nResetEventsParity", 		        4, 4);
        SetEntProp(iSentry, Prop_Send, "m_bServerOverridePlacement", 	    1, 1);
        SetEntProp(iSentry, Prop_Send, "m_nSequence",                       0);
        SetEntPropEnt(iSentry, Prop_Send, "m_hBuilder", 	                hBuilder);
        SetEntPropFloat(iSentry, Prop_Send, "m_flPercentageConstructed", 	flPercentage);
        SetEntPropFloat(iSentry, Prop_Send, "m_flModelWidthScale", 	        1.0);
        SetEntPropFloat(iSentry, Prop_Send, "m_flPlaybackRate", 			1.0);
        SetEntPropFloat(iSentry, Prop_Send, "m_flCycle", 					0.0);
        SetEntPropVector(iSentry, Prop_Send, "m_vecOrigin", 			    fOrigin);
        SetEntPropVector(iSentry, Prop_Send, "m_angRotation", 		        fAngle);
        SetEntPropVector(iSentry, Prop_Send, "m_vecBuildMaxs", 		        fBuildMaxs);
        //SetEntDataVector(iSentry, FindSendPropOffs("CObjectSentrygun","m_flModelWidthScale"),	fMdlWidth, true);
        if (bMini)
        {
            SetEntProp(iSentry, Prop_Send, "m_nSkin", 					    iTeam, 1);
            SetEntProp(iSentry, Prop_Send, "m_nBody", 					    5, 1);
        }
        else
        {
            SetEntProp(iSentry, Prop_Send, "m_nSkin", 					    (iTeam-2), 1);
            SetEntProp(iSentry, Prop_Send, "m_nBody", 					    0, 1);
        }
        SetVariantInt(iTeam);
        AcceptEntityInput(iSentry, "TeamNum", -1, -1, 0);
        SetVariantInt(iTeam);
        AcceptEntityInput(iSentry, "SetTeam", -1, -1, 0);
        SetVariantInt(hBuilder);
        AcceptEntityInput(iSentry, "SetBuilder", -1, -1, 0);
        new Handle:event = CreateEvent("player_builtobject");
        if (event != INVALID_HANDLE)
        {
            SetEventInt(event, "userid", GetClientUserId(hBuilder));
            SetEventInt(event, "object", _:TFExtObject_Sentry);
            SetEventInt(event, "index", iSentry);
            SetEventBool(event, "sourcemod", true);
            FireEvent(event);
        }
        g_WasBuilt[iSentry] = true;
        g_HasBuilt[hBuilder] |= HasBuiltSentry;
    }
    return iSentry;
}
SentryOnGameFrame(){
	new i = -1;
	while ((i = FindEntityByClassname(i, "obj_sentrygun")) != -1)
	{
		new level = GetEntProp(i, Prop_Send, "m_iUpgradeLevel");
		new metal = GetEntProp(i, Prop_Send, "m_iUpgradeMetal");
		if(level < 3 && metal > 0){
			
			// new iLevel = level + 1;
			// new iSentry = i;
			//     new Float:fBuildMaxs[3];
		 //    fBuildMaxs[0] = 24.0;
		 //    fBuildMaxs[1] = 24.0;
		 //    fBuildMaxs[2] = 66.0;
		 //    new Float:fMdlWidth[3];
		 //    fMdlWidth[0] = 1.0;
		 //    fMdlWidth[1] = 0.5;
		 //    fMdlWidth[2] = 0.0;
		    
		 //    decl String:sModel[64];
		  
		    
		 //    new iShells, iHealth, iRockets;
		    
		 //    if(iLevel == 1)
		 //    {
		 //        sModel = "models/buildables/sentry1.mdl";
		 //        iShells = 100;
		 //        iHealth = 150;
		 //    }
		 //    else if(iLevel == 2)
		 //    {
		 //        sModel = "models/buildables/sentry2.mdl";
		 //        iShells = 120;
		 //        iHealth = 180;
		 //    }
		 //    else if(iLevel == 3)
		 //    {
		 //        sModel = "models/buildables/sentry3.mdl";
		 //        iShells = 144;
		 //        iHealth = 216;
		 //        iRockets = 20;
		 //    }
		    
		    
		
		    
		 //    SetEntityModel(iSentry,sModel);
		    
		 //    //SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_flAnimTime"),                 51, 4 , true);
		 //   // SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_nNewSequenceParity"),         4, 4 , true);
		 //    //SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_nResetEventsParity"),         4, 4 , true);
		 //    SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_iAmmoShells") ,                 iShells, 4, true);
		 //    SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_iMaxHealth"),                 iHealth, 4, true);
		 //    SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_iHealth"),                     iHealth, 4, true);
		 //    //SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_bBuilding"),                 0, 2, true);
		 //    //SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_bPlacing"),                     0, 2, true);
		 //    //SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_bDisabled"),                 0, 2, true);
		 //    //SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_iObjectType"),                 3, true);
		 //   // SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_iState"),                     1, true);
		 //    SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_iUpgradeMetal"),             0, true);
		 //    //SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_bHasSapper"),                 0, 2, true);
		 //    //SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_bServerOverridePlacement"),     1, 1, true);
		 //    SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_iUpgradeLevel"),             iLevel, 4, true);
		 //    SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_iAmmoRockets"),                 iRockets, 4, true);
		    
		 //    //SetEntDataEnt2(iSentry, FindSendPropOffs("CObjectSentrygun","m_nSequence"), 0, true);
		 //    //SetEntDataFloat(iSentry, FindSendPropOffs("CObjectSentrygun","m_flCycle"),                     0.0, true);
		 //    //SetEntDataFloat(iSentry, FindSendPropOffs("CObjectSentrygun","m_flPlaybackRate"),             1.0, true);
		 //    //SetEntDataFloat(iSentry, FindSendPropOffs("CObjectSentrygun","m_flPercentageConstructed"),     0.9, true);
			// SetEntProp(iSentry, Prop_Send, "m_iHighestUpgradeLevel", iLevel);
			// SetEntProp(iSentry, Prop_Send, "m_bBuilding", iLevel);
		 //    SetEntDataVector(iSentry, FindSendPropOffs("CObjectSentrygun","m_vecBuildMaxs"),         fBuildMaxs, true);
		 //    SetEntDataVector(iSentry, FindSendPropOffs("CObjectSentrygun","m_flModelWidthScale"),     fMdlWidth, true);
		}
	}
}
public OnGameFrame(){
	SkeysOnGameFrame();
	if(GetConVarBool(hSpeedrunEnabled)){
		SpeedrunOnGameFrame();
	}
	if(GetConVarBool(g_hFastBuild)){
		SentryOnGameFrame();
	}
}
// Support for beggers bazooka
Hook_Func_regenerate()
{
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "func_regenerate")) != INVALID_ENT_REFERENCE) {
		// Support for concmap*, and quad* maps that are imported from TFC.
		HookFunc(entity);
	}
}
HookFunc(entity)
{
#if defined DEBUG
	LogMessage("Hooked entity %d",entity);
#endif
	SDKUnhook(entity,SDKHook_StartTouch,OnPlayerStartTouchFuncRegenerate);
	SDKUnhook(entity,SDKHook_Touch,OnPlayerStartTouchFuncRegenerate);
	SDKUnhook(entity,SDKHook_EndTouch,OnPlayerStartTouchFuncRegenerate);
	SDKHook(entity,SDKHook_StartTouch,OnPlayerStartTouchFuncRegenerate);
	SDKHook(entity,SDKHook_Touch,OnPlayerStartTouchFuncRegenerate);
	SDKHook(entity,SDKHook_EndTouch,OnPlayerStartTouchFuncRegenerate);
}
public OnMapStart()
{
	if (GetConVarBool(g_hPluginEnabled))
	{
		for(new i = 0; i < MAXPLAYERS+1 ; i++){
			ResetRace(i);
			g_iLastTeleport[i] = 0;
		}
		if (g_hDatabase != INVALID_HANDLE)
		{
			LoadMapCFG();
		}
		SetConVarInt(waitingForPlayers, 0);
		// Precache cap sounds
		PrecacheSound("misc/freeze_cam.wav");
		PrecacheSound("misc/killstreak.wav");
		g_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
		g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
		// Change game rules to CP.
		TF2_SetGameType();
		// Find caps, and store the number of them in g_iCPs.
		new iCP = -1; g_iCPs = 0;
		while ((iCP = FindEntityByClassname(iCP, "trigger_capture_area")) != -1)
		{
			g_iCPs++;
		}
		if(databaseConfigured){
			LoadMapSpeedrunInfo();
		}
		Hook_Func_regenerate();
	}
}
public OnClientDisconnect(client)
{
	if (GetConVarBool(g_hPluginEnabled))
	{
		g_bHardcore[client] = false, g_bHPRegen[client] = false, g_bLoadedPlayerSettings[client] = false, g_bBeatTheMap[client] = false;
		g_bGetClientKeys[client] = false, g_bSpeedRun[client] = false, g_bUnkillable[client] = false, Format(g_sCaps[client], sizeof(g_sCaps), "\0");
		EraseLocs(client);
	}
	if(g_bRace[client] !=0)
	{
		LeaveRace(client);
	}
	speedrunStatus[client] = 0;
	for(new i = 0; i < 32; i++){
		zoneTimes[client][i] = 0.0;
	}
	lastFrameInStartZone[client] = false;
	SetSkeysDefaults(client);
	new idx;
	if((idx = FindValueInArray(hArray_NoFuncRegen,client)) != -1)
	{
		RemoveFromArray(hArray_NoFuncRegen,idx);
	}
}
public OnClientPutInServer(client)
{
	if (GetConVarBool(g_hPluginEnabled))
	{
		if(hSpeedrunEnabled){
			UpdateSteamID(client);
		}
		// Hook the client
		if(IsValidClient(client))
		{
			SDKHook(client, SDKHook_WeaponEquipPost, SDKHook_OnWeaponEquipPost);
		}
		// Load the player profile.
		decl String:sSteamID[64]; GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
		LoadPlayerProfile(client, sSteamID);
		// Welcome message. 15 seconds seems to be a good number.
		if (GetConVarBool(g_hWelcomeMsg))
		{
			CreateTimer(15.0, WelcomePlayer, client);
		}
		g_bHardcore[client] = false, g_bHPRegen[client] = false, g_bLoadedPlayerSettings[client] = false, g_bBeatTheMap[client] = false;
		g_bGetClientKeys[client] = false, g_bSpeedRun[client] = false, g_bUnkillable[client] = false, Format(g_sCaps[client], sizeof(g_sCaps), "\0");
	}
}
/*****************************************************************************************************************
												Functions
*****************************************************************************************************************/
//I SHOULD MAKE THIS DO A PAGED MENU IF IT DOESNT ALREADY IDK ANY MAPS WITH THAT MANY CPS ANYWAY
public Action:cmdRaceInitialize(client, args)
{
	if (!IsValidClient(client)) { return; }
	if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
		PrintToChat(client, "\x01[\x03JA\x01] You may not race while speedrunning");
		return;
	}
	if (g_bSpeedRun[client])
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Speedrun_Active");
		return;
	}
	if (g_iCPs == 0){
		PrintToChat(client, "\x01[\x03JA\x01] You may only race on maps with control points.");
		return;
	}
	if(IsPlayerFinishedRacing(client))
	{
		LeaveRace(client);
	}
	if (IsClientRacing(client)){
		PrintToChat(client, "\x01[\x03JA\x01] You are already in a race.");
		return;
	}
	g_bRace[client] = client;
	g_bRaceStatus[client] = 1;
	g_bRaceClassForce[client] = true;
	new String:cpName[32];
	new Handle:menu = CreateMenu(ControlPointSelector);
	SetMenuTitle(menu, "Select End Control Point");
	new entity;
	new String:buffer[32];
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1)
	{
		new pIndex = GetEntProp(entity, Prop_Data, "m_iPointIndex");
		GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
		IntToString(pIndex, buffer, sizeof(buffer));
		AddMenuItem(menu, buffer, cpName);
	}
	DisplayMenu(menu, client, 300);
	return;
}
public ControlPointSelector(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_bRaceEndPoint[param1] = StringToInt(info);
	}
	else if (action == MenuAction_Cancel)
	{
		g_bRace[param1] = 0;
		PrintToChat(param1, "\x01[\x03JA\x01] The race has been cancelled.");
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public Action:cmdRaceInvite(client, args)
{
	if (!IsValidClient(client)) { return Plugin_Handled; }
	if (!IsClientRacing(client)){
		PrintToChat(client, "\x01[\x03JA\x01] You have not started a race.");
		return Plugin_Handled;
	}
	if (!IsRaceLeader(client, g_bRace[client])){
		PrintToChat(client, "\x01[\x03JA\x01] You are not the race lobby leader.");
		return Plugin_Handled;
	}
	if (HasRaceStarted(client)){
		PrintToChat(client, "\x01[\x03JA\x01] The race has already started.");
		return Plugin_Handled;
	}
	if(args == 0){
		new Handle:g_PlayerMenu = INVALID_HANDLE;
		g_PlayerMenu = PlayerMenu();
		DisplayMenu(g_PlayerMenu, client, MENU_TIME_FOREVER);
	}else{
		new String:arg1[32];
		new String:clientName[128];
		new String:client2Name[128];
		new String:buffer[128];
		new Handle:panel;
		GetClientName(client, clientName, sizeof(clientName));
		new target;
		for(new i = 1; i < args+1; i++){
			GetCmdArg(i, arg1, sizeof(arg1));
			target = FindTarget(client, arg1, true, false);
			GetClientName(target, client2Name, sizeof(client2Name));
			if(target != -1 && !speedrunStatus[target]){
				PrintToChat(client, "\x01[\x03JA\x01] You have invited %s to race.", client2Name);
				Format(buffer, sizeof(buffer), "You have been invited to race to %s by %s", GetCPNameByIndex(g_bRaceEndPoint[client]), clientName);
				panel = CreatePanel();
				SetPanelTitle(panel, buffer);
				DrawPanelItem(panel, "Accept");
				DrawPanelItem(panel, "Decline");
				g_bRaceInvitedTo[target] = client;
				SendPanelToClient(panel, target, InviteHandler, 15);
				CloseHandle(panel);
			}else if(speedrunStatus[target]){
				PrintToChat(client, "\x01[\x03JA\x01] %s is currently in a speedrun", client2Name);
			}
		}
	}
	return Plugin_Continue;
}
stock String:GetCPNameByIndex(index)
{
	new entity;
	new String:cpName[32];
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1)
	{
		if(GetEntProp(entity, Prop_Data, "m_iPointIndex") == index)
		{
			GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
		}
	}
	return cpName;
}
Handle:PlayerMenu()
{
	new Handle:menu = CreateMenu(Menu_InvitePlayers);
	new String:buffer[128];
	new String:clientName[128];
	//SHOULDNT SHOW CURRENT PLAYER AND ALSO PLAYERS ALREADY IN A RACE BUT I NEED THAT FOR TESTING FOR NOW
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if(IsValidClient(i) && !speedrunStatus[i])
		{
			IntToString(i, buffer, sizeof(buffer));
			GetClientName(i, clientName, sizeof(clientName));
			AddMenuItem(menu, buffer, clientName);
		}
		SetMenuTitle(menu, "Select Players to Invite:");
	}
	return menu;
}
public Menu_InvitePlayers(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:clientName[128];
		new String:client2Name[128];
		new String:buffer[128];
		new String:info[32];
		GetClientName(param1, clientName, sizeof(clientName));
		GetMenuItem(menu, param2, info, sizeof(info));
		GetClientName(StringToInt(info), client2Name, sizeof(client2Name));
		PrintToChat(param1, "\x01[\x03JA\x01] You have invited %s to race.", client2Name);
		GetMenuItem(menu, param2, info, sizeof(info));
		Format(buffer, sizeof(buffer), "You have been invited to race to %s by %s", GetCPNameByIndex(g_bRaceEndPoint[param1]), clientName);
		new Handle:panel = CreatePanel();
		SetPanelTitle(panel, buffer);
		DrawPanelItem(panel, "Accept");
		DrawPanelItem(panel, "Decline");
		g_bRaceInvitedTo[StringToInt(info)] = param1;
		SendPanelToClient(panel, StringToInt(info), InviteHandler, 15);
		CloseHandle(panel);
	}
	else if (action == MenuAction_Cancel)
	{
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public InviteHandler(Handle:menu, MenuAction:action, param1, param2)
{
	// if (action == MenuAction_Select)
	// {
		// PrintToConsole(param1, "You selected item: %d", param2);
		// g_bRaceInvitedTo[param1] = 0;
	// } else if (action == MenuAction_Cancel) {
		// PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
		// g_bRaceInvitedTo[param1] = 0;
	// }
	AlertInviteAcceptOrDeny(g_bRaceInvitedTo[param1], param1, param2);
}
public AlertInviteAcceptOrDeny(client, client2, choice)
{
	new String:clientName[128];
	GetClientName(client2, clientName, sizeof(clientName));
	if (choice == 1)
	{
		if(HasRaceStarted(client)){
			PrintToChat(client, "\x01[\x03JA\x01] This race has already started.");
			return;
		}
		LeaveRace(client2);
		g_bRace[client2] = client;
		PrintToChat(client, "\x01[\x03JA\x01] %s has accepted your request to race", clientName);
	}
	else if (choice < 1)
	{
		PrintToChat(client, "\x01[\x03JA\x01] %s failed to respond to your invitation", clientName);
	}
	else
	{
		PrintToChat(client, "\x01[\x03JA\x01] %s has declined your request to race", clientName);
	}
}
//THE WORST WORKAROUND YOU'VE EVER SEEN
public Action:RaceCountdown(Handle:timer, any:raceID)
{
	PrintToRace(raceID, "****************************");
	PrintToRace(raceID, "             Starting race in: 3");
	PrintToRace(raceID, "****************************");
	CreateTimer(1.0, RaceCountdown2, raceID);
}
public Action:RaceCountdown2(Handle:timer, any:raceID)
{
	PrintToRace(raceID, "****************************");
	PrintToRace(raceID, "                         2");
	PrintToRace(raceID, "****************************");
	CreateTimer(1.0, RaceCountdown1, raceID);
}
public Action:RaceCountdown1(Handle:timer, any:raceID)
{
	PrintToRace(raceID, "****************************");
	PrintToRace(raceID, "                         1");
	PrintToRace(raceID, "****************************");
	CreateTimer(1.0, RaceCountdownGo, raceID);
}
public Action:RaceCountdownGo(Handle:timer, any:raceID)
{
	UnlockRacePlayers(raceID);
	PrintToRace(raceID, "****************************");
	PrintToRace(raceID, "                        GO!");
	PrintToRace(raceID, "****************************");
	new Float:time = GetEngineTime();
	g_bRaceStartTime[raceID] = time;
	g_bRaceStatus[raceID] = 3;
}
public Action:cmdRaceList(client, args){
	if (!IsValidClient(client)) { return; }
	//WILL NEED TO ADD && !ISCLINETOBSERVER(CLIENT) WHEN I ADD SPEC SUPPORT FOR THIS
	new iClientToShow, iObserverMode;
	if (!IsClientRacing(client))
	{
		if(IsClientObserver(client)){
			iObserverMode = GetEntPropEnt(client, Prop_Send, "m_iObserverMode");
			iClientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if(!IsClientRacing(iClientToShow)){
				PrintToChat(client, "\x01[\x03JA\x01] This client is not in a race!");
				return;
			}
			if (!IsValidClient(client) || !IsValidClient(iClientToShow) || iObserverMode == 6) {
				return;
			}
		}else{
			PrintToChat(client, "\x01[\x03JA\x01] You are not in a race!");
			return;
		}
	}else{
		iClientToShow = client;
	}
	new race = g_bRace[iClientToShow];
	new String:leader[32];
	new String:leaderFormatted[32];
	new String:racerNames[32];
	new String:racerEntryFormatted[255];
	new String:racerTimes[128];
	new String:racerDiff[128];
	new Handle:panel = CreatePanel();
	new bool:space;
	GetClientName(g_bRace[iClientToShow], leader, sizeof(leader));
	Format(leaderFormatted, sizeof(leaderFormatted), "%s's Race", leader);
	DrawPanelText(panel, leaderFormatted);
	DrawPanelText(panel, " ");
	for(new i = 0; i < MAXPLAYERS; i++){
		if(g_bRaceFinishedPlayers[race][i] == 0){
			break;
		}
		space = true;
		GetClientName(g_bRaceFinishedPlayers[race][i], racerNames, sizeof(racerNames));
		racerTimes = TimeFormat(g_bRaceTimes[race][i] - g_bRaceStartTime[race]);
		if(g_bRaceFirstTime[race] != g_bRaceTimes[race][i]){
			racerDiff = TimeFormat(g_bRaceTimes[race][i] - g_bRaceFirstTime[race]);
		}else{
			racerDiff = "00:00:000";
		}
		Format(racerEntryFormatted, sizeof(racerEntryFormatted), "%d. %s - %s[-%s]", (i+1), racerNames, racerTimes, racerDiff);
		DrawPanelText(panel, racerEntryFormatted);
	}
	if(space){
		DrawPanelText(panel, " ");
	}
	new String:name[32];
	for(new i = 0; i < MAXPLAYERS; i++){
		if(IsClientInRace(i, race) && !IsPlayerFinishedRacing(i)){
			GetClientName(i, name, sizeof(name));
			DrawPanelText(panel, name);
		}
	}
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, InfoHandler, 30);
	CloseHandle(panel);
}
public ListHandler(Handle:menu, MenuAction:action, param1, param2)
{
	// if (action == MenuAction_Select)
	// {
		// PrintToConsole(param1, "You selected item: %d", param2);
		// g_bRaceInvitedTo[param1] = 0;
	// } else if (action == MenuAction_Cancel) {
		// PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
		// g_bRaceInvitedTo[param1] = 0;
	// }
}
public Action:cmdRaceInfo(client, args)
{
	if (!IsValidClient(client)) { return; }
	//WILL NEED TO ADD && !ISCLINETOBSERVER(CLIENT) WHEN I ADD SPEC SUPPORT FOR THIS
	new iClientToShow, iObserverMode;
	if (!IsClientRacing(client))
	{
		if(IsClientObserver(client)){
			iObserverMode = GetEntPropEnt(client, Prop_Send, "m_iObserverMode");
			iClientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if(!IsClientRacing(iClientToShow)){
				PrintToChat(client, "\x01[\x03JA\x01] This client is not in a race!");
				return;
			}
			if (!IsValidClient(client) || !IsValidClient(iClientToShow) || iObserverMode == 6) {
				return;
			}
		}else{
			PrintToChat(client, "\x01[\x03JA\x01] You are not in a race!");
			return;
		}
	}else{
		iClientToShow = client;
	}
	new String:leader[32];
	new String:leaderFormatted[64];
	new String:status[64];
	new String:healthRegen[32];
	new String:ammoRegen[32];
	new String:classForce[32];
	GetClientName(g_bRace[iClientToShow], leader, sizeof(leader));
	Format(leaderFormatted, sizeof(leaderFormatted), "Race Host: %s", leader);
	if(g_bRaceHealthRegen[g_bRace[iClientToShow]]){
		healthRegen = "HP Regen: Enabled";
	}else{
		healthRegen = "HP Regen: Disabled";
	}
	if(g_bRaceHealthRegen[g_bRace[iClientToShow]]){
		ammoRegen = "Ammo Regen: Enabled";
	}else{
		ammoRegen = "Ammo Regen: Disabled";
	}
	if(GetRaceStatus(iClientToShow) == 1){
		status = "Race Status: Waiting for start";
	}else if(GetRaceStatus(iClientToShow) == 2){
		status = "Race Status: Starting";
	}else if(GetRaceStatus(iClientToShow) == 3){
		status = "Race Status: Racing";
	}else if(GetRaceStatus(iClientToShow) == 4){
		status = "Race Status: Waiting for finshers";
	}
	if(g_bRaceClassForce[g_bRace[iClientToShow]]){
		classForce = "Class Force: Enabled";
	}else{
		classForce = "Class Force: Disabled";
	}
	new Handle:panel = CreatePanel();
	DrawPanelText(panel, leaderFormatted);
	DrawPanelText(panel, status);
	DrawPanelText(panel, "---------------");
	DrawPanelText(panel, healthRegen);
	DrawPanelText(panel, ammoRegen);
	DrawPanelText(panel, "---------------");
	DrawPanelText(panel, classForce);
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, InfoHandler, 30);
	CloseHandle(panel);
}
public InfoHandler(Handle:menu, MenuAction:action, param1, param2)
{
	// if (action == MenuAction_Select)
	// {
		// PrintToConsole(param1, "You selected item: %d", param2);
		// g_bRaceInvitedTo[param1] = 0;
	// } else if (action == MenuAction_Cancel) {
		// PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
		// g_bRaceInvitedTo[param1] = 0;
	// }
}
public Action:cmdRaceStart(client, args)
{
	if (!IsValidClient(client)) { return; }
	if (g_bRace[client] == 0)
	{
		PrintToChat(client, "\x01[\x03JA\x01] You are not hosting a race!");
		return;
	}
	if (!IsRaceLeader(client, g_bRace[client]))
	{
		PrintToChat(client, "\x01[\x03JA\x01] You are not the race lobby leader.");
		return;
	}
	//RIGHT HERE I SHOULD CHECK TO MAKE SURE THERE ARE TWO OR MORE PEOPLE
	if (HasRaceStarted(client)){
		PrintToChat(client, "\x01[\x03JA\x01] The race has already started.");
		return;
	}
	LockRacePlayers(client);
	ApplyRaceSettings(client);
	new TFClassType:class = TF2_GetPlayerClass(client);
	new team = GetClientTeam(client);
	g_bRaceStatus[client] = 2;
	CreateTimer(1.0, RaceCountdown, client);
	SendRaceToStart(client, class, team);
	PrintToRace(client, "Teleporting to race start!");
}
stock PrintToRace(raceID, String:message[])
{
	new String:buffer[128];
	Format(buffer, sizeof(buffer), "\x01[\x03JA\x01] %s", message);
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, raceID) || IsClientSpectatingRace(i, raceID))
		{
			PrintToChat(i, buffer);
		}
	}
}
stock SendRaceToStart(raceID, TFClassType:class, team)
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, raceID))
		{
			if(g_bRaceClassForce[raceID]){
				TF2_SetPlayerClass(i, class);
			}
			ChangeClientTeam(i, team);
			SendToStart(i);
		}
	}
}
stock LockRacePlayers(raceID)
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, raceID))
		{
			g_bRaceLocked[i] = true;
		}
	}
}
stock UnlockRacePlayers(raceID)
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, raceID))
		{
			g_bRaceLocked[i] = false;
		}
	}
}
public Action:cmdRaceLeave(client, args)
{
	if (!IsClientRacing(client)){
		PrintToChat(client, "\x01[\x03JA\x01] You are not in a race.");
		return;
	}
	LeaveRace(client);
	PrintToChat(client, "\x01[\x03JA\x01] You have left the race.");
}
public Action:cmdServerRace(client, args)
{
	cmdRaceInitializeServer(client, args);
}
public Action:cmdRaceInitializeServer(client, args)
{
	if (!IsValidClient(client)) { return; }
	if (g_bSpeedRun[client])
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Speedrun_Active");
		return;
	}
	if (g_iCPs == 0){
		PrintToChat(client, "\x01[\x03JA\x01] You may only race on maps with control points.");
		return;
	}
	if(IsPlayerFinishedRacing(client))
	{
		LeaveRace(client);
	}
	if (IsClientRacing(client)){
		PrintToChat(client, "\x01[\x03JA\x01] You are already in a race.");
		return;
	}
	g_bRace[client] = client;
	g_bRaceStatus[client] = 1;
	g_bRaceClassForce[client] = true;
	new String:cpName[32];
	new Handle:menu = CreateMenu(ControlPointSelectorServer);
	SetMenuTitle(menu, "Select End Control Point");
	new entity;
	new String:buffer[32];
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1)
	{
		new pIndex = GetEntProp(entity, Prop_Data, "m_iPointIndex");
		GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
		IntToString(pIndex, buffer, sizeof(buffer));
		AddMenuItem(menu, buffer, cpName);
	}
	DisplayMenu(menu, client, 300);
	return;
}
public ControlPointSelectorServer(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_bRaceEndPoint[param1] = StringToInt(info);
		new String:buffer[128];
		new String:clientName[128];
		GetClientName(param1, clientName, sizeof(clientName));
		for (new i = 1; i <= GetMaxClients(); i++)
		{
			if (IsValidClient(i) && param1 != i)
			{
				Format(buffer, sizeof(buffer), "You have been invited to race to %s by %s", GetCPNameByIndex(g_bRaceEndPoint[param1]), clientName);
				new Handle:panel = CreatePanel();
				SetPanelTitle(panel, buffer);
				DrawPanelItem(panel, "Accept");
				DrawPanelItem(panel, "Decline");
				g_bRaceInvitedTo[i] = param1;
				SendPanelToClient(panel, i, InviteHandler, 15);
				CloseHandle(panel);
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		g_bRace[param1] = 0;
		PrintToChat(param1, "\x01[\x03JA\x01] The race has been cancelled.");
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public Action:cmdRaceSpec(client, args){
	if(!IsValidClient(client)){return Plugin_Handled; }
	if(args == 0){
		PrintToChat(client, "\x01[\x03JA\x01] No target race selected.");
		return Plugin_Handled;
	}
	new String:arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	new target = FindTarget(client, arg1, true, false);
	if(target == -1){
		return Plugin_Handled;
	}else{
		if(target == client){
			PrintToChat(client, "\x01[\x03JA\x01] You may not spectate yourself.");
			return Plugin_Handled;
		}
		if(!IsClientRacing(target)){
			PrintToChat(client, "\x01[\x03JA\x01] Target client is not in a race.");
			return Plugin_Handled;
		}
		if(IsClientObserver(target)){
			PrintToChat(client, "\x01[\x03JA\x01] You may not spectate a spectator.");
			return Plugin_Handled;
		}
		if(IsClientRacing(client)){
			LeaveRace(client);
		}
		if(!IsClientObserver(client)){
			ChangeClientTeam(client, 1);
			ForcePlayerSuicide(client);
		}
		g_bRaceSpec[client] = g_bRace[target];
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", g_bRace[target]);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
	}
	return Plugin_Continue;
}
public Action:cmdRaceSet(client, args){
	if(!IsValidClient(client)){return Plugin_Handled; }
	if(!IsClientRacing(client)){
		PrintToChat(client, "\x01[\x03JA\x01] You are not in a race.");
		return Plugin_Handled;
	}
	if(!IsRaceLeader(client, g_bRace[client])){
		PrintToChat(client, "\x01[\x03JA\x01] You are not the leader of this race.");
		return Plugin_Handled;
	}
	if(HasRaceStarted(client)){
		PrintToChat(client, "\x01[\x03JA\x01] The race has already started.");
		return Plugin_Handled;
	}
	if(args != 2){
		PrintToChat(client, "\x01[\x03JA\x01] This number of arguments is not supported.");
		return Plugin_Handled;
	}
	new String:arg1[32];
	new String:arg2[32];
	new bool:toSet;
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	PrintToServer(arg2);
	if(!(StrEqual(arg2, "on", false) || StrEqual(arg2, "off", false))){
		PrintToChat(client, "\x01[\x03JA\x01] Your second argument is not valid.");
		return Plugin_Handled;
	}else{
		if(StrEqual(arg2, "on", false)){
			toSet = true;
		}else{
			toSet = false;
		}
	}
	if(StrEqual(arg1, "ammo", false)){
		g_bRaceAmmoRegen[client] = toSet;
		PrintToChat(client, "\x01[\x03JA\x01] Ammo regen has been set.");
	}else if(StrEqual(arg1, "health", false)){
		g_bRaceHealthRegen[client] = toSet;
		PrintToChat(client, "\x01[\x03JA\x01] Health regen has been set.");
	}else if(StrEqual(arg1, "regen", false)){
		g_bRaceAmmoRegen[client] = toSet;
		g_bRaceHealthRegen[client] = toSet;
		PrintToChat(client, "\x01[\x03JA\x01] Regen has been set.");
	}else if(StrEqual(arg1, "cf", false) || StrEqual(arg1, "classforce", false)){
		g_bRaceClassForce[client] = toSet;
		PrintToChat(client, "\x01[\x03JA\x01] Class force has been set.");
	}else{
		PrintToChat(client, "\x01[\x03JA\x01] Invalid setting.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
stock ApplyRaceSettings(race){
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, race))
		{
			g_bAmmoRegen[i] = g_bRaceAmmoRegen[g_bRace[i]];
			g_bHPRegen[i] = g_bRaceHealthRegen[g_bRace[i]];
		}
	}
}
stock GetSpecRace(client)
{
	return g_bRaceSpec[client];
}
stock GetPlayersInRace(raceID)
{
	new players;
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, raceID))
		{
			players++;
		}
	}
	return players;
}
stock GetPlayersStillRacing(raceID)
{
	new players;
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, raceID) && !IsPlayerFinishedRacing(i))
		{
			players++;
		}
	}
	return players;
}
stock LeaveRace(client){
	new race = g_bRace[client];
	if(race == 0){
		return;
	}
	if(GetPlayersInRace(race) == 0)
	{
		ResetRace(race);
	}
	if(client == race)
	{
		if(GetPlayersInRace(race) == 1)
		{
			ResetRace(race);
		}
		else
		{
			if(HasRaceStarted(race)){
					for (new i = 1; i <= GetMaxClients(); i++)
					{
						if (IsClientInRace(i, race) && IsClientRacing(i) && !IsRaceLeader(i, race))
						{
							new newRace = i;
							new a[32];
							new Float:b[32];
							g_bRaceStatus[i] = g_bRaceStatus[race];
							g_bRaceEndPoint[i] = g_bRaceEndPoint[race];
							g_bRaceStartTime[i] = g_bRaceStartTime[race];
							g_bRaceFirstTime[i] = g_bRaceFirstTime[race];
							g_bRaceAmmoRegen[i] = g_bRaceAmmoRegen[race];
							g_bRaceHealthRegen[i] = g_bRaceHealthRegen[race];
							g_bRaceClassForce[i] = g_bRaceClassForce[race];
							g_bRaceTimes[i] = g_bRaceTimes[race];
							g_bRaceFinishedPlayers[i] = g_bRaceFinishedPlayers[race];
							g_bRace[client] = 0;
							g_bRaceTime[client] = 0.0;
							g_bRaceLocked[client] = false;
							g_bRaceFirstTime[client] = 0.0;
							g_bRaceEndPoint[client] = 0;
							g_bRaceStartTime[client] = 0.0;
							g_bRaceFinishedPlayers[client] = a;
							g_bRaceTimes[client] = b;
							for (new j = 1; j <= GetMaxClients(); j++)
							{
								if (IsClientRacing(j) && !IsRaceLeader(j, race))
								{
									g_bRace[j] = newRace;
								}
							}
							return;
						}
					}
			}
			else
			{
				PrintToRace(race, "The race has been cancelled.");
				ResetRace(race);
			}
		}
	}
	else
	{
		g_bRace[client] = 0;
		g_bRaceTime[client] = 0.0;
		g_bRaceLocked[client] = false;
		g_bRaceFirstTime[client] = 0.0;
		g_bRaceEndPoint[client] = 0;
		g_bRaceStartTime[client] = 0.0;
	}
	new String:clientName[128];
	new String:buffer[128];
	GetClientName(client, clientName, sizeof(clientName));
	Format(buffer, sizeof(buffer), "%s has left the race.", clientName);
	PrintToRace(race, buffer);
}
stock ResetRace(raceID)
{
	for (new i = 0; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, raceID))
		{
			g_bRace[i] = 0;
			g_bRaceStatus[i] = 0;
			g_bRaceTime[i] = 0.0;
			g_bRaceLocked[i] = false;
			g_bRaceFirstTime[i] = 0.0;
			g_bRaceEndPoint[i] = 0;
			g_bRaceStartTime[i] = 0.0;
			g_bRaceAmmoRegen[i] = false;
			g_bRaceHealthRegen[i] = false;
			g_bRaceClassForce[i] = true;
		}
		g_bRaceTimes[raceID][i] = 0.0;
		g_bRaceFinishedPlayers[raceID][i] = 0;
	}
}
stock EmitSoundToRace (raceID, String:sound[])
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInRace(i, raceID) || IsClientSpectatingRace(i, raceID))
		{
			EmitSoundToClient(i, sound);
		}
	}
	return;
}
stock EmitSoundToNotRace (raceID, String:sound[])
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (!IsClientInRace(i, raceID) && !IsClientSpectatingRace(i, raceID) && IsValidClient(i))
		{
			EmitSoundToClient(i, sound);
		}
	}
	return;
}
stock bool:IsClientRacing(client){
	if (g_bRace[client] != 0){
		return true;
	}
	return false;
}
stock bool:IsClientInRace(client, race){
	if(g_bRace[client] == race){
		return true;
	}
	return false;
}
stock GetRaceStatus(client){
	return g_bRaceStatus[g_bRace[client]];
}
stock bool:IsRaceLeader(client, race){
	if(client == race){
		return true;
	}
	return false;
}
stock bool:HasRaceStarted(client){
	if(g_bRaceStatus[g_bRace[client]] > 1){
		return true;
	}
	return false;
}
stock bool:IsPlayerFinishedRacing(client){
	if(g_bRaceTime[client] != 0.0){
		return true;
	}
	return false;
}
stock bool:IsClientSpectatingRace(client, race){
	if(!IsValidClient(client)){
		return false;
	}
	if(!IsClientObserver(client)){
		return false;
	}
	new iClientToShow, iObserverMode;
	iObserverMode = GetEntPropEnt(client, Prop_Send, "m_iObserverMode");
	iClientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	if (!IsValidClient(client) || !IsValidClient(iClientToShow) || iObserverMode == 6) {
		return false;
	}
	if(IsClientInRace(iClientToShow, race)){
		return true;
	}
	return false;
}
stock String:TimeFormat(Float:timeTaken){
	new intTimeTaken;
	new Float:ms;
	new String:msFormat[128];
	new String:msFormatFinal[128];
	new String:final[128];
	new seconds;
	new minutes;
	new hours;
	new String:secondsString[128];
	new String:minutesString[128];
	new String:hoursString[128];
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
	if(hours != 0){
		Format(final, sizeof(final), "%s:%s:%s:%s", hoursString, minutesString, secondsString, msFormatFinal);
	}else{
		Format(final, sizeof(final), "%s:%s:%s", minutesString, secondsString, msFormatFinal);
	}
	return final;
}
stock String:FormatTimeComponent(time){
	new String:final[8];
	if(time > 9){
		Format(final, sizeof(final), "%d", time);
	}else{
		Format(final, sizeof(final), "0%d", time);
	}
	return final;
}
stock bool:IsRaceOver(client){
	if(g_bRaceStatus[client] == 5){
		return true;
	}
	return false;
}

public Action:cmdToggleAmmo(client, args)
{
	if (!IsValidClient(client)) { return; }
	if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
		PrintToChat(client, "\x01[\x03JA\x01] You may not change regen during a speedrun");
		return;
	}
	if(IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)){
		ReplyToCommand(client, "\x01[\x03JA\x01] You may not change regen during a race");
		return;
	}
	SetRegen(client, "Ammo", "z");
}
public Action:cmdToggleHealth(client, args)
{
	if (!IsValidClient(client)) { return; }
	if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
		PrintToChat(client, "\x01[\x03JA\x01] You may not change regen during a speedrun");
		return;
	}
	if(IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)){
		ReplyToCommand(client, "\x01[\x03JA\x01] You may not change regen during a race");
		return;
	}
	SetRegen(client, "Health", "z");
}
public Action:cmdToggleHardcore(client, args)
{
	if (!IsValidClient(client)) { return; }
	if (IsUsingJumper(client))
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Jumper_Command_Disabled");
		return;
	}
	Hardcore(client);
}
public Action:cmdJAHelp(client, args)
{
	if(IsUserAdmin(client)){
		ReplyToCommand(client, "**********ADMIN COMMANDS**********");
		ReplyToCommand(client, "mapset - Change map settings");
		ReplyToCommand(client, "addtele - Add a teleport location");
		ReplyToCommand(client, "jatele - Teleport a user to a location");
	}
	new Handle:panel;
	panel = CreatePanel();
	SetPanelTitle(panel, "Help Menu:");
	DrawPanelItem(panel, "Saving and Teleporting");
	DrawPanelItem(panel, "Regen");
	DrawPanelItem(panel, "Skeys");
	DrawPanelItem(panel, "Racing");
	DrawPanelItem(panel, "Miscellaneous");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, JAHelpHandler, 15);
	CloseHandle(panel);
	return;
}
public JAHelpHandler(Handle:menu, MenuAction:action, param1, param2){
	//1 is client
	//2 is choice
	new client = param1;
	if(param2 < 1 || param2 == 6){
		return;
	}
	new Handle:panel;
	panel = CreatePanel();
	if(param2 == 1){
		SetPanelTitle(panel, "Save Help");
		DrawPanelText(panel, "!save or !s - Saves your position");
		DrawPanelText(panel, "!tele or !t - Teleports you to your saved position");
		DrawPanelText(panel, "!undo - Reverts your last save");
		DrawPanelText(panel, "!reset or !r - Restarts you on the map");
		DrawPanelText(panel, "!restart - Deletes your save and restarts you");
	}else if(param2 == 2){
		SetPanelTitle(panel, "Regen Help");
		DrawPanelText(panel, "!regen <on|off> - Sets ammo & health regen");
		DrawPanelText(panel, "!ammo - Toggles ammo regen");
		DrawPanelText(panel, "!health - Toggles health regen");
	}else if(param2 == 3){
		SetPanelTitle(panel, "Skeys Help");
		DrawPanelText(panel, "!skeys - Shows key presses on the screen");
		DrawPanelText(panel, "!skeys_color <R> <G> <B> - Skeys color");
		DrawPanelText(panel, "!skeys_loc <X> <Y> - Sets skeys location with x and y values from 0 to 1");
	}else if(param2 == 4){
		SetPanelTitle(panel, "Racing Help");
		DrawPanelText(panel, "!race - Initialize a race and select final CP.");
		DrawPanelText(panel, "!r_info - Provides info about the current race.");
		DrawPanelText(panel, "!r_inv - Invite players to the race.");
		DrawPanelText(panel, "!r_set - Change settings of a race.");
		DrawPanelText(panel, "     <classforce|cf|ammo|health|regen>");
		DrawPanelText(panel, "     <on|off>");
		DrawPanelText(panel, "!r_list - Lists race players and their times");
		DrawPanelText(panel, "!r_spec - Spectates a race.");
		DrawPanelText(panel, "!r_start - Start the race.");
		DrawPanelText(panel, "!r_leave - Leave a race.");
	}else if(param2 == 5){
		DrawPanelText(panel, "!jumpassist - Shows the JumpAssist forum page.");
		DrawPanelText(panel, "!jumptf - Shows the Jump.tf website.");
		DrawPanelText(panel, "!forums - Shows the Jump.tf forums.");
	}
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "Back");
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, HelpMenuHandler, 15);
	CloseHandle(panel);
}
public HelpMenuHandler(Handle:menu, MenuAction:action, param1, param2){
	if(param2 == 1){
		cmdJAHelp(param1, 0);
	}
}
stock bool:IsUsingJumper(client)
{
	if (!IsValidClient(client)) { return false; }
	if (TF2_GetPlayerClass(client) == TFClass_Soldier)
	{
		if (!IsValidWeapon(g_iClientWeapons[client][0])) { return false; }
		new sol_weap = GetEntProp(g_iClientWeapons[client][0], Prop_Send, "m_iItemDefinitionIndex");
		switch (sol_weap)
		{
			case 237:
				return true;
		}
		return false;
	}
	if (TF2_GetPlayerClass(client) == TFClass_DemoMan)
	{
		if (!IsValidWeapon(g_iClientWeapons[client][1])) { return false; }
		new dem_weap = GetEntProp(g_iClientWeapons[client][1], Prop_Send, "m_iItemDefinitionIndex");
		switch (dem_weap)
		{
			case 265:
				return true;
		}
		return false;
	}
	return false;
}
stock CheckBeggers(iClient)
{
	new iWeapon = GetPlayerWeaponSlot(iClient, 0);
	new index = FindValueInArray(hArray_NoFuncRegen,iClient);
        if (IsValidEntity(iWeapon) &&
		GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex") == 730)
	{
		if(index == -1)
		{
			PushArrayCell(hArray_NoFuncRegen,iClient);
#if defined DEBUG
			LogMessage("Preventing player %d from touching func_regenerate");
#endif
		}
	} else if(index != -1) {
		RemoveFromArray(hArray_NoFuncRegen,index);
#if defined DEBUG
		LogMessage("Allowing player %d to touch func_regenerate");
#endif
	}
}
stock IsStringNumeric(const String:MyString[])
{
	new n=0;
	while (MyString[n] != '\0')
	{
		if (!IsCharNumeric(MyString[n]))
		{
			return false;
		}
		n++;
	}
	return true;
}
public Action:RunQuery(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "\x01[\x03JA\x01] More parameters are required for this command.");
		return Plugin_Handled;
	}
	decl String:query[1024];
	GetCmdArgString(query, sizeof(query));
	SQL_TQuery(g_hDatabase, SQL_OnPlayerRanSQL, query, client);
	return Plugin_Handled;
}
public Action:cmdUnkillable(client, args)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return Plugin_Handled; }
	if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
		ReplyToCommand(client, "\x01[\x03JA\x01] You may not use superman during a speedrun");
		return Plugin_Handled;
	}
	if (!GetConVarBool(g_hSuperman) && !IsUserAdmin(client))
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Command_Locked");
		return Plugin_Handled;
	}
	if (g_bSpeedRun[client])
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Speedrun_Active");
		return Plugin_Handled;
	}
	if (!g_bUnkillable[client])
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_UnkillableOn");
		g_bUnkillable[client] = true;
	} else {
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_UnkillableOff");
		g_bUnkillable[client] = false;
	}
	return Plugin_Handled;
}
public Action:cmdUndo(client, args)
{
	if (g_bSpeedRun[client])
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Save_UndoSpeedRun");
		return Plugin_Handled;
	}
	if (g_fLastSavePos[client][0] == 0.0)
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Save_UndoCant");
		return Plugin_Handled;
	} else {
		g_fOrigin[client][0] = g_fLastSavePos[client][0]; g_fAngles[client][0] = g_fLastSaveAngles[client][0];
		g_fOrigin[client][1] = g_fLastSavePos[client][1]; g_fAngles[client][1] = g_fLastSaveAngles[client][1];
		g_fOrigin[client][2] = g_fLastSavePos[client][2]; g_fAngles[client][2] = g_fLastSaveAngles[client][2];
		g_fLastSavePos[client][0] = 0.0; g_fLastSavePos[client][1] = 0.0; g_fLastSavePos[client][2] = 0.0;
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Save_Undo");
		return Plugin_Handled;
	}
}
public Action:cmdDoRegen(client, args)
{
	if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
		ReplyToCommand(client, "\x01[\x03JA\x01] You may not change regen during a speedrun");
		return Plugin_Handled;
	}
	if(IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)){
		ReplyToCommand(client, "\x01[\x03JA\x01] You may not change regen during a race");
		return Plugin_Handled;
	}
	decl String:arg1[MAX_NAME_LENGTH];
	GetCmdArg(1, arg1, sizeof(arg1));
	if (StrEqual(arg1, "on", false))
	{
		SetRegen(client, "regen", "on");
		return Plugin_Handled;
	} else if (StrEqual(arg1, "off", false))
	{
		SetRegen(client, "regen", "off");
		return Plugin_Handled;
	} else {
		SetRegen(client, "Regen", "Display");
	}
	return Plugin_Handled;
}
//public Action:cmdClearSave(client, args)
//{
//	if (GetConVarBool(g_hPluginEnabled))
//	{
//		EraseLocs(client);
//		PrintToChat(client, "\x01[\x03JA\x01] %t", "Player_ClearedSave");
//	}
//	return Plugin_Handled;
//}
public Action:cmdSendPlayer(client, args)
{
	if(!databaseConfigured)
	{
		PrintToChat(client, "This feature is not supported without a database configuration");
		return Plugin_Handled;
	}
	if (GetConVarBool(g_hPluginEnabled))
	{
		if (args < 2)
		{
			ReplyToCommand(client, "\x01[\x03JA\x01] %t", "SendPlayer_Help", LANG_SERVER);
			return Plugin_Handled;
		}
		new String:arg1[MAX_NAME_LENGTH];
		new String:arg2[MAX_NAME_LENGTH];
		GetCmdArg(1, arg1, sizeof(arg1));
		GetCmdArg(2, arg2, sizeof(arg2));
		new target1 = FindTarget2(client, arg1, true, false);
		new target2 = FindTarget2(client, arg2, true, false);
		if (target1 < 0 || target2 < 0){
			return Plugin_Handled;
		}
		if(speedrunStatus[target1]){
			ReplyToCommand(client, "\x01[\x03JA\x01] You cannot send a player in a speedrun");
			return Plugin_Handled;
		}
		if (target1 == client)
		{
			ReplyToCommand(client, "\x01[\x03JA\x01] %t", "SendPlayer_Self", cLightGreen, cDefault);
			return Plugin_Handled;
		}
		if (!target1 || !target2)
		{
			return Plugin_Handled;
		}
		new Float:TargetOrigin[3];
		new Float:pAngle[3];
		new Float:pVec[3];
		GetClientAbsOrigin(target2, TargetOrigin);
		GetClientAbsAngles(target2, pAngle);
		pVec[0] = 0.0;
		pVec[1] = 0.0;
		pVec[2] = 0.0;
		TeleportEntity(target1, TargetOrigin, pAngle, pVec);
		new String:target1_name[MAX_NAME_LENGTH];
		new String:target2_name[MAX_NAME_LENGTH];
		GetClientName(target1, target1_name, sizeof(target1_name));
		GetClientName(target2, target2_name, sizeof(target2_name));
		ShowActivity2(client, "\x01[\x03JA\x01] ", "%t", "Send_Player", target1_name, target2_name);
	}
	return Plugin_Handled;
}

public Action:cmdReset(client, args)
{
	if (GetConVarBool(g_hPluginEnabled))
	{
		if (skillsrank)
		{
			if (IsPlayerBusy(client))
			{
				PrintToChat(client, "\x01[\x03JA\x01] %t", "General_Busy");
				return Plugin_Handled;
			}
		}
		if (IsClientObserver(client))
		{
			return Plugin_Handled;
		}
		g_iLastTeleport[client] = 0;
		SendToStart(client);
		g_bUsedReset[client] = true;
	}
	return Plugin_Handled;
}
public Action:cmdTele(client, args)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return Plugin_Handled; }
	if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
		PrintToChat(client, "\x01[\x03JA\x01] You may not teleport while speedrunning");
		return Plugin_Handled;
	}
	Teleport(client);
	g_iLastTeleport[client] = RoundFloat(GetEngineTime());
	return Plugin_Handled;
}
public Action:cmdSave(client, args)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return Plugin_Handled; }
	SaveLoc(client);
	return Plugin_Handled;
}
Teleport(client)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	if (!IsValidClient(client)) { return; }
	if (g_bRace[client] && (g_bRaceStatus[g_bRace[client]] == 2 || g_bRaceStatus[g_bRace[client]] == 3) )
	{
		PrintToChat(client, "\x01[\x03JA\x01] Cannot teleport while racing.");
		return;
	}
	if (g_bSpeedRun[client])
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Speedrun_Active");
		return;
	}
	new g_iClass = view_as<int>(TF2_GetPlayerClass(client));
	new g_iTeam = GetClientTeam(client);
	decl String:g_sClass[32], String:g_sTeam[32];
	new Float:g_vVelocity[3];
	g_vVelocity[0] = 0.0; g_vVelocity[1] = 0.0; g_vVelocity[2] = 0.0;
	Format(g_sClass, sizeof(g_sClass), "%s", GetClassname(g_iClass));
	if (g_iTeam == 2)
	{
		Format(g_sTeam, sizeof(g_sTeam), "%T", "Red_Team", LANG_SERVER);
	} else if (g_iTeam == 3)
	{
		Format(g_sTeam, sizeof(g_sTeam), "%T", "Blu_Team", LANG_SERVER);
	}
	if (g_bHardcore[client])
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Teleports_Disabled");
	else if(!IsPlayerAlive(client))
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Teleport_Dead");
	else if(g_fOrigin[client][0] == 0.0)
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Teleport_NoSave", g_sClass, g_sTeam, cLightGreen, cDefault, cLightGreen, cDefault);
	else
	{
		TeleportEntity(client, g_fOrigin[client], g_fAngles[client], g_vVelocity);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Teleport_Self");
	}
}
SaveLoc(client)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	if (g_bSpeedRun[client])
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Speedrun_Active");
		return;
	}
	if (g_bHardcore[client])
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_Disabled");
	else if(!IsPlayerAlive(client))
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_Dead");
	else if(!(GetEntityFlags(client) & FL_ONGROUND))
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_InAir");
	else if(GetEntProp(client, Prop_Send, "m_bDucked") == 1)
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_Ducked");
	else
	{
		g_fLastSavePos[client][0] = g_fOrigin[client][0]; g_fLastSaveAngles[client][0] = g_fAngles[client][0];
		g_fLastSavePos[client][1] = g_fOrigin[client][1]; g_fLastSaveAngles[client][1] = g_fAngles[client][1];
		g_fLastSavePos[client][2] = g_fOrigin[client][2]; g_fLastSaveAngles[client][2] = g_fAngles[client][2];
		GetClientAbsOrigin(client, g_fOrigin[client]);
		GetClientAbsAngles(client, g_fAngles[client]);
		if(databaseConfigured){
			GetPlayerData(client);
		}
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Saves_Location");
	}
}
ResetPlayerPos(client)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	if (!IsClientInGame(client) || IsClientObserver(client))
	{
		return;
	}
	DeletePlayerData(client);
	return;
}
Hardcore(client)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	if (skillsrank)
	{
		if (IsPlayerBusy(client))
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Hardcore_SettingsBusy");
			return;
		}
	}
	new String:steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	if (!IsClientInGame(client))
	{
		return;
	}
	else if (IsClientObserver(client))
	{
		return;
	}
	if (!g_bHardcore[client])
	{
		g_bHardcore[client] = true;
		g_bHPRegen[client] = false;
		g_bAmmoRegen[client] = false;
		EraseLocs(client);
		if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
			RestartSpeedrun(client);
		}else{
			TF2_RespawnPlayer(client);
		}
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Hardcore_On", cLightGreen, cDefault);
	} else {
		g_bHardcore[client] = false;
		LoadPlayerData(client);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Hardcore_Off");
	}
}
SetRegen(client, String:RegenType[], String:RegenToggle[])
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	if (skillsrank)
	{
		if (IsPlayerBusy(client))
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_SettingsBusy");
			return;
		}
	}
	if (StrEqual(RegenType, "Ammo", false))
	{
		if (g_bHardcore[client]) { g_bHardcore[client] = false; }
		if (!g_bAmmoRegen[client])
		{
			g_bAmmoRegen[client] = true;
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_AmmoOnlyOn");
			return;
		} else {
			g_bAmmoRegen[client] = false;
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_AmmoOnlyOff");
			return;
		}
	}
	if (StrEqual(RegenType, "Health", false))
	{
		if (g_bHardcore[client]) { g_bHardcore[client] = false; }
		if (!g_bHPRegen[client])
		{
			g_bHPRegen[client] = true;
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_HealthOnlyOn");
			return;
		} else {
			g_bHPRegen[client] = false;
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_HealthOnlyOff");
			return;
		}
	}
	if (StrEqual(RegenType, "Regen", false) && StrEqual(RegenToggle, "display", false))
	{
		if (!g_bAmmoRegen[client])
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_DisplayAmmoOff");
		} else {
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_DisplayAmmoOn");
		}
		if (!g_bHPRegen[client])
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_DisplayHealthOff");
		} else {
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_DisplayHealthOn");
		}
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_ShowHelp");
		return;
	} else if (StrEqual(RegenType, "Regen", false) && StrEqual(RegenToggle, "on", false))
	{
		g_bAmmoRegen[client] = true;
		g_bHPRegen[client] = true;
		if (g_bHardcore[client]) { g_bHardcore[client] = false; }
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_On");
	} else if (StrEqual(RegenType, "Regen", false) && StrEqual(RegenToggle, "off", false))
	{
		g_bAmmoRegen[client] = false;
		g_bHPRegen[client] = false;
		if (g_bHardcore[client]) { g_bHardcore[client] = false; }
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Regen_Off");
	} else {
		LogError("Unknown regen settings.");
	}
	return;
}
public Action:cmdJumpTF(client, args)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	ShowMOTDPanel(client, "Jump Assist Help", szWebsite, MOTDPANEL_TYPE_URL);
	return;
}
public Action:cmdJumpAssist(client, args)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	ShowMOTDPanel(client, "Jump Assist Help", szJumpAssist, MOTDPANEL_TYPE_URL);
	return;
}
public Action:cmdJumpForums(client, args)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	ShowMOTDPanel(client, "Jump Assist Help", szForum, MOTDPANEL_TYPE_URL);
	return;
}
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon){
	g_iButtons[client] = buttons; //FOR SKEYS AS WELL AS REGEN
	if ((g_iButtons[client] & IN_ATTACK) == IN_ATTACK || IN_ATTACK2)
	{
		if (g_bAmmoRegen[client])
		{
			ReSupply(client, g_iClientWeapons[client][0]);
			ReSupply(client, g_iClientWeapons[client][1]);
			ReSupply(client, g_iClientWeapons[client][2]);
			
			if (TF2_GetPlayerClass(client) == TFClass_Engineer){
				SetEntProp(client, Prop_Data, "m_iAmmo", 200, 4, 3);
			}
		}
		if (g_bHPRegen[client]){
			new iMaxHealth = TF2_GetPlayerResourceData(client, TFResource_MaxHealth);
			SetEntityHealth(client, iMaxHealth);
		}
	}
	if(g_bRaceLocked[client])
	{
		buttons &= ~IN_ATTACK;
		buttons &= ~IN_ATTACK2;
		if(buttons & IN_BACK)
		{
			return Plugin_Handled;
		}
		if(buttons & IN_FORWARD)
		{
			return Plugin_Handled;
		}
		if(buttons & IN_MOVERIGHT)
		{
			return Plugin_Handled;
		}
		if(buttons & IN_MOVELEFT)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
public SDKHook_OnWeaponEquipPost(client, weapon)
{
	if (IsValidClient(client))
	{
		g_iClientWeapons[client][0] = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		g_iClientWeapons[client][1] = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		g_iClientWeapons[client][2] = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	}
}
stock bool:IsValidWeapon(iEntity)
{
	decl String:strClassname[128];
	if (IsValidEntity(iEntity) && GetEntityClassname(iEntity, strClassname, sizeof(strClassname)) && StrContains(strClassname, "tf_weapon", false) != -1) return true;
	return false;
}
stock void ReSupply(int iClient, int iWeapon)
{
	if (!GetConVarBool(g_hPluginEnabled)) return;
	if (!IsValidWeapon(iWeapon)) return;
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient)) return;	//Check if the client is valid and alive
	
	int iWepIndex = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");	//Grab the weapon index
	char szClassname[128];
	GetEntityClassname(iWeapon, szClassname, sizeof(szClassname));				//Grab the weapon's classname
	
	//Rocket Launchers
	if (!StrContains(szClassname, "tf_weapon_rocketlauncher") || !StrContains(szClassname, "tf_weapon_particle_cannon")) //Check for Rocket Launchers
	{
		switch (iWepIndex)
		{
			case 441: //The Cow Mangler 5000
			{
				SetEntPropFloat(iWeapon, Prop_Send, "m_flEnergy", 100.0);	//Cow Mangler uses Energy instead of ammo.
			}
			case 228, 1085: //Black Box
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 3);
			}
			case 414: //Liberty Launcher
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 5);
			}
			case 730: {} //Beggar's Bazooka - This is here so we don't keep refilling its clip infinitely.
			default: //The default action for Rocket Launchers. This basically future proofs it for any new Rocket Launchers unless they have a totally different classname like the CM5K.
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 4); //Technically we don't need to make extra cases for different clip sizes, since players are constantly ReSupply()'d, but whatever.
			}
		}
		GivePlayerAmmo(iClient, 100, view_as<int>(TFWeaponSlot_Primary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	//Grenade Launchers
	if (!StrContains(szClassname, "tf_weapon_grenadelauncher") || !StrContains(szClassname, "tf_weapon_cannon")) //Check for Stickybomb Launchers
	{
		switch (iWepIndex)
		{
			case 308: // Loch-n-Load
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 3);
			}
			default: //The default action for Grenade Launchers
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 4);
			}
		}
		GivePlayerAmmo(iClient, 100, view_as<int>(TFWeaponSlot_Primary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	//MiniGuns
	if (!StrContains(szClassname, "tf_weapon_minigun")) //Check for Minigun
	{
		switch(iWepIndex)
		{
			default:
			{
				SetAmmo(iClient, iWeapon, 200);
			}
		}
	}
	//Stickybomb Launchers
	if (!StrContains(szClassname, "tf_weapon_pipebomblauncher")) //Check for Stickybomb Launchers
	{
		switch (iWepIndex)
		{
			case 1150: //Quickiebomb Launcher
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 4);
			}
			default: //The default action for Stickybomb Launchers
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 8);
			}
		}
		GivePlayerAmmo(iClient, 100, view_as<int>(TFWeaponSlot_Secondary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	//Shotguns
	if (!StrContains(szClassname, "tf_weapon_shotgun") || !StrContains(szClassname, "tf_weapon_sentry_revenge")) //Check for Shotguns
	{
		switch (iWepIndex)
		{
			case 425: //Family Business
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 8);
			}
			case 997, 415: //Rescue Ranger, Reserve Shooter
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 4);
			}
			case 141, 1004: //Frontier Justice
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 3);
			}
			case 527: //Widowmaker
			{
				SetEntProp(iClient, Prop_Data, "m_iAmmo", 200, _, 3); //Sets Metal count to 200
			}
			default: //The default action for Shotguns
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 6);
			}
		}
		if (TF2_GetPlayerClass(iClient) == TFClass_Engineer)
			GivePlayerAmmo(iClient, 100, view_as<int>(TFWeaponSlot_Primary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
		else
			GivePlayerAmmo(iClient, 100, view_as<int>(TFWeaponSlot_Secondary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	//FlameThrower
	if (!StrContains(szClassname, "tf_weapon_flamethrower")) //Check for FlameThrowers
	{
		switch (iWepIndex)
		{
			default: //The default action for FlameThrowers
			{
				SetAmmo(iClient, iWeapon, 200);
			}
		}
	}
	if (!StrContains(szClassname, "tf_weapon_flaregun")) // Check for Flare Guns
	{
		switch (iWepIndex)
		{
			default: //Force-A-Nature, Soda Popper
			{
				SetAmmo(iClient, iWeapon, 16);
			}
		}
	}
	//ScatterGuns
	if (!StrContains(szClassname, "tf_weapon_scattergun")) //Check for Scatter Guns
	{
		switch (iWepIndex)
		{
			case 45, 448: //Force-A-Nature, Soda Popper
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 2);
			}
			case 220, 772, 1103: //Shortstop, Babyface, BackScatter
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 4);
			}
			default: //The default action for Scatter Guns
			{
				SetEntProp(iWeapon, Prop_Send, "m_iClip1", 6);
			}
		}
		GivePlayerAmmo(iClient, 100, view_as<int>(TFWeaponSlot_Primary)+1, false); //Refill the player's ammo supply to whatever the weapon's max is.
	}
	// Ullapool caber
	if (!StrContains(szClassname, "tf_weapon_stickbomb"))
	{
		SetEntProp(iWeapon, Prop_Send, "m_bBroken", 0);
		SetEntProp(iWeapon, Prop_Send, "m_iDetonated", 0);
	}
}	
stock SetAmmo(client, iWeapon, iAmmo)
{
	new iAmmoType = GetEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType");
	if(iAmmoType != -1) SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, iAmmoType);
}
EraseLocs(client)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	g_fOrigin[client][0] = 0.0; g_fOrigin[client][1] = 0.0; g_fOrigin[client][2] = 0.0;
	g_fAngles[client][0] = 0.0; g_fAngles[client][1] = 0.0; g_fAngles[client][2] = 0.0;
	for(new j = 0; j < 8; j++)
	{
		g_bCPTouched[client][j] = false;
		g_iCPsTouched[client] = 0;
	}
	g_bBeatTheMap[client] = false;
	Format(g_sCaps[client], sizeof(g_sCaps), "\0");
}
CheckTeams()
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new maxplayers = GetMaxClients();
	for (new i=1; i<=maxplayers; i++)
	{
		if (!IsClientInGame(i) || IsClientObserver(i))
		{
			continue;
		} else if (GetClientTeam(i) == g_iForceTeam)
		{
			continue;
		}
		else {
			ChangeClientTeam(i, g_iForceTeam);
			PrintToChat(i, "\x01[\x03JA\x01] %t", "Switched_Teams");
		}
	}
}
LockCPs()
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new iCP = -1;
	g_iCPs = 0;
	while ((iCP = FindEntityByClassname(iCP, "trigger_capture_area")) != -1)
	{
		SetVariantString("2 0");
		AcceptEntityInput(iCP, "SetTeamCanCap");
		SetVariantString("3 0");
		AcceptEntityInput(iCP, "SetTeamCanCap");
		g_iCPs++;
	}
}
public Action:cmdRestart(client, args)
{
	if (!IsValidClient(client) || IsClientObserver(client) || !GetConVarBool(g_hPluginEnabled))
	{
		return Plugin_Handled;
	}
	if (skillsrank)
	{
		if (IsPlayerBusy(client))
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "General_Busy");
			return Plugin_Handled;
		}
	}
	EraseLocs(client);
	if(databaseConfigured)
	{
		ResetPlayerPos(client);
	}
	if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
		RestartSpeedrun(client);
	}else{
		TF2_RespawnPlayer(client);
	}
	PrintToChat(client, "\x01[\x03JA\x01] %t", "Player_Restarted");
	g_iLastTeleport[client] = 0;
	return Plugin_Handled;
}
SendToStart(client)
{
	if (!IsValidClient(client) || IsClientObserver(client) || !GetConVarBool(g_hPluginEnabled))
	{
		return;
	}
	g_bUsedReset[client] = true;
	if(GetConVarBool(hSpeedrunEnabled) && IsSpeedrunMap()&& speedrunStatus[client]){
		RestartSpeedrun(client);
	}else{
		TF2_RespawnPlayer(client);
	}
	PrintToChat(client, "\x01[\x03JA\x01] %t", "Player_SentToStart");
}
stock String:GetClassname(class)
{
	new String:buffer[128];
	switch(class)
	{
		case 1:	{ Format(buffer, sizeof(buffer), "%T", "Class_Scout", LANG_SERVER); }
		case 2: { Format(buffer, sizeof(buffer), "%T", "Class_Sniper", LANG_SERVER); }
		case 3: { Format(buffer, sizeof(buffer), "%T", "Class_Soldier", LANG_SERVER); }
		case 4: { Format(buffer, sizeof(buffer), "%T", "Class_Demoman", LANG_SERVER); }
		case 5: { Format(buffer, sizeof(buffer), "%T", "Class_Medic", LANG_SERVER); }
		case 6: { Format(buffer, sizeof(buffer), "%T", "Class_Heavy", LANG_SERVER); }
		case 7: { Format(buffer, sizeof(buffer), "%T", "Class_Pyro", LANG_SERVER); }
		case 8: { Format(buffer, sizeof(buffer), "%T", "Class_Spy", LANG_SERVER); }
		case 9: { Format(buffer, sizeof(buffer), "%T", "Class_Engineer", LANG_SERVER); }
	}
	return buffer;
}
bool:IsValidClient( client )
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) || IsFakeClient(client))
        return false;
    return true;
}
public jteleHandler(Handle:menu, MenuAction:action, client, item)
{
	//decl String:MenuInfo[64];
	if (action == MenuAction_Select)
	{
		GetMenuItem(menu, item, Jtele, sizeof(Jtele));
		JumpList(client);
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
	return;
}
stock FindTarget2(client, const String:target[], bool:nobots = false, bool:immunity = true)
{
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[1], target_count, bool:tn_is_ml;
	new flags = COMMAND_FILTER_NO_MULTI;
	if (nobots)
	{
		flags |= COMMAND_FILTER_NO_BOTS;
	}
	if (!immunity)
	{
		flags |= COMMAND_FILTER_NO_IMMUNITY;
	}
	if ((target_count = ProcessTargetString(
			target,
			client,
			target_list,
			1,
			flags,
			target_name,
			sizeof(target_name),
			tn_is_ml)) > 0)
	{
		return target_list[0];
	}
	else
	{
		if (target_count == 0) { return -1; }
		ReplyToCommand(client, "\x01[\x03JA\x01] %t", "No matching client");
		return -1;
	}
}
// Ugly wtf was I thinking?
stock GetValidClassNum(String:class[])
{
	new iClass = -1;
	if(StrEqual(class,"scout", false))
	{
		iClass = 1;
		return iClass;
	}
	if(StrEqual(class,"sniper", false))
	{
		iClass = 2;
		return iClass;
	}
	if(StrEqual(class,"soldier", false))
	{
		iClass = 3;
		return iClass;
	}
	if(StrEqual(class,"demoman", false))
	{
		iClass = 4;
		return iClass;
	}
	if(StrEqual(class,"medic", false))
	{
		iClass = 5;
		return iClass;
	}
	if(StrEqual(class,"heavy", false))
	{
		iClass = 6;
		return iClass;
	}
	if(StrEqual(class,"pyro", false))
	{
		iClass = 7;
		return iClass;
	}
	if(StrEqual(class,"spy", false))
	{
		iClass = 8;
		return iClass;
	}
	if(StrEqual(class,"engineer", false))
	{
		iClass = 9;
		return iClass;
	}
	return iClass;
}
public JumpListHandler(Handle:menu, MenuAction:action, client, item)
{
	if(!databaseConfigured)
	{
		PrintToChat(client, "This feature is not supported without a database configuration");
		return;
	}
	decl String:MenuInfo[64];
	if (action == MenuAction_Select)
	{
		GetMenuItem(menu, item, MenuInfo, sizeof(MenuInfo));
		MenuSendToLocation(client, Jtele, MenuInfo);
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
	return;
}
stock bool:IsUserAdmin(client)
{
	new bool:IsAdmin = GetAdminFlag(GetUserAdmin(client), Admin_Generic);
	if (IsAdmin)
		return true;
	else
		return false;
}
stock SetCvarValues()
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	if (!GetConVarBool(g_hCriticals))
		SetConVarInt(FindConVar("tf_weapon_criticals"), 0, true, false);
	if (GetConVarBool(g_hFastBuild))
		SetConVarInt(FindConVar("tf_fastbuild"), 1, false, false);
	if (GetConVarBool(g_hCheapObjects))
		SetConVarInt(FindConVar("tf_cheapobjects"), 1, false, false);
	if (GetConVarBool(g_hAmmoCheat))
		SetConVarInt(FindConVar("tf_sentrygun_ammocheat"), 1, false, false);
}
/*****************************************************************************************************************
													Natives
*****************************************************************************************************************/
public Native_JA_GetSettings(Handle:plugin, numParams)
{
	new setting = GetNativeCell(1);
	new client = GetNativeCell(2);
	if (client != -1)
	{
		// Client is only needed for all but 1 setting so far.
		if (client < 1 || client > GetMaxClients())
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
		}
		if (!IsClientConnected(client))
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
		}
	}
	switch (setting)
	{
		case 1: { return g_iMapClass; }
		case 2: { return g_bAmmoRegen[client]; }
		case 3: { return g_bHPRegen[client]; }
	}
	return ThrowNativeError(SP_ERROR_NATIVE, "Invalid setting param.");
}
public Native_JA_ClearSave(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > GetMaxClients())
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	if (!IsClientConnected(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}
	EraseLocs(client);
	PrintToChat(client, "\x01[\x03JA\x01] %t", "Native_ClearSave");
	return true;
}
public Native_JA_PrepSpeedRun(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > GetMaxClients())
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	if (!IsClientConnected(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}
	EraseLocs(client);
	if (g_bUnkillable[client]) { g_bUnkillable[client] = false; SetEntProp(client, Prop_Data, "m_takedamage", 2, 1); }
	g_bSpeedRun[client] = true;
	PrintToChat(client, "\x01[\x03JA\x01] %t", "Native_ClearSave");
	return true;
}
public Native_JA_ReloadPlayerSettings(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > GetMaxClients())
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	if (!IsClientConnected(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}
	g_bSpeedRun[client] = false;
	if(databaseConfigured)
	{
		ReloadPlayerData(client);
	}
	return true;
}
/*****************************************************************************************************************
												Player Events
*****************************************************************************************************************/
public Action:OnPlayerStartTouchFuncRegenerate(entity, other)
{
	if(other <= MaxClients && GetArraySize(hArray_NoFuncRegen) > 0 && FindValueInArray(hArray_NoFuncRegen,other) != -1)
	{
#if defined DEBUG_FUNC_REGEN
		LogMessage("Entity %d touch %d Prevented",entity,other);
#endif
		return Plugin_Handled;
	}
#if defined DEBUG_FUNC_REGEN
	LogMessage("Entity %d touch %d Allowed",entity,other);
#endif
	return Plugin_Continue;
}
public Action:eventPlayerBuiltObj(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new client = GetClientOfUserId(GetEventInt(event, "userid")), obj = GetEventInt(event, "object"), index = GetEventInt(event, "index");
	if (obj == 2)
	{
		if (GetConVarInt(g_hSentryLevel) == 3)
		{
			//SetEntData(index, FindSendPropOffs("CObjectSentrygun", "m_iUpgradeLevel"), 3, 4);
			//SetEntData(index, FindSendPropOffs("CObjectSentrygun", "m_iUpgradeMetal"), 200);
		}
	}
	if (!g_bHardcore[client])
	{
		SetEntData(client, FindDataMapOffs(client, "m_iAmmo") + (3 * 4), 199, 4);
	}
}
public Action:eventPlayerUpgradedObj(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new client = GetClientOfUserId(GetEventInt(event, "userid")); //object = GetEventInt(event, "object"), index = GetEventInt(event, "index");
	if (!g_bHardcore[client])
	{
		SetEntData(client, FindDataMapOffs(client, "m_iAmmo") + (3 * 4), 199, 4);
	}
}
public Action:eventRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:currentMap[32]; GetCurrentMap(currentMap, sizeof(currentMap));
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	if (g_iLockCPs == 1) { LockCPs(); }
	Hook_Func_regenerate();
	SetCvarValues();
}
public Action:eventTouchCP(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new client = GetEventInt(event, "player"), area = GetEventInt(event, "area"), class = view_as<int>(TF2_GetPlayerClass(client)), entity;
	decl String:g_sClass[33], String:playerName[64], String:cpName[32], String:s_area[32];
	
	if (!g_bCPTouched[client][area] || g_bRace[client] != 0)
	{
		Format(g_sClass, sizeof(g_sClass), "%s", GetClassname(class));
		GetClientName(client, playerName, 64);
		while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1)
		{
			new pIndex = GetEntProp(entity, Prop_Data, "m_iPointIndex");
			if (pIndex == area)
			{
				new bool:raceComplete;
				if(g_bRaceEndPoint[g_bRace[client]] == pIndex && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)){
					raceComplete = true;
					new Float:time;
					new String:timeString[255];
					new String:clientName[128];
					new String:buffer[128];
					time = GetEngineTime();
					g_bRaceTime[client] = time;
					new Float:timeTaken;
					timeTaken = time - g_bRaceStartTime[g_bRace[client]];
					timeString = TimeFormat(timeTaken);
					GetClientName(client, clientName, sizeof(clientName));
					if(RoundToNearest(g_bRaceFirstTime[g_bRace[client]]) == 0)
					{
						Format(buffer, sizeof(buffer), "%s won the race in %s!", clientName, timeString);
						g_bRaceFirstTime[g_bRace[client]] = time;
						g_bRaceStatus[g_bRace[client]] = 4;
						for(new i = 0; i < MAXPLAYERS; i++){
							if(g_bRaceFinishedPlayers[g_bRace[client]][i] == 0){
								g_bRaceFinishedPlayers[g_bRace[client]][i] = client;
								g_bRaceTimes[g_bRace[client]][i] = time;
								break;
							}
						}
						EmitSoundToRace(client, "misc/killstreak.wav");
					}
					else
					{
						new Float:firstTime;
						new Float:diff;
						new String:diffFormatted[255];
						firstTime = g_bRaceFirstTime[g_bRace[client]];
						diff = time - firstTime;
						diffFormatted = TimeFormat(diff);
						for(new i = 0; i < MAXPLAYERS; i++){
							if(g_bRaceFinishedPlayers[g_bRace[client]][i] == 0){
								g_bRaceFinishedPlayers[g_bRace[client]][i] = client;
								g_bRaceTimes[g_bRace[client]][i] = time;
								break;
							}
						}
						Format(buffer, sizeof(buffer), "%s finished the race in %s[-%s]!", clientName, timeString, diffFormatted);
						EmitSoundToRace(client, "misc/freeze_cam.wav");
					}
					if(RoundToZero(g_bRaceFirstTime[g_bRace[client]]) == 0)
					{
						g_bRaceFirstTime[g_bRace[client]] = time;
					}
					PrintToRace(g_bRace[client], buffer);
					if (GetPlayersStillRacing(g_bRace[client]) == 0)
					{
						PrintToRace(g_bRace[client], "Everyone has finished the race.");
						PrintToRace(g_bRace[client], "\x01Type \x03!r_list\x01 to see all times.");
						g_bRaceStatus[g_bRace[client]] = 5;
					}
				}
				if (!g_bCPTouched[client][area] && ((RoundFloat(GetEngineTime()) - g_iLastTeleport[client]) > 10)){
					GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
					if (g_bHardcore[client])
					{
						// "Hardcore" mode
						//PrintToChatAll("\x01[\x03JA\x01] %t", "Player_Capped_BOSS", playerName, cpName, g_sClass, cLightGreen, cDefault, cLightGreen, cDefault, cLightGreen, cDefault);
						CPrintToChatAll("{DEFAULT}[{LIGHTGREEN}JA{DEFAULT}] [{ORANGERED}Hardcore{DEFAULT}] {LIGHTGREEN}%s{DEFAULT} has reached {LIGHTGREEN}%s{DEFAULT} as {LIGHTGREEN}%s{DEFAULT}.", playerName, cpName, g_sClass);
						if(raceComplete){
							EmitSoundToNotRace(client, "misc/freeze_cam.wav");
						}else{
							EmitSoundToAll("misc/freeze_cam.wav");
						}
					} else {
						// Normal mode
						PrintToChatAll("\x01[\x03JA\x01] %t", "Player_Capped", playerName, cpName, g_sClass, cLightGreen, cDefault, cLightGreen, cDefault, cLightGreen, cDefault);
						if(raceComplete){
							EmitSoundToNotRace(client, "misc/freeze_cam.wav");
						}else{
							EmitSoundToAll("misc/freeze_cam.wav");
						}
					}
					if (g_iCPsTouched[client] == g_iCPs)
					{
						g_bBeatTheMap[client] = true;
						//PrintToChat(client, "\x01[\x03JA\x01] %t", "Goto_Avail");
					}
				}
			}
			//SaveCapData(client);
		}
		g_bCPTouched[client][area] = true; g_iCPsTouched[client]++; IntToString(area, s_area, sizeof(s_area));
		if (g_sCaps[client] != -1) { Format(g_sCaps[client], sizeof(g_sCaps), "%s%s", g_sCaps[client], s_area); } else { Format(g_sCaps[client], sizeof(g_sCaps), "%s", s_area); }
	}
}
public Action:eventPlayerChangeClass(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsClientRacing(client) && !IsPlayerFinishedRacing(client) && HasRaceStarted(client)){
		if(g_bRaceClassForce[g_bRace[client]]){
			new TFClassType:oldclass = TF2_GetPlayerClass(client);
			TF2_SetPlayerClass(client, oldclass);
			PrintToChat(client, "\x01[\x03JA\x01] Cannot change class while racing.");
			return;
		}
	}
	decl String:g_sClass[MAX_NAME_LENGTH], String:steamid[32];
	EraseLocs(client);
	TF2_RespawnPlayer(client);
	g_bUnkillable[client] = false;
	GetClientAuthId(client,AuthId_Steam2, steamid, sizeof(steamid));
	new class = view_as<int>(TF2_GetPlayerClass(client));
	Format(g_sClass, sizeof(g_sClass), "%s", GetClassname(g_iMapClass));
	g_fLastSavePos[client][0] = 0.0;
	g_fLastSavePos[client][1] = 0.0;
	g_fLastSavePos[client][2] = 0.0;
	g_iClientWeapons[client][0] = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	g_iClientWeapons[client][1] = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	g_iClientWeapons[client][2] = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (g_iMapClass != -1)
	{
		if (class != g_iMapClass)
		{
			g_bHPRegen[client] = true;
			g_bAmmoRegen[client] = true;
			g_bHardcore[client] = false;
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Designed_For", cLightGreen, g_sClass, cDefault);
		}
	}
}
public Action:eventPlayerChangeTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return Plugin_Handled; }
	new client = GetClientOfUserId(GetEventInt(event, "userid")), team = GetEventInt(event, "team");
	if (g_bRace[client] && (g_bRaceStatus[g_bRace[client]] == 2 || g_bRaceStatus[g_bRace[client]] == 3))
	{
		PrintToChat(client, "\x01[\x03JA\x01] You may not change teams during the race.");
		return Plugin_Handled;
	}
	g_bUnkillable[client] = false;
	if (team == 1 || g_iForceTeam == 1 || team == g_iForceTeam)
	{
		g_fOrigin[client][0] = 0.0; g_fOrigin[client][1] = 0.0; g_fOrigin[client][2] = 0.0;
		g_fAngles[client][0] = 0.0; g_fAngles[client][1] = 0.0; g_fAngles[client][2] = 0.0;
		if(speedrunStatus[client]){
			PrintToChat(client, "\x01[\x03JA\x01] Speedrun cancelled");
		}
		speedrunStatus[client] = 0;
		for(new i = 0; i < 32; i++){
			zoneTimes[client][i] = 0.0;
		}
		lastFrameInStartZone[client] = false;
	} else {
		CreateTimer(0.1, timerTeam, client);
	}
	g_fLastSavePos[client][0] = 0.0;
	g_fLastSavePos[client][1] = 0.0;
	g_fLastSavePos[client][2] = 0.0;
	return Plugin_Handled;
}
public eventInventoryUpdate(Handle:hEvent, String:strName[], bool:bDontBroadcast)
{
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!IsValidClient(iClient)) return;
	CheckBeggers(iClient);
}
public Action:eventPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, timerRespawn, client);
}
public Action:eventPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (g_bHPRegen[client])
	{
		CreateTimer(0.1, timerRegen, client);
	}
	if (g_bAmmoRegen[client])
	{
		ReSupply(client, g_iClientWeapons[client][0]);
		ReSupply(client, g_iClientWeapons[client][1]);
		ReSupply(client, g_iClientWeapons[client][2]);
	}
}
public Action:eventPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return; }
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	// Check if they have the jumper equipped, and hardcore is on for some reason.
	if (IsUsingJumper(client) && g_bHardcore[client])
	{
		g_bHardcore[client] = false;
	}
	// Disable func_regenerate if player is using beggers bazooka
	CheckBeggers(client);
	if (g_bUsedReset[client])
	{
		if(databaseConfigured)
		{
			ReloadPlayerData(client);
		}
		g_bUsedReset[client] = false;
		return;
	}
	if(databaseConfigured){
		LoadPlayerData(client);
	}
	g_bRaceSpec[client] = 0;
}
/*****************************************************************************************************************
												Timers
*****************************************************************************************************************/
public Action:timerTeam(Handle:timer, any:client)
{
	if (client == 0)
	{
		return;
	}
	EraseLocs(client);
	if(IsClientInGame(client)){
		ChangeClientTeam(client, g_iForceTeam);
	}
}
public Action:timerRegen(Handle:timer, any:client)
{
	if (client == 0 || !IsValidEntity(client))
	{
		return;
	}
	new iMaxHealth = TF2_GetPlayerResourceData(client, TFResource_MaxHealth);
	SetEntityHealth(client, iMaxHealth);
}
public Action:timerRespawn(Handle:timer, any:client)
{
	if (IsValidClient(client))
	{
		TF2_RespawnPlayer(client);
	}
}
public Action:WelcomePlayer(Handle:timer, any:client)
{
	decl String:sHostname[64];
	GetConVarString(g_hHostname, sHostname, sizeof(sHostname));
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
public cvarFastBuildChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StringToInt(newValue) == 0)
	{
		SetConVarInt(FindConVar("tf_fastbuild"), 0);
	}
	else
	{
		SetConVarInt(FindConVar("tf_fastbuild"), 1);
	}
}
public cvarCheapObjectsChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StringToInt(newValue) == 0)
	{
		SetConVarInt(FindConVar("tf_cheapobjects"), 0);
	}
	else
	{
		SetConVarInt(FindConVar("tf_cheapobjects"), 1);
	}
}
public cvarAmmoCheatChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StringToInt(newValue) == 0)
	{
		SetConVarInt(FindConVar("tf_sentrygun_ammocheat"), 0);
	}
	else
	{
		SetConVarInt(FindConVar("tf_sentrygun_ammocheat"), 1);
	}
}
public cvarWelcomeMsgChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StringToInt(newValue) == 0)
		SetConVarBool(g_hWelcomeMsg, false);
	else
		SetConVarBool(g_hWelcomeMsg, true);
}
public cvarSentryLevelChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StringToInt(newValue) == 0)
		SetConVarBool(g_hSentryLevel, false);
	else
		SetConVarBool(g_hSentryLevel, true);
}
public cvarSupermanChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StringToInt(newValue) == 0)
		SetConVarBool(g_hSuperman, false);
	else
		SetConVarBool(g_hSuperman, true);
}
public cvarSpeedrunEnabledChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StringToInt(newValue) == 0)
		SetConVarBool(hSpeedrunEnabled, false);
	else
		SetConVarBool(hSpeedrunEnabled, true);
}