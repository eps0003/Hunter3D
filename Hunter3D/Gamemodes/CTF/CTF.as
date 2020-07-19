#include "Gamemode.as"
#include "MapGenerator.as"
#include "RespawnManager.as"

shared class CTF : Gamemode
{
	u8 respawnTime;

	CTF()
	{
		super(MapGenerator(Vec3f(192, 48, 192)));
		LoadConfig(openConfig("CTF.cfg"));
	}

	void onTick(CRules@ this)
	{
		getRespawnManager().Update();
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
		Gamemode::onCommand(this, cmd, params);

		if (cmd == this.getCommandID("c_remove_actor"))
		{
			Actor actor(params);
			getRespawnManager().AddToQueue(actor.player, respawnTime);
			// getObjectManager().AddObject(Flag(getMap3D().getMapDimensions() * Vec3f(0.5f, 1, 0.5f), 0));
		}
	}

	void onPlayerLoaded(CRules@ this, CPlayer@ player)
	{
		getRespawnManager().AddToQueue(player, 0);
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		Gamemode::LoadConfig(cfg);

		respawnTime = cfg.read_u8("respawn_time", 0);
	}
}
