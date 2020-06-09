#include "Gamemode.as"
#include "CTF.as"

shared GamemodeManager@ getGamemodeManager()
{
	CRules@ rules = getRules();

	GamemodeManager@ gamemodeManager;
	if (rules.get("gamemode_manager", @gamemodeManager))
	{
		return gamemodeManager;
	}

	@gamemodeManager = GamemodeManager();
	rules.set("gamemode_manager", gamemodeManager);
	return gamemodeManager;
}

shared class GamemodeManager
{
	private Gamemode@ gamemode = CTF();

	Gamemode@ getGamemode()
	{
		return gamemode;
	}

	void SetGamemode(Gamemode@ gamemode)
	{
		@this.gamemode = gamemode;
		LoadNextMap();
	}
}
