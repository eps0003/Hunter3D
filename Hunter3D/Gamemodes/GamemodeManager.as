#include "IGamemode.as"
#include "CTF.as"

GamemodeManager@ getGamemodeManager()
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

class GamemodeManager
{
	private IGamemode@ gamemode = CTF();

	IGamemode@ getGamemode()
	{
		return gamemode;
	}

	void SetGamemode(IGamemode@ gamemode)
	{
		@this.gamemode = gamemode;
		LoadNextMap();
	}
}
