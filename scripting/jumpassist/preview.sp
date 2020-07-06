enum {
	HIDEHUD_WEAPONSELECTION = (1<<1),
	HIDEHUD_FLASHLIGHT = (1<<2),
	HIDEHUD_ALL = (1<<3),
	HIDEHUD_HEALTH = (1<<4),
	HIDEHUD_PLAYERDEAD = (1<<5),
	HIDEHUD_NEEDSUIT = (1<<6),
	HIDEHUD_MISCSTATUS = (1<<7),
	HIDEHUD_CHAT = (1<<8),
	HIDEHUD_CROSSHAIR = (1<<9),
	HIDEHUD_VEHICLE_CROSSHAIR = (1<<10),
	HIDEHUD_INVEHICLE = (1<<11),
	HIDEHUD_BONUS_PROGRESS = (1<<12)
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

void EnablePreview(int client) {
	int flags = GetEntityFlags(client);
	if (!(flags & FL_ONGROUND)) {
		PrintJAMessage(client, "Can't begin preview mode while"...cTheme2..." in the air\x01.");
		return;
	}

	if ((flags & FL_DUCKING)) {
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

bool IsClientPreviewing(int client) {
	return g_bIsPreviewing[client];
}

/* ======================================================================
   ------------------------------- Hooks
*/

public Action hookWeaponSwitch(int client, int weapon) {
	return Plugin_Handled;
}