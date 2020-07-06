int g_iSpecTarget[MAXPLAYERS+1];
bool g_bFSpec[MAXPLAYERS+1];
bool g_bFSpecRestoring[MAXPLAYERS+1];

int g_iFSpecTeam[MAXPLAYERS+1];
TFClassType g_TFFSpecClass[MAXPLAYERS+1];
float g_vFSpecOrigin[MAXPLAYERS+1][3];
float g_vFSpecAngles[MAXPLAYERS+1][3];


/* ======================================================================
   ------------------------------- Commands
*/

public Action cmdSpec(int client, int args) {
	if (!client) {
		ReplyToCommand(client, "Must be in-game to use this command");
		return Plugin_Handled;
	}

	if (GetRaceStatus(client) != STATUS_NONE) {
		PrintJAMessage(client, "Unable to use this feature while racing.");
		return Plugin_Handled;	
	}

	if (args < 1) {
		menuSpec(client);
		return Plugin_Handled;
	}

	char targetName[MAX_NAME_LENGTH];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target;
	if ((target = FindTarget(client, targetName, false, false)) < 1) {
		return Plugin_Handled;
	}

	if (target == client) {
		PrintJAMessage(client, "Unable to spectate yourself. That would be pretty weird.");
		return Plugin_Handled;
	}
	
	bool isTargetInSpec;
	if (IsClientObserver(target)) {
		target = GetEntPropEnt(target, Prop_Send, "m_hObserverTarget");
		if (target < 1) {
			PrintJAMessage(client, "Target is in spec, but not spectating anyone.");
			return Plugin_Handled;
		}

		if (target == client) {
			PrintJAMessage(client, "Target is spectating you. Unable to spectate");
			return Plugin_Handled;
		}

		PrintJAMessage(client, "Target is in spec. Now spectating their target");
		isTargetInSpec = true;
	}

	if (GetClientTeam(client) > 1) {
		ChangeClientTeam(client, 1);
		g_iClientTeam[client] = TEAM_SPECTATOR;
	}

	if (!isTargetInSpec) {
		PrintJAMessage(client, "Spectating"...cTheme2..." %N", target);
	}

	FakeClientCommand(client, "spec_player #%i", GetClientUserId(target));
	FakeClientCommand(client, "spec_mode 1");
	return Plugin_Handled;
}

public Action cmdSpecLock(int client, int args) {
	if (!client) {
		ReplyToCommand(client, "Must be in-game to use this command");
		return Plugin_Handled;
	}

	if (GetRaceStatus(client) != STATUS_NONE) {
		PrintJAMessage(client, "Unable to use this feature while racing.");
		return Plugin_Handled;	
	}

	if (args < 1) {
		menuSpec(client, true);
		return Plugin_Handled;
	}

	char targetName[MAX_NAME_LENGTH];
	GetCmdArg(1, targetName, sizeof(targetName));

	if (StrEqual(targetName, "off", false) || StrEqual(targetName, "0", false)) {
		g_iSpecTarget[client] = 0;
		PrintJAMessage(client, "Spec lock disabled");
		return Plugin_Handled;
	}

	int target = FindTarget(client, targetName, false, false);
	if (target < 1) {
		return Plugin_Handled;
	}

	if (IsClientObserver(target)) {
		PrintJAMessage(client, "Target is in spec, will resume with spec when they spawn.");
		PrintJAMessage(client, "To disable, type"...cTheme2..." /speclock 0");
	}

	if (GetClientTeam(client) > 1) {
		ChangeClientTeam(client, 1);
		g_iClientTeam[client] = TEAM_SPECTATOR;
	}

	FakeClientCommand(client, "spec_player #%i", GetClientUserId(target));
	FakeClientCommand(client, "spec_mode 1");
	PrintJAMessage(client, "Spectating"...cTheme2..." %N", target);

	g_iSpecTarget[client] = target;
	return Plugin_Handled;
}

// ---------------- Admin Command

