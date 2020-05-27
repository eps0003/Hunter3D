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
		Vec3f worldPos(params);
		Voxel voxel(params);

		print("Received voxel from client at " + worldPos.toString());

		if (!voxel.handPlaced || !voxel.isSolid() || true) // || not intersecting with object
		{
			map.SetVoxel(worldPos, voxel);
			voxel.server_Sync(worldPos);
		}
		else
		{
			//revert voxel
		}
	}
}
