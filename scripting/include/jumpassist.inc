#if defined _jumpassist_included_
  #endinput
#endif
#define _jumpassist_included_

#define cTheme1 "\x0769cfbc"
#define cTheme2 "\x07a4e8dc"
#define cHardcore "\x07FF4500"
#define cRedTeam "\x07ff5b5b"
#define cBlueTeam "\x079bc4e8"

/**
 * Checks if client has hidden other players
 *
 * @param client                Client index
 * @return                      True if client is hiding players, else false
 */
native bool JA_IsClientHiding(int client);

/**
 * Checks if client has hardcore enabled
 *
 * @param client                Client index
 * @return                      True if client has hardcore enabled, else false
 */
native bool JA_IsClientHardcore(int client);

/**
 * Checks if client is racing
 *
 * @param client                Client index
 * @return                      True if client is racing, else false
 */
native bool JA_IsClientRacing(int client);

/**
 * Toggles use of skeys
 *
 * @param client                Client index
 * @param enable                True to enable, false to disable;
 */
native void JA_ToggleKeys(int client, bool enable);

/**
 * Interupts teleporting caused by respawn for 5 seconds.
 * Best results if paired with TF2_RespawnPlayer()
 *
 * @param client                client index
 */
native void JA_PauseTeleport(int client);

/**
 * Sends a jumpassist message to a target
 *
 * @param client                client index
 * @param format                formatting rules
 * @param any                   Variable number of format parameters.
 */
native void JA_PrintMessage(int client, char[] format, any ...);

/**
 * Sends a jumpassist message to all clients
 *
 * @param format                formatting rules
 * @param any                   Variable number of format parameters.
 */
native void JA_PrintMessageAll(char[] format, any...);

/**
 * Called when a client's show keys are about to be set
 *
 * @param client                Client index
 * @param buttons               Client button flags
 * @return                      Plugin_Changed to change display
 *                              Plugin_Handled/Stop to prevent display
 *                              Plugin_Continue to resume
 */
forward Action OnClientKeys(int client, int &buttons);

public SharedPlugin __pl_jumpassist = {
	name = "jumpassist",
	file = "jumpassist.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_jumpassist_SetNTVOptional() {
	MarkNativeAsOptional("JA_IsClientHiding");
	MarkNativeAsOptional("JA_IsClientHardcore");
	MarkNativeAsOptional("JA_IsClientRacing");
	MarkNativeAsOptional("JA_ToggleKeys");
	MarkNativeAsOptional("JA_PauseTeleport");
}
#endif
