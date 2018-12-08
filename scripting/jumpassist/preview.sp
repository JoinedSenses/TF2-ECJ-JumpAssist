/* ======================================================================
   ------------------------------- Global Vars
*/

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
		PrintColoredChat(client, "[%sJA\x01] Can't use this feature while racing.", cTheme1);
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
		PrintColoredChat(client, "[%sJA\x01] Can't begin preview mode while%s in the air\x01.", cTheme1, cTheme2);
		return;
	}
	if ((flags & FL_DUCKING)) {
		PrintColoredChat(client, "[%sJA\x01] Can't begin preview mode while%s ducking\x01.", cTheme1, cTheme2);
		return;
	}

	GetClientAbsOrigin(client, g_fPreviewOrigin[client]);
	GetClientAbsAngles(client, g_fPreviewAngles[client]);

	SetEntityMoveType(client, MOVETYPE_NOCLIP);
	SetEntityFlags(client, flags|FL_DONTTOUCH|FL_NOTARGET|FL_FLY);

	g_bIsPreviewing[client] = true;

	PrintColoredChat(client, "[%sJA\x01] Preview mode%s enabled\x01.", cTheme1, cTheme2);
}

void DisablePreview(int client, bool restore = false) {
	g_bIsPreviewing[client] = false;

	if (restore) {
		int flags = GetEntityFlags(client);
		TeleportEntity(client, g_fPreviewOrigin[client], g_fPreviewAngles[client], nullVector);

		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityFlags(client, flags & ~(FL_DONTTOUCH|FL_NOTARGET|FL_FLY));
	}
	if (IsClientInGame(client)) {
		PrintColoredChat(client, "[%sJA\x01] Preview mode%s disabled\x01.", cTheme1, cTheme2);
	}
}

bool IsClientPreviewing(int client) {
	return g_bIsPreviewing[client];
}

/* ======================================================================
   ------------------------------- Hooks
*/

public Action hookSetTransmitClient(int entity, int client) {
	if (IsValidClient(entity) && entity != client && IsClientPreviewing(entity) && !IsClientObserver(client)) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}