shared class Chunk
{
	private Map@ map;
	private SMesh mesh;
	private Vertex[] vertices;
	private u16[] indices;
	private uint index;

	private bool rebuild = true;

	Chunk(Map@ map, uint index)
	{
		@this.map = map;
		this.index = index;

		GenerateMesh();
	}

	void SetRebuild()
	{
		rebuild = true;
	}

	void GenerateMesh()
	{
		if (rebuild)
		{
			rebuild = false;

			vertices.clear();
			indices.clear();

			Vec3f chunkPos = map.to3DChunk(index);

			Vec3f startWorldPos = chunkPos * CHUNK_SIZE;
			Vec3f endWorldPos = (startWorldPos + CHUNK_SIZE).min(map.getMapDimensions());

			for (uint x = startWorldPos.x; x < endWorldPos.x; x++)
			for (uint y = startWorldPos.y; y < endWorldPos.y; y++)
			for (uint z = startWorldPos.z; z < endWorldPos.z; z++)
			{
				u8 block = map.getBlock(x, y, z);

				if (map.isBlockVisible(block))
				{
					float x1 = block / 8.0f;
					float y1 = Maths::Floor(x1) / 32.0f;
					float x2 = x1 + (1.0f / 32.0f);
					float y2 = y1 + (1.0f / 32.0f);

					SColor col = color_white;

					float overlap = 0.001f; //so faint lines dont appear between planes
					Vec3f p = Vec3f(x, y, z) - overlap;
					float w = 1 + overlap * 2;

					u8 left  = map.getBlockSafe(x - 1, y, z);
					u8 right = map.getBlockSafe(x + 1, y, z);
					u8 down  = map.getBlockSafe(x, y - 1, z);
					u8 up    = map.getBlockSafe(x, y + 1, z);
					u8 front = map.getBlockSafe(x, y, z - 1);
					u8 back  = map.getBlockSafe(x, y, z + 1);

					bool leftVisible  = map.isBlockSeeThrough(left);
					bool rightVisible = map.isBlockSeeThrough(right);
					bool downVisible  = map.isBlockSeeThrough(down);
					bool upVisible    = map.isBlockSeeThrough(up);
					bool frontVisible = map.isBlockSeeThrough(front);
					bool backVisible  = map.isBlockSeeThrough(back);

					uint vertexCount = (num(leftVisible) + num(rightVisible) + num(downVisible) + num(upVisible) + num(frontVisible) + num(backVisible)) * 4;
					uint indexCount = vertexCount * 1.5f;

					uint vi = vertices.length;
					uint ii = indices.length;

					vertices.set_length(vertices.length + vertexCount);
					indices.set_length(indices.length + indexCount);

					if (leftVisible)
					{
						vertices[vi++] = Vertex(p.x, p.y + w, p.z + w, x1, y1, col);
						vertices[vi++] = Vertex(p.x, p.y + w, p.z    , x2, y1, col);
						vertices[vi++] = Vertex(p.x, p.y    , p.z    , x2, y2, col);
						vertices[vi++] = Vertex(p.x, p.y    , p.z + w, x1, y2, col);
						ii = AddIndices(ii, vi);
					}

					if (rightVisible)
					{
						vertices[vi++] = Vertex(p.x + w, p.y + w, p.z    , x1, y1, col);
						vertices[vi++] = Vertex(p.x + w, p.y + w, p.z + w, x2, y1, col);
						vertices[vi++] = Vertex(p.x + w, p.y    , p.z + w, x2, y2, col);
						vertices[vi++] = Vertex(p.x + w, p.y    , p.z    , x1, y2, col);
						ii = AddIndices(ii, vi);
					}

					if (downVisible)
					{
						vertices[vi++] = Vertex(p.x + w, p.y, p.z + w, x1, y1, col);
						vertices[vi++] = Vertex(p.x    , p.y, p.z + w, x2, y1, col);
						vertices[vi++] = Vertex(p.x    , p.y, p.z    , x2, y2, col);
						vertices[vi++] = Vertex(p.x + w, p.y, p.z    , x1, y2, col);
						ii = AddIndices(ii, vi);
					}

					if (upVisible)
					{
						vertices[vi++] = Vertex(p.x    , p.y + w, p.z + w, x1, y1, col);
						vertices[vi++] = Vertex(p.x + w, p.y + w, p.z + w, x2, y1, col);
						vertices[vi++] = Vertex(p.x + w, p.y + w, p.z    , x2, y2, col);
						vertices[vi++] = Vertex(p.x    , p.y + w, p.z    , x1, y2, col);
						ii = AddIndices(ii, vi);
					}

					if (frontVisible)
					{
						vertices[vi++] = Vertex(p.x    , p.y + w, p.z, x1, y1, col);
						vertices[vi++] = Vertex(p.x + w, p.y + w, p.z, x2, y1, col);
						vertices[vi++] = Vertex(p.x + w, p.y    , p.z, x2, y2, col);
						vertices[vi++] = Vertex(p.x    , p.y    , p.z, x1, y2, col);
						ii = AddIndices(ii, vi);
					}

					if (backVisible)
					{
						vertices[vi++] = Vertex(p.x + w, p.y + w, p.z + w, x1, y1, col);
						vertices[vi++] = Vertex(p.x    , p.y + w, p.z + w, x2, y1, col);
						vertices[vi++] = Vertex(p.x    , p.y    , p.z + w, x2, y2, col);
						vertices[vi++] = Vertex(p.x + w, p.y    , p.z + w, x1, y2, col);
						ii = AddIndices(ii, vi);
					}
				}
			}
		}

		if (!vertices.empty())
		{
            mesh.SetVertex(vertices);
            mesh.SetIndices(indices);
            mesh.SetDirty(SMesh::VERTEX_INDEX);
            mesh.BuildMesh();
		}
		else
		{
			mesh.Clear();
		}
	}

	void Render()
	{
		mesh.RenderMesh();
	}

	private uint AddIndices(uint ii, uint vi)
	{
		indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
		indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
		return ii;
	}
}
