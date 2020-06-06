#include "CTF.as"
#include "RespawnManager.as"
#include "GamemodeManager.as"

IGamemode@ ctf;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	getRespawnManager().AddAllToQueue(0);
	@ctf = getGamemodeManager().getGamemode();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	getRespawnManager().AddToQueue(player, ctf.respawnTime);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	getRespawnManager().RemoveFromQueue(player);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	getRespawnManager().AddToQueue(victim, ctf.respawnTime);
}
