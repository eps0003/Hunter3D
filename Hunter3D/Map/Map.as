#include "Vec3f.as"
#include "Chunk.as"
#include "Camera.as"
#include "Tree.as"

const u8 CHUNK_SIZE = 12;

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
	private u8[] map;
	private Chunk@[] chunks;

	private Vec3f mapDim;
	private Vec3f chunkDim;

	private string texture = "BlocksMC.png";
	private SMaterial@ material = SMaterial();

	private Tree@ chunkTree;
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

	void InitChunkTree()
	{
		@chunkTree = Tree(this, Vec3f(), nearestPower(chunkDim));
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

	void SetBlockSafe(Vec3f position, u8 block)
	{
		SetBlockSafe(position.x, position.y, position.z, block);
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

	void SetBlock(Vec3f position, u8 block)
	{
		SetBlock(position.x, position.y, position.z, block);
	}

	void SetBlock(int x, int y, int z, u8 block)
	{
		SetBlock(toIndex(x, y, z), block);
	}

	void SetBlock(int index, u8 block)
	{
		map[index] = block;
	}

	u8 getBlockSafe(Vec3f position)
	{
		return getBlockSafe(position.x, position.y, position.z);
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

	u8 getBlock(Vec3f position)
	{
		return getBlock(position.x, position.y, position.z);
	}

	u8 getBlock(int x, int y, int z)
	{
		return getBlock(toIndex(x, y, z));
	}

	u8 getBlock(int index)
	{
		return map[index];
	}

	Chunk@ getChunkSafe(Vec3f position)
	{
		return getChunkSafe(position.x, position.y, position.z);
	}

	Chunk@ getChunkSafe(int x, int y, int z)
	{
		if (isValidChunk(x, y, z))
		{
			int index = toIndexChunk(x, y, z);
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

	Chunk@ getChunk(Vec3f position)
	{
		return getChunk(position.x, position.y, position.z);
	}

	Chunk@ getChunk(int x, int y, int z)
	{
		int index = toIndexChunk(x, y, z);
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

	bool isValidBlock(Vec3f position)
	{
		return isValidBlock(position.x, position.y, position.z);
	}

	bool isValidBlock(int x, int y, int z)
	{
		return (
			x >= 0 && x < mapDim.x &&
			y >= 0 && y < mapDim.y &&
			z >= 0 && z < mapDim.z
		);
	}

	bool isValidBlock(int index)
	{
		return index >= 0 && index < map.length;
	}

	bool isValidChunk(Vec3f position)
	{
		return isValidChunk(position.x, position.y, position.z);
	}

	bool isValidChunk(int x, int y, int z)
	{
		return (
			x >= 0 && x < chunkDim.x &&
			y >= 0 && y < chunkDim.y &&
			z >= 0 && z < chunkDim.z
		);
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

	Vec3f getChunkPos(Vec3f position)
	{
		return getChunkPos(position.x, position.y, position.z);
	}

	Vec3f getChunkPos(int x, int y, int z)
	{
		return (Vec3f(x, y, z) / CHUNK_SIZE).floor();
	}

	//https://coderwall.com/p/fzni3g/bidirectional-translation-between-1d-and-3d-arrays
	int toIndex(Vec3f position)
	{
		return toIndex(position.x, position.y, position.z);
	}

	int toIndex(int x, int y, int z)
	{
		return x + (y * mapDim.x) + (z * mapDim.z * mapDim.y);
	}

	int toIndexChunk(Vec3f position)
	{
		return toIndexChunk(position.x, position.y, position.z);
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

	uint getBlockCount()
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

	void Render()
	{
		material.SetVideoMaterial();
		GetVisibleChunks();

		for (uint i = 0; i < visibleChunks.length; i++)
		{
			Chunk@ chunk = visibleChunks[i];
			chunk.Render();
			// chunk.getBounds().Render();
		}
	}

	private void GetVisibleChunks()
	{
		visibleChunks.clear();
		// chunkTree.GetVisibleChunks(getCamera3D(), visibleChunks);

		Camera@ camera = getCamera3D();

		Frustum frustum = camera.getFrustum();
		AABB bounds = frustum.getBounds();

		Vec3f min = (bounds.min.max(Vec3f()) / CHUNK_SIZE).floor();
		Vec3f max = (bounds.max.min(mapDim) / CHUNK_SIZE).ceil();

		//frustum bounds arent in map bounds
		if (max.x <= min.x || max.y <= min.y || max.z <= min.z)
		{
			return;
		}

		for (uint x = min.x; x < max.x; x++)
		for (uint y = min.y; y < max.y; y++)
		for (uint z = min.z; z < max.z; z++)
		{
			Chunk@ chunk = getChunk(x, y, z);
			chunk.GenerateMesh();
			if (chunk.hasVertices())
			{
				visibleChunks.push_back(chunk);
			}
		}
	}
}
