#include "Voxel.as"

shared class Chunk
{
	private Voxel@[][][] voxels;

	private SMesh@ mesh = SMesh();
	private Vertex[] vertices;
	private u16[] indices;

	bool outdatedMesh = true;

	Chunk(Map@ map)
	{
		mesh.SetMaterial(map.material);

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

	Chunk(Map@ map, CBitStream@ bs)
	{
		mesh.SetMaterial(map.material);

		for (uint x = 0; x < CHUNK_SIZE; x++)
		for (uint y = 0; y < CHUNK_SIZE; y++)
		for (uint z = 0; z < CHUNK_SIZE; z++)
		{
			//initialize voxels array
			if (x == 0) voxels.set_length(CHUNK_SIZE);
			if (y == 0) voxels[x].set_length(CHUNK_SIZE);
			if (z == 0) voxels[x][y].set_length(CHUNK_SIZE);

			Vec3f voxelPos(x, y, z);
			Voxel voxel(bs);

			@voxels[voxelPos.x][voxelPos.y][voxelPos.z] = voxel;
		}
	}

	bool SetVoxel(Vec3f voxelPos, Voxel voxel)
	{
		Voxel@ currentVoxel = getVoxel(voxelPos);
		if (currentVoxel != null)
		{
			currentVoxel = voxel;
			outdatedMesh = true;
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

	void GenerateMesh(Vec3f chunkPos)
	{
		outdatedMesh = false;
		print("Generate mesh " + chunkPos.toString());

		vertices.clear();
		indices.clear();

		for (uint x = 0; x < CHUNK_SIZE; x++)
		for (uint y = 0; y < CHUNK_SIZE; y++)
		for (uint z = 0; z < CHUNK_SIZE; z++)
		{
			Vec3f voxelPos(x, y, z);
			Voxel@ voxel = getVoxel(voxelPos);
			if (voxel !is null)
			{
				Vec3f worldPos = getMap3D().getWorldPos(chunkPos, voxelPos);
				voxel.GenerateMesh(this, worldPos, vertices, indices);
			}
		}

		if (!vertices.empty())
		{
			mesh.SetVertex(vertices);
			mesh.SetIndices(indices);
			mesh.BuildMesh();
		}
	}

	void Render()
	{
		if (!vertices.empty())
		{
			float[] matrix;
			Matrix::MakeIdentity(matrix);
			Render::SetModelTransform(matrix);

			mesh.RenderMeshWithMaterial();
		}
	}

	void Serialize(CBitStream@ bs)
	{
		for (uint x = 0; x < CHUNK_SIZE; x++)
		for (uint y = 0; y < CHUNK_SIZE; y++)
		for (uint z = 0; z < CHUNK_SIZE; z++)
		{
			Vec3f voxelPos(x, y, z);
			Voxel@ voxel = getVoxel(voxelPos);
			voxel.Serialize(bs);
		}
	}

	private bool isValidVoxel(Vec3f voxelPos)
	{
		return (
			voxelPos.x >= 0 && voxelPos.x < CHUNK_SIZE &&
			voxelPos.y >= 0 && voxelPos.y < CHUNK_SIZE &&
			voxelPos.z >= 0 && voxelPos.z < CHUNK_SIZE
		);
	}
}
