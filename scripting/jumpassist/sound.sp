int g_iClientWeapons[MAXPLAYERS+1][3];

public Action HookVoice(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init) {
 	if (!g_hPluginEnabled.BoolValue)
		 return Plugin_Continue;
	int client = BfReadByte(bf), vMenu1 = BfReadByte(bf), vMenu2 = BfReadByte(bf);

	if(IsPlayerAlive(client) && IsValidClient(client) && g_hPluginEnabled.BoolValue) {
		if((vMenu1 == 0) && (vMenu2 == 0) && !g_bHardcore[client] && (!g_bRace[client] || g_bRaceTime[client] != 0.0)) {
			ReSupply(client, g_iClientWeapons[client][0]);
			ReSupply(client, g_iClientWeapons[client][1]);
			ReSupply(client, g_iClientWeapons[client][2]);
			if (TF2_GetPlayerClass(client) == TFClass_Engineer)
				SetEntProp(client, Prop_Data, "m_iAmmo", 200, 4, 3);
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}