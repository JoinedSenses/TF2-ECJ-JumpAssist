#if defined _saveloc_included_
  #endinput
#endif
#define _saveloc_included_

#define MAX_RECENT_LOCS 14
#define CUSTOMCOLOR1 "\x0769cfbc"
#define CUSTOMCOLOR2 "\x07a4e8dc"
#define DEFAULTCOLOR "\x03"
#define MESSAGETAG "[%sSL\x01] "

/**
 * Returns if client has practice mode enabled
 * 
 * @param client		Client index
 * @return				True if enabled, else false
 */
native bool SL_IsClientPracticing(int client);

/**
 * Disables practice mode on a client
 * 
 * @param client		Client index
 * @noreturn
 */
native void SL_DisablePractice(int client, bool clearSaves = false);

/**
 * Returns how many saves client has
 *
 * @param client		Client index
 * @return				(0 - MAX_RECENT_LOCS).
 */
native int SL_GetClientTotalCount(int client);

/**
 * Returns which save loc num the client is using
 *
 * @param client		Client index
 * @return				Save loc num as an index (Range: 0, MAX_RECENT_LOCS-1). -1 if no current
 */
native int SL_GetClientCurrentIndex(int client);

/**
 * Returns client's current stored position
 *
 * @param client		Client index
 * @param origin		Origin
 * @param angles		Eye angles
 * @param velocity		Velocity
 * @return				Save loc num as an index (Range: 0, MAX_RECENT_LOCS-1). -1 if no current
 */
native int SL_GetClientCurrentSave(int client, float origin[3], float angles[3], float velocity[3], float &time = 0.0);

/**
 * Returns client's stored position at a specific index
 *
 * @param client		Client index
 * @param index			Index to use (Range: 0, MAX_RECENT_LOCS-1)
 * @param origin		Origin
 * @param angles		Eye angles
 * @param velocity		Velocity
 * @return				True if retrieved, else false
 */
native bool SL_GetClientSaveAtIndex(int client, int index, float origin[3], float angles[3], float velocity[3], float &time = 0.0);

/**
 * Insert a save into the cliends recent saves
 *
 * @param client		Client index
 * @param origin		Origin
 * @param angles		Eye angles
 * @param velocity		Velocity
 * @param time			(Optional) Server local time in seconds
 * @return				Total number of saves
 */
native int SL_AddToSaves(int client, float origin[3], float angles[3], float velocity[3], float time = 0.0);

/**
 * Clears all of a clients saves
 * These are automatically removed on new client connect or map change
 *
 * @param client		Client index
 * @noreturn
 */
native void SL_ClearAllSaves(int client);

/**
 * Called just as a client is about to toggle practice mode
 *
 * @param client		Client index
 * @return				Plugin_Handled to prevent saving
 * 						Plugin_Continue to resume
 */
forward Action SL_OnPracticeToggle(int client);

/**
 * Called just before client loc data is about to be saved
 *
 * @param client		Client index
 * @param origin		Client origin
 * @param angles		Client eye angles
 * @param velocity		Client velocity
 * @param time			Server local time when they called sm_sl in seconds
 * @return				Plugin_Handled to prevent saving
 * 						Plugin_Continue to resume
 */
forward Action SL_OnSaveLoc(int client, float origin[3], float angles[3], float velocity[3], float time);

/**
 * Called just before client is about to teleport
 *
 * @param client		Client index
 * @return				Plugin_Handled to prevent saving
 * 						Plugin_Continue to resume
 */
forward Action SL_OnTeleLoc(int client);


stock bool GetClientAbsVelocity(int client, float velocity[3]) {
	static int offset = -1;
	
	if (offset == -1 && (offset = FindDataMapInfo(client, "m_vecAbsVelocity")) == -1) {
		ZeroVector(velocity);
		return false;
	}
	
	GetEntDataVector(client, offset, velocity);
	return true;
}

stock void ZeroVector(float vec[3]) {
	vec[0] = vec[1] = vec[2] = 0.0;
}

public SharedPlugin __pl_saveloc = {
	name = "saveloc",
	file = "saveloc.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_saveloc_SetNTVOptional() {
	MarkNativeAsOptional("SL_IsClientPracticing");
	MarkNativeAsOptional("SL_DisablePractice");
}
#endif