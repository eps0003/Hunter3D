#include "GamemodeManager.as"

#define SERVER_ONLY;

void onInit(CRules@ this)
{
	getGamemodeManager().getGamemode().onInit(this);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	getGamemodeManager().getGamemode().onRestart(this);
}

void onTick(CRules@ this)
{
	getGamemodeManager().getGamemode().onTick(this);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	getGamemodeManager().getGamemode().onNewPlayerJoin(this, player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	getGamemodeManager().getGamemode().onPlayerLeave(this, player);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	getGamemodeManager().getGamemode().onPlayerDie(this, victim, attacker, customData);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	getGamemodeManager().getGamemode().onCommand(this, cmd, params);
}
