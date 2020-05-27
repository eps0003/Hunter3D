uint64 currentID = 0;

uint64 getUniqueID()
{
	return currentID++;
}

class Identifiable
{
	int id;

	Identifiable()
	{
		this.id = getUniqueID();
	}
}
