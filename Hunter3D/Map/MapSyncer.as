#include "PlayerList.as"
#include "Map.as"

#define SERVER_ONLY

shared MapSyncer@ getMapSyncer()
{
	CRules@ rules = getRules();

	MapSyncer@ mapSyncer;
	if (rules.get("map_syncer", @mapSyncer))
	{
		return mapSyncer;
	}

	@mapSyncer = MapSyncer();
	rules.set("map_syncer", mapSyncer);
	return mapSyncer;
}

shared class MapSyncer : PlayerList
{
	void server_Sync()
	{
		if (shouldSync())
		{
			CBitStream bs;
			getMap3D().Serialize(bs);

			CRules@ rules = getRules();

			print("Synced map to:");

			for (uint i = 0; i < players.length; i++)
			{
				CPlayer@ player = players[i];
				print("> " + player.getUsername());
				rules.SendCommand(rules.getCommandID("s_map_data"), bs, player);
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

void onRestart(CRules@ this)
{
	getMapSyncer().AddAllPlayers();
}

void onTick(CRules@ this)
{
	getMapSyncer().server_Sync();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	getMapSyncer().AddPlayer(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	getMapSyncer().RemovePlayer(player);
}
