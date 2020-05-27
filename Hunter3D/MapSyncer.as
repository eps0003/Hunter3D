#include "PlayerList.as"

class MapSyncer : PlayerList
{
	bool shouldSync()
	{
		return hasPlayers();
	}

	void Sync()
	{
		print("Synced map");

		CBitStream bs;
		map.Serialize(bs);

		CRules@ rules = getRules();

		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ player = players[i];
			rules.SendCommand(rules.getCommandID("server map data"), bs, player);
		}

		ClearPlayers();
	}
}
