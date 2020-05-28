#include "Object.as"

class ObjectManager
{
	private Object@[] objects;

	void server_AddObject(Object@ object)
	{
		if (!hasObject(object))
		{
			objects.push_back(object);
		}
	}

	void server_AddObjects(Object@[] objects)
	{
		for (uint i = 0; i < objects.length; i++)
		{
			Object@ obj = objects[i];
			if (!hasObject(obj))
			{
				objects.push_back(obj);
			}
		}
	}

	void server_RemoveObject(Object@ object)
	{
		for (uint i = 0; i < objects.length; i++)
		{
			Object@ obj = objects[i];
			if (object.isSameAs(obj))
			{
				objects.removeAt(i);
				break;
			}
		}
	}

	void server_ClearObjects()
	{
		objects.clear();
	}

	Object@ getObject(uint index)
	{
		return objects[index];
	}

	bool hasObjects()
	{
		return !objects.empty();
	}

	uint getObjectCount()
	{
		return objects.length;
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

	void server_Sync(string command)
	{
		CBitStream bs;
		bs.write_u32(objects.length);

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ obj = objects[i];
			obj.Serialize(bs);
		}

		CRules@ rules = getRules();
		rules.SendCommand(rules.getCommandID(command), bs, true);

		server_ClearObjects();
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
