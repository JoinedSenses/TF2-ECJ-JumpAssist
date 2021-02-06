/*
 * Preview is a feature which allows clients to noclip.
 * While in this state:
 * - HUD is disabled
 * - Viewmodel visibility is disabled
 * - Attacking and weapon switching is disabled
 * - Invisible to other players who are alive
 * - Many JumpAssist features are disabled, such as saving
 */



float g_fPreviewOrigin[MAXPLAYERS+1][3];
float g_fPreviewAngles[MAXPLAYERS+1][3];

/* ======================================================================
   ------------------------------- Commands
*/

public Action cmdPreview(int client, int args) {
	if (!client || !IsPlayerAlive(client)) {
		PrintJAMessage(client, "Must be"...cTheme2..." alive\x01 to use this feature.");
		return Plugin_Handled;
	}

	if (IsClientRacing(client)) {
		PrintJAMessage(client, "Can't use this feature while"...cTheme2..." racing\x01.");
		return Plugin_Handled;
	}

	if (IsClientPreviewing(client)) {
		DisablePreview(client, true);
	}
	else {
		EnablePreview(client);
	}

	return Plugin_Handled;
}

/* ======================================================================
   ------------------------------- Functions
*/

/**
 * Purpose: Enable preview mode on a specific client
 * 
 * @param client       Client index
 */
void EnablePreview(int client) {
	int flags = GetEntityFlags(client);

	if (!(flags & FL_ONGROUND)) {
		PrintJAMessage(client, "Can't begin preview mode while"...cTheme2..." in the air\x01.");
		return;
	}

	if (flags & FL_DUCKING) {
		PrintJAMessage(client, "Can't begin preview mode while"...cTheme2..." ducking\x01.");
		return;
	}

	GetClientAbsOrigin(client, g_fPreviewOrigin[client]);
	GetClientAbsAngles(client, g_fPreviewAngles[client]);

	SetEntityMoveType(client, MOVETYPE_NOCLIP);
	SetEntityFlags(client, flags|FL_DONTTOUCH|FL_NOTARGET|FL_FLY);

	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()+9999999.0);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);

	SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_HEALTH|HIDEHUD_MISCSTATUS); 

	SDKHook(client, SDKHook_WeaponSwitch, hookWeaponSwitch);

	g_bIsPreviewing[client] = true;

	PrintJAMessage(client, "Preview mode"...cTheme2..." enabled\x01.");
}

/**
 * Purpose: Disable preview mode on a specific client
 * 
 * @param client       Client index
 * @param restore      Set to true to restore state prior to preview mode being enabled
 * @param click        Set to true if preview mode disabled due to player clicking mouse
 */
void DisablePreview(int client, bool restore = false, bool click = false) {
	g_bIsPreviewing[client] = false;

	if (restore) {
		int flags = GetEntityFlags(client);
		TeleportEntity(client, g_fPreviewOrigin[client], g_fPreviewAngles[client], EMPTY_VECTOR);

		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityFlags(client, flags & ~(FL_DONTTOUCH|FL_NOTARGET|FL_FLY));

		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()+(click?1.0:0.0)); 

		SDKUnhook(client, SDKHook_WeaponSwitch, hookWeaponSwitch);
	}
	
	if (IsClientInGame(client)) {
		PrintJAMessage(client, "Preview mode"...cTheme2..." disabled\x01.");
	}
}

/**
 * Purpose: Checks if client is currently in preview state
 * 
 * @param client       Client index
 * @return             True if preview state enabled, else false
 */
bool IsClientPreviewing(int client) {
	return g_bIsPreviewing[client];
}

/* ======================================================================
   ------------------------------- Hooks
*/

// Hooked during preview state, preventing client from switching weapons.
public Action hookWeaponSwitch(int client, int weapon) {
	return Plugin_Handled;
}