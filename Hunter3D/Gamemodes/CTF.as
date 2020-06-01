#include "IGamemode.as"
#include "RespawnManager.as"

class CTF : IGamemode
{
	void Init()
	{
		getRespawnManager().AddAllToQueue();
	}

	void Update()
	{

	}

	void RenderGUI()
	{

	}

	void PlayerJoin(CPlayer@ player)
	{
		getRespawnManager().AddToQueue(player);
	}

	void PlayerLeave(CPlayer@ player)
	{
		getRespawnManager().RemoveFromQueue(player);
	}

	void PlayerDie(CPlayer@ victim, CPlayer@ attacker, u8 hitter)
	{
		getRespawnManager().AddToQueue(victim);
	}

	Vec3f getRespawnPoint(CPlayer@ player)
	{
		return getMap3D().getMapDimensions() / 2;
	}

	bool canRespawn(CPlayer@ player)
	{
		return true;
	}

	void SetGameState(u8 state)
	{

	}

	u8 getGameState()
	{
		return 0;
	}

	int getWinningTeam()
	{
		return -1;
	}
}
