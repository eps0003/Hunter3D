#include "Vec3f.as"
#include "Map.as"
#include "ObjectManager.as"

#define SERVER_ONLY

void onTick(CRules@ this)
{
	ObjectManager@ objectManager = getObjectManager();

	Object@[] objects = objectManager.getNonActorObjects();
	for (uint i = 0; i < objects.length; i++)
	{
		Object@ object = objects[i];

		object.PreUpdate();
		object.Update();
		object.PostUpdate();
	}

	CBitStream bs;
	getActorManager().SerializeActors(bs);
	getFlagManager().SerializeFlags(bs);
	objectManager.SerializeRemovedObjects(bs);
	this.SendCommand(this.getCommandID("s_sync_objects"), bs, true);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = server_CreateBlob("husk");
	if (blob !is null)
	{
		blob.server_SetPlayer(player);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		blob.server_Die();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("c_sync_block"))
	{
		// u16 playerID = params.read_u16();
		// CPlayer@ player = getPlayerByNetworkId(playerID);
		// Vec3f worldPos(params);
		// Voxel voxel(params);

		// if (!voxel.handPlaced || !voxel.isSolid() || true) // || not intersecting with object
		// {
		// 	getMap3D().SetVoxel(worldPos, voxel);
		// 	voxel.server_Sync(worldPos, player);
		// }
		// else
		// {
		// 	//revert voxel
		// }
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
