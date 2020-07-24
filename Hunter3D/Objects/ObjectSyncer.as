shared ObjectSyncer@ getObjectSyncer()
{
	CRules@ rules = getRules();

	ObjectSyncer@ objectSyncer;
	if (rules.get("object_syncer", @objectSyncer))
	{
		return objectSyncer;
	}

	@objectSyncer = ObjectSyncer();
	rules.set("object_syncer", objectSyncer);
	return objectSyncer;
}

enum ObjectType
{
	None,
	Actor,
	Flag
}

shared class ObjectSyncer
{
	private uint[] removedObjects;
	private CPlayer@[] syncAllToPlayers;

	void AddRemovedObject(uint index)
	{
		removedObjects.push_back(index);
	}

	void AddNewPlayer(CPlayer@ player)
	{
		syncAllToPlayers.push_back(player);
	}

	void server_Sync()
	{
		CRules@ rules = getRules();

		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			bool syncAll = shouldSyncAll(player);

			CBitStream bs;
			SerializeObjects(bs, syncAll);
			rules.SendCommand(rules.getCommandID("s_sync_objects"), bs, player);
		}

		Object@[] objects = getObjectManager().getObjects();

		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			object.Synced();
		}

		removedObjects.clear();
	}

	private void SerializeObjects(CBitStream@ bs, bool syncAll)
	{
		Object@[] objects = getObjectManager().getObjects();

		SerializeRemovedObjects(bs);

		bs.write_u32(objects.size());
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];

			//serialize actor
			Actor@ actor = cast<Actor>(object);
			if (actor !is null && (syncAll || actor.shouldSync()))
			{
				bs.write_bool(true);
				bs.write_u8(ObjectType::Actor);
				actor.Serialize(bs);
				continue;
			}

			//serialize flag
			Flag@ flag = cast<Flag>(object);
			if (flag !is null && (syncAll || flag.shouldSync()))
			{
				bs.write_bool(true);
				bs.write_u8(ObjectType::Flag);
				flag.Serialize(bs);
				continue;
			}

			bs.write_bool(false);
		}
	}

	void client_Deserialize(CBitStream@ bs)
	{
		ObjectManager@ objectManager = getObjectManager();

		DeserializeRemovedObjects(bs);

		uint count = bs.read_u32();
		for (uint i = 0; i < count; i++)
		{
			if (!bs.read_bool()) continue;

			Object@[] objects = objectManager.getObjects();

			switch (bs.read_u8())
			{
				case ObjectType::Actor:
				{
					Actor actor(bs);

					if (i < objects.size())
					{
						//update actors that arent mine
						if (!actor.player.isMyPlayer())
						{
							Object@ object = objectManager.getObject(i);
							cast<Actor>(object) = actor;
						}
					}
					else
					{
						//spawn actor
						objectManager.AddObject(actor);

						if (actor.player.isMyPlayer())
						{
							getCamera3D().SetParent(actor);
						}
					}
				}
				break;

				case ObjectType::Flag:
				{
					Flag flag(bs);

					if (i < objects.size())
					{
						Object@ object = objectManager.getObject(i);
						cast<Flag>(object) = flag;
					}
					else
					{
						objectManager.AddObject(flag);
					}
				}
				break;
			}
		}
	}

	private bool shouldSyncAll(CPlayer@ player)
	{
		for (uint i = 0; i < syncAllToPlayers.size(); i++)
		{
			if (player is syncAllToPlayers[i])
			{
				syncAllToPlayers.removeAt(i);
				return true;
			}
		}
		return false;
	}

	private void SerializeRemovedObjects(CBitStream@ bs)
	{
		bs.write_u32(removedObjects.size());

		for (uint i = 0; i < removedObjects.size(); i++)
		{
			uint index = removedObjects[i];
			bs.write_u32(index);
		}
	}

	private void DeserializeRemovedObjects(CBitStream@ bs)
	{
		ObjectManager@ objectManager = getObjectManager();

		uint count = bs.read_u32();

		for (uint i = 0; i < count; i++)
		{
			uint index = bs.read_u32();
			objectManager.RemoveObject(index);
		}
	}
}