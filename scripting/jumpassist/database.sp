void ConnectToDatabase() {
	Database.Connect(SQL_OnConnect, "jumpassist");
}

public void SQL_OnConnect(Database db, const char[] error, any data) {
	if (!db || error[0]) {
		LogError("[JumpAssist] Unable to connect to database (%s)", error);
		return;
	}

	g_Database = db;
	
	RunDBCheck();

	if (g_bLateLoad) {
		LoadMapCFG();

		for (int i = 1; i <= MaxClients; ++i) {
			if (IsValidClient(i)) {
				ReloadPlayerData(i);
				LoadPlayerProfile(i);		
			}
		}
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

	FormatEx(
		query,
		sizeof(query),
		"CREATE TABLE IF NOT EXISTS player_saves " ...
		"(" ...
			"RecID INTEGER PRIMARY KEY %s, " ...
			"steamID VARCHAR(32) NOT NULL, " ...
			"playerClass TINYINT UNSIGNED NOT NULL, " ...
			"playerTeam TINYINT UNSIGNED NOT NULL, " ...
			"playerMap VARCHAR(32) NOT NULL, " ...
			"origin1 SMALLINT NOT NULL, " ...
			"origin2 SMALLINT NOT NULL, " ...
			"origin3 SMALLINT NOT NULL, " ...
			"angle2 SMALLINT NOT NULL" ...
		")",
		increment
	);

	SQL_LockDatabase(g_Database);
	if (!SQL_FastQuery(g_Database, query)) {
		SQL_GetError(g_Database, error, sizeof(error));
		LogError("Failed to query (player_saves) (error: %s)", error);
	}
	SQL_UnlockDatabase(g_Database);

	FormatEx(
		query,
		sizeof(query),
		"CREATE TABLE IF NOT EXISTS player_profiles " ...
		"(" ...
			"ID INTEGER PRIMARY KEY %s, " ...
			"SteamID TEXT NOT NULL, " ...
			"SKEYS_RED_COLOR TINYINT UNSIGNED NOT NULL DEFAULT 255, " ...
			"SKEYS_GREEN_COLOR TINYINT UNSIGNED NOT NULL DEFAULT 255, " ...
			"SKEYS_BLUE_COLOR TINYINT UNSIGNED NOT NULL DEFAULT 255, " ...
			"SKEYSX DECIMAL(5,4) NOT NULL DEFAULT 0.54, " ...
			"SKEYSY DECIMAL(5,4) NOT NULL DEFAULT 0.40" ...
		")",
		increment
	);
	
	SQL_LockDatabase(g_Database);
	if (!SQL_FastQuery(g_Database, query)) {
		SQL_GetError(g_Database, error, sizeof(error));
		LogError("Failed to query (player_profiles) (error: %s)", error);
	}
	SQL_UnlockDatabase(g_Database);

	FormatEx(
		query,
		sizeof(query),
		"CREATE TABLE IF NOT EXISTS map_settings " ...
		"(" ...
			"ID INTEGER PRIMARY KEY %s, " ...
			"Map TEXT NOT NULL, " ...
			"Team TINYINT UNSIGNED NOT NULL" ...
		")",
		increment
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
	g_Database.Format(query, sizeof(query), "SELECT Team FROM map_settings WHERE Map = '%s'", g_sCurrentMap);
	g_Database.Query(SQL_OnMapSettingsLoad, query);
}

public void SQL_OnMapSettingsLoad(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("Query failed! %s", error);
		return;
	}
	if (results.FetchRow()) {
		g_iForceTeam = results.FetchInt(0);
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
	g_Database.Format(query, sizeof(query), "INSERT INTO map_settings VALUES(null, '%s', '1')", g_sCurrentMap);
	g_Database.Query(SQL_CreateMapCFGCallback, query);
	g_iForceTeam = 1;
}

public void SQL_CreateMapCFGCallback(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("SQL_CreateMapCFGCallback() - Query failed! %s", error);
	}
}

void SaveMapSettings(int client, char[] arg1, char[] arg2) {
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
			PrintJAMessage(client, cTheme2..."Usage\x01: !mapset team <red|blue|none>");
			return;	
		}

		char query[512];
		g_Database.Format(query, sizeof(query), "UPDATE map_settings SET Team = '%i' WHERE Map = '%s'", g_iForceTeam, g_sCurrentMap);
		g_Database.Query(SQL_OnMapSettingsUpdated, query, client > 0 ? GetClientUserId(client) : 0);
	}
}

