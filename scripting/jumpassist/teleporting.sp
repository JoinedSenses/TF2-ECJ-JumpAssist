/* ======================================================================
   ------------------------------- Commands
*/

public Action OnBringAction(int client, int argc) {
	if (!client || !IsClientInGame(client)) {
		return Plugin_Handled;
	}
	if (IsClientPreviewing(client)) {
		PrintColoredChat(client, "[%sJA\x01] Unable to bring while in%s preview mode\x01.", cTheme1, cTheme2);
		return Plugin_Handled;
	}
	
	char sCommand[256];
	if (argc < 1) {
		if (!GetCmdArg(0, sCommand, sizeof(sCommand))) {
			return Plugin_Handled;
		}

		ReplyToCommand(client, "%s <client>", cTheme1, sCommand);
		return Plugin_Handled;
	}
	
	if (!GetCmdArgString(sCommand, sizeof(sCommand))) {
		return Plugin_Handled;
	}
	
	int iTargetsArray[MAXPLAYERS+1];
	char sName[MAX_TARGET_LENGTH];
	bool tn_is_ml;
	
	int iReturn = ProcessTargetString(sCommand, client, iTargetsArray, sizeof(iTargetsArray), COMMAND_FILTER_ALIVE, sName, sizeof(sName), tn_is_ml);
	
	if (iReturn < 1) {
		ReplyToTargetError(client, iReturn);
		return Plugin_Handled;
	}
	
	float fPosition[3];
	GetClientAbsOrigin(client, fPosition);
	
	for (int  i; i < iReturn; i++) {
		TeleportEntity(iTargetsArray[i], fPosition, NULL_VECTOR, NULL_VECTOR);
		PrintColoredChat(iTargetsArray[i], "[%sJA\x01]%s %N\x01 has brought you to their position", cTheme1, cTheme2, client);
	}

	char plural[5];
	if (tn_is_ml) {
		Format(plural, sizeof(plural), "the ");
	}

	PrintColoredChat(client, "[%sJA\x01] You have brought %s%s%s\x01 to your position", cTheme1, plural, cTheme2, sName);
	LogAction(client, -1, "\"%L\" (sm_bring) %N brought %s%s to their position.", client, client, plural, sName);
	return Plugin_Handled;
}

public Action OnGoToAction(int client, int args) {
	if (!client || !IsClientInGame(client)) {
		return Plugin_Handled;
	}
	
	char sCommand[256];
	int clientTeam = GetClientTeam(client);
	if (!args) {
		MainMenu(client);
		return Plugin_Handled;
	}
	
	if (!GetCmdArg(1, sCommand, sizeof(sCommand))) {
		return Plugin_Handled;
	}
	
	int target = FindTarget(client, sCommand, !(GetUserFlagBits(client) & ADMFLAG_ROOT));
	
	if (target == -1 || client == target) {
		return Plugin_Handled;
	}

	if (IsClientPreviewing(target)) {
		PrintColoredChat(client, "[%sJA\x01] Can't go to players while they're in%s preview mode\x01.", cTheme1, cTheme2);
		return Plugin_Handled;
	}

	float fPosition[3];
	if (clientTeam != GetClientTeam(target) && !(GetUserFlagBits(client) & (ADMFLAG_GENERIC|ADMFLAG_ROOT))) {
		PrintColoredChat(client, "[%sJA\x01] Can't go to players on the opposite team");
		return Plugin_Handled;
	}
	GetClientAbsOrigin(target, fPosition);
	TeleportEntity(client, fPosition, NULL_VECTOR, NULL_VECTOR);
	
	PrintColoredChat(client, "[%sJA\x01] You have teleported to%s %N\x01's position", cTheme1, cTheme2, target);
	PrintColoredChat(target, "[%sJA\x01]%s %N\x01 has teleported to your position.", cTheme1, cTheme2, client);
	return Plugin_Handled;
}

/* ======================================================================
   ------------------------------- Menu
*/

void MainMenu(int client) {
	Menu menu = new Menu(MenuHandler_Main, MENU_ACTIONS_DEFAULT|MenuAction_DrawItem);
	menu.SetTitle("GoTo Menu!");
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i) && IsPlayerAlive(i) && !IsClientPreviewing(i)) {
			char name[MAX_NAME_LENGTH];
			Format(name, sizeof(name), "%N", i);
			char userid[16];
			Format(userid, sizeof(userid), "%i", GetClientUserId(i));
			menu.AddItem(userid, name);
		}
	}
	menu.Display(client, MENU_TIME_FOREVER);
}
int MenuHandler_Main(Menu menu, MenuAction action, int param1, int param2) {
	switch(action) {
		case MenuAction_Select: {
			char UserId[64];
			menu.GetItem(param2, UserId, sizeof(UserId));
			FakeClientCommand(param1, "sm_goto #%s", UserId);
			menu.DisplayAt(param1, menu.Selection, MENU_TIME_FOREVER);
		}
		case MenuAction_DrawItem: {
			char UserId[64];
			menu.GetItem(param2, UserId, sizeof(UserId));
			int id = StringToInt(UserId);
			if (GetClientUserId(param1) == id) {
				return ITEMDRAW_IGNORE;
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