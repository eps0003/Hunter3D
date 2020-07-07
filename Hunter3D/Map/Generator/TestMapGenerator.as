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

	u8 GenerateVoxel(uint x, uint y, uint z)
	{
		if (y == 0)
		{
			return XORRandom(255) + 1;
		}

		return 0;
	}
}
