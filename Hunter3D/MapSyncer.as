#include "PlayerList.as"
#include "Map.as"

#define SERVER_ONLY

class MapSyncer : PlayerList
{
	void server_Sync()
	{
		if (mapSyncer.shouldSync())
		{
			CBitStream bs;
			getMap3D().Serialize(bs);

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

	private bool shouldSync()
	{
		return hasPlayers();
	}
}

void onInit(CRules@ this)
{
	onRestart(this);
}

MapSyncer@ mapSyncer;

void onRestart(CRules@ this)
{
	@mapSyncer = MapSyncer();

	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		mapSyncer.AddPlayer(player);
	}
}

void onTick(CRules@ this)
{
	mapSyncer.server_Sync();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	mapSyncer.AddPlayer(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	mapSyncer.RemovePlayer(player);
}