public Action cmdForceSpec(int client, int args) {
	if (args < 1) {
		PrintJAMessage(client, "Usage: sm_fspec <target> <OPTIONAL:targetToSpec>");
		return Plugin_Handled;
	}

	char targetName[MAX_NAME_LENGTH];
	GetCmdArg(1, targetName, sizeof(targetName));

	int target = FindTarget(client, targetName, false);
	if (target < 1) {
		return Plugin_Handled;
	}

	if (GetRaceStatus(target) != STATUS_NONE) {
		PrintJAMessage(client, "Unable to target this player while they racing.");
		return Plugin_Handled;	
	}

	if (IsClientFSpecRestoring(target)) {
		PrintJAMessage(client, "Unable to target this player while they're restoring from fspec.");
		return Plugin_Handled;		
	}

	if (IsClientForcedSpec(target)) {
		RestoreFSpecLocation(target);
		PrintJAMessage(client, "%N's status has been restored.", target);
		return Plugin_Handled;
	}

	char targetToSpecName[MAX_NAME_LENGTH];
	int targetToSpec;
	if (args == 2) {
		GetCmdArg(2, targetToSpecName, sizeof(targetToSpecName));
		if ((targetToSpec = FindTarget(client, targetToSpecName, false, false)) < 1) {
			return Plugin_Handled;
		}

		if (IsClientObserver(targetToSpec)) {
			PrintJAMessage(client, "Target"...cTheme2..." %N\x01 must be alive.", targetToSpec);
			return Plugin_Handled;
		}

		FormatEx(targetToSpecName, sizeof(targetToSpecName), "%N", targetToSpec);
	}
	else {
		FormatEx(targetToSpecName, sizeof(targetToSpecName), "you");
		targetToSpec = client;
	}

	SaveFSpecLocation(target);

	if (GetClientTeam(target) > 1) {
		ChangeClientTeam(target, 1);
		g_iClientTeam[client] = TEAM_SPECTATOR;
	}

	FakeClientCommand(target, "spec_player #%i", GetClientUserId(targetToSpec));
	FakeClientCommand(target, "spec_mode 1");

	PrintJAMessage(client, "Forced"...cTheme2..." %N\x01 to spectate"...cTheme2..." %s", target, targetToSpecName);
	g_bFSpec[target] = true;
	return Plugin_Handled;
}

/* ======================================================================
   ------------------------------- Menus
*/

