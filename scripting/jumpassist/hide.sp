bool
	g_bHide[MAXPLAYERS+1],
	g_bHooked,
	g_bIntelPickedUp;

//Sounds to block.  
char g_sSoundHook[][] = {
	"regenerate",
	"ammo_pickup",
	"pain",
	"fall_damage",
	"grenade_jump",
	"fleshbreak",
	"drown"
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
    CheckHooks();
}

public void OnEntityCreated(int entity, const char[] classname) {
	if (StrContains(classname, "tf_projectile_pipe") != -1) {
		SDKHook(entity, SDKHook_SetTransmit, hookSetTransmitPipes);
		return;
	}

	for (int i = 0; i < sizeof(g_sOwnerList); ++i) {
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

	for (int i = 0; i < sizeof(g_sGeneralList); ++i) {
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
	CheckHooks();
	PrintJAMessage(client, "Other players are now"...cTheme2..." %s\x01.", g_bHide[client] ? "hidden" : "visible");
	return Plugin_Handled;
}

/* ======================================================================
   ------------------------------- Hooks
*/

public Action hookSound(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity,
		int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed) {
	//Block sounds within g_sSoundHook list.
	for (int i = 0; i < sizeof(g_sSoundHook); ++i) {
		if (StrContains(sample, g_sSoundHook[i], false) != -1) {
			return Plugin_Stop; 
		}
	}

	// stop sounds coming from clients in preview mode.
	for (int i = 0; i < numClients; ++i) {
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

	for (int i = 0; i < numClients; ++i) {
		int client = clients[i];
		if (!IsClientInGame(client)
		|| (IsValidClient(client)
			&& g_bHide[client]
			&& client != entity
			&& client != owner
			&& g_iClientTeam[client] != 1
		)) {
			//Remove the client from the array if they have hide toggled,
			// if they are not the creator of the sound,
			// and if they are not in spectate.
			for (int j = i; j < numClients-1; ++j) {
				clients[j] = clients[j+1];
			}
			numClients--;
			i--;
		}
	}

	return (numClients > 0) ? Plugin_Changed : Plugin_Stop;
}

public Action hookSetTransmitClient(int entity, int client) {
	SetFlags(entity);
	//Transmit hook on player models.
	if (entity != client && (g_bHide[client] || IsClientPreviewing(entity)) && g_iClientTeam[client] > 1) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action hookSetTransmitPipes(int entity, int client) {
	if (g_bHide[client] && g_iClientTeam[client] > 1
	&& GetEntPropEnt(entity, Prop_Send, "m_hThrower") != client) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action hookSetTransmitOwnerEntity(int entity, int client) {
	SetFlags(entity);

	if (g_bHide[client] && g_iClientTeam[client] > 1
	&& GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action hookSetTransmitObjects(int entity, int client) {
	if (g_bHide[client] && g_iClientTeam[client] > 1
	&& GetEntPropEnt(entity, Prop_Send, "m_hBuilder") != client) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action hookSetTransmitProjectiles(int entity, int client) {
	if (g_bHide[client] && g_iClientTeam[client] > 1) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action hookSetTransmitParticle(int entity, int client) {
	SetFlags(entity);
	return Plugin_Continue;
}

public Action hookSetTransmitIntel(int entity, int client) {
	SetFlags(entity);

	if (g_bIntelPickedUp && IsClientHiding(client) && g_iClientTeam[client] > 1) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

// Remove explosion, blood, and cow mangler temp ents from game.
public Action hookTempEnt(const char[] te_name, const int[] players, int numClients, float delay) {
	if (StrEqual(te_name, "TFBlood")) {
		return Plugin_Stop;
	}

	if (StrEqual(te_name, "TFExplosion")) {
		static bool sending = false;
		if (sending) { // Ignore the TE we just sent
			sending = false;
			return Plugin_Continue;
		}

		int[] clients = new int[numClients];
		int idx = 0;
		for (int i = 0; i < numClients; ++i) {
			int client = players[i];
			if (g_bExplosions[client]) {
				clients[idx++] = client;
			}
		}

		if (idx) {
			sending = true;

			// Create new TE with same info and send to modified list
			float origin[3];
			TE_ReadVector("m_vecOrigin[0]", origin);

			float normal[3];
			TE_ReadVector("m_vecNormal", normal);

			int weaponID = TE_ReadNum("m_iWeaponID");
			int entIndex = TE_ReadNum("entindex");
			int defID = TE_ReadNum("m_nDefID");
			int sound = TE_ReadNum("m_nSound");
			int customParticleIndex = TE_ReadNum("m_iCustomParticleIndex");

			// sm_dump_teprops
			TE_Start("TFExplosion");
			TE_WriteVector("m_vecOrigin[0]", origin);
			TE_WriteVector("m_vecNormal", normal);
			TE_WriteNum("m_iWeaponID", weaponID);
			TE_WriteNum("entindex", entIndex);
			TE_WriteNum("m_nDefID", defID);
			TE_WriteNum("m_nSound", sound);
			TE_WriteNum("m_iCustomParticleIndex", customParticleIndex);
			TE_Send(clients, idx);
		}

		return Plugin_Stop;
	}

	if (StrEqual(te_name, "TFParticleEffect")) {
		// 1137: drg_cow_explosioncore_normal
		// 1146: drg_cow_explosioncore_charged
		// 1152: drg_cow_explosioncore_charged_blue
		// 1153: drg_cow_explosioncore_normal_blue
		switch (TE_ReadNum("m_iParticleSystemIndex")) {
			case 1137, 1146, 1152, 1153: {
				return Plugin_Stop;
			}
		}
	}

	return Plugin_Continue;
}

public Action hookTouch(int entity, int other) {
	if (0 < other <= MaxClients && IsClientHiding(other)) {
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}


/* ======================================================================
   ------------------------------- Internal Functions
*/

bool CheckHooks() {	
	for (int i = 1; i <= MaxClients; ++i) {
		if (IsClientInGame(i) && g_bHide[i]) {
			g_bHooked = true;
			return;
		}
	}

	g_bHooked = false;
}

void SetFlags(int edict) {
	//Function for allowing transmit hook for entities set to always transmit
	if (GetEdictFlags(edict) & FL_EDICT_ALWAYS) {
		SetEdictFlags(edict, (GetEdictFlags(edict) & ~FL_EDICT_ALWAYS));
	}
}

bool IsClientHiding(int client) {
	return g_bHide[client];
}
