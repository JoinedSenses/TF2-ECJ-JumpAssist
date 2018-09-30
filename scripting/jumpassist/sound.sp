int g_iClientWeapons[MAXPLAYERS+1][3];

public Action HookVoice(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init) {
 	if (!g_cvarPluginEnabled.BoolValue) {
		return Plugin_Continue;
	}
	int client = bf.ReadByte();
	int vMenu1 = bf.ReadByte();
	int vMenu2 = bf.ReadByte();

	if (IsPlayerAlive(client) && IsValidClient(client) && g_cvarPluginEnabled.BoolValue) {
		if ((vMenu1 == 0) && (vMenu2 == 0) && !g_bHardcore[client] && (!g_iRaceID[client] || g_fRaceTime[client] != 0.0)) {
			for (int i = 0; i <= 2; i++) {
				ReSupply(client, g_iClientWeapons[client][i]);
			}
			if (g_TFClientClass[client] == TFClass_Engineer) {
				SetEntProp(client, Prop_Data, "m_iAmmo", 200, 4, 3);
			}
		}
	}
	return Plugin_Continue;
}