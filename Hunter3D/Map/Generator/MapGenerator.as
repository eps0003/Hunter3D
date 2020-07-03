const uint VOXELS_PER_CHUNK = 512;

shared class MapGenerator
{
	private Vec3f size;
	private Random@ random;
	uint chunkIndex = 0;
	uint voxelChunkCount;

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
		Map map(size);
		getRules().set("map", map);
		getMap3D().loaded = true;
	}

	uint getVoxelCount()
	{
		return size.x * size.y * size.z;
	}

	uint getChunkCount()
	{
		return Maths::Ceil(float(getVoxelCount()) / float(VOXELS_PER_CHUNK));
	}
}
