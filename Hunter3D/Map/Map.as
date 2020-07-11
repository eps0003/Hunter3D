#include "Vec3f.as"
#include "Chunk.as"
#include "Camera.as"

const u8 CHUNK_SIZE = 16;

enum BlockType
{
	Air,
	Grass,
	Dirt,
	Stone,
	Gravel,
	Cobblestone,
	Gold,
	Crate,
	BirchLog,
	OakLog,
	Leaves,
	BirchWood,
	OakWood,
	Bricks,
	Glass,
	RedWool,
	OrangeWool,
	YellowWool,
	LimeWool,
	CyanWool,
	BlueWool,
	PurpleWool,
	WhiteWool,
	GrayWool,
	BlackWool,
	BrownWool,
	PinkWool,
	Iron,
	Steel,
	Gears,
	Bedrock
}

shared Map@ getMap3D()
{
	Map@ map;
	getRules().get("map", @map);
	return map;
}

shared class Map
{
	u8[] map;
	Chunk@[] chunks;

	private Vec3f mapDim;
	private Vec3f chunkDim;

	private string texture = "BlocksMC.png";
	private SMaterial@ material = SMaterial();

	private Chunk@[] visibleChunks;
	// private uint chunkUpdatesPerTick = 1;

	private bool loaded = false;

	//blocks
	private string[] name;
	private bool[] visible;
	private bool[] solid;
	private bool[] destructable;
	private bool[] collapsable;
	private bool[] seeThrough;

	Map(Vec3f mapDim)
	{
		this.mapDim = mapDim;
		map.set_length(mapDim.x * mapDim.y * mapDim.z);

		InitMaterial();
		InitBlocksTypes();
	}

	private void InitMaterial()
	{
		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);
	}

	void InitChunks()
	{
		chunkDim = (mapDim / CHUNK_SIZE).ceil();
		chunks.set_length(chunkDim.x * chunkDim.y * chunkDim.z);
	}

	void InitBlocksTypes()
	{
		name.clear();
		visible.clear();
		solid.clear();
		destructable.clear();
		collapsable.clear();
		seeThrough.clear();

		//							visible solid destroy collapse seethr
		AddBlockType("Air",			false,	false,	false,	false,	true);
		AddBlockType("Grass",		true,	true,	true,	false,	false);
		AddBlockType("Dirt", 		true,	true,	true,	false,	false);
		AddBlockType("Stone",		true,	true,	true,	false,	false);
		AddBlockType("Gravel",		true,	true,	true,	false,	false);
		AddBlockType("Cobblestone",	true,	true,	true,	true,	false);
		AddBlockType("Gold",		true,	true,	true,	true,	false);
		AddBlockType("Crate",		true,	true,	true,	true,	false);
		AddBlockType("Birch Log",	true,	true,	true,	true,	false);
		AddBlockType("Oak Log",		true,	true,	true,	true,	false);
		AddBlockType("Leaves",		true,	false,	true,	true,	true);
		AddBlockType("Birch Wood",	true,	true,	true,	true,	false);
		AddBlockType("Oak Wood",	true,	true,	true,	true,	false);
		AddBlockType("Bricks",		true,	true,	true,	true,	false);
		AddBlockType("Glass",		true,	true,	true,	true,	true);
		AddBlockType("Red Wool",	true,	true,	true,	true,	false);
		AddBlockType("Orange Wool",	true,	true,	true,	true,	false);
		AddBlockType("Yellow Wool",	true,	true,	true,	true,	false);
		AddBlockType("Lime Wool",	true,	true,	true,	true,	false);
		AddBlockType("Cyan Wool",	true,	true,	true,	true,	false);
		AddBlockType("Blue Wool",	true,	true,	true,	true,	false);
		AddBlockType("Purple Wool",	true,	true,	true,	true,	false);
		AddBlockType("White Wool",	true,	true,	true,	true,	false);
		AddBlockType("Gray Wool",	true,	true,	true,	true,	false);
		AddBlockType("Black Wool",	true,	true,	true,	true,	false);
		AddBlockType("Brown Wool",	true,	true,	true,	true,	false);
		AddBlockType("Pink Wool",	true,	true,	true,	true,	false);
		AddBlockType("Iron",		true,	true,	true,	true,	false);
		AddBlockType("Steel",		true,	true,	true,	true,	false);
		AddBlockType("Gears",		true,	true,	true,	true,	false);
		AddBlockType("Bedrock",		true,	true,	false,	false,	false);
	}

	void AddBlockType(string _name, bool _visible, bool _solid, bool _destructable, bool _collapsable, bool _seeThrough)
	{
		name.push_back(_name);
		visible.push_back(_visible);
		solid.push_back(_solid);
		destructable.push_back(_destructable);
		collapsable.push_back(_collapsable);
		seeThrough.push_back(_seeThrough);
	}

	void SetBlockSafe(int x, int y, int z, u8 block)
	{
		if (isValidBlock(x, y, z))
		{
			SetBlock(x, y, z, block);
		}
	}

	void SetBlockSafe(int index, u8 block)
	{
		if (isValidBlock(index))
		{
			SetBlock(index, block);
		}
	}

	void SetBlock(int x, int y, int z, u8 block)
	{
		SetBlock(toIndex(x, y, z), block);
	}

	void SetBlock(int index, u8 block)
	{
		map[index] = block;
	}

	u8 getBlockSafe(int x, int y, int z)
	{
		if (isValidBlock(x, y, z))
		{
			return getBlock(x, y, z);
		}
		return 0;
	}

	u8 getBlockSafe(int index)
	{
		if (isValidBlock(index))
		{
			return getBlock(index);
		}
		return 0;
	}

	u8 getBlock(int x, int y, int z)
	{
		return getBlock(toIndex(x, y, z));
	}

	u8 getBlock(int index)
	{
		return map[index];
	}

	Chunk@ getChunkSafe(int worldX, int worldY, int worldZ)
	{
		if (isValidBlock(worldX, worldY, worldZ))
		{
			Vec3f chunkPos = (Vec3f(worldX, worldY, worldZ) / CHUNK_SIZE).floor();
			int index = toIndexChunk(chunkPos.x, chunkPos.y, chunkPos.z);
			return getChunk(index);
		}
		return null;
	}

	Chunk@ getChunkSafe(int index)
	{
		if (isValidChunk(index))
		{
			return chunks[index];
		}
		return null;
	}

	Chunk@ getChunk(int x, int y, int z)
	{
		Vec3f chunkPos = getChunkPos(x, y, z);
		int index = toIndexChunk(chunkPos.x, chunkPos.y, chunkPos.z);
		return chunks[index];
	}

	Chunk@ getChunk(int index)
	{
		return chunks[index];
	}

	void SetChunk(int index, Chunk@ chunk)
	{
		@chunks[index] = chunk;
	}

	bool isValidBlock(int x, int y, int z)
	{
		return (
			x >= 0 && x < mapDim.x &&
			y >= 0 && y < mapDim.y &&
			z >= 0 && z < mapDim.z
		);
	}

	bool isValidChunk(int x, int y, int z)
	{
		return (
			x >= 0 && x < chunkDim.x &&
			y >= 0 && y < chunkDim.y &&
			z >= 0 && z < chunkDim.z
		);
	}

	bool isValidBlock(int index)
	{
		return index >= 0 && index < map.length;
	}

	bool isValidChunk(int index)
	{
		return index >= 0 && index < chunks.length;
	}

	bool isBlockVisible(u8 block)
	{
		return visible[block];
	}

	bool isBlockSolid(u8 block)
	{
		return solid[block];
	}

	bool isBlockDestructable(u8 block)
	{
		return destructable[block];
	}

	bool isBlockCollapsable(u8 block)
	{
		return collapsable[block];
	}

	bool isBlockSeeThrough(u8 block)
	{
		return seeThrough[block];
	}

	Vec3f getChunkPos(int x, int y, int z)
	{
		return (Vec3f(x, y, z) / CHUNK_SIZE).floor();
	}

	//https://coderwall.com/p/fzni3g/bidirectional-translation-between-1d-and-3d-arrays
	int toIndex(int x, int y, int z)
	{
		return x + (y * mapDim.x) + (z * mapDim.z * mapDim.y);
	}

	int toIndexChunk(int x, int y, int z)
	{
		return x + (y * chunkDim.x) + (z * chunkDim.z * chunkDim.y);
	}

	Vec3f to3D(int index)
	{
		Vec3f vec;
		vec.x = index % mapDim.x;
		vec.y = Maths::Floor(index / mapDim.x) % mapDim.y;
		vec.z = Maths::Floor(index / (mapDim.x * mapDim.y));
		return vec;
	}

	Vec3f to3DChunk(int index)
	{
		Vec3f vec;
		vec.x = index % chunkDim.x;
		vec.y = Maths::Floor(index / chunkDim.x) % chunkDim.y;
		vec.z = Maths::Floor(index / (chunkDim.x * chunkDim.y));
		return vec;
	}

	Vec3f getMapDimensions()
	{
		return mapDim;
	}

	uint getVoxelCount()
	{
		return map.length;
	}

	uint getChunkCount()
	{
		return chunks.length;
	}

	void SetLoaded()
	{
		loaded = true;
	}

	bool isLoaded()
	{
		return loaded;
	}

	void Update()
	{
		GetVisibleChunks();
	}

	void Render()
	{
		material.SetVideoMaterial();

		for (uint i = 0; i < visibleChunks.length; i++)
		{
			Chunk@ chunk = visibleChunks[i];
			chunk.Render();
		}
	}

	void GenerateChunkMesh(uint index)
	{
		Chunk@ chunk = chunks[index];
		chunk.GenerateMesh();
	}

	private void GetVisibleChunks()
	{
		for (uint i = 0; i < chunks.length; i++)
		{
			Chunk@ chunk = chunks[i];
			chunk.GenerateMesh();
		}

		visibleChunks = chunks;

		// Vec3f camPos = getCamera3D().getPosition();
		// Vec3f centerChunkPos = getChunkPos(camPos.x, camPos.y, camPos.z);

		// uint minX = Maths::Clamp(centerChunkPos.x - renderDistance, 0, chunkDim.x);
		// uint maxX = Maths::Clamp(centerChunkPos.x + renderDistance + 1, 0, chunkDim.x);
		// uint minY = 0;
		// uint maxY = chunkDim.y;
		// uint minZ = Maths::Clamp(centerChunkPos.z - renderDistance, 0, chunkDim.z);
		// uint maxZ = Maths::Clamp(centerChunkPos.z + renderDistance + 1, 0, chunkDim.z);

		// uint w = maxX - minX;
		// uint h = maxY - minY;
		// uint d = maxZ - minZ;

		// uint index = 0;
		// uint chunkUpdates = 0;

		// visibleChunks.clear();
		// visibleChunks.set_length(w * h * d);

		// for (uint x = minX; x < maxX; x++)
		// for (uint y = minY; y < maxY; y++)
		// for (uint z = minZ; z < maxZ; z++)
		// {
		// 	Vec3f chunkPos(x, y, z);
		// 	Chunk@ chunk = getChunk(chunkPos);

		// 	chunk.GenerateMesh(chunkPos);

		// 	@visibleChunks[index++] = chunk;
		// }
	}
}
