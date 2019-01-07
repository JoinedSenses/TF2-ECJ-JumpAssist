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
		PrintColoredChat(client, "[%sJA\x01] Unable to use this feature while racing.", cTheme1);
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
		PrintToChat(client, "\x01[\x03Spec\x01] Unable to spectate yourself. That would be pretty weird.");
		return Plugin_Handled;
	}
	
	bool isTargetInSpec;
	if (IsClientObserver(target)) {
		target = GetEntPropEnt(target, Prop_Send, "m_hObserverTarget");
		if (target < 1) {
			PrintColoredChat(client, "[%sJA\x01] Target is in spec, but not spectating anyone.", cTheme1);
			return Plugin_Handled;
		}
		if (target == client) {
			PrintColoredChat(client, "[%sJA\x01] Target is spectating you. Unable to spectate", cTheme1);
			return Plugin_Handled;
		}
		PrintColoredChat(client, "[%sJA\x01] Target is in spec. Now spectating their target", cTheme1);
		isTargetInSpec = true;
	}

	if (GetClientTeam(client) > 1) {
		ChangeClientTeam(client, 1);
		g_iClientTeam[client] = TEAM_SPECTATOR;
	}

	if (!isTargetInSpec) {
		PrintColoredChat(client, "[%sJA\x01] Spectating%s %N", cTheme1, cTheme2, target);
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
		PrintColoredChat(client, "[%sJA\x01] Unable to use this feature while racing.", cTheme1);
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
		PrintColoredChat(client, "[%sJA\x01] Spec lock disabled", cTheme1);
		return Plugin_Handled;
	}

	int target;
	if ((target = FindTarget(client, targetName, false, false)) < 1) {
		return Plugin_Handled;
	}

	if (IsClientObserver(target)) {
		PrintColoredChat(client, "[%sJA\x01] Target is in spec, will resume with spec when they spawn.", cTheme1);
		PrintColoredChat(client, "[%sJA\x01] To disable, type%s /speclock 0", cTheme1, cTheme2);
	}

	if (GetClientTeam(client) > 1) {
		ChangeClientTeam(client, 1);
		g_iClientTeam[client] = TEAM_SPECTATOR;
	}

	FakeClientCommand(client, "spec_player #%i", GetClientUserId(target));
	FakeClientCommand(client, "spec_mode 1");
	PrintColoredChat(client, "[%sJA\x01] Spectating%s %N", cTheme1, cTheme2, target);

	g_iSpecTarget[client] = target;
	return Plugin_Handled;
}

// ---------------- Admin Command

public Action cmdForceSpec(int client, int args) {
	if (args < 1) {
		PrintColoredChat(client, "Usage: sm_fspec <target> <OPTIONAL:targetToSpec>");
		return Plugin_Handled;
	}
	char targetName[MAX_NAME_LENGTH];
	GetCmdArg(1, targetName, sizeof(targetName));

	int target;
	if ((target = FindTarget(client, targetName, false, false)) < 1) {
		return Plugin_Handled;
	}

	if (GetRaceStatus(target) != STATUS_NONE) {
		PrintColoredChat(client, "[%sJA\x01] Unable to target this player while they racing.", cTheme1);
		return Plugin_Handled;	
	}

	if (IsClientFSpecRestoring(target)) {
		PrintColoredChat(client, "[%sJA\x01] Unable to target this player while they're restoring from fspec.", cTheme1);
		return Plugin_Handled;		
	}

	if (IsClientForcedSpec(target)) {
		RestoreFSpecLocation(target);
		PrintColoredChat(client, "[%xJA\x01] %N status restored.", cTheme1);
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
			PrintColoredChat(client, "[%sJA\x01] Target%s %N\x01 must be alive.", cTheme1, cTheme2, targetToSpec);
			return Plugin_Handled;
		}
		Format(targetToSpecName, sizeof(targetToSpecName), "%N", targetToSpec);
	}
	else {
		Format(targetToSpecName, sizeof(targetToSpecName), "you");
		targetToSpec = client;
	}

	SaveFSpecLocation(target);

	if (GetClientTeam(target) > 1) {
		ChangeClientTeam(target, 1);
		g_iClientTeam[client] = TEAM_SPECTATOR;
	}

	FakeClientCommand(target, "spec_player #%i", GetClientUserId(targetToSpec));
	FakeClientCommand(target, "spec_mode 1");

	PrintColoredChat(client, "[%sJA\x01] Forced%s %N\x01 to spectate%s %s", cTheme1, cTheme2, target, cTheme2, targetToSpecName);
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
	for (int i = 1; i <= MaxClients; i++) {
		if ((id = isValidClient(i)) > 0 && client != i) {
			Format(userid, sizeof(userid), "%i", id);
			Format(clientName, sizeof(clientName), "%N", i);
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
				PrintColoredChat(param1, "[%sJA\x01] Sent to spec", cTheme1);
				delete menu;
				return 0;
			}
			if (GetClientOfUserId(userid) == 0) {
				PrintColoredChat(param1, "[%sJA\x01] Player no longer in game", cTheme1);
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
			int target;
			if (userid == 0) {
				g_iSpecTarget[param1] = 0;
				PrintColoredChat(param1, "[%sJA\x01] Spec lock is now disabled", cTheme1);
				delete menu;
				return 0;
			}
			if ((target = GetClientOfUserId(userid)) < 0) {
				PrintColoredChat(param1, "[%sJA\x01] Player no longer in game", cTheme1);
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
	TeleportEntity(client, g_vFSpecOrigin[client], g_vFSpecAngles[client], nullVector);
	CreateTimer(5.0, timerDisableFSpec, client);
}

Action timerDisableFSpec(Handle timer, int  client) {
	DisableForceSpec(client);
}