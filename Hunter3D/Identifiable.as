shared void ResetUniqueID()
{
	getRules().set_u32("current_id", 0);
}

shared class Identifiable
{
	uint id = 0;
	string name;

	Identifiable(string name)
	{
		this.name = name;
	}

	Identifiable(CBitStream@ bs)
	{
		id = bs.read_u32();
	}

	bool opEquals(Identifiable@ identifiable)
	{
		return id == identifiable.id;
	}

	void AssignUniqueID()
	{
		if (isServer())
		{
			CRules@ rules = getRules();
			rules.add_u32("current_id", 1);
			id = rules.get_u32("current_id");
		}
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u32(id);
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		name = cfg.read_string("name", "Object");
	}
}
