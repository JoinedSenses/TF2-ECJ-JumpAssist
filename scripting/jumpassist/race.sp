enum RaceStatus {
	STATUS_NONE = 0,
	STATUS_INVITING,
	STATUS_COUNTDOWN,
	STATUS_RACING,
	STATUS_WAITING
}

int
	  g_iRaceID[MAXPLAYERS+1]
	, g_iRaceFinishedPlayers[MAXPLAYERS+1][MAXPLAYERS]
	, g_iRaceEndPoint[MAXPLAYERS+1] = {-1, ...}
	, g_iRaceInvitedTo[MAXPLAYERS+1]
	, g_iRaceSpec[MAXPLAYERS+1]
	, g_iCountDown[MAXPLAYERS+1]
	, g_iClientPreRaceTeam[MAXPLAYERS+1]
	, g_iClientPreRaceCPsTouched[MAXPLAYERS+1];
float
	  g_fRaceStartTime[MAXPLAYERS+1]
	, g_fRaceTime[MAXPLAYERS+1]
	, g_fRaceTimes[MAXPLAYERS+1][MAXPLAYERS]
	, g_fRaceFirstTime[MAXPLAYERS+1]
	, g_fClientPreRaceOrigin[MAXPLAYERS+1][3]
	, g_fClientPreRaceAngles[MAXPLAYERS+1][3];
bool
	  g_bRaceLocked[MAXPLAYERS+1]
	, g_bRaceAmmoRegen[MAXPLAYERS+1]
	, g_bRaceClassForce[MAXPLAYERS+1]
	, g_bWaitingInvite[MAXPLAYERS+1]
	, g_bClientPreRaceBeatTheMap[MAXPLAYERS+1]
	, g_bClientPreRaceAmmoRegen[MAXPLAYERS+1]
	, g_bClientPreRaceCPTouched[MAXPLAYERS+1][32];
TFClassType
	  g_TFClientPreRaceClass[MAXPLAYERS+1];
RaceStatus
	  g_iRaceStatus[MAXPLAYERS+1];

/* ======================================================================
   ------------------------------- Commands
*/

public Action cmdRace(int client, int args) {
	if (!g_cvarPluginEnabled.BoolValue || !IsValidClient(client)) {
		return Plugin_Handled;
	}

	if (g_iClientTeam[client] < 2 || !IsPlayerAlive(client)) {
		PrintJAMessage(client, "Must be alive and on a team to use this command.");
		return Plugin_Handled;
	}

	if (g_iCPCount == 0 && !g_bCPFallback) {
		PrintJAMessage(client, "You may only race on maps with control points.");
		return Plugin_Handled;
	}

	if (IsClientPreviewing(client)) {
		PrintJAMessage(client, "Unable to bein race while previewing.");
		return Plugin_Handled;
	}

	if (IsClientRacing(client) || g_iRaceID[client] != 0) {
		PrintJAMessage(client, "You are already in a race. Wait for it to finish or type %s/r_leave\x01 to leave.", cTheme2);
		return Plugin_Handled;
	}

	displayRaceCPMenu(client);
	return Plugin_Handled;
}

public Action cmdRaceLeave(int client, int args) {
	if (!IsClientRacing(client)) {
		PrintJAMessage(client, "You are not in a race.");
		return Plugin_Handled;
	}

	LeaveRace(client);
	PrintJAMessage(client, "You have%s left\x01 the race.", cTheme2);
	PostRaceClientRestore(client);

	return Plugin_Handled;
}

public Action cmdRaceSpec(int client, int args) {
	if (!IsValidClient(client)) {
		return Plugin_Handled;
	}

	if (args == 0) {
		PrintJAMessage(client, "No target race selected.");
		return Plugin_Handled;
	}

	char arg1[32];

	GetCmdArg(1, arg1, sizeof(arg1));
	int target = FindTarget(client, arg1, true, false);
	if (target == -1) {
		return Plugin_Handled;
	}

	if (target == client) {
		PrintJAMessage(client, "You may not spectate yourself.");
		return Plugin_Handled;
	}

	if (!IsClientRacing(target)) {
		PrintJAMessage(client, "%N is not in a race.", target);
		return Plugin_Handled;
	}

	if (IsClientObserver(target)) {
		PrintJAMessage(client, "You may not spectate a spectator.");
		return Plugin_Handled;
	}

	if (IsClientRacing(client)) {
		LeaveRace(client);
	}

	if (!IsClientObserver(client)) {
		ChangeClientTeam(client, 1);
		g_iClientTeam[client] = 1;
		ForcePlayerSuicide(client);
	}

	g_iRaceSpec[client] = g_iRaceID[target];
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", g_iRaceID[target]);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 4);

	return Plugin_Continue;
}

