shared class Identifiable
{
	uint id = 0;

	Identifiable() {}

	Identifiable(CBitStream@ bs)
	{
		id = bs.read_u32();
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

	bool isSameAs(Object@ object)
	{
		return id == object.id;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u32(id);
	}
}
