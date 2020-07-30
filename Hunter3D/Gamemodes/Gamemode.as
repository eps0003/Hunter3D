#include "Map.as"

shared class Gamemode
{
	string name;
	string shortName;

	private MapGenerator@ mapgen;

	Gamemode(MapGenerator@ mapgen)
	{
		@this.mapgen = mapgen;
	}

	void onInit(CRules@ this) {}
	void onRestart(CRules@ this) {}
	void onTick(CRules@ this) {}
	void onNewPlayerJoin(CRules@ this, CPlayer@ player) {}
	void onPlayerLeave(CRules@ this, CPlayer@ player) {}
	void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
	{
		ActorManager@ actorManager = getActorManager();
		Actor@ actor = actorManager.getActor(victim);

		actorManager.RemoveActor(victim);
		getObjectManager().AddObject(Spectator(victim, actor.position + Vec3f(0, actor.cameraHeight, 0), actor.rotation, actor.velocity));
	}
	void onCommand(CRules@ this, u8 cmd, CBitStream@ params) {}
	void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 currentTeam, u8 newTeam)
	{
		if (currentTeam != newTeam)
		{
			player.server_setTeamNum(newTeam);

			CBlob@ blob = player.getBlob();
			if (blob !is null && currentTeam != this.getSpectatorTeamNum())
			{
				blob.server_Die();
			}
		}
	}
	void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldTeam, u8 newTeam) {}
	void onPlayerLoaded(CRules@ this, CPlayer@ player) {}
	void onActorSpawned(CRules@ this, CPlayer@ player, Actor@ actor) {}
	void onBlockSetByPlayer(CRules@ this, Map@ map, CPlayer@ player, int index, u8 oldBlock, u8 newBlock) {}
	void onBlockSet(CRules@ this, Map@ map, int index, u8 oldBlock, u8 newBlock)
	{
		if (!map.isBlockSeeThrough(newBlock))
		{
			//check if block below is grass
			Vec3f worldPos = map.to3D(index);
			Vec3f posBelow = worldPos + Vec3f(0, -1, 0);
			u8 blockBelow = map.getBlockSafe(posBelow);

			if (blockBelow == BlockType::Grass)
			{
				//change grass to dirt
				map.SetBlock(posBelow, BlockType::Dirt);
			}
		}
	}
	void onObjectCreated(CRules@ this, Object@ object) {}
	void onObjectRemoved(CRules@ this, Object@ object) {}
	bool onPlayerAttemptRespawn(CRules@ this, CPlayer@ player, Actor@ &out actor) { return false; }

	void GenerateMap()
	{
		Map@ map = getMap3D();
		if (map is null || !map.isLoaded())
		{
			mapgen.GenerateMap();
		}
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		name = cfg.read_string("name", "Unknown Gamemode");
		shortName = cfg.read_string("short_name", "???");
	}
}
