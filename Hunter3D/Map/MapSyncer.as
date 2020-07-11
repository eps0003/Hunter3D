#include "PlayerList.as"
#include "Map.as"
#include "Utilities.as"
#include "ModLoader.as"

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

shared class MapRequest
{
	CPlayer@ player;
	uint packet;

	MapRequest(CPlayer@ player, uint packet = 0)
	{
		@this.player = player;
		this.packet = packet;
	}
}

shared class MapSyncer
{
	private MapRequest@[] mapRequests;
	private CBitStream@[] mapPackets;
	private uint voxelsPerPacket = 10000;

	void AddMapRequest(CPlayer@ player, uint packet = 0)
	{
		if (packet < getTotalPacketCount())
		{
			MapRequest request(player, packet);
			mapRequests.push_back(request);
		}
	}

	void AddMapRequestForEveryone()
	{
		mapRequests.clear();

		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null)
			{
				AddMapRequest(player);
			}
		}
	}

	void AddMapPacket(CBitStream@ packet)
	{
		mapPackets.push_back(packet);
	}

	MapRequest@ getNextMapRequest()
	{
		MapRequest@ request;
		if (hasRequests())
		{
			@request = mapRequests[0];
			mapRequests.removeAt(0);
		}
		return request;
	}

	bool hasRequests()
	{
		return !mapRequests.empty();
	}

	void server_Sync()
	{
		Map@ map = getMap3D();
		if (map is null || !map.isLoaded() || isClient()) return;

		MapRequest@ request = getNextMapRequest();
		if (request !is null)
		{
			CPlayer@ player = request.player;
			uint index = request.packet;

			//move straight onto next request if the player of this one doesnt exist
			if (player is null)
			{
				server_Sync();
				return;
			}

			//get index of first and last chunk to sync
			uint firstVoxel = index * voxelsPerPacket;
			uint lastVoxel = firstVoxel + voxelsPerPacket;

			//serialize index
			CBitStream bs;
			bs.write_u32(index);

			//serialize map size
			if (index == 0)
			{
				map.getMapDimensions().Serialize(bs);
			}

			//loop through these voxels and serialize
			for (uint i = firstVoxel; i < lastVoxel; i++)
			{
				if (i >= map.getVoxelCount()) break;

				u8 block = map.getBlock(i);
				bs.write_u8(block);

				getNet().server_KeepConnectionsAlive();
			}

			//send to requesting player
			CRules@ rules = getRules();
			rules.SendCommand(rules.getCommandID("s_map_data"), bs, player);
			// print("Synced map packet " + (index + 1) + "/" + getTotalPacketCount() + " to " + player.getUsername());

			//request next packet
			AddMapRequest(player, ++index);
		}
	}

	void client_Deserialize()
	{
		if (!mapPackets.empty())
		{
			CBitStream@ packet = mapPackets[0];
			mapPackets.removeAt(0);

			//get index of first and last chunk to sync
			uint index = packet.read_u32();
			uint firstVoxel = index * voxelsPerPacket;
			uint lastVoxel = firstVoxel + voxelsPerPacket;

			if (index == 0)
			{
				Vec3f mapDim(packet);
				Map map(mapDim);
				getRules().set("map", map);
			}

			Map@ map = getMap3D();

			//loop through these voxels and serialize
			for (uint i = firstVoxel; i < lastVoxel; i++)
			{
				if (i >= map.getVoxelCount()) break;

				u8 block = packet.read_u8();
				map.SetBlock(i, block);

				getNet().server_KeepConnectionsAlive();
			}

			// print("Deserialized map packet " + (index + 1) + "/" + getTotalPacketCount());

			if (index == getTotalPacketCount() - 1)
			{
				map.SetLoaded();
			}

			ModLoader@ modLoader = getModLoader();
			modLoader.SetProgress(float(index + 1) / float(getTotalPacketCount()));
		}
	}

	private uint getTotalPacketCount()
	{
		return Maths::Ceil(float(getMap3D().getVoxelCount()) / float(voxelsPerPacket));
	}
}

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (!isServer()) return;

	getMapSyncer().AddMapRequestForEveryone();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (!isServer()) return;

	getMapSyncer().AddMapRequest(player);
}

void onTick(CRules@ this)
{
	if (Network::isMultiplayer())
	{
		MapSyncer@ mapSyncer = getMapSyncer();
		if (isServer())
		{
			mapSyncer.server_Sync();
		}
		else
		{
			mapSyncer.client_Deserialize();
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("s_map_data"))
	{
		if (isClient())
		{
			CBitStream bs = params;
			bs.SetBitIndex(params.getBitIndex());
			getMapSyncer().AddMapPacket(bs);
		}
	}
}
