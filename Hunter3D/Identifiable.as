uint currentID = 0;

class Identifiable
{
	uint id = 0;

	Identifiable() {}

	Identifiable(CBitStream@ bs)
	{
		id = bs.read_u32();
	}

	//SERVER ONLY
	Identifiable(uint id)
	{
		this.id = id;
	}

	void AssignUniqueID()
	{
		if (isServer())
		{
			id = ++currentID;
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
