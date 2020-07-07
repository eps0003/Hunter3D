#include "PlayerList.as"
#include "Map.as"

const uint CHUNKS_PER_PACKET = 10;

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
	private MapRequest@[] requests;

	void AddMapRequest(CPlayer@ player, uint packet = 0)
	{
		// if (packet < getTotalPacketCount())
		// {
		// 	MapRequest request(player, packet);
		// 	requests.push_back(request);
		// }
	}

	void AddMapRequestForEveryone()
	{
		requests.clear();

		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null)
			{
				AddMapRequest(player);
			}
		}
	}

	MapRequest@ getNextMapRequest()
	{
		MapRequest@ request;
		if (hasRequests())
		{
			@request = requests[0];
			requests.removeAt(0);
		}
		return request;
	}

	bool hasRequests()
	{
		return !requests.empty();
	}

	void server_Sync()
	{
		Map@ map = getMap3D();
		if (map is null || !map.loaded) return;

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
			uint firstChunk = index * CHUNKS_PER_PACKET;
			uint lastChunk = firstChunk + CHUNKS_PER_PACKET;

			//serialize index
			CBitStream bs;
			bs.write_u32(index);

			//serialize map size
			if (index == 0)
			{
				map.getMapDimensions().Serialize(bs);
			}

			//loop through these chunks and serialize
			for (uint i = firstChunk; i < lastChunk; i++)
			{
				Chunk@ chunk = map.getChunk(i);
				if (chunk is null) break;
				chunk.Serialize(bs);
			}

			//send to requesting player
			CRules@ rules = getRules();
			rules.SendCommand(rules.getCommandID("s_map_data"), bs, player);
			print("Synced map packet " + (index + 1) + "/" + getTotalPacketCount() + " to " + player.getUsername());

			//request next packet
			AddMapRequest(player, ++index);

			getNet().server_KeepConnectionsAlive();
		}
	}

	private uint getTotalPacketCount()
	{
		return Maths::Ceil(float(getMap3D().getChunkCount()) / float(CHUNKS_PER_PACKET));
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
	if (!isServer()) return;

	getMapSyncer().server_Sync();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("s_map_data"))
	{
		if (!isClient()) return;

		uint index = params.read_u32();

		if (index == 0)
		{
			Vec3f mapDim(params);
			Map map(mapDim);
			this.set("map", map);
		}

		Map@ map = getMap3D();

		uint firstChunk = index * CHUNKS_PER_PACKET;
		uint lastChunk = firstChunk + CHUNKS_PER_PACKET;

		//get total number of packets
		uint totalPackets = Maths::Ceil(float(map.getChunkCount()) / float(CHUNKS_PER_PACKET));

		print("Received map packet " + (index + 1) + "/" + totalPackets);

		//loop through these chunks and serialize
		for (uint i = firstChunk; i < lastChunk; i++)
		{
			Chunk@ chunk = map.getChunk(i);
			if (chunk is null) break;
			chunk = Chunk(map, params);

			getNet().server_KeepConnectionsAlive();
		}

		if (index == totalPackets - 1)
		{
			map.FindVoxelNeighbors();
			map.loaded = true;
		}
	}
}
