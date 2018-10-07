Handle
	  g_hHudDisplayForward
	, g_hHudDisplayASD
	, g_hHudDisplayDuck
	, g_hHudDisplayJump
	, g_hHudDisplayM1
	, g_hHudDisplayM2;
bool
	  g_bSKeysEnabled[MAXPLAYERS+1];
int
	  g_iButtons[MAXPLAYERS+1]
	, g_iSkeysRed[MAXPLAYERS+1]
	, g_iSkeysGreen[MAXPLAYERS+1]
	, g_iSkeysBlue[MAXPLAYERS+1]
	, g_iSkeysMode[MAXPLAYERS+1];
float
	  g_fSkeysXLoc[MAXPLAYERS+1]
	, g_fSkeysYLoc[MAXPLAYERS+1];

void SetAllSkeysDefaults() {
	for(int i = 1; i <= MaxClients; i++) {
		SetSkeysDefaults(i);
	}
}

void SetSkeysDefaults(int client) {
	g_fSkeysXLoc[client] = XPOSDEFAULT;
	g_fSkeysYLoc[client] = YPOSDEFAULT;
}

public Action cmdGetClientKeys(int client, int args) {
	g_bSKeysEnabled[client] = !g_bSKeysEnabled[client];
	PrintColoredChat(client, "[%sJA\x01] %t", cTheme1, g_bSKeysEnabled[client] ? "Showkeys_On" : "Showkeys_Off", cTheme2, cDefault);
	return Plugin_Handled;
}

int IsStringNumeric(const char[] MyString) {
	int n = 0;
	while (MyString[n] != '\0') {
		if (!IsCharNumeric(MyString[n])) {
			return false;
		}
		n++;
	}
	return true;
}

public Action cmdChangeSkeysColor(int client, int args) {
	char red[4];
	char blue[4];
	char green[4];
	char query[512];
	
	if (args < 1) {
		PrintColoredChat(client, "[%sJA\x01] %t", cTheme1, "SkeysColor_Help");
		return Plugin_Handled;
	}
	GetCmdArg(1, red, sizeof(red));
	GetCmdArg(2, green, sizeof(green));
	GetCmdArg(3, blue, sizeof(blue));

	if (!IsStringNumeric(red) || !IsStringNumeric(blue) || !IsStringNumeric(green)) {
		PrintColoredChat(client, "[%sJA\x01] %t", cTheme1, "Numeric_Invalid");
		return Plugin_Handled;
	}
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
	g_Database.Query(SQL_OnSetKeys, query, client);

	return Plugin_Handled;
}

public Action cmdChangeSkeysLoc(int client, int args) {
	if (IsClientObserver(client)) {
		PrintColoredChat(client, "[%sJA\x01] Cannot use this feature while in spectate", cTheme1);
		return Plugin_Handled;
	}
	g_bSKeysEnabled[client] = true;
	switch (g_iSkeysMode[client]) {
		case EDIT: {
			g_iSkeysMode[client] = DISPLAY;
			SetEntityFlags(client, GetEntityFlags(client) & ~(FL_ATCONTROLS | FL_FROZEN));
		}
		case DISPLAY: {
			g_iSkeysMode[client] = EDIT;
			SetEntityFlags(client, GetEntityFlags(client) | FL_ATCONTROLS | FL_FROZEN);
		}
	}
	return Plugin_Handled;
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
	g_Database.Query(SQL_UpdateSkeys, query, client);
}

void SQL_UpdateSkeys(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null) {
		LogError("Query failed! %s", error);
		PrintColoredChat(data, "[%sJA\x01] Key position not saved (%s)", cTheme1, error);
	}
	else {
		PrintColoredChat(data, "[%sJA\x01] Key position updated", cTheme1);
	}
}