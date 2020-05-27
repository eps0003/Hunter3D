#include "RespawnManager.as"

#define SERVER_ONLY;

void onTick(CRules@ this)
{
	getRespawnManager().Update();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	getRespawnManager().AddToQueue(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	getRespawnManager().RemoveFromQueue(player);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	getRespawnManager().AddToQueue(victim);
}
