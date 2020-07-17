#include "ObjectManager.as"
#include "Flag.as"

shared FlagManager@ getFlagManager()
{
	CRules@ rules = getRules();

	FlagManager@ flagManager;
	if (rules.get("flag_manager", @flagManager))
	{
		return flagManager;
	}

	@flagManager = FlagManager();
	rules.set("flag_manager", flagManager);
	return flagManager;
}

shared class FlagManager
{
	Flag@ getFlag(Flag@ flag)
	{
		Flag@[] flags = getFlags();

		for (uint i = 0; i < flags.length; i++)
		{
			Flag@ f = flags[i];
			if (f == flag)
			{
				return f;
			}
		}

		return null;
	}

	Flag@[] getFlags()
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();
		Flag@[] flags;

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			Flag@ flag = cast<Flag>(object);

			if (flag !is null)
			{
				flags.push_back(flag);
			}
		}

		return flags;
	}

	Flag@[] getFlags(u8 team)
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();
		Flag@[] flags;

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			Flag@ flag = cast<Flag>(object);

			if (flag !is null && flag.getTeamNum() == team)
			{
				flags.push_back(flag);
			}
		}

		return flags;
	}

	Flag@[] getNonStaticFlags()
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();
		Flag@[] flags;

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			Flag@ flag = cast<Flag>(object);

			if (flag !is null && !flag.isStatic())
			{
				flags.push_back(flag);
			}
		}

		return flags;
	}

	void ClearFlags()
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			Flag@ flag = cast<Flag>(object);

			if (flag !is null)
			{
				objectManager.RemoveObject(i--);
			}
		}
	}

	uint getFlagCount()
	{
		return getFlags().length;
	}

	uint getFlagCount(u8 team)
	{
		return getFlags(team).length;
	}

	void SerializeFlags(CBitStream@ bs)
	{
		Flag@[] flags = getNonStaticFlags();

		bs.write_u16(flags.length);

		for (uint i = 0; i < flags.length; i++)
		{
			Flag@ flag = flags[i];
			flag.Serialize(bs);
		}
	}

	void DeserializeFlags(CBitStream@ bs)
	{
		ObjectManager@ objectManager = getObjectManager();

		u16 count = bs.read_u16();

		for (uint i = 0; i < count; i++)
		{
			Flag flag(bs);
			Flag@ existingFlag = getFlag(flag);

			if (existingFlag !is null)
			{
				existingFlag = flag;
			}
			else
			{
				objectManager.AddObject(flag);
			}
		}
	}
}
