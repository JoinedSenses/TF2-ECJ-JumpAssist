#if defined _jslib_included_
  #endinput
#endif
#define _jslib_included_

// --------------

#define EMPTY_VECTOR view_as<float>({0,0,0})

enum {
	TEAM_UNASSIGNED = 0,
	TEAM_SPECTATOR,
	TEAM_RED,
	TEAM_BLUE
}

enum {
	INTEL_PICKEDUP = 1,
	INTEL_CAPTURED,
	INTEL_DEFENDED,
	INTEL_DROPPED,
	INTEL_RETURNED
}

#define HIDEHUD_WEAPONSELECTION   (1<<0)
#define HIDEHUD_FLASHLIGHT        (1<<1)
#define HIDEHUD_ALL               (1<<2)
#define HIDEHUD_HEALTH            (1<<3)
#define HIDEHUD_PLAYERDEAD        (1<<4)
#define HIDEHUD_NEEDSUIT          (1<<5)
#define HIDEHUD_MISCSTATUS        (1<<6)
#define HIDEHUD_CHAT              (1<<7)
#define HIDEHUD_CROSSHAIR         (1<<8)
#define HIDEHUD_VEHICLE_CROSSHAIR (1<<9)
#define HIDEHUD_INVEHICLE         (1<<10)
#define HIDEHUD_BONUS_PROGRESS    (1<<11)


/**
 * Purpose: Checks if a 3D vector equals {0.0, 0.0, 0.0}.
 * 
 * @param vector       The 3D vector to check against
 * @return             True if empty, else false
 */
stock bool IsEmptyVector(float vector[3]) {
	return !vector[0] && !vector[1] && !vector[2];
}

/**
 * Purpose: Return absolute value of an integer
 * 
 * @param value       The value to check against
 */
stock int Abs(int value) {
    int mask = value >> 31;
    return (value + mask) ^ mask;
}

/**
 * Purpose: Return absolute value of a floating point value
 * 
 * @param value       The value to check against
 */
stock float AbsF(float value) {
   return view_as<float>(view_as<int>(x) & ~cellmin);
}

/**
 * Purpose: Clamp an int value to inclusive range [min, max].
 * Assumes that min is less than max.
 * 
 * @param value        The value to check against
 * @param min          Minimum boundary
 * @param max          Maximum boundary
 * @return             Value if within bounds, else boundary extrema
 */
stock int Clamp(int value, int min, int max) {
	if (value > max) {
		return max;
	}
	
	if (value < min) {
		return min;
	}

	return value;
}

/**
 * Purpose: Clamp a float value to inclusive range [min, max].
 * Assumes that min is less than max.
 * 
 * @param value        The value to check against
 * @param min          Minimum boundary
 * @param max          Maximum boundary
 * @return             Value if within bounds, else boundary extrema
 */
stock float ClampF(float value, float min, float max) {
	if (value > max) {
		return max;
	}
	
	if (value < min) {
		return min;
	}

	return value;
}

/**
 * Purpose: Searches for a client by name.
 * Differs from FindTarget in that it doesn't call ReplyToTargetError().
 * 
 * @param client       Client index of player searching for target
 * @param target       The search string of the target's name
 * @param nobots       Set to true to exclude bots
 * @param immunity     Set to false to ignore immunity
 * @return             Target index if found, else -1
 */
stock int FindTargetEx(int client, const char[] target, bool nobots = false, bool immunity = true) {
	int flags = COMMAND_FILTER_NO_MULTI;

	if (nobots) {
		flags |= COMMAND_FILTER_NO_BOTS;
	}

	if (!immunity) {
		flags |= COMMAND_FILTER_NO_IMMUNITY;
	}

	char target_name[MAX_TARGET_LENGTH];
	int target_list[1];
	bool tn_is_ml;

	if ((ProcessTargetString(target, client, target_list, 1, flags, target_name, sizeof(target_name), tn_is_ml)) > 0) {
		return target_list[0];
	}

	return -1;
}

/**
 * Purpose: Allows for changing the ammo count for the specific client and weapon
 * 
 * @param client         Client index
 * @param weapon         Weapon entity
 * @param ammo           New ammo count
 */
stock void SetPrimaryAmmo(int client, int weapon, int ammo) {
	int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammoType != -1) {
		SetEntProp(client, Prop_Data, "m_iAmmo", ammo, _, ammoType);
	}
}

/**
 * Purpose: Retrieves the string name of a class based on TFClassType
 * 
 * @param class     The class to retrieve name of
 * @param buffer    Destination string buffer
 * @param size      Length of destination buffer, including null terminator
 */
stock void GetClassName(TFClassType class, char[] buffer, int size) {
	switch(class) {
		case TFClass_Scout:    strcopy(buffer, size, "Scout");
		case TFClass_Sniper:   strcopy(buffer, size, "Sniper");
		case TFClass_Soldier:  strcopy(buffer, size, "Soldier");
		case TFClass_DemoMan:  strcopy(buffer, size, "Demoman");
		case TFClass_Medic:    strcopy(buffer, size, "Medic");
		case TFClass_Heavy:    strcopy(buffer, size, "Heavy");
		case TFClass_Pyro:     strcopy(buffer, size, "Pyro");
		case TFClass_Spy:      strcopy(buffer, size, "Spy");
		case TFClass_Engineer: strcopy(buffer, size, "Engineer");
	}
}