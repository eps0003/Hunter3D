#include "Object.as"

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

	void AddObject(Object@ object)
	{
		if (object !is null && !hasObject(object))
		{
			if (isServer())
			{
				object.AssignUniqueID();
			}

			objects.push_back(object);
		}
	}

	void RemoveObject(Object@ object)
	{
		for (uint i = 0; i < objects.length; i++)
		{
			Object@ obj = objects[i];
			if (object.isSameAs(obj))
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
			if (object.isSameAs(obj))
			{
				return true;
			}
		}
		return false;
	}
}
