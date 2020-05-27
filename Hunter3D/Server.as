#include "Vec3f.as"
#include "Map.as"
#include "Actor.as"
#include "ActorManager.as"
#include "TestMapGenerator.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	Map map = TestMapGenerator().GenerateMap(Vec3f(24, 8, 24));
	this.set("map", map);
}

void onTick(CRules@ this)
{
	getActorManager().server_Sync();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client sync voxel"))
	{
		u16 playerID = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(playerID);
		Vec3f worldPos(params);
		Voxel voxel(params);

		if (!voxel.handPlaced || !voxel.isSolid() || true) // || not intersecting with object
		{
			getMap3D().SetVoxel(worldPos, voxel);
			voxel.server_Sync(worldPos, player);
		}
		else
		{
			//revert voxel
		}
	}
	else if (cmd == this.getCommandID("client sync actor"))
	{
		Actor actor(params);
		getActorManager().UpdateActor(actor);
	}
}
