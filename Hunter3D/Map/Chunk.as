#include "Voxel.as"

class Chunk
{
	private Voxel@[][][] voxels;

	Vertex[] vertices;

	Chunk()
	{
		InitChunk();
	}

	bool SetVoxel(Vec3f voxelPos, Voxel voxel)
	{
		Voxel@ currentVoxel = getVoxel(voxelPos);
		if (currentVoxel != null)
		{
			currentVoxel = voxel;
			return true;
		}
		return false;
	}

	Voxel@ getVoxel(Vec3f voxelPos)
	{
		if (isValidVoxel(voxelPos))
		{
			return voxels[voxelPos.x][voxelPos.y][voxelPos.z];
		}
		return null;
	}

	private bool isValidVoxel(Vec3f voxelPos)
	{
		return (
			voxelPos.x >= 0 && voxelPos.x < CHUNK_SIZE &&
			voxelPos.y >= 0 && voxelPos.y < CHUNK_SIZE &&
			voxelPos.z >= 0 && voxelPos.z < CHUNK_SIZE
		);
	}

	private void InitChunk()
	{
		for (uint x = 0; x < CHUNK_SIZE; x++)
		for (uint y = 0; y < CHUNK_SIZE; y++)
		for (uint z = 0; z < CHUNK_SIZE; z++)
		{
			//initialize voxels array
			if (x == 0) voxels.set_length(CHUNK_SIZE);
			if (y == 0) voxels[x].set_length(CHUNK_SIZE);
			if (z == 0) voxels[x][y].set_length(CHUNK_SIZE);

			Vec3f voxelPos(x, y, z);
			Voxel voxel();

			@voxels[voxelPos.x][voxelPos.y][voxelPos.z] = voxel;
		}
	}

	void GenerateMesh(Vec3f chunkPos)
	{
		print("Generate mesh " + chunkPos.toString());

		vertices.clear();

		for (uint x = 0; x < CHUNK_SIZE; x++)
		for (uint y = 0; y < CHUNK_SIZE; y++)
		for (uint z = 0; z < CHUNK_SIZE; z++)
		{
			Vec3f voxelPos(x, y, z);
			Voxel@ voxel = getVoxel(voxelPos);
			if (voxel !is null)
			{
				Vec3f worldPos = getMap3D().getWorldPos(chunkPos, voxelPos);
				voxel.GenerateMesh(this, worldPos, vertices);
			}
		}
	}
}