public Action cmdRaceList(int client, int args) {
	//WILL NEED TO ADD && !ISCLINETOBSERVER(CLIENT) WHEN I ADD SPEC SUPPORT FOR THIS (Nolem's note. Not sure exactly what he wanted to do)
	int clientToShow;
	int iObserverMode;
	if (!IsClientRacing(client)) {
		if (IsClientObserver(client)) {
			iObserverMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
			clientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if (!IsValidClient(client) || !IsValidClient(clientToShow) || iObserverMode == 7) {
				return Plugin_Handled;
			}

			if (!IsClientRacing(clientToShow)) {
				PrintJAMessage(client, "%N is not in a race", clientToShow);
				return Plugin_Handled;
			}
		}
		else {
			PrintJAMessage(client, "You are not in a race");
			return Plugin_Handled;
		}
	}
	else {
		clientToShow = client;
	}

	displayRaceTimesMenu(client, clientToShow);
	return Plugin_Handled;
}

public Action cmdRaceInfo(int client, int args) {
	if (!IsValidClient(client)) {
		return Plugin_Handled;
	}
	//WILL NEED TO ADD && !ISCLINETOBSERVER(CLIENT) WHEN I ADD SPEC SUPPORT FOR THIS (nolem's note)
	int clientToShow;
	int iObserverMode;

	if (!IsClientRacing(client)) {
		if (IsClientObserver(client)) {
			iObserverMode = GetEntPropEnt(client, Prop_Send, "m_iObserverMode");
			clientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if (!IsValidClient(client) || !IsValidClient(clientToShow) || iObserverMode == 6) {
				return Plugin_Handled;
			}

			if (!IsClientRacing(clientToShow)) {
				PrintJAMessage(client, "%N is not in a race", clientToShow);
				return Plugin_Handled;
			}
		}
		else {
			PrintJAMessage(client, "You are not in a race");
			return Plugin_Handled;
		}
	}
	else {
		clientToShow = client;
	}

	displayRaceInfoPanel(client, clientToShow);
	return Plugin_Handled;
}

public Action cmdRaceServer(int client, int args) {
	if (!IsValidClient(client)) {
		return Plugin_Handled;
	}

	if (g_iClientTeam[client] < 2 || !IsPlayerAlive(client)) {
		PrintJAMessage(client, "Must be%s alive\x01 and on a%s team\x01 to use this command.", cTheme2, cTheme2);
		return Plugin_Handled;
	}

	if (g_iCPCount == 0 && !g_bCPFallback) {
		PrintJAMessage(client, "You may only race on maps with control points.");
		return Plugin_Handled;
	}

	if (IsPlayerFinishedRacing(client)) {
		LeaveRace(client);
	}

	if (IsClientRacing(client)) {
		PrintJAMessage(client, "[%sJA\x01] You are already in a race. Type%s /r_leave\x01 to leave.", cTheme1, cTheme2);
		return Plugin_Handled;
	}

	displayRaceCPMenu(client, true);
	return Plugin_Handled;
}

/* ======================================================================
   ------------------------------- Menus
*/

void displayRaceCPMenu(int client, bool serverRace = false) {
	char cpName[32];
	char buffer[32];
	int entity;

	Menu menu = new Menu(serverRace ? menuHandlerServerRaceCP : menuHandlerRaceCP);
	menu.SetTitle("Select End Control Point");

	int count;
	if (g_bCPFallback) {
		while ((entity = FindEntityByClassname(entity, "trigger_capture_area")) != -1) {
			GetEntPropString(entity, Prop_Data, "m_iszCapPointName", cpName, sizeof(cpName));
			IntToString(count++, buffer, sizeof(buffer));
			menu.AddItem(buffer, cpName);
		}		
	}
	else {
		while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1) {
			int pIndex = GetEntProp(entity, Prop_Data, "m_iPointIndex");
			GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
			IntToString(pIndex, buffer, sizeof(buffer));
			menu.AddItem(buffer, cpName);
			++count;
		}		
	}

	if (count) {
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else {
		PrintJAMessage(client, "Unable to add control points to the menu at this time.");
		delete menu;
	}
	
	return;
}

