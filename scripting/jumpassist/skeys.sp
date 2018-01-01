
new Handle:HudDisplayForward;
new Handle:HudDisplayASD;
new Handle:HudDisplayDuck;
new Handle:HudDisplayJump;
new Handle:HudDisplayM1;
new Handle:HudDisplayM2;


new bool:g_bGetClientKeys[MAXPLAYERS+1];

new g_iButtons[MAXPLAYERS+1];
new g_iSkeysRed[MAXPLAYERS+1];
new g_iSkeysGreen[MAXPLAYERS+1];
new g_iSkeysBlue[MAXPLAYERS+1];

new Float:g_iSkeysXLoc[MAXPLAYERS+1];
new Float:g_iSkeysYLoc[MAXPLAYERS+1];

new String:wasBack[MAXPLAYERS+1];
new String:wasMoveRight[MAXPLAYERS+1];
new String:wasMoveLeft[MAXPLAYERS+1];

new Float:defaultXLoc = 0.54;
new Float:defaultYLoc = 0.40;

public OnProfileLoaded(client, red, green, blue)
{
	g_iSkeysRed[client] = red;
	g_iSkeysGreen[client] = green;
	g_iSkeysBlue[client] = blue;

}

public SetAllSkeysDefaults(){
	for(new i = 0; i < MAXPLAYERS+1; i++){
		SetSkeysDefaults(i);
	}

}

public SetSkeysDefaults(client){
	g_iSkeysXLoc[client] = defaultXLoc;
	g_iSkeysYLoc[client] = defaultYLoc;
}





