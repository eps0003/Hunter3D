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

shared class ObjectManager
{
	private Object@[] objects;
	private uint[] removedObjects;

	void Interpolate()
	{
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			object.Interpolate();
		}
	}

	void Render()
	{
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
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ obj = objects[i];
			if (obj.id == id)
			{
				RemoveObject(i);
				return;
			}
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

	void SerializeRemovedObjects(CBitStream@ bs)
	{
		bs.write_u16(removedObjects.size());

		for (uint i = 0; i < removedObjects.size(); i++)
		{
			uint id = removedObjects[i];
			bs.write_u32(id);
		}

		removedObjects.clear();
	}

	void DeserializeRemovedObjects(CBitStream@ bs)
	{
		u16 count = bs.read_u16();

		for (uint i = 0; i < count; i++)
		{
			uint id = bs.read_u32();
			RemoveObjectByID(id);
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
