float g_vOriginPractice[MAXPLAYERS+1][3];
float g_vAnglesPractice[MAXPLAYERS+1][3];
float g_vZeroVelocity[3];

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
		SavePracticePos(client);
	}
	else {
		if (IsClientPreviewing(client)) {
			PrintColoredChat(client, "[%sJA\x01] Disable preview mode before toggling.", cTheme1);
			return Plugin_Handled;
		}
		RestorePracticePos(client);
	}
	return Plugin_Continue;
}

/* ======================================================================
   ------------------------------- Internal
*/

void SavePracticePos(int client) {
	GetClientAbsOrigin(client, g_vOriginPractice[client]);
	GetClientAbsAngles(client, g_vAnglesPractice[client]);
}

void RestorePracticePos(int client) {
	TeleportEntity(client, g_vOriginPractice[client], g_vAnglesPractice[client], g_vZeroVelocity);
}