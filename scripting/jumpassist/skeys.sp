Handle
	  g_hHudDisplayForward
	, g_hHudDisplayASD
	, g_hHudDisplayDuck
	, g_hHudDisplayJump
	, g_hHudDisplayM1
	, g_hHudDisplayM2;
bool
	  g_bGetClientKeys[MAXPLAYERS+1];
int
	  g_iButtons[MAXPLAYERS+1]
	, g_iSkeysRed[MAXPLAYERS+1]
	, g_iSkeysGreen[MAXPLAYERS+1]
	, g_iSkeysBlue[MAXPLAYERS+1]
	, g_iSkeysMode[MAXPLAYERS+1];
float
	  g_iSkeysXLoc[MAXPLAYERS+1]
	, g_iSkeysYLoc[MAXPLAYERS+1]
	, defaultXLoc = 0.54
	, defaultYLoc = 0.40;
char
	  wasBack[MAXPLAYERS+1]
	, wasMoveRight[MAXPLAYERS+1]
	, wasMoveLeft[MAXPLAYERS+1];

void SetAllSkeysDefaults() {
	for(int i = 0; i < MAXPLAYERS+1; i++) {
		SetSkeysDefaults(i);
	}
}

void SetSkeysDefaults(int client) {
	g_iSkeysXLoc[client] = defaultXLoc;
	g_iSkeysYLoc[client] = defaultYLoc;
}

public Action cmdGetClientKeys(int client, int args) {
	g_bGetClientKeys[client] = !g_bGetClientKeys[client];
	PrintColoredChat(client, "[\x03JA\x01] %t", g_bGetClientKeys[client] ? "Showkeys_On" : "Showkeys_Off", cTheme2, cDefault);
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
		PrintColoredChat(client, "[\x03JA\x01] %t", "SkeysColor_Help");
		return Plugin_Handled;
	}
	GetCmdArg(1, red, sizeof(red));
	GetCmdArg(2, green, sizeof(green));
	GetCmdArg(3, blue, sizeof(blue));

	if (!IsStringNumeric(red) || !IsStringNumeric(blue) || !IsStringNumeric(green)) {
		PrintColoredChat(client, "[\x03JA\x01] %t", "Numeric_Invalid");
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
	JA_SendQuery(query, client);

	return Plugin_Handled;
}

public Action cmdChangeSkeysLoc(int client, int args) {
	g_bGetClientKeys[client] = true;
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