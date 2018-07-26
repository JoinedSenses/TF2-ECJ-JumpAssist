ConVar
	g_cvarHostname
	, g_cvarPluginEnabled;
bool
	g_bCPTouched[MAXPLAYERS+1][32]
	, g_bAmmoRegen[MAXPLAYERS+1]
	, g_bHardcore[MAXPLAYERS+1]
	, g_bLoadedPlayerSettings[MAXPLAYERS+1]
	, g_bBeatTheMap[MAXPLAYERS+1]
	, g_bUsedReset[MAXPLAYERS+1]
	, g_bUnkillable[MAXPLAYERS+1]
	, g_bLateLoad
	, g_bDatabaseConfigured;
int
	g_iCPs
	, g_iForceTeam = 1
	, g_iCPsTouched[MAXPLAYERS+1]
	, g_iLockCPs = 1;
float
	g_fOrigin[MAXPLAYERS+1][3]
	, g_fAngles[MAXPLAYERS+1][3]
	, g_fLastSavePos[MAXPLAYERS+1][3]
	, g_fLastSaveAngles[MAXPLAYERS+1][3];

void JA_SendQuery(char[] query, int client) {
	g_Database.Query(SQL_OnSetKeys, query, client);
}

void ConnectToDatabase() {
	Database.Connect(SQL_OnConnect, "jumpassist");
}

void SQL_OnConnect(Database db, const char[] error, any data) {
	if (db == null) {
		PrintToServer("[JumpAssist] Invalid database configuration, assuming none");
		PrintToServer(error);
		g_bDatabaseConfigured = false;
	}
	else {
		g_bDatabaseConfigured = true;
		g_Database = db;
		if (g_bLateLoad) {
			for (int client = 1; client <= MaxClients; client++) {
				if (IsValidClient(client)) {
					GetClientAuthId(client, AuthId_Steam2, g_sClientSteamID[client], sizeof(g_sClientSteamID[]));
					ReloadPlayerData(client);
					LoadPlayerProfile(client);
				}
			}
		}
		RunDBCheck();
	}
}

void RunDBCheck() {
	char
		error[255]
		, query[2048]
		, dbType[32];

	DBDriver driverType = g_Database.Driver; 
	driverType.GetProduct(dbType, sizeof(dbType));

	bool isMysql = StrEqual(dbType, "mysql", false);
	g_Database.Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `player_saves` (`RecID` INTEGER NOT NULL PRIMARY KEY %s, `steamID` VARCHAR(32) NOT NULL, `playerClass` INT(1) NOT NULL, `playerTeam` INT(1) NOT NULL, `playerMap` VARCHAR(32) NOT NULL, `save1` INT(25) NOT NULL, `save2` INT(25) NOT NULL, `save3` INT(25) NOT NULL, `save4` INT(25) NOT NULL, `save5` INT(25) NOT NULL, `save6` INT(25) NOT NULL)", isMysql?"AUTO_INCREMENT":"AUTOINCREMENT");
	if (!SQL_FastQuery(g_Database, query)) {
		SQL_GetError(g_Database, error, sizeof(error));
		LogError("Failed to query (player_saves) (error: %s)", error);
	}
	g_Database.Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `player_profiles` (`ID` integer PRIMARY KEY %s NOT NULL, `SteamID` text NOT NULL, `SKEYS_RED_COLOR`  INTEGER NOT NULL DEFAULT 255, `SKEYS_GREEN_COLOR`  INTEGER NOT NULL DEFAULT 255, `SKEYS_BLUE_COLOR`  INTEGER NOT NULL DEFAULT 255)", isMysql?"AUTO_INCREMENT":"AUTOINCREMENT");
	if (!SQL_FastQuery(g_Database, query)) {
		SQL_GetError(g_Database, error, sizeof(error));
		LogError("Failed to query (player_profiles) (error: %s)", error);
	}
	g_Database.Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `map_settings` (`ID` integer PRIMARY KEY %s NOT NULL, `Map` text NOT NULL, `Team` int NOT NULL, `LockCPs` int NOT NULL)", isMysql?"AUTO_INCREMENT":"AUTOINCREMENT");
	if (!SQL_FastQuery(g_Database, query)) {
		SQL_GetError(g_Database, error, sizeof(error));
		LogError("Failed to query (map_settings) (error: %s)", error);
	}
}

void SQL_OnMapSettingsUpdated(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("Query failed! %s", error);
		ReplyToCommand(data, "\x01[\x03JA\x01] %t (%s)", "Mapset_Not_Saved", cLightGreen, cDefault, error);
	}
	else {
		ReplyToCommand(data, "\x01[\x03JA\x01] %t", "Mapset_Saved", cLightGreen, cDefault);
	}
}