int menuHandlerRaceCP(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			char info[32];
			menu.GetItem(param2, info, sizeof(info));

			g_iRaceEndPoint[param1] = StringToInt(info);
			g_iRaceID[param1] = param1;
			g_iRaceStatus[param1] = STATUS_INVITING;
			g_bRaceClassForce[param1] = true;
			
			displayRaceInviteMenu(param1);
		}
		case MenuAction_Cancel: {
			g_iRaceID[param1] = 0;
			g_iRaceStatus[param1] = STATUS_NONE;
			PrintJAMessage(param1, "The race has been cancelled.");	
		}
		case MenuAction_End: {
			delete menu;
		}
	}
}

int menuHandlerServerRaceCP(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			char info[32];
			char buffer[128];

			menu.GetItem(param2, info, sizeof(info));
			if (StrEqual(info, "*[Begin Race]*")) {
				BeginRace(param1);
				delete menu;
				return 0;
			}

			g_iRaceEndPoint[param1] = StringToInt(info);
			Panel panel;
			for (int i = 1; i <= MaxClients; ++i) {
				if (IsValidClient(i) && param1 != i && !g_bWaitingInvite[i] && g_iRaceID[i] == 0) {
					FormatEx(buffer, sizeof(buffer), "[JA] You have been invited to race to %s by %N", GetCPNameByIndex(g_iRaceEndPoint[param1]), param1);
					g_iRaceInvitedTo[i] = param1;

					panel = new Panel();
					panel.SetTitle(buffer);
					panel.DrawItem("Accept");
					panel.DrawItem("Decline");
					panel.Send(i, panelHandlerInvites, 15);
					delete panel;
				}
			}
		}
		case MenuAction_Cancel: {
			g_iRaceID[param1] = 0;
			PrintJAMessage(param1, "The race has been %scancelled\x01.", cTheme2);
		}
		case MenuAction_End: {
			delete menu;
		}
	}
	return 0;
}

