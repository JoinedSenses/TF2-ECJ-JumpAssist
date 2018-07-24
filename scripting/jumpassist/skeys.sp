Handle
	HudDisplayForward
	, HudDisplayASD
	, HudDisplayDuck
	, HudDisplayJump
	, HudDisplayM1
	, HudDisplayM2;
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
	, defaultXLoc = 0.54, defaultYLoc = 0.40;
char
	wasBack[MAXPLAYERS+1]
	, wasMoveRight[MAXPLAYERS+1]
	, wasMoveLeft[MAXPLAYERS+1];

void SetAllSkeysDefaults() {
	for(int i = 0; i < MAXPLAYERS+1; i++)
		SetSkeysDefaults(i);
}

void SetSkeysDefaults(int client) {
	g_iSkeysXLoc[client] = defaultXLoc;
	g_iSkeysYLoc[client] = defaultYLoc;
}

void SkeysOnGameFrame() {
	int iClientToShow, iObserverMode;
	for (int i = 1; i < MaxClients; i++) {
		if (g_bGetClientKeys[i] && IsClientInGame(i)) {
			ClearSyncHud(i, HudDisplayForward);
			ClearSyncHud(i, HudDisplayASD);
			ClearSyncHud(i, HudDisplayDuck);
			ClearSyncHud(i, HudDisplayJump);
			ClearSyncHud(i, HudDisplayM1);
			ClearSyncHud(i, HudDisplayM2);

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
				ShowSyncHudText(i, HudDisplayForward, "W");
			}
			else {
				SetHudTextParams(g_iSkeysXLoc[i]+0.06, g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayForward, "-");
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
				ShowSyncHudText(i, HudDisplayASD, g_sButtons);
			}
			else {
				char g_sButtons[64];
				Format(g_sButtons, sizeof(g_sButtons), "- - -");
				SetHudTextParams(g_iSkeysXLoc[i]+0.04, g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayASD, g_sButtons);
			}
			if (g_iButtons[iClientToShow] & IN_DUCK) {
				SetHudTextParams(g_iSkeysXLoc[i]+0.1, g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayDuck, "Duck");
			}
			if (g_iButtons[iClientToShow] & IN_JUMP) {
				SetHudTextParams(g_iSkeysXLoc[i] + 0.1, g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayJump, "Jump");
			}
			if (g_iButtons[iClientToShow] & IN_ATTACK) {
				SetHudTextParams(g_iSkeysXLoc[i], g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayM1, "M1");
			}
			if (g_iButtons[iClientToShow] & IN_ATTACK2) {
				SetHudTextParams(g_iSkeysXLoc[i], g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayM2, "M2");
			}
			//.54 x def and .4 y def
		}
	}
}

public Action cmdGetClientKeys(int client, int args) {
	g_bGetClientKeys[client] = !g_bGetClientKeys[client];
	PrintToChat(client, "\x01[\x03JA\x01] %t", g_bGetClientKeys[client] ? "Showkeys_On" : "Showkeys_Off");
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
	char
		red[4]
		, blue[4]
		, green[4]
		, query[512];
	
	if (args < 1) {
		PrintToChat(client, "\x01[\x03JA\x01] %t", "SkeysColor_Help");
		return Plugin_Handled;
	}
	GetCmdArg(1, red, sizeof(red));
	GetCmdArg(2, green, sizeof(green));
	GetCmdArg(3, blue, sizeof(blue));

	if (!IsStringNumeric(red) || !IsStringNumeric(blue) || !IsStringNumeric(green)) {
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Numeric_Invalid");
		return Plugin_Handled;
	}
	g_iSkeysRed[client] = StringToInt(red);
	g_iSkeysBlue[client] = StringToInt(blue);
	g_iSkeysGreen[client] = StringToInt(green);

	//This will throw a server error but its no big deal
	g_Database.Format(query, sizeof(query), "UPDATE `player_profiles` SET SKEYS_RED_COLOR=%i, SKEYS_GREEN_COLOR=%i, SKEYS_BLUE_COLOR=%i WHERE steamid = '%s'", g_iSkeysRed[client], g_iSkeysGreen[client], g_iSkeysBlue[client], clientSteamID[client]);
	JA_SendQuery(query, client);

	return Plugin_Handled;
}

public Action cmdChangeSkeysLoc(int client, int args) {
	if (args != 2) {
		PrintToChat(client, "\x01[\x03JA\x01] This command requires 2 arguments");
		return Plugin_Handled;
	}
	char
		arg1[16]
		, arg2[16];
	float
		xLoc
		, yLoc;

	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));

	xLoc = StringToFloat(arg1);
	yLoc = StringToFloat(arg2);

	if (xLoc >= 1.0 || yLoc >= 1.0 || xLoc <= 0.0 || yLoc <= 0.0) {
		PrintToChat(client, "\x01[\x03JA\x01] Both arguments must be between 0 and 1");
		return Plugin_Handled;
	}
	g_iSkeysXLoc[client] = xLoc;
	g_iSkeysYLoc[client] = yLoc;
	
	return Plugin_Continue;
}
