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
	ObjectManager()
	{
		Object@[] objects;
		getRules().set("objects", objects);
	}

	void AddObject(Object@ object)
	{
		if (object !is null && !hasObject(object))
		{
			if (isServer())
			{
				object.AssignUniqueID();
			}

			getRules().push("objects", @object);
		}
	}

	void RemoveObject(Object@ object)
	{
		Object@[] objects = getObjects();

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ obj = objects[i];
			if (object.isSameAs(obj))
			{
				getRules().removeAt("objects", i);
				return;
			}
		}
	}

	void RemoveObject(uint index)
	{
		if (index < getObjectCount())
		{
			getRules().removeAt("objects", index);
		}
	}

	Object@[] getObjects()
	{
		Object@[] objects;
		getRules().get("objects", objects);
		return objects;
	}

	Object@ getObjectByID(uint id)
	{
		Object@[] objects = getObjects();

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
		getRules().clear("objects");
	}

	uint getObjectCount()
	{
		return getObjects().length;
	}

	private bool hasObject(Object@ object)
	{
		Object@[] objects = getObjects();

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
