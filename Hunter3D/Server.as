#include "Vec3f.as"
#include "Map.as"
#include "ObjectManager.as"

#define SERVER_ONLY

void onTick(CRules@ this)
{
	Object@[] objects = getObjectManager().getNonActorObjects();
	for (uint i = 0; i < objects.length; i++)
	{
		Object@ object = objects[i];

		object.PreUpdate();
		object.Update();
		object.PostUpdate();
	}

	CBitStream bs;
	getActorManager().SerializeActors(bs);
	this.SendCommand(this.getCommandID("s_sync_objects"), bs, true);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("c_sync_voxel"))
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
	else if (cmd == this.getCommandID("c_sync_actor"))
	{
		Actor actor(params);
		Actor@ existingActor = getActorManager().getActor(actor);

		if (existingActor !is null)
		{
			existingActor = actor;
		}
	}
}
