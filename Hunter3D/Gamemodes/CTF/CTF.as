#include "Gamemode.as"
#include "MapGenerator.as"
#include "RespawnManager.as"

shared class CTF : Gamemode
{
	u8 respawnTime;

	CTF()
	{
		super(MapGenerator(Vec3f(96, 24, 96)));
		LoadConfig(openConfig("CTF.cfg"));
	}

	void onTick(CRules@ this)
	{
		getRespawnManager().Update();
	}

	void onNewPlayerJoin(CRules@ this, CPlayer@ player)
	{
		player.server_setTeamNum(0);
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
		if (cmd == this.getCommandID("c_do_something"))
		{
			getObjectManager().AddObject(Flag(getMap3D().getMapDimensions() * Vec3f(0.5f, 0.7f, 0.5f), 0));
		}

		if (cmd == this.getCommandID("c_do_something_else"))
		{
			getFlagManager().ClearFlags();
		}
	}

	void onPlayerLoaded(CRules@ this, CPlayer@ player)
	{
		if (player.getTeamNum() != this.getSpectatorTeamNum())
		{
			getRespawnManager().AddToQueue(player, 0);
		}
	}

	void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 currentTeam, u8 newTeam)
	{
		if (currentTeam == newTeam) return;

		bool spectator = newTeam == this.getSpectatorTeamNum();

		Actor@ actor = getActorManager().getActor(player);
		if (actor !is null)
		{
			actor.SetTeamNum(newTeam);

			if (spectator)
			{
				getActorManager().RemoveActor(actor);
			}
		}
		else
		{
			player.server_setTeamNum(newTeam);
		}

		if (!spectator)
		{
			getRespawnManager().AddToQueue(player, respawnTime);
		}
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		Gamemode::LoadConfig(cfg);

		respawnTime = cfg.read_u8("respawn_time", 0);
	}
}
