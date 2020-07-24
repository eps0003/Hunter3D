#include "Object.as"
#include "IRenderable.as"
#include "ActorManager.as"
#include "FlagManager.as"

shared ObjectManager@ getObjectManager()
{
	CRules@ rules = getRules();

	ObjectManager@ objectManager;
	if (rules.get("object_manager", @objectManager))
	{
		return objectManager;
	}

	@objectManager = ObjectManager();
	rules.set("object_manager", objectManager);
	return objectManager;
}

enum ObjectType
{
	None,
	Actor,
	Flag
}

shared class ObjectManager
{
	private Object@[] objects;
	private uint[] removedObjects;
	private dictionary idIndexPairs;

	void Interpolate(float t)
	{
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			object.Interpolate(t);
		}
	}

	void Render()
	{
		float t = getInterFrameTime();

		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];

			IRenderable@ renderable = cast<IRenderable>(object);
			if (renderable !is null && renderable.isVisible())
			{
				renderable.Render();
			}
		}
	}

	void AddObject(Object@ object)
	{
		if (object !is null && !hasObject(object))
		{
			if (isServer())
			{
				object.AssignUniqueID();
			}

			//call object event
			object.onCreate();

			objects.push_back(object);
			print("Added object: " + object.name + object.id);

			//call gamemode event
			getGamemodeManager().getGamemode().onObjectCreated(getRules(), object);
		}
	}

	void RemoveObject(Object@ object)
	{
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ obj = objects[i];
			if (object == obj)
			{
				if (!isClient())
				{
					removedObjects.push_back(obj.id);
				}

				//call object event
				object.onRemove();

				//call gamemode event
				getGamemodeManager().getGamemode().onObjectRemoved(getRules(), object);

				objects.removeAt(i);
				print("Removed object: " + object.name + object.id);
				return;
			}
		}
	}

	void RemoveObject(uint index)
	{
		if (index < getObjectCount())
		{
			Object@ object = objects[index];

			if (!isClient())
			{
				removedObjects.push_back(object.id);
			}

			objects.removeAt(index);
			print("Removed object: " + object.name + object.id);
		}
	}

	void RemoveObjectByID(uint id)
	{
		uint index;
		if (idIndexPairs.get("" + id, index))
		{
			RemoveObject(index);
		}
	}

	Object@[] getObjects()
	{
		return objects;
	}

	Object@[] getNonActorObjects()
	{
		Object@[] nonActorObjects;

		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			Actor@ actor = cast<Actor>(object);

			if (actor is null)
			{
				nonActorObjects.push_back(object);
			}
		}

		return nonActorObjects;
	}

	Object@ getObjectByID(uint id)
	{
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ obj = objects[i];
			if (obj.id == id)
			{
				return obj;
			}
		}
		return null;
	}

	void ClearObjects()
	{
		objects.clear();
	}

	uint getObjectCount()
	{
		return objects.size();
	}

	void SerializeObjects(CBitStream@ bs)
	{
		bs.write_u32(objects.size());

		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];

			//serialize actor
			Actor@ actor = cast<Actor>(object);
			if (actor !is null && actor.shouldSync())
			{
				bs.write_bool(true);
				bs.write_u8(ObjectType::Actor);
				actor.Serialize(bs);
				continue;
			}

			//serialize flag
			Flag@ flag = cast<Flag>(object);
			if (flag !is null && flag.shouldSync())
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

	void DeserializeObjects(CBitStream@ bs)
	{
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
							cast<Actor>(objects[index]) = actor;
						}
					}
					else
					{
						//spawn actor
						AddObject(actor);

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
						cast<Flag>(objects[index]) = flag;
					}
					else
					{
						AddObject(flag);
					}
				}
				break;
			}
		}

		DeserializeRemovedObjects(bs);
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
		BuildDictionary();

		uint count = bs.read_u32();

		for (uint i = 0; i < count; i++)
		{
			uint id = bs.read_u32();
			RemoveObjectByID(id);

			BuildDictionary();
		}
	}

	private void BuildDictionary()
	{
		idIndexPairs.deleteAll();

		for (uint i = 0; i < objects.size(); i++)
		{
			idIndexPairs.set("" + objects[i].id, i);
		}
	}

	private bool hasObject(Object@ object)
	{
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ obj = objects[i];
			if (object == obj)
			{
				return true;
			}
		}
		return false;
	}
}