void displayRaceInviteMenu(int client) {
	char buffer[128];
	char clientName[128];

	Menu menu = new Menu(menuHandlerInvitePlayers, MENU_ACTIONS_DEFAULT);
	menu.ExitBackButton = true;	
	menu.AddItem("*[Begin Race]*","*[Begin Race]*");

	for (int i = 1; i <= MaxClients; ++i) {
		if (IsValidClient(i) && i != client && !g_bWaitingInvite[i] && g_iRaceID[i] < 1) {
			IntToString(i, buffer, sizeof(buffer));
			GetClientName(i, clientName, sizeof(clientName));
			menu.AddItem(buffer, clientName);
		}
		menu.SetTitle("Select Players to Invite:");
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

int menuHandlerInvitePlayers(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			char buffer[128];
			char sPlayer[32];
			menu.GetItem(param2, sPlayer, sizeof(sPlayer));

			if (StrEqual(sPlayer, "*[Begin Race]*")) {
				BeginRace(param1);
				delete menu;
				return 0;
			}

			int iPlayer = StringToInt(sPlayer);

			menu.RemoveItem(param2);

			if (g_bWaitingInvite[iPlayer]) {
				PrintJAMessage(param1, "%s%N has already been invited", cTheme2, iPlayer);
				menu.DisplayAt(param1, menu.Selection, MENU_TIME_FOREVER);
				return 0;
			}
			PrintJAMessage(param1, "You have invited%s %N \x01to race.", cTheme2, iPlayer);
			FormatEx(buffer, sizeof(buffer), "[JA] You have been invited to race to %s by %N", GetCPNameByIndex(g_iRaceEndPoint[param1]), param1);
			
			Panel panel = new Panel();
			panel.SetTitle(buffer);
			panel.DrawItem("Accept");
			panel.DrawItem("Decline");
			panel.Send(iPlayer, panelHandlerInvites, 15);
			delete panel;

			g_iRaceInvitedTo[iPlayer] = param1;
			g_bWaitingInvite[iPlayer] = true;

			menu.DisplayAt(param1, menu.Selection, MENU_TIME_FOREVER);
		}
		case MenuAction_Cancel: {
			if (param2 == MenuCancel_ExitBack) {
				g_iRaceID[param1] = 0;
				displayRaceCPMenu(param1);
			}
			else {
				PrintToRace(param1, "The race has been%s cancelled\x01.", cTheme2);
				ResetRace(param1, false);
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

int panelHandlerInvites(Menu menu, MenuAction action, int param1, int param2) {
	int leader = g_iRaceInvitedTo[param1];
	int target = param1;

	if (!IsClientInGame(leader)) {
		g_iRaceID[target] = 0;
		return;
	}

	switch (param2) {
		case 1: {
			if (HasRaceStarted(leader)) {
				PrintJAMessage(leader, "This race has already%s started.", cTheme2);			
				return;
			}
			LeaveRace(target);
			g_iRaceID[target] = leader;
			PrintJAMessage(leader, "%s%N has%s accepted\x01 your request to race", cTheme2, target, cTheme2);
		}
		case 2: {
			g_iRaceID[target] = 0;
			PrintJAMessage(leader, "%s%N\x01 has%s declined\x01 your request to race", cTheme2, target, cTheme2);
		}
		default: {
			g_iRaceID[target] = 0;
			PrintJAMessage(leader, "%s%N\x01 failed to respond to your invitation", cTheme2, target);			
		}
	}

	g_bWaitingInvite[target] = false;
}

void displayRaceTimesMenu(int client, int clientToShow) {
	int race = g_iRaceID[clientToShow];
	char leader[32];
	char leaderFormatted[32];
	char racerEntryFormatted[255];
	char racerTimes[128];
	char racerDiff[128];
	bool space;

	GetClientName(g_iRaceID[clientToShow], leader, sizeof(leader));
	FormatEx(leaderFormatted, sizeof(leaderFormatted), "%s's Race", leader);
	
	Panel panel = new Panel();
	panel.DrawText(leaderFormatted);
	panel.DrawText(" ");
	
	int racer;
	for (int i = 0; i <= MaxClients && (racer = g_iRaceFinishedPlayers[race][i]) != 0; ++i) {
		space = true;
		racerTimes = TimeFormat(g_fRaceTimes[race][i] - g_fRaceStartTime[race]);

		if (g_fRaceFirstTime[race] != g_fRaceTimes[race][i]) {
			racerDiff = TimeFormat(g_fRaceTimes[race][i] - g_fRaceFirstTime[race]);
		}
		else {
			racerDiff = "00:00:000";
		}

		FormatEx(racerEntryFormatted, sizeof(racerEntryFormatted), "%d. %N - %s (+%s)", (i+1), racer, racerTimes, racerDiff);
		panel.DrawText(racerEntryFormatted);
	}

	if (space) {
		panel.DrawText(" ");
	}

	char name[32];
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInGame(i) && IsClientInRace(i, race) && !IsPlayerFinishedRacing(i)) {
			GetClientName(i, name, sizeof(name));
			panel.DrawText(name);
		}
	}

	panel.DrawText(" ");
	panel.DrawItem("Exit");
	panel.Send(client, panelHandlerDoNothing, 30);
	delete panel;
}

void displayRaceInfoPanel(int client, int clientToShow) {
	char leader[32];
	char leaderFormatted[64];
	char status[64];
	char ammoRegen[32];
	char classForce[32];

	GetClientName(g_iRaceID[clientToShow], leader, sizeof(leader));
	FormatEx(leaderFormatted, sizeof(leaderFormatted), "Race Host: %s", leader);

	switch (GetRaceStatus(clientToShow)) {
		case STATUS_INVITING: {
			status = "Race Status: Waiting for start";
		}
		case STATUS_COUNTDOWN: {
			status = "Race Status: Starting";
		}
		case STATUS_RACING: {
			status = "Race Status: Racing";
		}
		case STATUS_WAITING: {
			status = "Race Status: Waiting for finishers";
		}
	}

	FormatEx(classForce, sizeof(classForce), "Class Force: %s", g_bRaceClassForce[g_iRaceID[clientToShow]] ? "Enabled" : "Disabled");
		
	Panel panel = new Panel();
	panel.DrawText(leaderFormatted);
	panel.DrawText(status);
	panel.DrawText("---------------");
	panel.DrawText(ammoRegen);
	panel.DrawText("---------------");
	panel.DrawText(classForce);
	panel.DrawText(" ");
	panel.DrawItem("Exit");
	panel.Send(client, panelHandlerDoNothing, 30);
	delete panel;
}

int panelHandlerDoNothing(Menu menu, MenuAction action, int param1, int param2) {
	// Do nothing.
}

/* ======================================================================
   ------------------------------- Internal Functions
*/

void BeginRace(int raceid) {
	if (!IsValidClient(raceid)) {
		return;
	}

	LockRacePlayers(raceid);
	
	// apply race settings
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInRace(i, raceid)) {
			g_bAmmoRegen[i] = g_bRaceAmmoRegen[g_iRaceID[i]];
		}
	}

	g_iRaceStatus[raceid] = STATUS_COUNTDOWN;
	CreateTimer(2.0, RaceCountDown, raceid);
	g_iCountDown[raceid] = 3;
	SendRaceToStart(raceid, g_TFClientClass[raceid], g_iClientTeam[raceid]);
	PrintToRace(raceid, "Teleporting to race start");
}

