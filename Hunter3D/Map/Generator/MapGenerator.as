const uint VOXELS_PER_CHUNK = 512 * 3;

shared class MapGenerator
{
	private Vec3f size;
	private Random@ random;
	private uint chunkIndex = 0;

	MapGenerator(Vec3f size)
	{
		this.size = size;
		@this.random = Random();
	}

	MapGenerator(Vec3f size, uint seed)
	{
		this.size = size;
		@this.random = Random(seed);
	}

	void GenerateMap()
	{
		//note: 'chunk' in this context refers to a section of voxels generated this tick

		//initialize map
		if (chunkIndex == 0)
		{
			Map map(size);
			getRules().set("map", map);
		}

		//get map
		Map@ map = getMap3D();

		//dont load if map is already loaded
		if (map.loaded) return;

		//get start and end voxel index
		uint startIndex = chunkIndex * VOXELS_PER_CHUNK;
		uint endIndex = Maths::Min(startIndex + VOXELS_PER_CHUNK, size.x * size.y * size.z);

		//get chunk dimensions once before loop
		Vec3f chunkDim = map.getChunkDimensions();

		//loop through voxels in this chunk
		for (uint i = startIndex; i < endIndex; i++)
		{
			//calculate world position using index
			uint x = i / (size.y * size.z);
			uint y = (i / size.z) % size.y;
			uint z = i % size.z;

			Vec3f worldPos(x, y, z);
			Vec3f chunkPos = (worldPos / CHUNK_SIZE).floor();

			//initialize chunk arrays
			if (worldPos.x == 0) map.chunks.set_length(chunkDim.x);
			if (worldPos.y == 0) map.chunks[chunkPos.x].set_length(chunkDim.y);
			if (worldPos.z == 0) map.chunks[chunkPos.x][chunkPos.y].set_length(chunkDim.z);

			//initialize chunk
			if (x % CHUNK_SIZE == 0 && y % CHUNK_SIZE == 0 && z % CHUNK_SIZE == 0)
			{
				map.InitChunk(chunkPos);
			}

			//initialize voxel
			u8 type = GenerateVoxel(x, y, z);
			Voxel voxel(type);
			map.InitVoxel(worldPos, voxel);
		}

		uint chunkCount = getChunkCount();
		print("Generating map: " + (chunkIndex + 1) + "/" + chunkCount);

		if (chunkIndex < chunkCount - 1)
		{
			//move onto next chunk
			chunkIndex++;
		}
		else
		{
			//map generation complete
			print("Map generated!");
			map.loaded = true;
		}
	}

	u8 GenerateVoxel(uint x, uint y, uint z)
	{
		return 0;
	}

	// ????? GenerateFoliage(uint x, uint y, uint z)
	// {
	// 	//return foliage type from enum
	// }

	uint getVoxelCount()
	{
		return size.x * size.y * size.z;
	}

	private uint getChunkCount()
	{
		return Maths::Ceil(float(getVoxelCount()) / float(VOXELS_PER_CHUNK));
	}
}
