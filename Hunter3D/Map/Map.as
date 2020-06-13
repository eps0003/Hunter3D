#include "Vec3f.as"
#include "Chunk.as"
#include "Camera.as"

const u8 CHUNK_SIZE = 8;

shared Map@ getMap3D()
{
	Map@ map;
	getRules().get("map", @map);
	return map;
}

shared class Map
{
	private Chunk@[][][] chunks;

	private Vec3f mapDim;
	private Vec3f chunkDim;

	private string texture = "pixel";
	private SMaterial@ material = SMaterial();

	private Chunk@[] visibleChunks;
	private uint renderDistance = 8;
	private uint chunkUpdatesPerTick = 1;

	Map(Vec3f size)
	{
		this.mapDim = size;
		InitChunks();
	}

	Map(CBitStream@ bs)
	{
		this.mapDim = Vec3f(bs);
		InitChunks();

		for (uint x = 0; x < mapDim.x; x++)
		for (uint y = 0; y < mapDim.y; y++)
		for (uint z = 0; z < mapDim.z; z++)
		{
			Vec3f worldPos(x, y, z);
			Voxel voxel(bs);
			SetVoxel(worldPos, voxel);
		}
	}

	bool SetVoxel(Vec3f worldPos, Voxel voxel)
	{
		Vec3f chunkPos = getChunkPos(worldPos);
		Vec3f voxelPos = getVoxelPos(worldPos);

		Chunk@ chunk = getChunk(chunkPos);
		if (chunk !is null)
		{
			return chunk.SetVoxel(voxelPos, voxel);
		}

		return false;
	}

	Voxel@ getVoxel(Vec3f worldPos)
	{
		Vec3f chunkPos = getChunkPos(worldPos);
		Vec3f voxelPos = getVoxelPos(worldPos);

		Chunk@ chunk = getChunk(chunkPos);
		if (chunk !is null)
		{
			return chunk.getVoxel(voxelPos);
		}

		return null;
	}

	Vec3f getMapDimensions()
	{
		return mapDim;
	}

	void GenerateMesh()
	{
		for (uint x = 0; x < chunkDim.x; x++)
		for (uint y = 0; y < chunkDim.y; y++)
		for (uint z = 0; z < chunkDim.z; z++)
		{
			Vec3f chunkPos(x, y, z);
			Chunk@ chunk = getChunk(chunkPos);
			chunk.GenerateMesh(chunkPos);
		}
	}

	void Update()
	{
		GetVisibleChunks();
	}

	void Render()
	{
		for (uint i = 0; i < visibleChunks.length; i++)
		{
			Chunk@ chunk = visibleChunks[i];
			chunk.Render();
		}

		// for (uint x = 0; x < chunkDim.x; x++)
		// for (uint y = 0; y < chunkDim.y; y++)
		// for (uint z = 0; z < chunkDim.z; z++)
		// {
		// 	Vec3f chunkPos(x, y, z);
		// 	Chunk@ chunk = getChunk(chunkPos);
		// 	chunk.Render();
		// }
	}

	void Serialize(CBitStream@ bs)
	{
		mapDim.Serialize(bs);

		for (uint x = 0; x < mapDim.x; x++)
		for (uint y = 0; y < mapDim.y; y++)
		for (uint z = 0; z < mapDim.z; z++)
		{
			Vec3f worldPos(x, y, z);
			Voxel@ voxel = getVoxel(worldPos);
			voxel.Serialize(bs);
		}
	}

	Chunk@ getChunk(Vec3f chunkPos)
	{
		if (isValidChunk(chunkPos))
		{
			return chunks[chunkPos.x][chunkPos.y][chunkPos.z];
		}
		return null;
	}

	Vec3f getWorldPos(Vec3f chunkPos, Vec3f voxelPos)
	{
		return chunkPos * CHUNK_SIZE + voxelPos;
	}

	Vec3f getChunkPos(Vec3f worldPos)
	{
		return (worldPos / CHUNK_SIZE).floor();
	}

	Vec3f getVoxelPos(Vec3f worldPos)
	{
		return worldPos % CHUNK_SIZE;
	}

	private bool isValidChunk(Vec3f chunkPos)
	{
		return (
			chunkPos.x >= 0 && chunkPos.x < chunkDim.x &&
			chunkPos.y >= 0 && chunkPos.y < chunkDim.y &&
			chunkPos.z >= 0 && chunkPos.z < chunkDim.z
		);
	}

	private void InitChunks()
	{
		//setup material
		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);

		//get chunk dimensions
		chunkDim = getChunkPos(mapDim);

		//generate chunks
		for (uint x = 0; x < chunkDim.x; x++)
		for (uint y = 0; y < chunkDim.y; y++)
		for (uint z = 0; z < chunkDim.z; z++)
		{
			//initialize chunks array
			if (x == 0) chunks.set_length(chunkDim.x);
			if (y == 0) chunks[x].set_length(chunkDim.y);
			if (z == 0) chunks[x][y].set_length(chunkDim.z);

			Vec3f chunkPos(x, y, z);
			Chunk chunk;

			//set material
			chunk.mesh.SetMaterial(material);

			@chunks[chunkPos.x][chunkPos.y][chunkPos.z] = chunk;
		}

		//find voxel neighbors
		for (uint x = 0; x < mapDim.x; x++)
		for (uint y = 0; y < mapDim.y; y++)
		for (uint z = 0; z < mapDim.z; z++)
		{
			Vec3f worldPos(x, y, z);
			Voxel@ voxel = getVoxel(worldPos);
			voxel.FindNeighbors(this, worldPos);
		}
	}

	private void GetVisibleChunks()
	{
		Vec3f camPos = getCamera3D().getPosition();
		Vec3f centerChunkPos = getChunkPos(camPos);

		uint minX = Maths::Clamp(centerChunkPos.x - renderDistance, 0, chunkDim.x);
		uint maxX = Maths::Clamp(centerChunkPos.x + renderDistance + 1, 0, chunkDim.x);
		uint minY = 0;
		uint maxY = chunkDim.y;
		uint minZ = Maths::Clamp(centerChunkPos.z - renderDistance, 0, chunkDim.z);
		uint maxZ = Maths::Clamp(centerChunkPos.z + renderDistance + 1, 0, chunkDim.z);

		uint w = maxX - minX;
		uint h = maxY - minY;
		uint d = maxZ - minZ;

		uint index = 0;
		uint chunkUpdates = 0;

		visibleChunks.clear();
		visibleChunks.set_length(w * h * d);

		for (uint x = minX; x < maxX; x++)
		for (uint y = minY; y < maxY; y++)
		for (uint z = minZ; z < maxZ; z++)
		{
			Vec3f chunkPos(x, y, z);
			Chunk@ chunk = getChunk(chunkPos);

			if (chunk.outdatedMesh && chunkUpdates <= chunkUpdatesPerTick)
			{
				chunk.GenerateMesh(chunkPos);
				chunkUpdates++;
			}

			@visibleChunks[index++] = chunk;
		}
	}
}