void SendRaceToStart(int raceid, TFClassType class, int team) {
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInRace(i, raceid)) {
			// Get client's pre-race info so they can have it restored after a race.
			PreRaceClientRetrieve(i);

			if (g_bRaceClassForce[raceid]) {
				TF2_SetPlayerClass(i, class);
			}

			ChangeClientTeam(i, team);
			SendToStart(i);
			g_bIsPreviewing[i] = false;
		}
	}
}

char g_sAsterisk[] = "****************************";
char g_sTab[] = "			   ";

Action RaceCountDown(Handle timer, int raceID) {
	char value[4];
	char message[256];
	switch (g_iCountDown[raceID]) {
		case 0: {
			value = "GO!";
			UnlockRacePlayers(raceID);
			g_fRaceStartTime[raceID] = GetEngineTime();
			g_iRaceStatus[raceID] = STATUS_RACING;
		}
		default: {
			FormatEx(value, sizeof(value), "  %i", g_iCountDown[raceID]);
			CreateTimer(1.0, RaceCountDown, raceID);
			g_iCountDown[raceID]--;
		}
	}
	FormatEx(message, sizeof(message), "\n \n \n \n \n%s \n \n%s\x03%s\x01\n \n%s", g_sAsterisk, g_sTab, value, g_sAsterisk);
	PrintToRaceEx(raceID, message);
}

Action timerPostRace1(Handle timer, DataPack dp) {
	dp.Reset();
	int client = dp.ReadCell();
	CreateTimer(5.0, timerPostRace2, dp);

	PrintJAMessage(client, "%sRestoring\x01 pre-race%s status\x01 in 5 seconds.", cTheme2, cTheme2);
}

Action timerPostRace2(Handle timer, DataPack dp) {
	dp.Reset();
	int client = dp.ReadCell();
	int raceID = dp.ReadCell();
	delete dp;

	if (g_iRaceID[client] == raceID) {	
		g_iRaceID[client] = 0;
		g_iRaceStatus[client] = STATUS_NONE;
		g_fRaceTime[client] = g_fRaceFirstTime[client] = g_fRaceStartTime[client] = 0.0;
		g_bRaceLocked[client] = g_bRaceAmmoRegen[client] = false;
		g_iRaceEndPoint[client] = -1;
		g_bRaceClassForce[client] = true;
	}

	PostRaceClientRestore(client);
}

char[] GetCPNameByIndex(int index) {
	int entity;
	char cpName[32];
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1) {
		if (GetEntProp(entity, Prop_Data, "m_iPointIndex") == index) {
			GetEntPropString(entity, Prop_Data, "m_iszPrintName", cpName, sizeof(cpName));
		}
	}
	return cpName;
}

