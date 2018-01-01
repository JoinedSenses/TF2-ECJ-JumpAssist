#undef REQUIRE_PLUGIN
//#include <skillsrank>
#define REQUIRE_PLUGIN

new bool:skillsrank = false;

public IsPlayerBusy(client)
{
	PrintToServer("Is client %i busy? FALSE", client);
	return false;
}