class PlayerList
{
	private CPlayer@[] players;

	void AddPlayer(CPlayer@ player)
	{
		if (!hasPlayer(player))
		{
			players.push_back(player);
		}
	}

	void AddPlayers(CPlayer@[] players)
	{
		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ player = players[i];
			if (!hasPlayer(player))
			{
				players.push_back(player);
			}
		}
	}

	void RemovePlayer(CPlayer@ player)
	{
		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ p = players[i];
			if (p is player)
			{
				players.removeAt(i);
			}
		}
	}

	void ClearPlayers()
	{
		players.clear();
	}

	bool hasPlayers()
	{
		return !players.empty();
	}

	private bool hasPlayer(CPlayer@ player)
	{
		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ p = players[i];
			if (p is player)
			{
				return true;
			}
		}
		return false;
	}
}