void SQL_OnMapSettingsLoad(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("Query failed! %s", error);
	}
	else if (results.FetchRow()) {
		g_iForceTeam = results.FetchInt(0);
		g_iLockCPs = results.FetchInt(1);
	}
	else {
		CreateMapCFG();
	}
}

void SQL_OnSetKeys(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("Query failed! %s", error);
	}
	PrintToChat(data, "\x01[\x03JA\x01] %t", (db == null) ? "SetMy_Failed" : "SetMy_Success");
}

void SQL_OnLoadPlayerProfile(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnLoadPlayerProfile() - Query failed!");
	}
	else if (results.FetchRow()) {
		g_iSkeysRed[data] = results.FetchInt(2);
		g_iSkeysGreen[data] = results.FetchInt(3);
		g_iSkeysBlue[data] = results.FetchInt(4);	

		g_bLoadedPlayerSettings[data] = true;
	}
	else if (IsValidClient(data) && g_bDatabaseConfigured) {
		// No profile
		CreatePlayerProfile(data);
	}
}

void SQL_OnCreatePlayerProfile(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnCreatePlayerProfile() - Query failed! %s", error);
		return;
	}
	g_bHardcore[data] = g_bLoadedPlayerSettings[data] = false;
}

void SQL_OnDefaultCallback(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnDefaultCallback() - Query failed! %s", error);
	}
}

void SQL_OnReloadPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnreloadPlayerData() - Query failed! %s", error);
	}
	else if (results.FetchRow()) {
		for (int i = 0; i <= 2; i++) {
			 g_fOrigin[data][i] = results.FetchFloat(i);
			 g_fAngles[data][i] = results.FetchFloat(i+3);
		}
		g_bUsedReset[data] = false;
	}
}

void SQL_OnLoadPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnLoadPlayerData() - Query failed! %s", error);
	}
	else if (results.FetchRow()) {
		for (int i = 0; i <= 2; i++) {
			 g_fOrigin[data][i] = results.FetchFloat(i);
			 g_fAngles[data][i] = results.FetchFloat(i+3);
		}
		if (!g_bHardcore[data] && !IsClientRacing(data)) {
			Teleport(data);
			g_iLastTeleport[data] = RoundFloat(GetEngineTime());
		}
	}
}

void SQL_OnDeletePlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnDeletePlayerData() - Query failed! %s", error);
		return;
	}
	EraseLocs(data);
	g_bBeatTheMap[data] = false;
}

void SQL_OnGetPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnGetPlayerData() - Query failed! %s", error);
		return;
	}
	if (results.FetchRow()) {
		UpdatePlayerData(data);
	}
	else {
		SavePlayerData(data);
	}
}

void GetPlayerData(int client) {
	char sQuery[256];

	Format(sQuery, sizeof(sQuery), "SELECT * FROM `player_saves` WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", g_sClientSteamID[client], g_iClientTeam[client], view_as<int>(g_TFClientClass[client]), g_sCurrentMap);
	g_Database.Query(SQL_OnGetPlayerData, sQuery, client);
}

void SavePlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}
	char
		sQuery[1024];
	float
		SavePos1[MAXPLAYERS+1][3]
		, SavePos2[MAXPLAYERS+1][3];

	GetClientAbsOrigin(client, SavePos1[client]);
	GetClientAbsAngles(client, SavePos2[client]);

	Format(sQuery, sizeof(sQuery), "INSERT INTO `player_saves` VALUES(null, '%s', '%i', '%i', '%s', '%f', '%f', '%f', '%f', '%f', '%f')", g_sClientSteamID[client], view_as<int>(g_TFClientClass[client]), g_iClientTeam[client], g_sCurrentMap, SavePos1[client][0], SavePos1[client][1], SavePos1[client][2], SavePos2[client][0], SavePos2[client][1], SavePos2[client][2]);
	g_Database.Query(SQL_OnDefaultCallback, sQuery, client);
}

void UpdatePlayerData(int client) {
	char
		sQuery[1024];
	float
		SavePos1[MAXPLAYERS+1][3]
		, SavePos2[MAXPLAYERS+1][3];

	GetClientAbsOrigin(client, SavePos1[client]);
	GetClientAbsAngles(client, SavePos2[client]);

	Format(sQuery, sizeof(sQuery), "UPDATE `player_saves` SET save1 = '%f', save2 = '%f', save3 = '%f', save4 = '%f', save5 = '%f', save6 = '%f' where steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", SavePos1[client][0], SavePos1[client][1], SavePos1[client][2], SavePos2[client][0], SavePos2[client][1], SavePos2[client][2], g_sClientSteamID[client], g_iClientTeam[client], view_as<int>(g_TFClientClass[client]), g_sCurrentMap);
	g_Database.Query(SQL_OnDefaultCallback, sQuery, client);
}

