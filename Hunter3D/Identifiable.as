uint currentID = 0;

uint getUniqueID()
{
	return currentID++;
}

class Identifiable
{
	uint id;

	Identifiable()
	{
		id = getUniqueID();
	}

	Identifiable(CBitStream@ bs)
	{
		id = bs.read_u32();
	}

	//SERVER ONLY
	Identifiable(uint id)
	{
		this.id = id;
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
