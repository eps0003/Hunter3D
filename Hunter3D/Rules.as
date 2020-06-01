#include "GamemodeManager.as"
#include "RespawnManager.as"

#define SERVER_ONLY;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	getGamemodeManager().getGamemode().Init();
}

void onTick(CRules@ this)
{
	getRespawnManager().Update();
	getGamemodeManager().getGamemode().Update();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	getGamemodeManager().getGamemode().PlayerJoin(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	getGamemodeManager().getGamemode().PlayerLeave(player);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	getGamemodeManager().getGamemode().PlayerDie(victim, attacker, customData);
}
