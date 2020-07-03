#include "Gamemode.as"
#include "TestMapGenerator.as"
#include "RespawnManager.as"

shared class CTF : Gamemode
{
	u8 respawnTime;

	CTF()
	{
		super(TestMapGenerator(Vec3f(24, 8, 24)));
		LoadConfig(openConfig("CTF.cfg"));
	}

	void onRestart(CRules@ this)
	{
		getRespawnManager().AddAllToQueue(0);
	}

	void onTick(CRules@ this)
	{
		Gamemode::onTick(this);
		getRespawnManager().Update();
	}

	void onNewPlayerJoin(CRules@ this, CPlayer@ player)
	{
		getRespawnManager().AddToQueue(player, 0);
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

	void LoadConfig(ConfigFile@ cfg)
	{
		Gamemode::LoadConfig(cfg);

		respawnTime = cfg.read_u8("respawn_time", 0);
	}
}
