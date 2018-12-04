bool
	  g_bLoadedPlayerSettings[MAXPLAYERS+1];
int
	  g_iCPs
	, g_iForceTeam = 1
	, g_iCPsTouched[MAXPLAYERS+1]
	, g_iLockCPs = 1;

void ConnectToDatabase() {
	Database.Connect(SQL_OnConnect, "jumpassist");
}

void SQL_OnConnect(Database db, const char[] error, any data) {
	if (db == null) {
		PrintToServer("[JumpAssist] Invalid database configuration, assuming none");
		PrintToServer(error);
	}
	else {
		g_Database = db;
		if (g_bLateLoad) {
			for (int client = 1; client <= MaxClients; client++) {
				if (IsValidClient(client)) {
					ReloadPlayerData(client);
					LoadPlayerProfile(client);
					LoadMapCFG();
				}
			}
		}
		RunDBCheck();
	}
}

void RunDBCheck() {
	char error[255];
	char query[2048];
	char dbType[32];

	DBDriver driverType = g_Database.Driver; 
	driverType.GetProduct(dbType, sizeof(dbType));

	char increment[16];
	strcopy(increment, sizeof(increment),(StrEqual(dbType, "mysql", false)) ? "AUTO_INCREMENT" : "AUTOINCREMENT");
	g_Database.Format(
		query
		, sizeof(query)
		, "CREATE TABLE IF NOT EXISTS player_saves "
		... "("
			... "RecID INT NOT NULL PRIMARY KEY %s, "
			... "steamID VARCHAR(32) NOT NULL, "
			... "playerClass TINYINT UNSIGNED NOT NULL, "
			... "playerTeam TINYINT UNSIGNED NOT NULL, "
			... "playerMap VARCHAR(32) NOT NULL, "
			... "origin1 SMALLINT NOT NULL, "
			... "origin2 SMALLINT NOT NULL, "
			... "origin3 SMALLINT NOT NULL, "
			... "angle2 SMALLINT NOT NULL"
		... ")"
		, increment
	);
	SQL_LockDatabase(g_Database);
	if (!SQL_FastQuery(g_Database, query)) {
		SQL_GetError(g_Database, error, sizeof(error));
		LogError("Failed to query (player_saves) (error: %s)", error);
	}
	SQL_UnlockDatabase(g_Database);
	g_Database.Format(
		query
		, sizeof(query)
		, "CREATE TABLE IF NOT EXISTS player_profiles "
		... "("
			... "ID INT PRIMARY KEY %s NOT NULL, "
			... "SteamID TEXT NOT NULL, "
			... "SKEYS_RED_COLOR TINYINT UNSIGNED NOT NULL DEFAULT 255, "
			... "SKEYS_GREEN_COLOR TINYINT UNSIGNED NOT NULL DEFAULT 255, "
			... "SKEYS_BLUE_COLOR TINYINT UNSIGNED NOT NULL DEFAULT 255, "
			... "SKEYSX DECIMAL(5,4) NOT NULL DEFAULT 0.54, "
			... "SKEYSY DECIMAL(5,4) NOT NULL DEFAULT 0.40"
		... ")"
		, increment
	);
	
	SQL_LockDatabase(g_Database);
	if (!SQL_FastQuery(g_Database, query)) {
		SQL_GetError(g_Database, error, sizeof(error));
		LogError("Failed to query (player_profiles) (error: %s)", error);
	}
	SQL_UnlockDatabase(g_Database);
	g_Database.Format(
		query
		, sizeof(query)
		, "CREATE TABLE IF NOT EXISTS map_settings "
		... "("
			... "ID INT PRIMARY KEY %s NOT NULL, "
			... "Map TEXT NOT NULL, "
			... "Team TINYINT UNSIGNED NOT NULL, "
			... "LockCPs TINYINT UNSIGNED NOT NULL"
		... ")"
		, increment
	);
	SQL_LockDatabase(g_Database);
	if (!SQL_FastQuery(g_Database, query)) {
		SQL_GetError(g_Database, error, sizeof(error));
		LogError("Failed to query (map_settings) (error: %s)", error);
	}
	SQL_UnlockDatabase(g_Database);
}

void LoadMapCFG() {
	char query[1024];
	Format(query, sizeof(query), "SELECT Team, LockCPs FROM map_settings WHERE Map = '%s'", g_sCurrentMap);
	g_Database.Query(SQL_OnMapSettingsLoad, query);
}

void SQL_OnMapSettingsLoad(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("Query failed! %s", error);
	}
	else if (results.FetchRow()) {
		g_iForceTeam = results.FetchInt(0);
		g_iLockCPs = results.FetchInt(1);
		if (g_bLateLoad && g_iForceTeam > 1) {
			CheckTeams();
		}
	}
	else {
		CreateMapCFG();
	}
}

