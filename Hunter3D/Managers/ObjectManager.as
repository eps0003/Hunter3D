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

	void Interpolate()
	{
		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			object.Interpolate();
		}
	}

	void Render()
	{
		for (uint i = 0; i < objects.length; i++)
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

			objects.push_back(object);
			print("Added object: " + object.name + object.id);
		}
	}

	void RemoveObject(Object@ object)
	{
		for (uint i = 0; i < objects.length; i++)
		{
			Object@ obj = objects[i];
			if (object == obj)
			{
				objects.removeAt(i);
				return;
			}
		}
	}

	void RemoveObject(uint index)
	{
		if (index < getObjectCount())
		{
			objects.removeAt(index);
		}
	}

	Object@[] getObjects()
	{
		return objects;
	}

	Object@[] getNonActorObjects()
	{
		Object@[] nonActorObjects;

		for (uint i = 0; i < objects.length; i++)
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
		for (uint i = 0; i < objects.length; i++)
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
		return objects.length;
	}

	private bool hasObject(Object@ object)
	{
		for (uint i = 0; i < objects.length; i++)
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