void DeletePlayerData(int client) {
	char sQuery[1024];
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM player_saves WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", g_sClientSteamID[client], g_iClientTeam[client], view_as<int>(g_TFClientClass[client]), g_sCurrentMap);
	g_Database.Query(SQL_OnDeletePlayerData, sQuery, client);
}

void ReloadPlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}
	char sQuery[1024];

	Format(sQuery, sizeof(sQuery), "SELECT save1, save2, save3, save4, save5, save6 FROM player_saves WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", g_sClientSteamID[client], g_iClientTeam[client], view_as<int>(g_TFClientClass[client]), g_sCurrentMap);
	g_Database.Query(SQL_OnReloadPlayerData, sQuery, client, DBPrio_High);
}

void LoadPlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}
	char sQuery[1024];
	
	Format(sQuery, sizeof(sQuery), "SELECT save1, save2, save3, save4, save5, save6 FROM player_saves WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", g_sClientSteamID[client], g_iClientTeam[client], view_as<int>(g_TFClientClass[client]), g_sCurrentMap);
	g_Database.Query(SQL_OnLoadPlayerData, sQuery, client, DBPrio_High);
}

void LoadPlayerProfile(int client) {
	if (!IsValidClient(client)) {
		return;
	}
	char query[1024];
	if (g_bDatabaseConfigured) {
		Format(query, sizeof(query), "SELECT * FROM `player_profiles` WHERE SteamID = '%s'", g_sClientSteamID[client]);
		g_Database.Query(SQL_OnLoadPlayerProfile, query, client);
	}
	else {
		g_bAmmoRegen[client] = g_bHardcore[client] = false;
		g_bLoadedPlayerSettings[client] = true;
	}
}

void CreateMapCFG() {
	char query[1024];
	Format(query, sizeof(query), "INSERT INTO `map_settings` values(null, '%s', '1', '1')", g_sCurrentMap);
	g_Database.Query(SQL_OnDefaultCallback, query);
	g_iForceTeam = g_iLockCPs = 1;
}

void LoadMapCFG() {
	char query[1024];
	Format(query, sizeof(query), "SELECT Team, LockCPs FROM `map_settings` WHERE Map = '%s'", g_sCurrentMap);
	g_Database.Query(SQL_OnMapSettingsLoad, query);
}

void CreatePlayerProfile(int client) {
	char query[1024];
	Format(query, sizeof(query), "INSERT INTO `player_profiles` values(null, '%s', '255', '255', '255')", g_sClientSteamID[client]);
	g_Database.Query(SQL_OnCreatePlayerProfile, query, client);
}

Action cmdMapSet(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Handled;
	}
	if (!g_bDatabaseConfigured) {
		PrintToChat(client, "This feature is not supported without a database configuration");
		return Plugin_Handled;
	}
	if (args < 2) {
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Mapset_Help");
		return Plugin_Handled;
	}
	int
		g_iTeam
		, g_iLock;
	char
		arg1[MAX_NAME_LENGTH]
		, arg2[MAX_NAME_LENGTH]
		, query[512];

	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));

	if (StrEqual(arg1, "team", false)) {
		// Wonder if there is a prettier way of doing this.
		if (StrEqual(arg2, "none", false)) {
			g_iTeam = g_iForceTeam = 1;
		}
		else if (StrEqual(arg2, "red", false)) {
			g_iTeam = g_iForceTeam = 2;
			CheckTeams();
		}
		else if (StrEqual(arg2, "blue", false)) {
			g_iTeam = g_iForceTeam = 3;
			CheckTeams();
		}
		else {
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Mapset_Team_Help");
			return Plugin_Handled;	
		}
		g_Database.Format(query, sizeof(query), "UPDATE `map_settings` SET Team = '%i' WHERE Map = '%s'", g_iTeam, g_sCurrentMap);
		g_Database.Query(SQL_OnMapSettingsUpdated, query, client);
	}
	else if (StrEqual(arg1, "lockcps", false)) {
		if (StrEqual(arg2, "on", false)) {
			g_iLock = 1;
		}
		else if (StrEqual(arg2, "off", false)) {
			g_iLock = 0;
		}
		else {
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Mapset_LockCP_Help");
			return Plugin_Handled;
		}
		g_Database.Format(query, sizeof(query), "UPDATE `map_settings` SET LockCPs = '%i' WHERE Map = '%s'", g_iLock, g_sCurrentMap);
		g_Database.Query(SQL_OnMapSettingsUpdated, query, client);
	}
	return Plugin_Handled;
}