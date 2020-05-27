#include "Chunk.as"

const u8 CHUNK_SIZE = 8;

class Map
{
	private Chunk@[][][] chunks;
	private Vec3f mapDim;
	private Vec3f chunkDim;

	Map(Vec3f size)
	{
		this.mapDim = size;
		InitChunks();
	}

	void SetVoxel(Vec3f position, Voxel voxel)
	{
		Vec3f chunkPos = getChunkPos(position);
		Vec3f voxelPos = getVoxelPos(position);

		Chunk@ chunk = getChunk(chunkPos);
		if (chunk !is null)
		{
			chunk.SetVoxel(voxelPos, voxel);
		}
	}

	Voxel@ getVoxel(Vec3f position)
	{
		Vec3f chunkPos = getChunkPos(position);
		Vec3f voxelPos = getVoxelPos(position);

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
			Vec3f position(x, y, z);
			Chunk@ chunk = getChunk(position);
			chunk.GenerateMesh();
		}
	}

	void Render()
	{
		for (uint x = 0; x < chunkDim.x; x++)
		for (uint y = 0; y < chunkDim.y; y++)
		for (uint z = 0; z < chunkDim.z; z++)
		{
			Vec3f position(x, y, z);
			Chunk@ chunk = getChunk(position);
			Render::RawQuads("pixel", chunk.vertices);
		}
	}

	private Chunk@ getChunk(Vec3f chunkPos)
	{
		if (isValidChunk(chunkPos))
		{
			return chunks[chunkPos.x][chunkPos.y][chunkPos.z];
		}
		return null;
	}

	private bool isValidChunk(Vec3f chunkPos)
	{
		return (
			chunkPos.x >= 0 && chunkPos.x < chunkDim.x &&
			chunkPos.y >= 0 && chunkPos.y < chunkDim.y &&
			chunkPos.z >= 0 && chunkPos.z < chunkDim.z
		);
	}

	private Vec3f getChunkPos(Vec3f worldPos)
	{
		return (worldPos / CHUNK_SIZE).floor();
	}

	private Vec3f getVoxelPos(Vec3f worldPos)
	{
		return worldPos % CHUNK_SIZE;
	}

	private void InitChunks()
	{
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
			Chunk chunk(chunkPos);

			@chunks[chunkPos.x][chunkPos.y][chunkPos.z] = chunk;
		}

		//find voxel neighbors
		for (uint x = 0; x < mapDim.x; x++)
		for (uint y = 0; y < mapDim.y; y++)
		for (uint z = 0; z < mapDim.z; z++)
		{
			Voxel@ voxel = getVoxel(Vec3f(x, y, z));
			voxel.FindNeighbors(this);
		}
	}
}
