#include "MapGenerator.as"

shared class TestMapGenerator : MapGenerator
{
	TestMapGenerator(Vec3f size)
	{
		super(size);
	}

	u8 GenerateBlock(uint x, uint y, uint z)
	{
		if (y == 0)
		{
			return BlockType::Grass;
		}

		return BlockType::Air;
	}
}
