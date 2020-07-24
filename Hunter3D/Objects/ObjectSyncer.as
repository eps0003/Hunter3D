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
	private dictionary idIndexPairs;
	private CPlayer@[] syncAllToPlayers;

	void AddRemovedObject(uint id)
	{
		removedObjects.push_back(id);
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

	}

	private void SerializeObjects(CBitStream@ bs, bool syncAll)
	{
		Object@[] objects = getObjectManager().getObjects();

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

		SerializeRemovedObjects(bs);
	}

	void client_Deserialize(CBitStream@ bs)
	{
		ObjectManager@ objectManager = getObjectManager();

		uint count = bs.read_u32();
		for (uint i = 0; i < count; i++)
		{
			if (!bs.read_bool()) continue;

			switch (bs.read_u8())
			{
				case ObjectType::Actor:
				{
					Actor actor(bs);

					uint index;
					if (idIndexPairs.get("" + actor.id, index))
					{
						//update actors that arent mine
						if (!actor.player.isMyPlayer())
						{
							Object@ object = objectManager.getObject(index);
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

					uint index;
					if (idIndexPairs.get("" + flag.id, index))
					{
						Object@ object = objectManager.getObject(index);
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

		DeserializeRemovedObjects(bs);
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
			uint id = removedObjects[i];
			bs.write_u32(id);
		}

		removedObjects.clear();
	}

	private void DeserializeRemovedObjects(CBitStream@ bs)
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();

		BuildDictionary(objects);

		uint count = bs.read_u32();

		for (uint i = 0; i < count; i++)
		{
			uint id = bs.read_u32();

			uint index;
			if (idIndexPairs.get("" + id, index))
			{
				objectManager.RemoveObject(index);
			}

			BuildDictionary(objects);
		}
	}

	private void BuildDictionary(Object@[] objects)
	{
		idIndexPairs.deleteAll();

		for (uint i = 0; i < objects.size(); i++)
		{
			idIndexPairs.set("" + objects[i].id, i);
		}
	}
}