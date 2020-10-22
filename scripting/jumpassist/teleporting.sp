bool g_bGoToCooldown[MAXPLAYERS+1];
ArrayList g_aGoToRecent[MAXPLAYERS+1];

/* ======================================================================
   ------------------------------- Commands
*/

void CreateGoToArrays() {
	for (int i = 0; i <= MaxClients; ++i) {
		g_aGoToRecent[i] = new ArrayList();
	}
}

void ClearGoToArray(int client) {
	g_aGoToRecent[client].Clear();
}

public Action cmdBring(int client, int argc) {
	if (!client || !IsClientInGame(client)) {
		return Plugin_Handled;
	}

	if (IsClientPreviewing(client)) {
		PrintJAMessage(client, "Unable to bring while in"...cTheme2..." preview mode\x01.");
		return Plugin_Handled;
	}
	
	char cmd[256];
	if (argc < 1) {
		if (!GetCmdArg(0, cmd, sizeof(cmd))) {
			return Plugin_Handled;
		}

		ReplyToCommand(client, "%s <client>", cmd);
		return Plugin_Handled;
	}
	
	if (!GetCmdArgString(cmd, sizeof(cmd))) {
		return Plugin_Handled;
	}
	
	int targets[MAXPLAYERS+1];
	char name[MAX_TARGET_LENGTH];
	bool tn_is_ml;
	
	int count = ProcessTargetString(
		cmd,
		client,
		targets,
		sizeof(targets),
		COMMAND_FILTER_ALIVE,
		name,
		sizeof(name),
		tn_is_ml
	);
	
	if (count < 1) {
		ReplyToTargetError(client, count);
		return Plugin_Handled;
	}
	
	float fPosition[3];
	GetClientAbsOrigin(client, fPosition);
	
	for (int i = 0; i < count; ++i) {
		TeleportEntity(targets[i], fPosition, NULL_VECTOR, NULL_VECTOR);
		PrintJAMessage(targets[i], cTheme2..."%N\x01 has brought you to their position", client);
	}

	char plural[5];
	if (tn_is_ml) {
		strcopy(plural, sizeof(plural), "the ");
	}

	PrintJAMessage(client, "You have brought %s"...cTheme2..."%s\x01 to your position", plural, name);
	LogAction(client, -1, "\"%L\" (sm_bring) %N brought %s%s to their position.", client, client, plural, name);

	return Plugin_Handled;
}

public Action cmdGoTo(int client, int args) {
	if (!client || !IsClientInGame(client) || g_bGoToCooldown[client]) {
		return Plugin_Handled;
	}

	if (!args) {
		MainMenu(client);
		return Plugin_Handled;
	}

	char arg[256];
	if (!GetCmdArg(1, arg, sizeof(arg))) {
		return Plugin_Handled;
	}
	
	int target = FindTarget(client, arg, !(GetUserFlagBits(client) & ADMFLAG_ROOT), false);
	
	if (target == -1 || client == target) {
		return Plugin_Handled;
	}

	if (!IsPlayerAlive(target)) {
		PrintJAMessage(client, "Target must be alive.");
		return Plugin_Handled;
	}

	if (g_aGoToRecent[client].FindValue(target) != -1) {
		PrintJAMessage(client, "Unable to teleport to recently targeted players.");
		return Plugin_Handled;
	}

	if (IsClientPreviewing(target)) {
		PrintJAMessage(client, "Unable to teleport to players while they're in"...cTheme2..." preview mode\x01.");
		return Plugin_Handled;
	}

	if (GetClientTeam(client) != GetClientTeam(target) && !(GetUserFlagBits(client) & (ADMFLAG_GENERIC|ADMFLAG_ROOT))) {
		PrintJAMessage(client, "Can't go to players on the"...cTheme2..." opposite team");
		return Plugin_Handled;
	}

	float origin[3];
	GetClientAbsOrigin(target, origin);
	TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
	
	PrintJAMessage(client, "You have teleported to"...cTheme2..." %N\x01's position", target);
	PrintJAMessage(target, cTheme2..."%N\x01 has teleported to your position.", client);

	if (CheckCommandAccess(client, "sm_bring", ADMFLAG_GENERIC)) {
		return Plugin_Handled;
	}

	g_aGoToRecent[client].Push(target);
	CreateTimer(20.0, timerRecentTargetCooldown, client);

	g_bGoToCooldown[client] = true;
	CreateTimer(3.0, timerGoToCooldown, client);

	return Plugin_Handled;
}

