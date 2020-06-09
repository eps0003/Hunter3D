#include "Gamemode.as"
#include "TestMapGenerator.as"
#include "RespawnManager.as"

shared class CTF : Gamemode
{
	u8 respawnTime;

	CTF()
	{
		LoadConfig();
	}

	void onRestart(CRules@ this)
	{
		TestMapGenerator().GenerateMap(Vec3f(24, 8, 24));
		getRespawnManager().AddAllToQueue(respawnTime);
	}

	void onTick(CRules@ this)
	{
		getRespawnManager().Update();
	}

	void onNewPlayerJoin(CRules@ this, CPlayer@ player)
	{
		getRespawnManager().AddToQueue(player, respawnTime);
	}

	void onPlayerLeave(CRules@ this, CPlayer@ player)
	{
		getRespawnManager().RemoveFromQueue(player);
	}

	void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
	{
		getRespawnManager().AddToQueue(victim, respawnTime);
	}

	void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
	{
		if (cmd == this.getCommandID("c_remove_actor"))
		{
			Actor actor(params);
			getRespawnManager().AddToQueue(actor.player, respawnTime);
		}
	}

	void LoadConfig()
	{
		ConfigFile@ cfg = openConfig("CTF.cfg");
		Gamemode::LoadConfig(cfg);

		respawnTime = cfg.read_u8("respawn_time", 0);
	}
}
