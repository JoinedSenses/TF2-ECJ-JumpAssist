/** Double-include prevention */
#if defined _jumpassist_included_
  #endinput
#endif
#define _jumpassist_included_

public SharedPlugin:__pl_jumpassist = 
{
	name = "jumpassist",
	file = "jumpassist.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

public __pl_jumpassist_SetNTVOptional()
{
	MarkNativeAsOptional("JA_GetSettings");
	MarkNativeAsOptional("JA_PrepSpeedRun");
	MarkNativeAsOptional("JA_ClearSave");
	MarkNativeAsOptional("JA_ReloadPlayerSettings");
}
/*
	@param			client index
	@return			Status of the clients supermans effect.
*/
native bool:JA_Superman(client);
/*
	@param			client index
	@noreturn
*/
native bool:JA_GotoClient(client);
/*
	@param			(1 map class setting, 2 ammo, 3 health)
	@param			client
	
	JA_GetSettings(1, -1) for getting the map class
	JA_GetSettings(2, client) for regen. replace 2 with 3 for health.
*/
native bool:JA_GetSettings(Setting, client);

/*
	@param			client index

	clears the save of the client supplied.
*/
native bool:JA_ClearSave(client);

/*
	@param			client

	Preps the user for a speed run.
*/
native bool:JA_PrepSpeedRun(client);

/*
	@param			client
	
	Reload the players stored settings.
*/
native bool:JA_ReloadPlayerSettings(client);

forward OnProfileLoaded(client, red, green, blue);