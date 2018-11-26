#define XPOSDEFAULT 0.54
#define YPOSDEFAULT 0.4

enum {
	DISPLAY = 0,
	EDIT
}

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

/* ======================================================================
   ------------------------------- Commands
*/

public Action cmdGetClientKeys(int client, int args) {
	g_bSKeysEnabled[client] = !g_bSKeysEnabled[client];
	PrintColoredChat(client, "[%sJA\x01] HUD keys are%s %s\x01.", cTheme1, cTheme2, g_bSKeysEnabled[client]?"enabled":"disabled");
	return Plugin_Handled;
}

public Action cmdChangeSkeysColor(int client, int args) {
	if (client == 0) {
		return Plugin_Handled;
	}
	char red[4];
	char blue[4];
	char green[4];
	
	if (args < 1) {
		PrintColoredChat(client, "[%sJA\x01]%s Usage\x01: sm_skeys_color <R> <G> <B>", cTheme1, cTheme2);
		return Plugin_Handled;
	}
	GetCmdArg(1, red, sizeof(red));
	GetCmdArg(2, green, sizeof(green));
	GetCmdArg(3, blue, sizeof(blue));

	if (!IsStringNumeric(red) || !IsStringNumeric(blue) || !IsStringNumeric(green)) {
		PrintColoredChat(client, "[%sJA\x01] Invalid numeric value", cTheme1);
		return Plugin_Handled;
	}

	SaveKeyColor(client, red, green, blue);
	return Plugin_Handled;
}

public Action cmdChangeSkeysLoc(int client, int args) {
	if (client == 0) {
		return Plugin_Handled;
	}
	if (IsClientObserver(client)) {
		PrintColoredChat(client, "[%sJA\x01] Cannot use this feature while in spectate", cTheme1);
		return Plugin_Handled;
	}
	g_bSKeysEnabled[client] = true;
	switch (g_iSkeysMode[client]) {
		case EDIT: {
			g_iSkeysMode[client] = DISPLAY;
			SetEntityFlags(client, GetEntityFlags(client)&~(FL_ATCONTROLS|FL_FROZEN));
		}
		case DISPLAY: {
			g_iSkeysMode[client] = EDIT;
			SetEntityFlags(client, GetEntityFlags(client)|FL_ATCONTROLS|FL_FROZEN);
			PrintColoredChat(
				  client,
				"[%sSKEYS\x01] Update position using%s mouse movement\x01.\n"
			... "[%sSKEYS\x01] Save with%s mouse1\x01.\n"
			... "[%sSKEYS\x01] Reset with%s jump\x01."
				, cTheme1, cTheme2
				, cTheme1, cTheme2
				, cTheme1, cTheme2
			);
		}
	}
	return Plugin_Handled;
}

/* ======================================================================
   ---------------------------- Internal Functions 
*/

void SetAllSkeysDefaults() {
	for (int i = 1; i <= MaxClients; i++) {
		SetSkeysDefaults(i);
	}
}

void SetSkeysDefaults(int client) {
	g_fSkeysXLoc[client] = XPOSDEFAULT;
	g_fSkeysYLoc[client] = YPOSDEFAULT;
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