void SQL_OnMapSettingsUpdated(Database db, DBResultSet results, const char[] error, any data) {
	bool isError;
	if (!db || !results || error[0]) {
		LogError("Query failed! %s", error);
		isError = true;
	}

	int client;
	if (data > 0 && (client = GetClientOfUserId(data)) > 0) {
		PrintJAMessage(client, "Map settings were"...cTheme2..." %ssaved\x01.", isError ? "NOT ":"");
	}
}

void LoadPlayerProfile(int client) {
	if (!IsValidClient(client)) {
		return;
	}

	char query[80];
	if (g_Database != null) {
		FormatEx(query, sizeof(query), "SELECT * FROM player_profiles WHERE SteamID = '%s'", g_sClientSteamID[client]);
		g_Database.Query(SQL_OnLoadPlayerProfile, query, GetClientUserId(client));
	}
}

public void SQL_OnLoadPlayerProfile(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("OnLoadPlayerProfile() - Query failed!");
		return;
	}

	int client = GetClientOfUserId(data);
	if (client < 1) {
		return;
	}

	if (results.FetchRow()) {
		g_iSKeysColor[client][RED] = results.FetchInt(2);
		g_iSKeysColor[client][GREEN] = results.FetchInt(3);
		g_iSKeysColor[client][BLUE] = results.FetchInt(4);

		g_fSKeysPos[client][XPOS] = results.FetchFloat(5);
		g_fSKeysPos[client][YPOS] = results.FetchFloat(6);
	}
	else if (IsValidClient(client)) {
		// No profile
		CreatePlayerProfile(client);
	}
}

void CreatePlayerProfile(int client) {
	char query[1024];
	g_Database.Format(
		query,
		sizeof(query),
		"INSERT INTO player_profiles " ...
		"VALUES" ...
		"(" ...
			"null, '%s', '255', '255', '255', '0.54', '0.40'" ...
		")",
		g_sClientSteamID[client]
	);
	g_Database.Query(SQL_OnCreatePlayerProfile, query, GetClientUserId(client));
}

void SQL_OnCreatePlayerProfile(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("OnCreatePlayerProfile() - Query failed! %s", error);
		return;
	}

	int client = GetClientOfUserId(data);
	if (client > 0) {
		g_bHardcore[client] = false;
	}
	
}

void GetPlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}

	char query[256];

	g_Database.Format(
		query,
		sizeof(query),
		"SELECT * " ...
		"FROM player_saves " ...
		"WHERE steamID = '%s' " ...
		"AND playerTeam = '%i' " ...
		"AND playerClass = '%i' " ...
		"AND playerMap = '%s'",
		g_sClientSteamID[client],
		g_iClientTeam[client],
		view_as<int>(g_TFClientClass[client]),
		g_sCurrentMap
	);
	g_Database.Query(SQL_OnGetPlayerData, query, GetClientUserId(client));
}

void SQL_OnGetPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("OnGetPlayerData() - Query failed! %s", error);
		return;
	}

	int client = GetClientOfUserId(data);
	if (client < 1) {
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

	char query[1024];

	g_Database.Format(
		query,
		sizeof(query),
		"INSERT INTO player_saves " ...
		"VALUES" ...
		"(" ...
			"null, " ...
			"'%s', " ... // g_sClientSteamID[client]
			"'%i', " ... // view_as<int>(g_TFClientClass[client])
			"'%i', " ... // g_iClientTeam[client]
			"'%s', " ... // g_sCurrentMap
			"'%f', " ... // SavePos1[client][0]
			"'%f', " ... // SavePos1[client][1]
			"'%f', " ... // SavePos1[client][2]
			"'%f'"   ... // SavePos2[client][1]
		")",
		g_sClientSteamID[client],
		view_as<int>(g_TFClientClass[client]),
		g_iClientTeam[client],
		g_sCurrentMap,
		g_fOrigin[client][0],
		g_fOrigin[client][1],
		float(RoundToCeil(g_fOrigin[client][2])),
		g_fAngles[client][1]
	);
	g_Database.Query(SQL_SaveLocCallback, query, GetClientUserId(client));
}

