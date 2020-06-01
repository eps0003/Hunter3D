#include "Vec3f.as"

interface IGamemode
{
	void Init();
	void Update();
	void RenderGUI();
	void PlayerJoin(CPlayer@ player);
	void PlayerLeave(CPlayer@ player);
	void PlayerDie(CPlayer@ victim, CPlayer@ attacker, u8 hitter);

	Vec3f getRespawnPoint(CPlayer@ player);
	bool canRespawn(CPlayer@ player);

	void SetGameState(u8 state);
	u8 getGameState();

	int getWinningTeam();
}
