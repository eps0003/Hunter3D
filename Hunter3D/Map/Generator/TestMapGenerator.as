#include "IMapGenerator.as"

shared class TestMapGenerator : IMapGenerator
{
	void GenerateMap(Vec3f size)
	{
		Map map(size);

		for (uint x = 0; x < size.x; x++)
		for (uint y = 0; y < size.y; y++)
		for (uint z = 0; z < size.z; z++)
		{
			Vec3f position(x, y, z);

			u8 type = 0;
			if (y == 0)
			{
				type = XORRandom(255) + 1;
			}

			Voxel voxel(type);
			map.SetVoxel(position, voxel);
		}

		getRules().set("map", map);
	}
}