public SkeysOnGameFrame()
{
	new iClientToShow, iObserverMode;
	for (new i=1;i<MaxClients;i++)
	{

		if (g_bGetClientKeys[i] && IsClientInGame(i))
		{
			ClearSyncHud(i, HudDisplayForward);
			ClearSyncHud(i, HudDisplayASD);
			ClearSyncHud(i, HudDisplayDuck);
			ClearSyncHud(i, HudDisplayJump);
			ClearSyncHud(i, HudDisplayM1);
			ClearSyncHud(i, HudDisplayM2);

			if (g_iButtons[i] & IN_SCORE) { return; }
			iObserverMode = GetEntPropEnt(i, Prop_Send, "m_iObserverMode");
			if (IsClientObserver(i)) { iClientToShow = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget"); } else { iClientToShow = i; }
			if (!IsValidClient(i) || !IsValidClient(iClientToShow) || iObserverMode == 6) { return; }

			if (g_iButtons[iClientToShow] & IN_FORWARD)
			{
				SetHudTextParams(g_iSkeysXLoc[i]+0.06, g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayForward, "W");
			} else {
				SetHudTextParams(g_iSkeysXLoc[i]+0.06, g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayForward, "-");
			}


			if (g_iButtons[iClientToShow] & IN_BACK || g_iButtons[iClientToShow] & IN_MOVELEFT || g_iButtons[iClientToShow] & IN_MOVERIGHT)
			{
				decl String:g_sButtons[64];

				if (g_iButtons[iClientToShow] & IN_BACK)
				{
					Format(wasBack[iClientToShow], sizeof(wasBack), "S");
				} else {
					Format(wasBack[iClientToShow], sizeof(wasBack), "-");
				}
				if (g_iButtons[iClientToShow] & IN_MOVELEFT)
				{
					Format(wasMoveLeft[iClientToShow], sizeof(wasMoveLeft), "A");
				} else {
					Format(wasMoveLeft[iClientToShow], sizeof(wasMoveLeft), "-");
				}
				if (g_iButtons[iClientToShow] & IN_MOVERIGHT)
				{
					Format(wasMoveRight[iClientToShow], sizeof(wasMoveRight), "D");
				} else {
					Format(wasMoveRight[iClientToShow], sizeof(wasMoveRight), "-");
				}
				Format(g_sButtons, sizeof(g_sButtons), "%s %s %s", wasMoveLeft[iClientToShow], wasBack[iClientToShow], wasMoveRight[iClientToShow]);
				SetHudTextParams(g_iSkeysXLoc[i] + 0.04, g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayASD, g_sButtons);
			} else {
				decl String:g_sButtons[64]; Format(g_sButtons, sizeof(g_sButtons), "- - -");
				SetHudTextParams(g_iSkeysXLoc[i]+0.04, g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayASD, g_sButtons);
			}
			if (g_iButtons[iClientToShow] & IN_DUCK)
			{
				SetHudTextParams(g_iSkeysXLoc[i]+0.1, g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayDuck, "Duck");
			}
			if (g_iButtons[iClientToShow] & IN_JUMP)
			{
				SetHudTextParams(g_iSkeysXLoc[i] + 0.1, g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayJump, "Jump");

			}
			if (g_iButtons[iClientToShow] & IN_ATTACK)
			{
				SetHudTextParams(g_iSkeysXLoc[i], g_iSkeysYLoc[i], 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayM1, "M1");

			}
			if (g_iButtons[iClientToShow] & IN_ATTACK2)
			{
				SetHudTextParams(g_iSkeysXLoc[i], g_iSkeysYLoc[i]+0.05, 0.3, g_iSkeysRed[i], g_iSkeysGreen[i], g_iSkeysBlue[i], 255, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, HudDisplayM2, "M2");

			}
			//.54 x def and .4 y def
		}
	}


}




public Action:cmdGetClientKeys(client, args)
{
/*
	if (!IsClientObserver(client))
	{
		ReplyToCommand(client, "\x01[\x03JA\x01] %t", "Showkeys_SpecOnly");
		return Plugin_Handled;
	}
*/
	if (g_bGetClientKeys[client])
	{
		g_bGetClientKeys[client] = false;
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Showkeys_Off");
	} else {
		g_bGetClientKeys[client] = true;
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Showkeys_On");
	}
	return Plugin_Handled;
}
public Action:cmdChangeSkeysColor(client, args)
{

	decl String:red[4], String:blue[4], String:green[4], String:query[512], String:steamid[32];
	if (args < 1)
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "SkeysColor_Help");
		return Plugin_Handled;
	}

	GetCmdArg(1, red, sizeof(red)), GetCmdArg(2, green, sizeof(green)), GetCmdArg(3, blue, sizeof(blue));
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	if (!IsStringNumeric(red) || !IsStringNumeric(blue) || !IsStringNumeric(green))
	{
		PrintToChat(client, "\x01[\x03JA\x01] %t", "Numeric_Invalid");
		return Plugin_Handled;
	}

	g_iSkeysRed[client] = StringToInt(red); g_iSkeysBlue[client] = StringToInt(blue); g_iSkeysGreen[client] = StringToInt(green);

	//if(!databaseConfigured)
	//{
	//	PrintToChat(client, "No database configured - cannot save key colors");
	//	return Plugin_Handled;
	//}

	//This will throw a server error but its no big deal
	Format(query, sizeof(query), "UPDATE `player_profiles` SET SKEYS_RED_COLOR=%i, SKEYS_GREEN_COLOR=%i, SKEYS_BLUE_COLOR=%i WHERE steamid = '%s'", g_iSkeysRed[client], g_iSkeysGreen[client], g_iSkeysBlue[client], steamid);
	JA_SendQuery(query, client);

	return Plugin_Handled;
}

public Action:cmdChangeSkeysLoc(client, args){
	if (args != 2)
	{
		PrintToChat(client, "\x01[\x03JA\x01] This command requires 2 arguments");
		return Plugin_Handled;
	}

	new String:arg1[16], String:arg2[16];
	new Float:xLoc, Float:yLoc;

	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	xLoc = StringToFloat(arg1);
	yLoc = StringToFloat(arg2);
	if(xLoc >= 1.0 || yLoc >= 1.0 || xLoc <= 0.0 || yLoc <= 0.0){
		PrintToChat(client, "\x01[\x03JA\x01] Both arguments must be between 0 and 1");
		return Plugin_Handled;
	}
	g_iSkeysXLoc[client] = xLoc;
	g_iSkeysYLoc[client] = yLoc;

	return Plugin_Continue;

}