void UpdatePlayerData(int client) {
	char query[1024];

	g_Database.Format(
		query,
		sizeof(query),
		"UPDATE player_saves " ...
		"SET " ...
			"origin1 = '%f', " ...    // SavePos1[client][0]
			"origin2 = '%f', " ...    // SavePos1[client][1]
			"origin3 = '%f', " ...    // SavePos1[client][2]
			"angle2 = '%f' " ...      // SavePos2[client][1]
		"WHERE steamID = '%s' " ...   // g_sClientSteamID[client]
		"AND playerTeam = '%i' " ...  // g_iClientTeam[client]
		"AND playerClass = '%i' " ... // view_as<int>(g_TFClientClass[client])
		"AND playerMap = '%s'",       // g_sCurrentMap
		g_fOrigin[client][0],
		g_fOrigin[client][1],
		float(RoundToCeil(g_fOrigin[client][2])),
		g_fAngles[client][1],
		g_sClientSteamID[client],
		g_iClientTeam[client],
		g_TFClientClass[client],
		g_sCurrentMap
	);
	g_Database.Query(SQL_SaveLocCallback, query, GetClientUserId(client));
}

void SQL_SaveLocCallback(Database db, DBResultSet results, const char[] error, any data) {
	bool isError;
	if (!db || !results || error[0]) {
		LogError("SaveLocCallback() - %N, Query failed! %s", data, error);
		isError = true;
	}

	int client = GetClientOfUserId(data);
	if (client > 0 && !g_bHideMessage[client]) {
		PrintJAMessage(client, "Location"...cTheme2..." %s\x01.", isError ? "failed to save" : "saved");
	}
}

void ReloadPlayerData(int client) {
	if (IsFakeClient(client)) {
		return;
	}

	char query[1024];

	g_Database.Format(
		query,
		sizeof(query),
		"SELECT origin1, origin2, origin3, angle2 " ...
		"FROM player_saves " ...
		"WHERE steamID = '%s' " ...   // g_sClientSteamID[client]
		"AND playerTeam = '%i' " ...  // g_iClientTeam[client]
		"AND playerClass = '%i' " ... // view_as<int>(g_TFClientClass[client])
		"AND playerMap = '%s'",       // g_sCurrentMap
		g_sClientSteamID[client],
		g_iClientTeam[client],
		view_as<int>(g_TFClientClass[client]),
		g_sCurrentMap
	);
	g_Database.Query(SQL_OnReloadPlayerData, query, GetClientUserId(client), DBPrio_High);
}

void SQL_OnReloadPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("OnreloadPlayerData() - Query failed! %s", error);
		return;
	}

	int client = GetClientOfUserId(data);
	if (client < 1) {
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

	char query[1024];
	
	g_Database.Format(
		query,
		sizeof(query),
		"SELECT origin1, origin2, origin3, angle2 " ...
		"FROM player_saves " ...
		"WHERE steamID = '%s' " ...   // g_sClientSteamID[client]
		"AND playerTeam = '%i' " ...  // g_iClientTeam[client]
		"AND playerClass = '%i' " ... // view_as<int>(g_TFClientClass[client])
		"AND playerMap = '%s'",       // g_sCurrentMap
		g_sClientSteamID[client],
		g_iClientTeam[client],
		view_as<int>(g_TFClientClass[client]),
		g_sCurrentMap
	);
	g_Database.Query(SQL_OnLoadPlayerData, query, GetClientUserId(client), DBPrio_High);
}

