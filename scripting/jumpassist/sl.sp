

/* ======================================================================
   ------------------------------- SaveLoc API
*/

public Action SL_OnPracticeToggle(int client) {
	if (GetClientTeam(client) == TEAM_SPECTATOR) {
		PrintJAMessage(client, "Can't use this feature while%s spectating", cTheme2);
		return Plugin_Handled;
	}
	if (!SL_IsClientPracticing(client)) {
		if (IsClientRacing(client)) {
			PrintJAMessage(client, "Can't use this feature while%s racing", cTheme2);
			return Plugin_Handled;
		}
		if (IsClientPreviewing(client)) {
			PrintJAMessage(client, "Can't use this feature while in%s preview mode", cTheme2);
			return Plugin_Handled;
		}
	}
	else {
		if (IsClientPreviewing(client)) {
			PrintJAMessage(client, "Disable%s preview mode\x01 before toggling.", cTheme2);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}