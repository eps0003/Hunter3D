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
	void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData) {}
	void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
	{
		if (cmd == this.getCommandID("c_loaded"))
		{
			u16 playerID = params.read_u16();
			CPlayer@ player = getPlayerByNetworkId(playerID);

			if (player !is null)
			{
				onPlayerLoaded(this, player);
			}
		}
	}
	void onPlayerLoaded(CRules@ this, CPlayer@ player) {}
	void onActorSpawned(CRules@ this, CPlayer@ player, Vec3f worldPos, Actor@ actor) {}
	void onBlockSetByPlayer(CRules@ this, Map@ map, CPlayer@ player, int index, u8 oldBlock, u8 newblock) {}
	void onBlockSet(CRules@ this, Map@ map, int index, u8 oldBlock, u8 newblock)
	{
		if (!map.isBlockSeeThrough(newblock))
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

	void GenerateMap()
	{
		Map@ map = getMap3D();
		if (map is null || !map.isLoaded())
		{
			mapgen.GenerateMap();
		}
	}

	Vec3f getRespawnPoint(CPlayer@ player)
	{
		Vec3f dim = getMap3D().getMapDimensions();
		return Vec3f(dim.x / 2, dim.y, dim.z / 2);
	}

	bool canRespawn(CPlayer@ player)
	{
		return true;
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		name = cfg.read_string("name", "Unknown Gamemode");
		shortName = cfg.read_string("short_name", "???");
	}
}
