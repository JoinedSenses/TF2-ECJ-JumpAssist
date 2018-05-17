new Handle:g_hDatabase = INVALID_HANDLE;
new Handle:g_hHostname;
new Handle:g_hPluginEnabled;
new Handle:g_hProfileLoaded = INVALID_HANDLE;

new bool:g_bCPTouched[MAXPLAYERS+1][32];
new bool:g_bAmmoRegen[MAXPLAYERS+1];
new bool:g_bHardcore[MAXPLAYERS+1];
new bool:g_bLoadedPlayerSettings[MAXPLAYERS+1];
new bool:g_bBeatTheMap[MAXPLAYERS+1];
new bool:g_bUsedReset[MAXPLAYERS+1];
// new bool:g_bSpeedRun[MAXPLAYERS+1];
new bool:g_bUnkillable[MAXPLAYERS+1];
new bool:g_bLateLoad = false;



new bool:databaseConfigured;

new g_iCPs, g_iForceTeam = 1;
new g_iCPsTouched[MAXPLAYERS+1];
new g_iMapClass = -1;
new g_iLockCPs = 1;

new Float:g_fOrigin[MAXPLAYERS+1][3];
new Float:g_fAngles[MAXPLAYERS+1][3];
new Float:g_fLastSavePos[MAXPLAYERS+1][3];
new Float:g_fLastSaveAngles[MAXPLAYERS+1][3];

new String:g_sCaps[MAXPLAYERS+1];