char[] TimeFormat(float timeTaken) {
	char msFormat[128];
	char msFormatFinal[128];
	char final[128];
	char secondsString[128];
	char minutesString[128];
	char hoursString[128];
	
	float ms = timeTaken-RoundToZero(timeTaken);
	FormatEx(msFormat, sizeof(msFormat), "%.3f", ms);
	strcopy(msFormatFinal, sizeof(msFormatFinal), msFormat[2]);
	
	int intTimeTaken = RoundToZero(timeTaken);
	int seconds = intTimeTaken % 60;
	int minutes = (intTimeTaken-seconds)/60;
	int hours = (intTimeTaken-seconds - minutes * 60)/60;
	secondsString = FormatTimeComponent(seconds);
	minutesString = FormatTimeComponent(minutes);
	hoursString = FormatTimeComponent(hours);
	
	if (hours != 0) {
		FormatEx(final, sizeof(final), "%s:%s:%s:%s", hoursString, minutesString, secondsString, msFormatFinal);
	}
	else {
		FormatEx(final, sizeof(final), "%s:%s:%s", minutesString, secondsString, msFormatFinal);
	}

	return final;
}

char[] FormatTimeComponent(int time) {
	char final[8];
	FormatEx(final, sizeof(final), (time > 9) ? "%d" : "0%d", time);
	return final;
}

void PrintToRace(int raceID, char[] message, any ...) {
	char output[1024];
	VFormat(output, sizeof(output), message, 3);
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInGame(i) && (IsClientInRace(i, raceID) || IsClientSpectatingRace(i, raceID))) {
			PrintJAMessage(i, "%s", output);
		}
	}
}

void PrintToRaceEx(int raceID, char[] message, any ...) {
	char output[1024];
	VFormat(output, sizeof(output), message, 3);
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInGame(i) && (IsClientInRace(i, raceID) || IsClientSpectatingRace(i, raceID))) {
			PrintColoredChat(i, "%s", output);
		}		
	}
}

int GetPlayersStillRacing(int raceID) {
	int players;
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInRace(i, raceID) && !IsPlayerFinishedRacing(i)) {
			++players;
		}
	}
	if (players != 0) {
		PrintToRace(raceID, "There are%s %i \x01players still racing.", cTheme2, players);
	}
	return players;
}

void LockRacePlayers(int raceID) {
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInRace(i, raceID)) {
			g_bRaceLocked[i] = true;
		}
	}
}

void UnlockRacePlayers(int raceID) {
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInRace(i, raceID)) {
			g_bRaceLocked[i] = false;
		}
	}
}

void LeaveRace(int client, bool raceFinished = false) {
	int raceID = g_iRaceID[client];
	g_iRaceID[client] = 0;
	if (raceID == 0) {
		return;
	}

	if (GetPlayersStillRacing(raceID) < 2) {
		ResetRace(raceID);
		raceID = 0;
	}

	if (client == raceID) {
		if (HasRaceStarted(raceID)) {
			for (int i = 1; i <= MaxClients; ++i) {
				if (IsClientInRace(i, raceID) && IsClientRacing(i) && !IsRaceLeader(i, raceID)) {
					int newRace = i;
					int emptyInt[32];
					float emptyFloat[32];
					g_iRaceStatus[i] = g_iRaceStatus[raceID];
					g_iRaceEndPoint[i] = g_iRaceEndPoint[raceID];
					g_fRaceStartTime[i] = g_fRaceStartTime[raceID];
					g_fRaceFirstTime[i] = g_fRaceFirstTime[raceID];
					g_bRaceAmmoRegen[i] = g_bRaceAmmoRegen[raceID];
					g_bRaceClassForce[i] = g_bRaceClassForce[raceID];
					g_fRaceTimes[i] = g_fRaceTimes[raceID];
					g_iRaceFinishedPlayers[i] = g_iRaceFinishedPlayers[raceID];
					g_iRaceID[client] = 0;
					g_iRaceFinishedPlayers[client] = emptyInt;
					g_fRaceTime[client] = g_fRaceFirstTime[client] = g_fRaceStartTime[raceID] = 0.0;
					g_fRaceTimes[client] = emptyFloat;
					g_bRaceLocked[client] = false;
					g_iRaceEndPoint[client] = -1;
					// assign race to someone else if leader has left
					for (int j = 1; j <= MaxClients; ++j) {
						if (IsClientRacing(j) && !IsRaceLeader(j, raceID)) {
							g_iRaceID[j] = newRace;
						}
					}
					return;
				}
			}
		}
		else {
			ResetRace(raceID);
		}
	}
	else {
		g_iRaceID[client] = 0;
		g_fRaceTime[client] = g_fRaceFirstTime[client] = g_fRaceStartTime[client] = 0.0;
		g_bRaceLocked[client] = false;
		g_iRaceEndPoint[client] = -1;
	}

	if (!raceFinished) {
		char buffer[128];
		FormatEx(buffer, sizeof(buffer), "%N has left the race.", client);
		PrintToRace(raceID, buffer);
	}
}

