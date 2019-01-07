

/* ======================================================================
   ------------------------------- SaveLoc API
*/

public Action SL_OnPracticeToggle(int client) {
	if (GetClientTeam(client) == TEAM_SPECTATOR) {
		PrintColoredChat(client, "[%sJA\x01] Can't use this feature while%s spectating", cTheme1, cTheme2);
		return Plugin_Handled;
	}
	if (!SL_IsClientPracticing(client)) {
		if (IsClientRacing(client)) {
			PrintColoredChat(client, "[%sJA\x01] Can't use this feature while%s racing", cTheme1, cTheme2);
			return Plugin_Handled;
		}
		if (IsClientPreviewing(client)) {
			PrintColoredChat(client, "[%sJA\x01] Can't use this feature while in%s preview mode", cTheme1, cTheme2);
			return Plugin_Handled;
		}
	}
	else {
		if (IsClientPreviewing(client)) {
			PrintColoredChat(client, "[%sJA\x01] Disable preview mode before toggling.", cTheme1);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}