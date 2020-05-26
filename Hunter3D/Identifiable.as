int currentID = 0;

int getID()
{
	return currentID++;
}

class Identifiable
{
	int id;

	Identifiable()
	{
		this.id = getID();
	}
}
