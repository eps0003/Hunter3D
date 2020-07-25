#include "GamemodeManager.as"
#include "Identifiable.as"

#define SERVER_ONLY;

void onInit(CRules@ this)
{
	getGamemodeManager().getGamemode().onInit(this);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	ResetUniqueID();
	getGamemodeManager().getGamemode().onRestart(this);
}

void onTick(CRules@ this)
{
	Gamemode@ gamemode = getGamemodeManager().getGamemode();
	gamemode.GenerateMap();
	gamemode.onTick(this);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	getGamemodeManager().getGamemode().onNewPlayerJoin(this, player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	getGamemodeManager().getGamemode().onPlayerLeave(this, player);
	getActorManager().RemoveActor(player);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	getGamemodeManager().getGamemode().onPlayerDie(this, victim, attacker, customData);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	getGamemodeManager().getGamemode().onCommand(this, cmd, params);
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	getGamemodeManager().getGamemode().onPlayerRequestTeamChange(this, player, player.getTeamNum(), newteam);
}