JA_SendQuery(String:query[], client)
{
	SQL_TQuery(g_hDatabase, SQL_OnSetMy, query, client);
}
JA_CreateForward()
{
	g_hProfileLoaded = CreateGlobalForward("OnProfileLoaded", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
}
ConnectToDatabase()
{
	SQL_TConnect(SQL_OnConnect, "jumpassist");
}
RunDBCheck()
{
	decl String:error[255], String:query[2048], String:ident[64];
	SQL_ReadDriver(g_hDatabase, ident, sizeof ident);
	new bool:isMysql = StrEqual(ident, "mysql", false);
	
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `player_saves` (`RecID` INTEGER NOT NULL PRIMARY KEY %s, `steamID` VARCHAR(32) NOT NULL, `playerClass` INT(1) NOT NULL, `playerTeam` INT(1) NOT NULL, `playerMap` VARCHAR(32) NOT NULL, `save1` INT(25) NOT NULL, `save2` INT(25) NOT NULL, `save3` INT(25) NOT NULL, `save4` INT(25) NOT NULL, `save5` INT(25) NOT NULL, `save6` INT(25) NOT NULL, `Capped` VARCHAR(32))", isMysql?"AUTO_INCREMENT":"AUTOINCREMENT");
	if (!SQL_FastQuery(g_hDatabase, query))
	{
		SQL_GetError(g_hDatabase, error, sizeof(error));
		LogError("Failed to query (player_saves) (error: %s)", error);
		SQL_UnlockDatabase(g_hDatabase);
	}
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `player_profiles` (`ID` integer PRIMARY KEY %s NOT NULL, `SteamID` text NOT NULL, `Ammo` integer NOT NULL DEFAULT 0, `Hardcore` integer NOT NULL DEFAULT 0, `PlayerFOV` integer NOT NULL DEFAULT 90, `SKEYS_RED_COLOR`  INTEGER NOT NULL DEFAULT 255, `SKEYS_GREEN_COLOR`  INTEGER NOT NULL DEFAULT 255, `SKEYS_BLUE_COLOR`  INTEGER NOT NULL DEFAULT 255)", isMysql?"AUTO_INCREMENT":"AUTOINCREMENT");
	if (!SQL_FastQuery(g_hDatabase, query))
	{
		SQL_GetError(g_hDatabase, error, sizeof(error));
		LogError("Failed to query (player_profiles) (error: %s)", error);
		SQL_UnlockDatabase(g_hDatabase);
	}
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `map_settings` (`ID` integer PRIMARY KEY %s NOT NULL, `Map` text NOT NULL, `Team` int NOT NULL, `LockCPs` int NOT NULL, `Class` int NOT NULL)", isMysql?"AUTO_INCREMENT":"AUTOINCREMENT");
	if (!SQL_FastQuery(g_hDatabase, query))
	{
		SQL_GetError(g_hDatabase, error, sizeof(error));
		LogError("Failed to query (map_settings) (error: %s)", error);
		SQL_UnlockDatabase(g_hDatabase);
	}
}
public SQL_OnConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		PrintToServer("[JumpAssist] Invalid database configuration, assuming none");
		PrintToServer(error);
		databaseConfigured = false;
	}
	else
	{
		databaseConfigured = true;
		g_hDatabase = hndl;
		if (g_bLateLoad)
		{
			// Reload player saves for those who are a valid client.
			for (new i=1; i<MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					ReloadPlayerData(i);
				}
			}
		}
		RunDBCheck();
	}
}
public SQL_OnPlayerRanSQL(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;

	if (hndl == INVALID_HANDLE)
	{
		LogError("Query failed! %s", error);
		ReplyToCommand(client, "\x01[\x03JA\x01] Query Failed. %s", error);
		return false;
	}
	PrintToChat(client, "\x01[\x03JA\x01] Query was successful.");
	return true;
}
public SQL_OnMapSettingsUpdated(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (hndl == INVALID_HANDLE)
	{
		LogError("Query failed! %s", error);
		PrintToChat(client, "\x01[\x03JA\x01] %t (%s)", "Mapset_Not_Saved", cLightGreen, cDefault, error);
		return false;
	}
	PrintToChat(client, "\x01[\x03JA\x01] %t", "Mapset_Saved", cLightGreen, cDefault);
	return true;
}
public SQL_OnMapSettingsLoad(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("Query failed! %s", error);
		return false;
	}

	if (SQL_GetRowCount(hndl))
	{
		SQL_FetchRow(hndl);
		g_iForceTeam = SQL_FetchInt(hndl, 0);
		g_iLockCPs = SQL_FetchInt(hndl, 1);
		g_iMapClass = SQL_FetchInt(hndl, 2);
		return true;
	}
	else
	{
		CreateMapCFG();
		return true;
	}
}
public SQL_OnSetMy(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (hndl == INVALID_HANDLE)
	{
		LogError("Query failed! %s", error);
		PrintToChat(client, "\x01[\x03JA\x01] %t", "SetMy_Failed");
		return false;
	}
	PrintToChat(client, "\x01[\x03JA\x01] %t", "SetMy_Success");
	return true;
}
public SQL_OnLoadPlayerProfile(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new String:sMapName[32]; GetCurrentMap(sMapName, sizeof(sMapName));
	new client = data;

	if (hndl == INVALID_HANDLE)
	{
		LogError("Something bad happened");

		return false;

	}
	if (SQL_GetRowCount(hndl))
	{
		//Bookmark
		SQL_FetchRow(hndl);
		new Ammo = SQL_FetchInt(hndl, 2), HC = SQL_FetchInt(hndl, 3), PlayerFOV = SQL_FetchInt(hndl, 4), red = SQL_FetchInt(hndl, 5), green = SQL_FetchInt(hndl, 6), blue = SQL_FetchInt(hndl, 7);
		//LogError("HP = %i, Ammo = %i, HC = %i, PlayerFOV = %i, red = %i, green = %i, blue = %i", HP, Ammo, HC, PlayerFOV, red, green, blue);

		// Skeys hud color.
		//g_iSkeysRed[client] = red; g_iSkeysGreen[client] = green; g_iSkeysBlue[client] = blue;
		new bool:result = true;
		Call_StartForward(g_hProfileLoaded);

		Call_PushCell(client);
		Call_PushCell(red);
		Call_PushCell(green);
		Call_PushCell(blue);

		Call_Finish(_:result);

		// FOV
		if (FindPluginByFile("fov.smx") != INVALID_HANDLE)
		{
			decl String:fovcmd[32];
			Format(fovcmd, sizeof(fovcmd), "sm_fov %i", PlayerFOV);
			if (IsClientConnected(client)) { FakeClientCommand(client, fovcmd); }
		}

		if (Ammo == 1) { g_bAmmoRegen[client] = true; } else { g_bAmmoRegen[client] = false; }
		if (HC == 1) { g_bHardcore[client] = true, g_bAmmoRegen[client] = false; }

		g_bLoadedPlayerSettings[client] = true;
		return true;
	}else {
		// No profile
		if (IsValidClient(client))
		{
			decl String:SteamID[32]; GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
			if(databaseConfigured){
				CreatePlayerProfile(client, SteamID);
			}
		}
		return false;
	}

}
public SQL_OnCreatePlayerProfile(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (hndl == INVALID_HANDLE)
	{
		LogError("OnCreatePlayerProfile() - Query failed! %s", error);
		return false;
	}

	g_bHardcore[client] = false;
	g_bLoadedPlayerSettings[client] = true;
	return true;
}
public SQL_OnDefaultCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("OnDefaultCallback() - Query failed! %s", error);
	}
}
public SQL_OnReloadPlayerData(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;

	if (hndl == INVALID_HANDLE)
	{
		LogError("OnreloadPlayerData() - Query failed! %s", error);
	}
	else if (SQL_GetRowCount(hndl))
	{
		SQL_FetchRow(hndl);
		g_fOrigin[client][0] = SQL_FetchFloat(hndl, 0);
		g_fOrigin[client][1] = SQL_FetchFloat(hndl, 1);
		g_fOrigin[client][2] = SQL_FetchFloat(hndl, 2);

		g_fAngles[client][0] = SQL_FetchFloat(hndl, 3);
		g_fAngles[client][1] = SQL_FetchFloat(hndl, 4);
		g_fAngles[client][2] = SQL_FetchFloat(hndl, 5);

		SQL_FetchString(hndl, 6, g_sCaps[client], sizeof(g_sCaps));

		g_bUsedReset[client] = false;
	}
}
public SQL_OnLoadPlayerData(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (hndl == INVALID_HANDLE)
	{
		LogError("OnLoadPlayerData() - Query failed! %s", error);
	}
	else if (SQL_GetRowCount(hndl))
	{

		SQL_FetchRow(hndl);
		g_fOrigin[client][0] = SQL_FetchFloat(hndl, 0);
		g_fOrigin[client][1] = SQL_FetchFloat(hndl, 1);
		g_fOrigin[client][2] = SQL_FetchFloat(hndl, 2);

		g_fAngles[client][0] = SQL_FetchFloat(hndl, 3);
		g_fAngles[client][1] = SQL_FetchFloat(hndl, 4);
		g_fAngles[client][2] = SQL_FetchFloat(hndl, 5);

		SQL_FetchString(hndl, 6, g_sCaps[client], sizeof(g_sCaps));

		if (!g_bHardcore[client] && !IsClientRacing(client))
		{
			Teleport(client);
			g_iLastTeleport[client] = RoundFloat(GetEngineTime());
		}
	}
}
public SQL_OnDeletePlayerData(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	new sTeam = GetClientTeam(client);
	new class = view_as<int>(TF2_GetPlayerClass(client));

	if (hndl == INVALID_HANDLE)
	{
		LogError("OnDeletePlayerData() - Query failed! %s", error);
	}
	else if (SQL_GetRowCount(hndl))
	{
		decl String:sQuery[256], String:sSteamID[64], String:pMap[32];

		GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
		GetCurrentMap(pMap, sizeof(pMap));

		Format(sQuery, sizeof(sQuery), "DELETE FROM player_saves WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", sSteamID, sTeam, class, pMap);
		SQL_TQuery(g_hDatabase, SQL_OnDefaultCallback, sQuery, client, DBPrio_High);

		g_bBeatTheMap[client] = false;

		//TF2_RespawnPlayer(client);
		//PrintToChat(client, "\x01[\x03JA\x01] %t", "Player_Restarted");
		return;
	}
	else
	{
		g_bBeatTheMap[client] = false;
		EraseLocs(client);
		//TF2_RespawnPlayer(client);
		//PrintToChat(client, "\x01[\x03JA\x01] %t", "Player_Restarted");
		return;
	}
}
public SQL_OnGetPlayerData(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;

	if (hndl == INVALID_HANDLE)
	{
		LogError("OnGetPlayerData() - Query failed! %s", error);
	}
	else if (SQL_GetRowCount(hndl))
	{
		UpdatePlayerData(client);
	}
	else
	{
		SavePlayerData(client);
	}
}
public SQL_OnTeleportAdded(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;

	if (hndl == INVALID_HANDLE)
	{
		LogError("OnTeleportAdded() - Query failed! %s", error);
	}
	else if (SQL_GetRowCount(hndl))
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "AddTele_Failed");
	}
	else
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "AddTele_Success");
	}
}
GetPlayerData(client)
{
	decl String:sQuery[256], String:sSteamID[64], String:pMap[32];

	GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
	GetCurrentMap(pMap, sizeof(pMap));

	new sTeam = GetClientTeam(client);
	new class = view_as<int>(TF2_GetPlayerClass(client));

	Format(sQuery, sizeof(sQuery), "SELECT * FROM `player_saves` WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", sSteamID, sTeam, class, pMap);

	SQL_TQuery(g_hDatabase, SQL_OnGetPlayerData, sQuery, client);
}
SavePlayerData(client)
{
	if(IsFakeClient(client)){return; }
	decl String:sQuery[1024], String:sSteamID[64], String:sMap[64];

	GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
	GetCurrentMap(sMap, sizeof(sMap));

	new sTeam = GetClientTeam(client);
	new class = view_as<int>(TF2_GetPlayerClass(client));
	new Float:SavePos1[MAXPLAYERS+1][3];
	new Float:SavePos2[MAXPLAYERS+1][3];

	GetClientAbsOrigin(client, SavePos1[client]);
	GetClientAbsAngles(client, SavePos2[client]);
	Format(sQuery, sizeof(sQuery), "INSERT INTO `player_saves` VALUES(null, '%s', '%i', '%i', '%s', '%f', '%f', '%f', '%f', '%f', '%f', '%s')", sSteamID, class, sTeam, sMap, SavePos1[client][0], SavePos1[client][1], SavePos1[client][2], SavePos2[client][0], SavePos2[client][1], SavePos2[client][2], g_sCaps[client]);

	SavePos1[client][0] = 0.0;
	SavePos1[client][1] = 0.0;
	SavePos1[client][2] = 0.0;

	SavePos2[client][0] = 0.0;
	SavePos2[client][1] = 0.0;
	SavePos2[client][2] = 0.0;

	SQL_TQuery(g_hDatabase, SQL_OnDefaultCallback, sQuery, client);
}
UpdatePlayerData(client)
{
	decl String:sQuery[1024], String:sSteamID[64], String:sMap[64];

	GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
	GetCurrentMap(sMap, sizeof(sMap));

	new sTeam = GetClientTeam(client);
	new class = view_as<int>(TF2_GetPlayerClass(client));

	new Float:SavePos1[MAXPLAYERS+1][3];
	new Float:SavePos2[MAXPLAYERS+1][3];

	GetClientAbsOrigin(client, SavePos1[client]);
	GetClientAbsAngles(client, SavePos2[client]);

	Format(sQuery, sizeof(sQuery), "UPDATE `player_saves` SET save1 = '%f', save2 = '%f', save3 = '%f', save4 = '%f', save5 = '%f', save6 = '%f', Capped = '%s' where steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", SavePos1[client][0], SavePos1[client][1], SavePos1[client][2], SavePos2[client][0], SavePos2[client][1], SavePos2[client][2],  g_sCaps[client], sSteamID, sTeam, class, sMap);

	SavePos1[client][0] = 0.0;
	SavePos1[client][1] = 0.0;
	SavePos1[client][2] = 0.0;

	SavePos2[client][0] = 0.0;
	SavePos2[client][1] = 0.0;
	SavePos2[client][2] = 0.0;

	SQL_TQuery(g_hDatabase, SQL_OnDefaultCallback, sQuery, client);
}
DeletePlayerData(client)
{
	decl String:sQuery[1024], String:sSteamID[64], String:pMap[32];

	GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
	GetCurrentMap(pMap, sizeof(pMap));

	new sTeam = GetClientTeam(client);
	new class = view_as<int>(TF2_GetPlayerClass(client));

	Format(sQuery, sizeof(sQuery), "DELETE FROM player_saves WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", sSteamID, sTeam, class, pMap);

	SQL_TQuery(g_hDatabase, SQL_OnDeletePlayerData, sQuery, client);
}
ReloadPlayerData(client)
{
	if(IsFakeClient(client)){return; }
	decl String:sQuery[1024], String:sSteamID[64], String:pMap[32];
	GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
	GetCurrentMap(pMap, sizeof(pMap));

	new sTeam = GetClientTeam(client);
	new class = view_as<int>(TF2_GetPlayerClass(client));

	Format(sQuery, sizeof(sQuery), "SELECT save1, save2, save3, save4, save5, save6, capped FROM player_saves WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", sSteamID, sTeam, class, pMap);
	SQL_TQuery(g_hDatabase, SQL_OnReloadPlayerData, sQuery, client, DBPrio_High);
}
LoadPlayerData(client)
{
	if(IsFakeClient(client)){return; }
	decl String:sQuery[1024], String:pMap[32];
	decl String:SteamID[32];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	GetCurrentMap(pMap, sizeof(pMap));

	new sTeam = GetClientTeam(client);
	new class = view_as<int>(TF2_GetPlayerClass(client));


	Format(sQuery, sizeof(sQuery), "SELECT save1, save2, save3, save4, save5, save6, capped FROM player_saves WHERE steamID = '%s' AND playerTeam = '%i' AND playerClass = '%i' AND playerMap = '%s'", SteamID, sTeam, class, pMap);
	SQL_TQuery(g_hDatabase, SQL_OnLoadPlayerData, sQuery, client, DBPrio_High);
}
LoadPlayerProfile(client, String:SteamID[])
{
	if (!IsValidClient(client)) { return; }

	decl String:query[1024];

	Format(query, sizeof(query), "SELECT * FROM `player_profiles` WHERE SteamID = '%s'", SteamID);
	if(databaseConfigured)
	{
		SQL_TQuery(g_hDatabase, SQL_OnLoadPlayerProfile, query, client);
	}else
	{
		g_bAmmoRegen[client] = false;
		g_bHardcore[client] = false;
		g_bLoadedPlayerSettings[client] = true;
	}
}

