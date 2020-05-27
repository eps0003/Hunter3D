#include "PlayerList.as"

class MapSyncer : PlayerList
{
	bool shouldSync()
	{
		return hasPlayers();
	}

	void Sync()
	{
		CBitStream bs;
		map.Serialize(bs);

		CRules@ rules = getRules();

		print("Synced map to:");

		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ player = players[i];
			print("> " + player.getUsername());
			rules.SendCommand(rules.getCommandID("server map data"), bs, player);
		}

		ClearPlayers();
	}
}
