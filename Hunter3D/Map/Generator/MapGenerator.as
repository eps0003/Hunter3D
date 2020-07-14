shared class MapGenerator
{
	private Vec3f size;
	private uint chunkIndex = 0;
	private uint blocksPerChunk = 10000;

	private Noise@ noise;

	MapGenerator(Vec3f size)
	{
		this.size = size;
		@noise = Noise();
	}

	MapGenerator(Vec3f size, uint seed)
	{
		this.size = size;
		@noise = Noise(seed);
	}

	void GenerateMap()
	{
		//initialize map
		if (chunkIndex == 0)
		{
			Map map(size);
			getRules().set("map", map);
		}

		//get map
		Map@ map = getMap3D();

		//dont load if map is already loaded
		if (map.isLoaded()) return;

		//get start and end block index
		uint startIndex = chunkIndex * blocksPerChunk;
		uint endIndex = Maths::Min(startIndex + blocksPerChunk, size.x * size.y * size.z);

		//loop through blocks in this chunk
		for (uint i = startIndex; i < endIndex; i++)
		{
			Vec3f pos = map.to3D(i);
			u8 type = GenerateBlock(pos.x, pos.y, pos.z);
			map.SetBlock(pos.x, pos.y, pos.z, type);
		}

		uint chunkCount = getChunkCount();
		// print("Generating map: " + (chunkIndex + 1) + "/" + chunkCount);

		if (isClient())
		{
			ModLoader@ modLoader = getModLoader();
			modLoader.SetProgress(float(chunkIndex) / float(chunkCount));
		}

		if (chunkIndex < chunkCount - 1)
		{
			//move onto next chunk
			chunkIndex++;
		}
		else
		{
			//map generation complete
			map.SetLoaded();
		}
	}

	u8 GenerateBlock(uint x, uint y, uint z)
	{
		Vec3f mapDim = getMapDimensions();

		uint centerLine = mapDim.y / 2.0f;
		float amplitude = mapDim.y / 2.0f;
		float frequency = 0.05f;
		uint h = centerLine + noise.Sample(x * frequency, z * frequency) * amplitude;

		if (y == 0)
		{
			return BlockType::Bedrock;
		}
		else if (y == h)
		{
			return BlockType::Grass;
		}
		else if (y < h)
		{
			return BlockType::Dirt;
		}

		return BlockType::Air;
	}

	// u8 GenerateFoliage(uint x, uint y, uint z)
	// {
	// 	//return foliage type from enum
	// }

	uint getBlockCount()
	{
		return size.x * size.y * size.z;
	}

	Vec3f getMapDimensions()
	{
		return size;
	}

	private uint getChunkCount()
	{
		return Maths::Ceil(float(getBlockCount()) / float(blocksPerChunk));
	}
}