CreateMapCFG()
{
	decl String:sMapName[64], String:query[1024]; GetCurrentMap(sMapName, sizeof(sMapName));

	Format(query, sizeof(query), "INSERT INTO `map_settings` values(null, '%s', '1', '1', '-1')", sMapName);
	SQL_TQuery(g_hDatabase, SQL_OnDefaultCallback, query);
	g_iForceTeam = 1;
	g_iMapClass = -1;
	g_iLockCPs = 1;

	return true;
}
LoadMapCFG()
{
	decl String:sMapName[64], String:query[1024]; GetCurrentMap(sMapName, sizeof(sMapName));
	Format(query, sizeof(query), "SELECT Team, LockCPs, Class FROM `map_settings` WHERE Map = '%s'", sMapName);
	SQL_TQuery(g_hDatabase, SQL_OnMapSettingsLoad, query);
}
CreatePlayerProfile(client, String:SteamID[])
{
	decl String:query[1024];
	Format(query, sizeof(query), "INSERT INTO `player_profiles` values(null, '%s', '0', '0', '70', '255', '255', '255')", SteamID);

	SQL_TQuery(g_hDatabase, SQL_OnCreatePlayerProfile, query, client);
}
public Action:cmdAddTele(client, args)
{
	if(!databaseConfigured)
	{
		PrintToChat(client, "This feature is not supported without a database configuration");
		return Plugin_Handled;
	}
	if (args < 1)
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "AddTele_Help");
		return Plugin_Handled;
	}
	new String:jump_name[32];
	decl String:sQuery[1024], String:Map[32], Float:Location[3], Float:Angles[3];

	GetClientAbsOrigin(client, Location); GetClientAbsAngles(client, Angles); GetCmdArg(1, jump_name, sizeof(jump_name)); GetCurrentMap(Map, sizeof(Map));

	Format(sQuery, sizeof(sQuery), "INSERT Into `Teleports` values(null, '%s', '%s', '%f', '%f', '%f', '%f', '%f', '%f')", Map, jump_name, Location[0], Location[1], Location[2], Angles[0], Angles[1], Angles[2]);

	SQL_TQuery(g_hDatabase, SQL_OnTeleportAdded, sQuery, client);

	return Plugin_Handled;
}
public Action:cmdSetMy(client, args)
{
	if(!databaseConfigured)
	{
		PrintToChat(client, "This feature is not supported without a database configuration");
		return Plugin_Handled;
	}
	if (!GetConVarBool(g_hPluginEnabled)) { return Plugin_Handled; }
	if (args < 1)
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "SetMy_Help");
		return Plugin_Handled;
	}
	decl String:arg1[MAX_NAME_LENGTH], String:arg2[MAX_NAME_LENGTH], String:SteamID[32];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	GetCmdArg(1, arg1, sizeof(arg1)), GetCmdArg(2, arg2, sizeof(arg2));

	if (StrEqual(arg1[0], "hardcore", false))
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			decl String:query[1024];

			if (IsUsingJumper(client))
			{
				PrintToChat(client, "\x01[\x03JA\x01] %t", "Jumper_Command_Disabled");
				return Plugin_Handled;
			}

			if (StrEqual(arg2[0], "off", false))
			{
				Format(query, sizeof(query), "UPDATE `player_profiles` SET SET Ammo=0, Hardcore=0 WHERE SteamID = '%s'", SteamID);
				SQL_TQuery(g_hDatabase, SQL_OnSetMy, query, client);
				g_bHardcore[client] = false;
				g_bAmmoRegen[client] = false;
			} else if (StrEqual(arg2[0], "on", false))
			{
				Format(query, sizeof(query), "UPDATE `player_profiles` SET Ammo=0, Hardcore=1 WHERE SteamID = '%s'", SteamID);
				SQL_TQuery(g_hDatabase, SQL_OnSetMy, query, client);
				g_bHardcore[client] = true;
				g_bAmmoRegen[client] = false;
			} else {
				PrintToChat(client, "\x01[\x03JA\x01] %t", "SetMy_Hardcore_Help");
				return Plugin_Handled;
			}
		}
	}
	if (StrEqual(arg1[0], "ammo", false))
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			decl String:query[1024];

			if (StrEqual(arg2[0], "off", false))
			{
				Format(query, sizeof(query), "UPDATE `player_profiles` SET Ammo=0, Hardcore=0 WHERE SteamID = '%s'", SteamID);
				SQL_TQuery(g_hDatabase, SQL_OnSetMy, query, client);
				g_bHardcore[client] = false; g_bAmmoRegen[client] = false;
			} else if (StrEqual(arg2[0], "on", false))
			{
				Format(query, sizeof(query), "UPDATE `player_profiles` SET Ammo=1, Hardcore=0 WHERE SteamID = '%s'", SteamID);
				SQL_TQuery(g_hDatabase, SQL_OnSetMy, query, client);
				g_bHardcore[client] = false; g_bAmmoRegen[client] = true;
			} else {
				PrintToChat(client, "\x01[\x03JA\x01] %t", "SetMy_Regen_Help");
				return Plugin_Handled;
			}
		}
	}
	if (StrEqual(arg1[0], "fov", false))
	{
		if (FindPluginByFile("fov.smx") == INVALID_HANDLE)
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "SetMy_FOV_NotInstalled");
			return Plugin_Handled;
		}
		decl String:query[1024], String:fovcmd[12];
		if (StrEqual(arg2[0], "", false))
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "SetMy_FOV_Help");
			return Plugin_Handled;
		}
		if (!IsCharNumeric(arg2[0]))
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Numeric_Invalid");
			return Plugin_Handled;
		}
		Format(query, sizeof(query), "UPDATE `player_profiles` SET PlayerFOV=%i WHERE SteamID = '%s'", StringToInt(arg2), SteamID);
		SQL_TQuery(g_hDatabase, SQL_OnSetMy, query, client);

		Format(fovcmd, sizeof(fovcmd), "sm_fov %i", StringToInt(arg2[0]));
		FakeClientCommand(client, fovcmd);
	}
	return Plugin_Handled;
}
public Action:cmdMapSet(client, args)
{
	if(!databaseConfigured)
	{
		PrintToChat(client, "This feature is not supported without a database configuration");
		return Plugin_Handled;
	}
	if (!GetConVarBool(g_hPluginEnabled)) { return Plugin_Handled; }
	if(args < 2)
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Mapset_Help");
		return Plugin_Handled;
	}
	decl String:arg1[MAX_NAME_LENGTH], String:arg2[MAX_NAME_LENGTH], String:query[512];
	decl String:sMapName[64]; GetCurrentMap(sMapName, sizeof(sMapName));
	new g_iTeam, g_iClass, g_iLock;

	GetCmdArg(1, arg1, sizeof(arg1)),	GetCmdArg(2, arg2, sizeof(arg2));

	if (StrEqual(arg1[0], "team", false))
	{
		if (StrEqual(arg2[0], "red", false) || StrEqual(arg2[0], "blue", false) || StrEqual(arg2[0], "none", false))
		{
			// Wonder if there is a prettier way of doing this.
			if (StrEqual(arg2[0], "red", false))
			{
				g_iTeam = 2;
				g_iForceTeam = 2;
				CheckTeams();
			} else if (StrEqual(arg2[0], "blue", false)) {
				g_iTeam = 3;
				g_iForceTeam = 3;
				CheckTeams();
			} else if (StrEqual(arg2[0], "none", false)) {
				g_iTeam = 1;
				g_iForceTeam = 1;
			}
			Format(query, sizeof(query), "UPDATE `map_settings` SET Team = '%i' WHERE Map = '%s'", g_iTeam, sMapName);
			SQL_TQuery(g_hDatabase, SQL_OnMapSettingsUpdated, query, client);
		} else {
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Mapset_Team_Help");
			return Plugin_Handled;
		}
	}
	if (StrEqual(arg1[0], "class", false))
	{
		g_iClass = GetValidClassNum(arg2[0]);
		if (g_iClass == -1)
		{
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Mapset_Class_Invalid", arg2[0], cLightGreen, cDefault);
			return Plugin_Handled;
		}
		g_iMapClass = g_iClass;
		Format(query, sizeof(query), "UPDATE `map_settings` SET Class = '%i' WHERE Map = '%s'", g_iClass, sMapName);
		SQL_TQuery(g_hDatabase, SQL_OnMapSettingsUpdated, query, client);
	}
	if (StrEqual(arg1[0], "lockcps", false))
	{
		if (StrEqual(arg2[0], "on", false))
		{
			g_iLock = 1;
		} else if (StrEqual(arg2[0], "off", false)) {
			g_iLock = 0;
		}  else {
			PrintToChat(client, "\x01[\x03JA\x01] %t", "Mapset_LockCP_Help");
			return Plugin_Handled;
		}
		Format(query, sizeof(query), "UPDATE `map_settings` SET LockCPs = '%i' WHERE Map = '%s'", g_iLock, sMapName);
		SQL_TQuery(g_hDatabase, SQL_OnMapSettingsUpdated, query, client);
	}
	return Plugin_Handled;
}
