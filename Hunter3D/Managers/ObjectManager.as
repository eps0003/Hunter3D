#include "Object.as"
#include "IRenderable.as"
#include "ActorManager.as"
#include "FlagManager.as"
#include "ObjectSyncer.as"

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
				RemoveObject(i);
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
				getObjectSyncer().AddRemovedObject(index);
			}

			//call object event
			object.onRemove();

			//call gamemode event
			getGamemodeManager().getGamemode().onObjectRemoved(getRules(), object);

			objects.removeAt(index);
			print("Removed object: " + object.name + object.id);
		}
	}

	Object@ getObject(uint index)
	{
		if (index < objects.size())
		{
			return objects[index];
		}
		return null;
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
