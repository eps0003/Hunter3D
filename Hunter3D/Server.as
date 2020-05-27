#include "Utilities.as"
#include "Vec3f.as"
#include "Map.as"
#include "MapSyncer.as"
#include "TestMapGenerator.as"

#define SERVER_ONLY

Map@ map;
MapSyncer@ mapSyncer;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@map = TestMapGenerator().GenerateMap(Vec3f(24, 8, 24));
	map.GenerateMesh();

	@mapSyncer = MapSyncer();

	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		mapSyncer.AddPlayer(player);
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	mapSyncer.AddPlayer(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	mapSyncer.RemovePlayer(player);
}

//TODO: this isnt run in singleplayer while in menu
void onTick(CRules@ this)
{
	//for some reason this gets called on client when they are kicked for being afk
	if (!isServer()) return;

	if (mapSyncer.shouldSync())
	{
		mapSyncer.Sync();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client sync voxel"))
	{
		u16 playerID = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(playerID);
		Vec3f position(params);
		Voxel voxel(params);
		map.SetVoxel(position, voxel);
		position.Print();
		print("Received voxel from " + player.getUsername());
	}
}
