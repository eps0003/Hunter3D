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
		Gamemode::onPlayerDie(this, victim, attacker, customData);

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
		getRespawnManager().AddToQueue(player, 0);
	}

	void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldTeam, u8 newTeam)
	{
		ActorManager@ actorManager = getActorManager();
		if (actorManager.playerHasActor(player))
		{
			//create spectator object if player isnt already doesnt exist
			Actor@ actor = actorManager.getActor(player);
			if (actor !is null && cast<Spectator>(actor) is null)
			{
				actorManager.RemoveActor(actor);
				getObjectManager().AddObject(Spectator(player, actor.position + Vec3f(0, actor.cameraHeight, 0), actor.rotation, actor.velocity));
			}

			//add player to queue
			getRespawnManager().AddToQueue(player, respawnTime);
		}
	}

	bool onPlayerAttemptRespawn(CRules@ this, CPlayer@ player, Actor@ &out actor)
	{
		Vec3f dim = getMap3D().getMapDimensions();
		Vec3f position(dim.x / 2, dim.y, dim.z / 2);

		@actor = Builder(player, position);
		return true;
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		Gamemode::LoadConfig(cfg);

		respawnTime = cfg.read_u8("respawn_time", 0);
	}
}
