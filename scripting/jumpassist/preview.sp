float
	  g_fPreviewOrigin[MAXPLAYERS+1][3]
	, g_fPreviewAngles[MAXPLAYERS+1][3];

// ------------------ Command

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

// ------------------ Internal Functions

void EnablePreview(int client) {
	if (IsClientOnCooldown(client)) {
		PrintColoredChat(client, "[%sJA\x01] Must wait for cooldown period of%s %0.1f seconds\x01 to end.", cTheme1, cTheme2, g_cvarPreviewCooldownTime.FloatValue);
		return;
	}
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

	if (!CheckCommandAccess(client, "sm_preview_extended", ADMFLAG_RESERVATION)) {
		g_bOnPreviewCooldown[client] = true;

		CreateTimer(g_cvarPreviewTime.FloatValue, timerPreviewEnd, client);
		CreateTimer(g_cvarPreviewCooldownTime.FloatValue+g_cvarPreviewTime.FloatValue, timerPreviewCooldown, client);

		PrintColoredChat(client, "[%sJA\x01] Preview will end in\%s %0.1f seconds\x01.", cTheme1, cTheme2, g_cvarPreviewTime.FloatValue);
	}
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

bool IsClientOnCooldown(int client) {
	return g_bOnPreviewCooldown[client];
}

// ------------------ Hooks

public Action hookSetTransmitClient(int entity, int client) {
	if (IsValidClient(entity) && entity != client && IsClientPreviewing(entity) && !IsClientObserver(client)) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

// ------------------ Timers

Action timerPreviewEnd(Handle timer, int client) {
	if (IsClientPreviewing(client)) {
		DisablePreview(client, IsClientInGame(client));
	}
}

Action timerPreviewCooldown(Handle timer, int client) {
	g_bOnPreviewCooldown[client] = false;
}