public Action cmdSendPlayer(int client,int args) {
	if (g_Database == null) {
		PrintJAMessage(client, "This feature is not supported without a database configuration");
		return Plugin_Handled;
	}

	if (args < 2) {
		PrintJAMessage(client, cTheme2..."Usage\x01: sm_send <playerName> <targetName>");
		return Plugin_Handled;
	}

	char arg1[MAX_NAME_LENGTH];
	char arg2[MAX_NAME_LENGTH];

	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));

	int target1 = FindTarget2(client, arg1, false, false);
	int target2 = FindTarget2(client, arg2, false, false);

	if (target1 < 1 || target2 < 1) {
		return Plugin_Handled;
	}

	if (IsClientPreviewing(target1)) {
		PrintJAMessage(client, "Unable to send."...cTheme2..." %N\x01 in"...cTheme2..." preview mode\x01.", target1);
		return Plugin_Handled;
	}

	if (IsClientPreviewing(target2)) {
		PrintJAMessage(client, "Unable to send."...cTheme2..." %N\x01 in"...cTheme2..." preview mode\x01.", target2);
		return Plugin_Handled;
	}

	float origin[3];
	float angle[3];

	GetClientAbsOrigin(target2, origin);
	GetClientAbsAngles(target2, angle);
	
	TeleportEntity(target1, origin, angle, EMPTY_VECTOR);
	
	PrintJAMessage(client, "Sent"...cTheme2..." %N\x01 to"...cTheme2..." %N\x01.", target1, target2);
	PrintJAMessage(target1, cTheme2..."%N\x01 sent you to"...cTheme2..." %N\x01.", client, target2);

	return Plugin_Handled;
}

/* ======================================================================
   ------------------------------- Menu
*/

void MainMenu(int client) {
	Menu menu = new Menu(MenuHandler_Main, MENU_ACTIONS_DEFAULT|MenuAction_DrawItem);
	menu.SetTitle("GoTo Menu!");
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsValidClient(i) && IsPlayerAlive(i) && !IsClientPreviewing(i)) {
			char name[MAX_NAME_LENGTH];
			FormatEx(name, sizeof(name), "%N", i);

			char userid[16];
			FormatEx(userid, sizeof(userid), "%i", GetClientUserId(i));

			menu.AddItem(userid, name);
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Main(Menu menu, MenuAction action, int param1, int param2) {
	switch(action) {
		case MenuAction_Select: {
			char userid[64];
			menu.GetItem(param2, userid, sizeof(userid));

			if (GetClientOfUserId(StringToInt(userid))) {
				FakeClientCommand(param1, "sm_goto #%s", userid);
			}
			else {
				menu.RemoveItem(param2);
			}

			menu.DisplayAt(param1, menu.Selection, MENU_TIME_FOREVER);
		}
		case MenuAction_DrawItem: {
			char userid[64];
			menu.GetItem(param2, userid, sizeof(userid));
			int id = StringToInt(userid);

			if (GetClientUserId(param1) == id) {
				return ITEMDRAW_IGNORE;
			}

			if (g_aGoToRecent[param1].FindValue(GetClientOfUserId(id)) != -1) {
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

public Action timerRecentTargetCooldown(Handle timer, int client) {
	if (g_aGoToRecent[client].Length) {
		g_aGoToRecent[client].Erase(0);
	}
}

public Action timerGoToCooldown(Handle timer, int client) {
	g_bGoToCooldown[client] = false;
}