void CreateMapCFG() {
	char query[1024];
	Format(query, sizeof(query), "INSERT INTO map_settings VALUES(null, '%s', '1', '1')", g_sCurrentMap);
	g_Database.Query(SQL_CreateMapCFGCallback, query);
	g_iForceTeam = g_iLockCPs = 1;
}

void SQL_CreateMapCFGCallback(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("SQL_CreateMapCFGCallback() - Query failed! %s", error);
	}
}

void SaveMapSettings(int client, char[] arg1, char[] arg2) {
	int lock;
	char query[512];
	
	if (StrEqual(arg1, "team", false)) {
		// Wonder if there is a prettier way of doing this.
		if (StrEqual(arg2, "none", false)) {
			g_iForceTeam = 1;
		}
		else if (StrEqual(arg2, "red", false)) {
			g_iForceTeam = 2;
			CheckTeams();
		}
		else if (StrEqual(arg2, "blue", false)) {
			g_iForceTeam = 3;
			CheckTeams();
		}
		else {
			PrintColoredChat(client, "[%sJA\x01] %sUsage\x01: !mapset team <red|blue|none>", cTheme1, cTheme1);
			return;	
		}
		g_Database.Format(query, sizeof(query), "UPDATE map_settings SET Team = '%i' WHERE Map = '%s'", g_iForceTeam, g_sCurrentMap);
		g_Database.Query(SQL_OnMapSettingsUpdated, query, GetClientUserId(client));
	}
	else if (StrEqual(arg1, "lockcps", false)) {
		if (StrEqual(arg2, "on", false)) {
			lock = 1;
		}
		else if (StrEqual(arg2, "off", false)) {
			lock = 0;
		}
		else {
			PrintColoredChat(client, "[%sJA\x01] %sUsage\x01: !mapset <lockcps> <on|off>", cTheme1, cTheme2);
			return;
		}
		g_Database.Format(query, sizeof(query), "UPDATE map_settings SET LockCPs = '%i' WHERE Map = '%s'", lock, g_sCurrentMap);
		g_Database.Query(SQL_OnMapSettingsUpdated, query, GetClientUserId(client));
	}
}

void SQL_OnMapSettingsUpdated(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("Query failed! %s", error);
	}
	int client;
	if ((client = GetClientOfUserId(data)) > 0) {
		PrintColoredChat(client, "[%sJA\x01] Map settings were%s %ssaved\x01.", cTheme1, cTheme2, (db == null)?"NOT ":"");
	}
}

void LoadPlayerProfile(int client) {
	if (!IsValidClient(client)) {
		return;
	}
	char query[1024];
	if (g_Database != null) {
		Format(query, sizeof(query), "SELECT * FROM player_profiles WHERE SteamID = '%s'", g_sClientSteamID[client]);
		g_Database.Query(SQL_OnLoadPlayerProfile, query, GetClientUserId(client));
	}
	else {
		g_bLoadedPlayerSettings[client] = true;
	}
}

void SQL_OnLoadPlayerProfile(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnLoadPlayerProfile() - Query failed!");
		return;
	}
	int client;
	if ((client = GetClientOfUserId(data) < 1)) {
		return;
	}
	if (results.FetchRow()) {
		g_iSkeysRed[client] = results.FetchInt(2);
		g_iSkeysGreen[client] = results.FetchInt(3);
		g_iSkeysBlue[client] = results.FetchInt(4);

		g_fSkeysXLoc[client] = results.FetchFloat(5);
		g_fSkeysYLoc[client] = results.FetchFloat(6);

		g_bLoadedPlayerSettings[client] = true;
	}
	else if (IsValidClient(client)) {
		// No profile
		CreatePlayerProfile(client);
	}
}

void CreatePlayerProfile(int client) {
	char query[1024];
	Format(
		query
		, sizeof(query)
		, "INSERT INTO player_profiles "
		... "VALUES"
		... "("
			... "null, '%s', '255', '255', '255', '0.54', '0.40'"
		... ")"
		, g_sClientSteamID[client]
	);
	g_Database.Query(SQL_OnCreatePlayerProfile, query, GetClientUserId(client));
}

void SQL_OnCreatePlayerProfile(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnCreatePlayerProfile() - Query failed! %s", error);
		return;
	}
	int client;
	if ((client = GetClientOfUserId(data)) > 0) {
		g_bHardcore[client] = g_bLoadedPlayerSettings[client] = false;
	}
	
}

void GetPlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}

	char sQuery[256];

	g_Database.Format(
		sQuery
		, sizeof(sQuery)
		, "SELECT * "
		... "FROM player_saves "
		... "WHERE steamID = '%s' "
		... "AND playerTeam = '%i' "
		... "AND playerClass = '%i' "
		... "AND playerMap = '%s'"
		, g_sClientSteamID[client]
		, g_iClientTeam[client]
		, view_as<int>(g_TFClientClass[client])
		, g_sCurrentMap
	);
	g_Database.Query(SQL_OnGetPlayerData, sQuery, GetClientUserId(client));
}

void SQL_OnGetPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnGetPlayerData() - Query failed! %s", error);
		return;
	}
	int client;
	if ((client = GetClientOfUserId(data)) < 1) {
		return;
	}
	if (results.FetchRow()) {
		UpdatePlayerData(client);
	}
	else {
		SavePlayerData(client);
	}
}

void SavePlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}

	char sQuery[1024];
	float SavePos1[MAXPLAYERS+1][3];
	float SavePos2[MAXPLAYERS+1][3];

	GetClientAbsOrigin(client, SavePos1[client]);
	GetClientAbsAngles(client, SavePos2[client]);

	g_Database.Format(
		sQuery
		, sizeof(sQuery)
		, "INSERT INTO player_saves "
		... "VALUES("
			... "null, "
			... "'%s', "	// g_sClientSteamID[client]
			... "'%i', "	// view_as<int>(g_TFClientClass[client])
			... "'%i', "	// g_iClientTeam[client]
			... "'%s', "	// g_sCurrentMap
			... "'%f', "	// SavePos1[client][0]
			... "'%f', "	// SavePos1[client][1]
			... "'%f', "	// SavePos1[client][2]
			... "'%f'"		// SavePos2[client][1]
		... ")"
		, g_sClientSteamID[client]
		, view_as<int>(g_TFClientClass[client])
		, g_iClientTeam[client]
		, g_sCurrentMap
		, SavePos1[client][0]
		, SavePos1[client][1]
		, SavePos1[client][2]
		, SavePos2[client][1]
	);
	g_Database.Query(SQL_SaveLocCallback, sQuery, GetClientUserId(client));
}

void UpdatePlayerData(int client) {
	char sQuery[1024];
	float SavePos1[MAXPLAYERS+1][3];
	float SavePos2[MAXPLAYERS+1][3];

	GetClientAbsOrigin(client, SavePos1[client]);
	GetClientAbsAngles(client, SavePos2[client]);

	g_Database.Format(
		sQuery
		, sizeof(sQuery)
		, "UPDATE player_saves "
		... "SET "
			... "origin1 = '%f', "		// SavePos1[client][0]
			... "origin2 = '%f', "		// SavePos1[client][1]
			... "origin3 = '%f', "		// SavePos1[client][2]
			... "angle2 = '%f' "		// SavePos2[client][1]
		... "WHERE steamID = '%s' "		// g_sClientSteamID[client]
		... "AND playerTeam = '%i' "	// g_iClientTeam[client]
		... "AND playerClass = '%i' "	// view_as<int>(g_TFClientClass[client])
		... "AND playerMap = '%s'"		// g_sCurrentMap
		, SavePos1[client][0]
		, SavePos1[client][1]
		, SavePos1[client][2]
		, SavePos2[client][1]
		, g_sClientSteamID[client]
		, g_iClientTeam[client]
		, view_as<int>(g_TFClientClass[client])
		, g_sCurrentMap
	);
	g_Database.Query(SQL_SaveLocCallback, sQuery, GetClientUserId(client));
}

void SQL_SaveLocCallback(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("SaveLocCallback() - %N, Query failed! %s", data, error);
		return;
	}
	int client;
	if ((client = GetClientOfUserId(data)) > 0 && !g_bHideMessage[client]) {
		PrintColoredChat(client, "[%sJA\x01] Location has been%s saved\x01.", cTheme1, cTheme2);
	}
}

void ReloadPlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}
	char sQuery[1024];

	g_Database.Format(
		sQuery
		, sizeof(sQuery)
		, "SELECT origin1, origin2, origin3, angle2 "
		... "FROM player_saves "
		... "WHERE steamID = '%s' "		// g_sClientSteamID[client]
		... "AND playerTeam = '%i' "	// g_iClientTeam[client]
		... "AND playerClass = '%i' "	// view_as<int>(g_TFClientClass[client])
		... "AND playerMap = '%s'"		// g_sCurrentMap
		, g_sClientSteamID[client]
		, g_iClientTeam[client]
		, view_as<int>(g_TFClientClass[client])
		, g_sCurrentMap
	);
	g_Database.Query(SQL_OnReloadPlayerData, sQuery, GetClientUserId(client), DBPrio_High);
}

