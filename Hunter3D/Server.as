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
		Map@ map = getMap3D();

		u16 playerID = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(playerID);
		if (player is null) return;

		uint index = params.read_u32();
		Vec3f worldPos = map.to3D(index);
		if (!map.isValidBlock(index)) return;

		u8 block = params.read_u8();

		CBitStream bs;
		bs.write_u32(index);

		bool notIntersectingObjects = true;
		Object@[] objects = getObjectManager().getObjects();
		for (uint i = 0; i < objects.length; i++)
		{
			PhysicsObject@ object = cast<PhysicsObject>(objects[i]);
			if (object !is null)
			{
				AABB@ bounds = object.getCollisionBox();
				AABB blockBounds(worldPos, worldPos + 1);
				if (bounds !is null && bounds.intersects(object.position, blockBounds))
				{
					notIntersectingObjects = false;
					break;
				}
			}
		}

		if (!map.isBlockSolid(block) || notIntersectingObjects)
		{

			map.SetBlock(index, block);

			//sync block to all clients
			bs.write_u8(block);
			this.SendCommand(this.getCommandID("s_sync_block"), bs, true);
		}
		else
		{
			//revert voxel on client who placed the block
			bs.write_u8(map.getBlock(index));
			this.SendCommand(this.getCommandID("s_revert_block"), bs, player);
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
