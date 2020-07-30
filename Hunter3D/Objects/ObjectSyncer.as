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
	Builder,
	Spectator,
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

			//serialize builder
			Builder@ builder = cast<Builder>(object);
			if (builder !is null && (syncAll || builder.shouldSync()))
			{
				bs.write_bool(true);
				builder.Serialize(bs);
				continue;
			}

			//serialize spectator
			Spectator@ spectator = cast<Spectator>(object);
			if (spectator !is null && (syncAll || spectator.shouldSync()))
			{
				bs.write_bool(true);
				spectator.Serialize(bs);
				continue;
			}

			//serialize flag
			Flag@ flag = cast<Flag>(object);
			if (flag !is null && (syncAll || flag.shouldSync()))
			{
				bs.write_bool(true);
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
				case ObjectType::Builder:
				{
					Builder builder(bs);

					if (i < objects.size())
					{
						//update builders that arent mine
						if (!builder.getPlayer().isMyPlayer())
						{
							Object@ object = objectManager.getObject(i);
							cast<Builder>(object) = builder;
						}
					}
					else
					{
						//spawn builder
						objectManager.AddObject(builder);

						if (builder.getPlayer().isMyPlayer())
						{
							getCamera3D().SetParent(builder);
						}
					}
				}
				break;

				case ObjectType::Spectator:
				{
					Spectator spectator(bs);

					if (i < objects.size())
					{
						//update spectators that arent mine
						if (!spectator.getPlayer().isMyPlayer())
						{
							Object@ object = objectManager.getObject(i);
							cast<Spectator>(object) = spectator;
						}
					}
					else
					{
						//spawn spectator
						objectManager.AddObject(spectator);

						if (spectator.getPlayer().isMyPlayer())
						{
							getCamera3D().SetParent(spectator);
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

	void server_DeserializeActor(CBitStream@ bs)
	{
		ObjectManager@ objectManager = getObjectManager();

		switch (bs.read_u8())
		{
			case ObjectType::Builder:
			{
				Builder builder(bs);

				Builder@ existingBuilder = cast<Builder>(objectManager.getObjectByID(builder.id));

				if (existingBuilder !is null)
				{
					existingBuilder = builder;
				}
			}
			break;

			case ObjectType::Spectator:
			{
				Spectator spectator(bs);

				Spectator@ existingSpectator = cast<Spectator>(objectManager.getObjectByID(spectator.id));

				if (existingSpectator !is null)
				{
					existingSpectator = spectator;
				}
			}
			break;
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