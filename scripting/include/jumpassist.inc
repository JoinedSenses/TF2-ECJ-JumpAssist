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
 * Formats client's class as a string
 *
 * @param class			Class index
 * @param className		Char array to format
 * @noreturn
 */
native void JA_GetClassName(TFClassType class, char[] className, int size);

//public __pl_jumpassist_SetNTVOptional() {
//}