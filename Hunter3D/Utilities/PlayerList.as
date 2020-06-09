shared class PlayerList
{
	private CPlayer@[] players;

	void AddPlayer(CPlayer@ player)
	{
		if (player !is null && !hasPlayer(player))
		{
			players.push_back(player);
		}
	}

	void AddPlayers(CPlayer@[] players)
	{
		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ player = players[i];
			if (player !is null && !hasPlayer(player))
			{
				players.push_back(player);
			}
		}
	}

	void AddAllPlayers()
	{
		ClearPlayers();

		uint count = getPlayersCount();
		for (uint i = 0; i < count; i++)
		{
			CPlayer@ player = getPlayer(i);
			AddPlayer(player);
		}
	}

	void RemovePlayer(CPlayer@ player)
	{
		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ p = players[i];
			if (p is null || p is player)
			{
				RemoveIndex(i);
			}
		}
	}

	void RemoveIndex(uint index)
	{
		if (index < getPlayerCount())
		{
			players.removeAt(index);
		}
	}

	CPlayer@ getPlayer(uint index)
	{
		if (index < getPlayerCount())
		{
			return players[index];
		}
		return null;
	}

	uint getPlayerCount()
	{
		return players.length;
	}

	void ClearPlayers()
	{
		players.clear();
	}

	bool hasPlayers()
	{
		return !players.empty();
	}

	bool hasPlayer(CPlayer@ player)
	{
		if (player !is null)
		{
			for (uint i = 0; i < players.length; i++)
			{
				CPlayer@ p = players[i];
				if (p is player)
				{
					return true;
				}
			}
		}
		return false;
	}
}