void menuSpec(int client, bool lock = false) {
	Menu menu = new Menu(lock ? menuHandler_SpecLock : menuHandler_Spec, MENU_ACTIONS_DEFAULT|MenuAction_DrawItem);
	menu.SetTitle("Spectate Menu");

	if (GetClientTeam(client) > 1 && !lock) {
		menu.AddItem("", "QUICK SPEC");
	}

	if (lock && g_iSpecTarget[client] > 0) {
		menu.AddItem("", "DISABLE LOCK");
	}
	
	int id;
	char userid[6];
	char clientName[MAX_NAME_LENGTH];
	for (int i = 1; i <= MaxClients; ++i) {
		if ((id = isValidClient(i)) > 0 && client != i) {
			FormatEx(userid, sizeof(userid), "%i", id);
			FormatEx(clientName, sizeof(clientName), "%N", i);
			menu.AddItem(userid, clientName);
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

int menuHandler_Spec(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			char targetid[6];
			menu.GetItem(param2, targetid, sizeof(targetid));

			int userid = StringToInt(targetid);
			if (userid == 0) {
				ChangeClientTeam(param1, 1);
				PrintJAMessage(param1, "Sent to spec");
				delete menu;
				return 0;
			}

			if (GetClientOfUserId(userid) == 0) {
				PrintJAMessage(param1, "Player no longer in game");
				menuSpec(param1);
				delete menu;
				return 0;
			}

			if (GetClientTeam(param1) > 1) {
				ChangeClientTeam(param1, 1);
				g_iClientTeam[param1] = TEAM_SPECTATOR;
			}

			FakeClientCommand(param1, "spec_player #%i", userid);
			FakeClientCommand(param1, "spec_mode 1");

			menu.DisplayAt(param1, menu.Selection, MENU_TIME_FOREVER);
		}
		case MenuAction_DrawItem: {
			char targetid[6];
			menu.GetItem(param2, targetid, sizeof(targetid));
			int target = GetClientOfUserId(StringToInt(targetid));
			if (IsClientObserver(param1) && GetEntPropEnt(param1, Prop_Send, "m_hObserverTarget") == target) {
				return ITEMDRAW_DISABLED;
			}
		}
		case MenuAction_End: {
			if (param2 != MenuEnd_Selected) {
				delete menu;
			}
		}
	}
	return 0;
}

int menuHandler_SpecLock(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			char targetid[6];
			menu.GetItem(param2, targetid, sizeof(targetid));

			int userid = StringToInt(targetid);
			if (userid == 0) {
				g_iSpecTarget[param1] = 0;
				PrintJAMessage(param1, "Spec lock is now disabled");
				delete menu;
				return 0;
			}

			int target = GetClientOfUserId(userid);
			if (target < 0) {
				PrintJAMessage(param1, "Player no longer in game");
				menuSpec(param1);
				delete menu;
				return 0;
			}

			if (GetClientTeam(param1) > 1) {
				ChangeClientTeam(param1, 1);
				g_iClientTeam[param1] = TEAM_SPECTATOR;
			}

			FakeClientCommand(param1, "spec_player #%i", userid);
			FakeClientCommand(param1, "spec_mode 1");

			g_iSpecTarget[param1] = target;

			menu.DisplayAt(param1, menu.Selection, MENU_TIME_FOREVER);
		}
		case MenuAction_DrawItem: {
			char targetid[6];
			menu.GetItem(param2, targetid, sizeof(targetid));

			int target = GetClientOfUserId(StringToInt(targetid));
			if (IsClientObserver(param1) && GetEntPropEnt(param1, Prop_Send, "m_hObserverTarget") == target) {
				return ITEMDRAW_DISABLED;
			}
		}
		case MenuAction_End: {
			if (param2 != MenuEnd_Selected) {
				delete menu;
			}
		}
	}

	return 0;
}

/* ======================================================================
   ------------------------------- Stocks
*/

int isValidClient(int client) {
	if (!IsClientInGame(client) || !IsPlayerAlive(client)) {
		return 0;
	}

	return GetClientUserId(client);
}

bool IsClientForcedSpec(int client) {
	return g_bFSpec[client];
}

bool IsClientFSpecRestoring(int client) {
	return g_bFSpecRestoring[client];
}

void DisableForceSpec(int client) {
	g_bFSpec[client] = false;
	g_bFSpecRestoring[client] = false;
}

void SaveFSpecLocation(int client) {
	g_iFSpecTeam[client] = GetClientTeam(client);
	g_TFFSpecClass[client] = TF2_GetPlayerClass(client);
	GetClientAbsOrigin(client, g_vFSpecOrigin[client]);
	GetClientAbsAngles(client, g_vFSpecAngles[client]);
}

void RestoreFSpecLocation(int client) {
	g_bFSpecRestoring[client] = true;

	if (GetClientTeam(client) != g_iFSpecTeam[client]) {
		ChangeClientTeam(client, g_iFSpecTeam[client]);
	}

	if (!IsPlayerAlive(client)) {
		TF2_RespawnPlayer(client);
	}

	RequestFrame(frameRequestFSpecRestore, client);
}

void frameRequestFSpecRestore(int client) {
	if (TF2_GetPlayerClass(client) != g_TFFSpecClass[client]) {
		TF2_SetPlayerClass(client, g_TFFSpecClass[client]);
	}

	TeleportEntity(client, g_vFSpecOrigin[client], g_vFSpecAngles[client], EMPTY_VECTOR);
	CreateTimer(5.0, timerDisableFSpec, client);
}

public Action timerDisableFSpec(Handle timer, int client) {
	DisableForceSpec(client);
}