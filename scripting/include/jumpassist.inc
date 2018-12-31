#if defined _jumpassist_included_
  #endinput
#endif
#define _jumpassist_included_

public SharedPlugin __pl_jumpassist = 
{
	name = "jumpassist",
	file = "jumpassist.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#define cTheme1 "\x0769cfbc"
#define cTheme2 "\x07a4e8dc"
#define cHardcore "\x07FF4500"
#define cRedTeam "\x07ff5b5b"
#define cBlueTeam "\x079bc4e8"

/**
 * Checks if client has hidden other players
 *
 * @param client		Client index
 * @return				Bool value - Is client hiding other players?
 */
native bool JA_IsClientHiding(int client);

/**
 * Checks if client has hardcore enabled
 *
 * @param client		Client index
 * @return				Bool value - Is client in hardcore mode?
 */
native bool JA_IsClientHardcore(int client);

/**
 * Checks if client is racing
 *
 * @param client		Client index
 * @return				Bool value - Is client racing?
 */
native bool JA_IsClientRacing(int client);

/**
 * Formats class as a string
 *
 * @param class			Class index
 * @param className		Char array to format
 * @noreturn
 */
native void JA_GetClassName(char[] className, int size, TFClassType class);

/**
 * Toggles use of skeys
 *
 * @param client		client index
 * @param enable		True to enable, false to disable;
 * @noreturn
 */
native void JA_ToggleKeys(int client, bool enable);

/**
 * Called when a client's show keys are about to be set
 *
 * @param client		Client index
 * @param buttons		Client button flags
 * @return				Plugin_Changed to change display
 * 						Plugin_Handled to prevent display
 * 						Plugin_Continue to resume
 */
forward Action OnClientKeys(int client, int &buttons);

//public __pl_jumpassist_SetNTVOptional() {
//}