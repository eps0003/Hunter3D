#include "MapGenerator.as"

shared class TestMapGenerator : MapGenerator
{
	TestMapGenerator(Vec3f size)
	{
		super(size);
	}

	TestMapGenerator(Vec3f size, uint seed)
	{
		super(size, seed);
	}

	void GenerateMap()
	{
		if (chunkIndex == 0)
		{
			Map map(size);
			getRules().set("map", map);
		}

		Map@ map = getMap3D();
		uint index = chunkIndex * VOXELS_PER_CHUNK;

		for (uint i = index; i < index + VOXELS_PER_CHUNK; i++)
		{
			uint x = i / (size.y * size.z);
			uint y = (i / size.z) % size.y;
			uint z = i % size.z;

			u8 type = 0;
			if (y == 0)
			{
				type = XORRandom(255) + 1;
			}

			Voxel voxel(type);
			map.SetVoxel(Vec3f(x, y, z), voxel);
		}

		if (chunkIndex < getChunkCount() - 1)
		{
			chunkIndex++;
		}
		else
		{
			map.loaded = true;
		}
	}
}