void SQL_OnLoadPlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("OnLoadPlayerData() - Query failed! %s", error);
		return;
	}

	int client = GetClientOfUserId(data);
	if ((client) < 1) {
		return;
	}

	if (results.FetchRow()) {
		g_fOrigin[client][0] = results.FetchFloat(0);
		g_fOrigin[client][1] = results.FetchFloat(1);
		g_fOrigin[client][2] = results.FetchFloat(2);

		g_fAngles[client][1] = results.FetchFloat(3);

		if (!IsClientHardcore(client) && !IsClientRacing(client) && !IsTeleportPaused(client) && !IsClientForcedSpec(client)) {
			Teleport(client);
			g_iLastTeleport[client] = RoundFloat(GetEngineTime());
		}
	}
}

void DeletePlayerData(int client) {
	char query[1024];
	
	g_Database.Format(
		query,
		sizeof(query),
		"DELETE FROM player_saves " ...
		"WHERE steamID = '%s' " ...   // g_sClientSteamID[client]
		"AND playerMap = '%s'" ...    // g_sCurrentMap
		"AND playerTeam = '%i' " ...  // g_iClientTeam[client]
		"AND playerClass = '%i' ",    // view_as<int>(g_TFClientClass[client])
		g_sClientSteamID[client],
		g_sCurrentMap,
		g_iClientTeam[client],
		view_as<int>(g_TFClientClass[client])
	);
	g_Database.Query(SQL_OnDeletePlayerData, query, GetClientUserId(client));
}

void SQL_OnDeletePlayerData(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("OnDeletePlayerData() - Query failed! %s", error);
		return;
	}

	int client = GetClientOfUserId(data);
	if (client > 0) {
		EraseLocs(client);
		g_bBeatTheMap[client] = false;	
	}
}

void SaveKeyColor(int client, char[] red, char[] green, char[] blue) {
	char query[512];
	g_iSKeysColor[client][RED] = Clamp(StringToInt(red), 0, 255);
	g_iSKeysColor[client][GREEN] = StringToInt(blue);
	g_iSKeysColor[client][BLUE] = StringToInt(green);

	g_Database.Format(
		query,
		sizeof(query),
		"UPDATE player_profiles " ...
		"SET " ...
			"SKEYS_RED_COLOR = %i, " ...
			"SKEYS_GREEN_COLOR = %i, " ...
			"SKEYS_BLUE_COLOR = %i " ...
		"WHERE steamid = '%s'",
		g_iSKeysColor[client][RED],
		g_iSKeysColor[client][GREEN],
		g_iSKeysColor[client][BLUE],
		g_sClientSteamID[client]
	);
	g_Database.Query(SQL_OnSetKeys, query, GetClientUserId(client));
}

void SQL_OnSetKeys(Database db, DBResultSet results, const char[] error, any data) {
	bool isError;
	if (!db || !results || error[0]) {
		LogError("Query failed! %s", error);
		isError = true;
	}

	int client = GetClientOfUserId(data);
	if (client > 0) {
		PrintJAMessage(client, "Your settings were "...cTheme2..."%ssaved\x01.", isError ? "NOT " : "");
	}
}

void SaveKeyPos(int client, float x, float y) {
	char query[256];
	g_Database.Format(
		query,
		sizeof(query),
		"UPDATE player_profiles " ...
		"SET " ...
			"SKEYSX = %0.4f, " ...
			"SKEYSY = %0.04f " ...
		"WHERE steamid = '%s'",
		x,
		y,
		g_sClientSteamID[client]
	);
	g_Database.Query(SQL_UpdateSkeys, query, GetClientUserId(client));
}

public void SQL_UpdateSkeys(Database db, DBResultSet results, const char[] error, any data) {
	if (!db || !results || error[0]) {
		LogError("Query failed! %s", error);
		return;
	}

	int client = GetClientOfUserId(data);
	if (client > 0) {
		PrintJAMessage(client, "Key position updated");
	}
}