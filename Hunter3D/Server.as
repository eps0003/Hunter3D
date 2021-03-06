#include "Vec3f.as"
#include "Map.as"
#include "ObjectManager.as"
#include "MapSyncer.as"
#include "ObjectSyncer.as"
#include "GamemodeManager.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			CreateHusk(this, player);
		}
	}
}

void onTick(CRules@ this)
{
	if (!isClient())
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getNonActorObjects();
		uint count = objects.size();

		for (uint i = 0; i < count; i++)
		{
			objects[i].PreUpdate();
		}

		for (uint i = 0; i < count; i++)
		{
			objects[i].Update();
		}

		for (uint i = 0; i < count; i++)
		{
			objects[i].PostUpdate();
		}

		getObjectSyncer().server_Sync();
		getMapSyncer().server_Sync();
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	CreateHusk(this, player);

	getMapSyncer().AddMapRequest(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		blob.server_Die();
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	CreateHusk(this, victim);
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
		u8 existingBlock = map.getBlock(index);

		bool canSetBlock = true;

		if (map.isBlockSolid(block))
		{
			//check if object intersects block
			Object@[] objects = getObjectManager().getObjects();
			for (uint i = 0; i < objects.size(); i++)
			{
				PhysicsObject@ object = cast<PhysicsObject>(objects[i]);
				if (object !is null)
				{
					AABB@ bounds = object.getCollisionBox();
					if (bounds !is null && bounds.intersectsVoxel(object.position, worldPos))
					{
						canSetBlock = false;
						break;
					}
				}
			}
		}

		if (canSetBlock)
		{
			//call gamemode event
			getGamemodeManager().getGamemode().onBlockSetByPlayer(getRules(), map, player, index, existingBlock, block);

			//set block
			map.SetBlock(index, block);
		}
		else
		{
			//revert voxel on client who placed the block
			CBitStream bs;
			bs.write_u32(index);
			bs.write_u8(existingBlock);
			this.SendCommand(this.getCommandID("s_revert_block"), bs, player);
		}
	}
	else if (cmd == this.getCommandID("c_sync_actor"))
	{
		getObjectSyncer().server_DeserializeActor(params);
	}
	else if (cmd == this.getCommandID("c_loaded"))
	{
		u16 playerID = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(playerID);

		if (player !is null)
		{
			//call gamemode event
			getGamemodeManager().getGamemode().onPlayerLoaded(this, player);

			//sync all objects to player
			getObjectSyncer().AddNewPlayer(player);
		}
	}
}

void CreateHusk(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = server_CreateBlob("husk");
	if (blob !is null)
	{
		blob.server_SetPlayer(player);
	}
}