void ResetRace(int raceID, bool raceEnded = true) {
	for (int i = 0; i <= MaxClients; ++i) {
		if (g_iRaceID[i] == raceID) {
			g_iRaceID[i] = 0;
			g_iRaceStatus[i] = STATUS_NONE;
			g_fRaceTime[i] = g_fRaceFirstTime[i] = g_fRaceStartTime[i] = 0.0;
			g_bRaceLocked[i] = g_bRaceAmmoRegen[i] = false;
			g_iRaceEndPoint[i] = -1;
			g_bRaceClassForce[i] = true;

			if (raceEnded && IsClientInGame(i)) {
				DataPack dp = new DataPack();
				dp.WriteCell(i);
				dp.WriteCell(raceID);
				CreateTimer(3.0, timerPostRace1, dp);
				PrintJAMessage(i, "Race has%s ended\x01.", cTheme2);				
			}
		}

		g_fRaceTimes[raceID][i] = 0.0;
		g_iRaceFinishedPlayers[raceID][i] = 0;
	}
}

void PreRaceClientRetrieve(int client) {
	g_iClientPreRaceCPsTouched[client] = g_iCPsTouched[client];
	g_bClientPreRaceBeatTheMap[client] = g_bBeatTheMap[client];
	g_bClientPreRaceAmmoRegen[client] = g_bAmmoRegen[client];
	g_bClientPreRaceCPTouched[client] = g_bCPTouched[client];
	GetClientAbsOrigin(client, g_fClientPreRaceOrigin[client]);
	GetClientAbsAngles(client, g_fClientPreRaceAngles[client]);
	g_TFClientPreRaceClass[client] = TF2_GetPlayerClass(client);
	g_iClientPreRaceTeam[client] = GetClientTeam(client);
	PrintJAMessage(client, "%sSaving\x01 pre-race status.", cTheme2);
}

void PostRaceClientRestore(int client) {
	if (!IsValidClient(client)) {
		return;
	}

	g_iCPsTouched[client] = g_iClientPreRaceCPsTouched[client];
	g_bBeatTheMap[client] = g_bClientPreRaceBeatTheMap[client];
	g_bAmmoRegen[client] = g_bClientPreRaceAmmoRegen[client];
	g_bCPTouched[client] = g_bClientPreRaceCPTouched[client];
	TF2_SetPlayerClass(client, g_TFClientPreRaceClass[client]);
	ChangeClientTeam(client, g_iClientPreRaceTeam[client]);
	TeleportEntity(client, g_fClientPreRaceOrigin[client], g_fClientPreRaceAngles[client], nullVector);
	PrintJAMessage(client, "Pre-race status has been%s restored\x01.", cTheme2);
}

bool IsClientRacing(int client) {
	return (g_iRaceID[client] != 0);
}

bool IsClientInRace(int client, int race) {
	return (g_iRaceID[client] == race);
}

bool IsRaceLeader(int client, int race) {
	return (client == race);
}

RaceStatus GetRaceStatus(int client) {
	return g_iRaceStatus[g_iRaceID[client]];
}

bool HasRaceStarted(int client) {
	int clientRaceStatus = view_as<int>(g_iRaceStatus[g_iRaceID[client]]);
	return (clientRaceStatus > 1);
}

bool IsPlayerFinishedRacing(int client) {
	return (g_fRaceTime[client] != 0.0);
}

bool IsClientSpectatingRace(int client, int race) {
	if (!IsValidClient(client) || !IsClientObserver(client)) {
		return false;
	}

	int iObserverMode = GetEntPropEnt(client, Prop_Send, "m_iObserverMode");
	int clientToShow = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

	return (IsValidClient(clientToShow) && iObserverMode != 6 && IsClientInRace(clientToShow, race));
}