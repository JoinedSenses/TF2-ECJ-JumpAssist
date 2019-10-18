enum (<<=1) {
	HIDEHUD_WEAPONSELECTION = 1,
	HIDEHUD_FLASHLIGHT,
	HIDEHUD_ALL,
	HIDEHUD_HEALTH,
	HIDEHUD_PLAYERDEAD,
	HIDEHUD_NEEDSUIT,
	HIDEHUD_MISCSTATUS,
	HIDEHUD_CHAT,
	HIDEHUD_CROSSHAIR,
	HIDEHUD_VEHICLE_CROSSHAIR,
	HIDEHUD_INVEHICLE,
	HIDEHUD_BONUS_PROGRESS
}

float
	  g_fPreviewOrigin[MAXPLAYERS+1][3]
	, g_fPreviewAngles[MAXPLAYERS+1][3];

/* ======================================================================
   ------------------------------- Commands
*/

public Action cmdPreview(int client, int args) {
	if (!IsValidClient(client) || !IsPlayerAlive(client)) {
		return Plugin_Handled;
	}

	if (IsClientRacing(client)) {
		PrintJAMessage(client, "Can't use this feature while%s racing.", cTheme2);
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

void EnablePreview(int client) {
	int flags = GetEntityFlags(client);
	if (!(flags & FL_ONGROUND)) {
		PrintJAMessage(client, "Can't begin preview mode while%s in the air\x01.", cTheme2);
		return;
	}

	if ((flags & FL_DUCKING)) {
		PrintJAMessage(client, "Can't begin preview mode while%s ducking\x01.", cTheme2);
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

	PrintJAMessage(client, "Preview mode%s enabled\x01.", cTheme2);
}

void DisablePreview(int client, bool restore = false, bool click = false) {
	g_bIsPreviewing[client] = false;

	if (restore) {
		int flags = GetEntityFlags(client);
		TeleportEntity(client, g_fPreviewOrigin[client], g_fPreviewAngles[client], EmptyVector());

		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityFlags(client, flags & ~(FL_DONTTOUCH|FL_NOTARGET|FL_FLY));

		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()+(click?1.0:0.0)); 

		SDKUnhook(client, SDKHook_WeaponSwitch, hookWeaponSwitch);
	}
	
	if (IsClientInGame(client)) {
		PrintJAMessage(client, "Preview mode%s disabled\x01.", cTheme2);
	}
}

bool IsClientPreviewing(int client) {
	return g_bIsPreviewing[client];
}

/* ======================================================================
   ------------------------------- Hooks
*/

public Action hookWeaponSwitch(int client, int weapon) {
	return Plugin_Handled;
}