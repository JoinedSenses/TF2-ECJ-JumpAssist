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
	, g_iSkeysBlue[MAXPLAYERS+1];
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

void SkeysOnGameFrame() {
	int iClientToShow, iObserverMode;
	for (int i = 1; i < MaxClients; i++) {
		if (g_bGetClientKeys[i] && IsClientInGame(i)) {
			ClearSyncHud(i, g_hHudDisplayForward);
			ClearSyncHud(i, g_hHudDisplayASD);
			ClearSyncHud(i, g_hHudDisplayDuck);
			ClearSyncHud(i, g_hHudDisplayJump);
			ClearSyncHud(i, g_hHudDisplayM1);
			ClearSyncHud(i, g_hHudDisplayM2);

			if (g_iButtons[i] & IN_SCORE) {
				return;
			}
			iObserverMode = GetEntPropEnt(i, Prop_Send, "m_iObserverMode");
			if (IsClientObserver(i)) {
				iClientToShow = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
			}
			else {
				iClientToShow = i;
			}
			if (!IsValidClient(i) || !IsValidClient(iClientToShow) || iObserverMode == 6) {
				return;
			}
			if (g_iButtons[iClientToShow] & IN_FORWARD) {
				SetHudTextParams(g_iSkeysXLoc[i]+0.06, g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, g_hHudDisplayForward, "W");
			}
			else {
				SetHudTextParams(g_iSkeysXLoc[i]+0.06, g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, g_hHudDisplayForward, "-");
			}
			if (g_iButtons[iClientToShow] & IN_BACK || g_iButtons[iClientToShow] & IN_MOVELEFT || g_iButtons[iClientToShow] & IN_MOVERIGHT) {
				char g_sButtons[64];
				if (g_iButtons[iClientToShow] & IN_BACK) {
					Format(wasBack[iClientToShow], sizeof(wasBack), "S");
				}
				else {
					Format(wasBack[iClientToShow], sizeof(wasBack), "-");
				}
				if (g_iButtons[iClientToShow] & IN_MOVELEFT) {
					Format(wasMoveLeft[iClientToShow], sizeof(wasMoveLeft), "A");
				}
				else {
					Format(wasMoveLeft[iClientToShow], sizeof(wasMoveLeft), "-");
				}
				if (g_iButtons[iClientToShow] & IN_MOVERIGHT) {
					Format(wasMoveRight[iClientToShow], sizeof(wasMoveRight), "D");
				}
				else {
					Format(wasMoveRight[iClientToShow], sizeof(wasMoveRight), "-");
				}
				Format(g_sButtons, sizeof(g_sButtons), "%s %s %s", wasMoveLeft[iClientToShow], wasBack[iClientToShow], wasMoveRight[iClientToShow]);
				SetHudTextParams(g_iSkeysXLoc[i] + 0.04, g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, g_hHudDisplayASD, g_sButtons);
			}
			else {
				char g_sButtons[64];
				Format(g_sButtons, sizeof(g_sButtons), "- - -");
				SetHudTextParams(g_iSkeysXLoc[i]+0.04, g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, g_hHudDisplayASD, g_sButtons);
			}
			if (g_iButtons[iClientToShow] & IN_DUCK) {
				SetHudTextParams(g_iSkeysXLoc[i]+0.1, g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, g_hHudDisplayDuck, "Duck");
			}
			if (g_iButtons[iClientToShow] & IN_JUMP) {
				SetHudTextParams(g_iSkeysXLoc[i] + 0.1, g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, g_hHudDisplayJump, "Jump");
			}
			if (g_iButtons[iClientToShow] & IN_ATTACK) {
				SetHudTextParams(g_iSkeysXLoc[i], g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, g_hHudDisplayM1, "M1");
			}
			if (g_iButtons[iClientToShow] & IN_ATTACK2) {
				SetHudTextParams(g_iSkeysXLoc[i], g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, g_hHudDisplayM2, "M2");
			}
			//.54 x def and .4 y def
		}
	}
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

	//This will throw a server error but its no big deal
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
	if (args != 2) {
		PrintColoredChat(client, "[%sJA\x01] This command requires%s 2\x01 arguments", cTheme1, cTheme2);
		return Plugin_Handled;
	}
	char arg1[16];
	char arg2[16];

	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));

	float xLoc = StringToFloat(arg1);
	float yLoc = StringToFloat(arg2);

	if (xLoc >= 1.0 || yLoc >= 1.0 || xLoc <= 0.0 || yLoc <= 0.0) {
		PrintColoredChat(client, "[%sJA\x01] Both arguments must be between%s 0\x01 and%s 1", cTheme1, cTheme2, cTheme2);
		return Plugin_Handled;
	}
	g_iSkeysXLoc[client] = xLoc;
	g_iSkeysYLoc[client] = yLoc;

	return Plugin_Continue;
}