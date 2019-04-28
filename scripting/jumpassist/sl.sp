

/* ======================================================================
   ------------------------------- SaveLoc API
*/

public Action SL_OnPracticeToggle(int client) {
	if (GetClientTeam(client) == TEAM_SPECTATOR) {
		PrintJAMessage(client, "Can't use this feature while%s spectating", cTheme2);
		return Plugin_Handled;
	}

	if (IsClientPreviewing(client)) {
		PrintJAMessage(client, "Can't toggle this feature while in%s preview mode", cTheme2);
		return Plugin_Handled;
	}

	if (IsClientRacing(client)) {
		PrintJAMessage(client, "Can't toggle this feature while%s racing", cTheme2);
		return Plugin_Handled;
	}

	if (IsClientHardcore(client)) {
		PrintJAMessage(client, "Can't toggle this feature while in%s hardcore mode", cHardcore);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action SL_OnSaveLoc(int client, float origin[3], float angles[3], float velocity[3], float time) {
	if (IsClientPreviewing(client) || IsClientRacing(client) || IsClientHardcore(client)) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action SL_OnTeleLoc(int client) {
	if (IsClientPreviewing(client) || IsClientRacing(client) || IsClientHardcore(client)) {
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}