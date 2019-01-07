bool
	  g_bHide[MAXPLAYERS+1]
	, g_bHooked
	, g_bIntelPickedUp;
ConVar
	  g_cvarExplosions;

//Sounds to block.  
char g_sSoundHook[][] = {
	"regenerate",
	"ammo_pickup",
	"pain",
	"fall_damage",
	"grenade_jump",
	"fleshbreak"
};

//Entities to get m_hOwnerEntity net prop for
char g_sOwnerList[][] = {
	"projectile_rocket",
	"projectile_energy_ball",
	"weapon",
	"wearable",
	// conc uses prop_physics
	"prop_physics"
};

//Entities to hide.
char g_sGeneralList[][] = {
	"projectile",
	"tf_ammo_pack"
};

/* ======================================================================
   ------------------------------- SM API
*/

public void OnClientDisconnect_Post(int client) {
    g_bHide[client] = false;
    g_bHooked = checkHooks();
}

public void OnEntityCreated(int entity, const char[] classname) {
	if (StrContains(classname, "tf_projectile_pipe") != -1) {
		SDKHook(entity, SDKHook_SetTransmit, hookSetTransmitPipes);
		return;
	}

	for (int i = 0; i < sizeof(g_sOwnerList); i++) {
		if (StrContains(classname, g_sOwnerList[i]) != -1) {
			SDKHook(entity, SDKHook_SetTransmit, hookSetTransmitOwnerEntity);
			return;
		}
	}

	//Find owner of vgui screen and sentry rockets, which will be the sentry or dispenser.		
	if (StrContains(classname, "vgui_screen") != -1 || StrContains(classname, "sentryrocket") != -1) {
		int building;
		if ((building = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")) < 1) {
			return;
		}
		char className2[32];
		GetEntityClassname(building, className2, sizeof(className2));
		if (StrContains(className2, "obj_") != -1) {
			SDKHook(entity, SDKHook_SetTransmit, hookSetTransmitObjects);
			return;
		}
	}

	for (int i = 0; i < sizeof(g_sGeneralList); i++) {
		if (StrContains(classname, g_sGeneralList[i]) != -1) {
			SDKHook(entity, SDKHook_SetTransmit, hookSetTransmitProjectiles);
			return;
		}
	}

	//Touch hook on Engineer buildings.
	if (StrContains(classname, "obj_") == 0) {
		SDKHook(entity, SDKHook_StartTouch, hookTouch);
		SDKHook(entity, SDKHook_Touch, hookTouch);
		SDKHook(entity, SDKHook_SetTransmit, hookSetTransmitObjects);
		return;
	}

	//Seperate hook for particles.
	if (StrEqual(classname, "info_particle_system")) {
		SDKHook(entity, SDKHook_SetTransmit, hookSetTransmitParticle);
		return;
	}

	if (StrEqual(classname, "teamflag")) {
		SDKHook(entity, SDKHook_SetTransmit, hookSetTransmitIntel);
		return;
	}
}

/* ======================================================================
   ------------------------------- Commands
*/

public Action cmdHide(int client, int args) {
	g_bHide[client] = !g_bHide[client];
	g_bHooked = checkHooks();
	PrintColoredChat(client, "[%sJA\x01] Other players are now%s %s\x01.", cTheme1, cTheme2, g_bHide[client] ? "hidden" : "visible");
	return Plugin_Handled;
}

/* ======================================================================
   ------------------------------- Hooks
*/

public Action hookSound(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed) {
	//Block sounds within g_sSoundHook list.
	for (int i = 0; i < sizeof(g_sSoundHook); i++) {
		if (StrContains(sample, g_sSoundHook[i], false) != -1) {
			return Plugin_Stop; 
		}
	}

	for (int i = 0; i < numClients; i++) {
		int client = clients[i];
		if (IsClientPreviewing(client) && entity == client) {
			return Plugin_Stop;
		}
	}

	if (!g_bHooked) {
		return Plugin_Continue;
	}

	char className[32];
	GetEntityClassname(entity, className, sizeof(className));

	int owner;
	if (StrContains(className, "obj_") != -1) {
		owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	}
	else if (StrEqual(className, "prop_physics")) {
		owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	}

	for (int i = 0; i < numClients; i++) {
		int client = clients[i];
		if (IsValidClient(client) && IsClientHiding(client) && client != entity && client != owner && g_iClientTeam[client] != 1) {
			//Remove the client from the array if they have hide toggled, if they are not the creator of the sound, and if they are not in spectate.
			for (int j = i; j < numClients-1; j++) {
				clients[j] = clients[j+1];
			}
			numClients--;
			i--;
		}
	}

	return (numClients > 0) ? Plugin_Changed : Plugin_Stop;
}

public Action hookSetTransmitClient(int entity, int client) {
	setFlags(entity);
	//Transmit hook on player models.
	if ((entity != client && (IsClientHiding(client) || IsClientPreviewing(entity)) && g_iClientTeam[client] > 1)) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action hookSetTransmitPipes(int entity, int client) {
	if (!IsClientHiding(client) || g_iClientTeam[client] == 1) {
		return Plugin_Continue;
	}

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
	return (owner == client) ? Plugin_Continue : Plugin_Handled;
}

public Action hookSetTransmitOwnerEntity(int entity, int client) {
	setFlags(entity);
	if (!IsClientHiding(client) || g_iClientTeam[client] == 1) {
		return Plugin_Continue;
	}
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	return (owner == client) ? Plugin_Continue : Plugin_Handled;
}

public Action hookSetTransmitObjects(int entity, int client) {
	if (!IsClientHiding(client) || g_iClientTeam[client] == 1) {
		return Plugin_Continue;
	}

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	return (owner == client) ? Plugin_Continue : Plugin_Handled;
}

public Action hookSetTransmitProjectiles(int entity, int client) {
	if (!IsClientHiding(client) || g_iClientTeam[client] == 1) {
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public Action hookSetTransmitParticle(int entity, int client) {
	setFlags(entity);
	return Plugin_Continue;
}

public Action hookSetTransmitIntel(int entity, int client) {
	setFlags(entity);
	if (!IsClientHiding(client) || g_iClientTeam[client] == 1) {
		return Plugin_Continue;
	}
	return g_bIntelPickedUp ? Plugin_Handled : Plugin_Continue;
}

public Action hookTempEnt(const char[] te_name, const int[] players, int numClients, float delay) {
	if (g_cvarExplosions.BoolValue) {
		//Remove explosion, blood, and cow mangler temp ents from game.
		if (StrEqual(te_name, "TFExplosion") || StrEqual(te_name, "TFBlood")) {
			return Plugin_Handled;
		}
		else if (StrContains(te_name, "ParticleEffect") != -1) {
			switch (TE_ReadNum("m_iParticleSystemIndex")) {
				case 1138, 1147, 1153, 1154: {
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action hookTouch(int entity, int other) {
	//If valid client and hide is toggled, prevent them from touching buildings
	if (0 < other <= MaxClients && IsClientHiding(other)) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

/* ======================================================================
   ------------------------------- Internal Functions
*/

bool checkHooks() {	
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i) && g_bHide[i]) {
			return true;
		}
	}
	//Fake (un)hook because toggling actual hooks will cause server instability.
	return false;
}

void setFlags(int edict) {
	//Function for allowing transmit hook for entities set to always transmit
	if (GetEdictFlags(edict) & FL_EDICT_ALWAYS) {
		SetEdictFlags(edict, (GetEdictFlags(edict) & ~FL_EDICT_ALWAYS));
	}
}

bool IsClientHiding(int client) {
	return g_bHide[client];
}