void SQL_OnReloadPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnreloadPlayerData() - Query failed! %s", error);
		return;
	}
	int client;
	if ((client = GetClientOfUserId(data)) < 1) {
		return;
	}
	if (results.FetchRow()) {
		g_fOrigin[client][0] = results.FetchFloat(0);
		g_fOrigin[client][1] = results.FetchFloat(1);
		g_fOrigin[client][2] = results.FetchFloat(2);

		g_fAngles[client][1] = results.FetchFloat(3);

		g_bUsedReset[client] = false;
	}
}

void LoadPlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}
	char sQuery[1024];
	
	g_Database.Format(
		sQuery
		, sizeof(sQuery)
		, "SELECT origin1, origin2, origin3, angle2 "
		... "FROM player_saves "
		... "WHERE steamID = '%s' "		// g_sClientSteamID[client]
		... "AND playerTeam = '%i' "	// g_iClientTeam[client]
		... "AND playerClass = '%i' "	// view_as<int>(g_TFClientClass[client])
		... "AND playerMap = '%s'"		// g_sCurrentMap
		, g_sClientSteamID[client]
		, g_iClientTeam[client]
		, view_as<int>(g_TFClientClass[client])
		, g_sCurrentMap
	);
	g_Database.Query(SQL_OnLoadPlayerData, sQuery, GetClientUserId(client), DBPrio_High);
}

void SQL_OnLoadPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnLoadPlayerData() - Query failed! %s", error);
		return;
	}
	int client;
	if ((client = GetClientOfUserId(data)) < 1) {
		return;
	}
	if (results.FetchRow()) {
		g_fOrigin[client][0] = results.FetchFloat(0);
		g_fOrigin[client][1] = results.FetchFloat(1);
		g_fOrigin[client][2] = results.FetchFloat(2);

		g_fAngles[client][1] = results.FetchFloat(3);

		if (!g_bHardcore[client] && !IsClientRacing(client)) {
			Teleport(client);
			g_iLastTeleport[client] = RoundFloat(GetEngineTime());
		}
	}
}

void DeletePlayerData(int client) {
	char sQuery[1024];
	
	g_Database.Format(
		sQuery
		, sizeof(sQuery)
		, "DELETE FROM player_saves "
		... "WHERE steamID = '%s' "		// g_sClientSteamID[client]
		... "AND playerMap = '%s'"		// g_sCurrentMap
		... "AND playerTeam = '%i' "	// g_iClientTeam[client]
		... "AND playerClass = '%i' "	// view_as<int>(g_TFClientClass[client])
		, g_sClientSteamID[client]
		, g_sCurrentMap
		, g_iClientTeam[client]
		, view_as<int>(g_TFClientClass[client])
	);
	g_Database.Query(SQL_OnDeletePlayerData, sQuery, GetClientUserId(client));
}

void SQL_OnDeletePlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("OnDeletePlayerData() - Query failed! %s", error);
		return;
	}
	int client;
	if ((client = GetClientOfUserId(data)) > 0) {
		EraseLocs(client);
		g_bBeatTheMap[client] = false;	
	}
}

void SaveKeyColor(int client, char[] red, char[] green, char[] blue) {
	char query[512];
	g_iSkeysRed[client] = StringToInt(red);
	g_iSkeysBlue[client] = StringToInt(blue);
	g_iSkeysGreen[client] = StringToInt(green);

	g_Database.Format(
		query
		, sizeof(query)
		, "UPDATE player_profiles "
		... "SET "
			... "SKEYS_RED_COLOR = %i, "
			... "SKEYS_GREEN_COLOR = %i, "
			... "SKEYS_BLUE_COLOR = %i "
		... "WHERE steamid = '%s'"
		, g_iSkeysRed[client]
		, g_iSkeysGreen[client]
		, g_iSkeysBlue[client]
		, g_sClientSteamID[client]
	);
	g_Database.Query(SQL_OnSetKeys, query, GetClientUserId(client));
}

void SQL_OnSetKeys(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("Query failed! %s", error);
	}
	int client;
	if ((client = GetClientOfUserId(data)) > 0) {
		PrintColoredChat(client, "\x01[%sJA\x01] Your settings were %s%ssaved\x01.", cTheme1, cTheme2, (db == null)?"NOT ":"");
	}
}

void SaveKeyPos(int client, float x, float y) {
	char query[256];
	g_Database.Format(
		query
		, sizeof(query)
		, "UPDATE player_profiles "
		... "SET "
			... "SKEYSX = %0.4f, "
			... "SKEYSY = %0.04f "
		... "WHERE steamid = '%s'"
		, x
		, y
		, g_sClientSteamID[client]
	);
	g_Database.Query(SQL_UpdateSkeys, query, GetClientUserId(client));
}

void SQL_UpdateSkeys(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("Query failed! %s", error);
		return;
	}
	int client;
	if ((client = GetClientOfUserId(data)) > 0) {
		PrintColoredChat(client, "[%sJA\x01] Key position updated", cTheme1);
	}
}