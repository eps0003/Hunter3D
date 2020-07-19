shared class Chunk
{
	private Map@ map;

	private uint index;
	private bool rebuild = true;

	private SMesh mesh;
	private Vertex[] vertices;
	private u16[] indices;
	private bool noVertices = true;

    private AABB box;

	Chunk(Map@ map, uint index)
	{
		@this.map = map;
		this.index = index;

		Vec3f startWorldPos = map.to3DChunk(index) * CHUNK_SIZE;
		Vec3f endWorldPos = startWorldPos + CHUNK_SIZE;
        box = AABB(startWorldPos, endWorldPos);

        mesh.SetHardwareMapping(SMesh::STATIC);

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
				int index = map.toIndex(x, y, z);
				u8 faces = map.getFaceFlags(index);

				if (faces != FaceFlag::None)
				{
					u8 block = map.getBlock(index);

					float x1 = block / 8.0f;
					float y1 = Maths::Floor(x1) / 32.0f;
					float x2 = x1 + (1.0f / 32.0f);
					float y2 = y1 + (1.0f / 32.0f);

					SColor col = color_white;

					float overlap = 0.001f; //so faint lines dont appear between planes
					Vec3f p = Vec3f(x, y, z) - overlap;
					float w = 1 + overlap * 2;

					if (blockHasFace(faces, FaceFlag::Left))
					{
						vertices.push_back(Vertex(p.x, p.y + w, p.z + w, x1, y1, col));
						vertices.push_back(Vertex(p.x, p.y + w, p.z    , x2, y1, col));
						vertices.push_back(Vertex(p.x, p.y    , p.z    , x2, y2, col));
						vertices.push_back(Vertex(p.x, p.y    , p.z + w, x1, y2, col));
						AddIndices();
					}

					if (blockHasFace(faces, FaceFlag::Right))
					{
						vertices.push_back(Vertex(p.x + w, p.y + w, p.z    , x1, y1, col));
						vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x2, y1, col));
						vertices.push_back(Vertex(p.x + w, p.y    , p.z + w, x2, y2, col));
						vertices.push_back(Vertex(p.x + w, p.y    , p.z    , x1, y2, col));
						AddIndices();
					}

					if (blockHasFace(faces, FaceFlag::Down))
					{
						vertices.push_back(Vertex(p.x + w, p.y, p.z + w, x1, y1, col));
						vertices.push_back(Vertex(p.x    , p.y, p.z + w, x2, y1, col));
						vertices.push_back(Vertex(p.x    , p.y, p.z    , x2, y2, col));
						vertices.push_back(Vertex(p.x + w, p.y, p.z    , x1, y2, col));
						AddIndices();
					}

					if (blockHasFace(faces, FaceFlag::Up))
					{
						vertices.push_back(Vertex(p.x    , p.y + w, p.z + w, x1, y1, col));
						vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x2, y1, col));
						vertices.push_back(Vertex(p.x + w, p.y + w, p.z    , x2, y2, col));
						vertices.push_back(Vertex(p.x    , p.y + w, p.z    , x1, y2, col));
						AddIndices();
					}

					if (blockHasFace(faces, FaceFlag::Front))
					{
						vertices.push_back(Vertex(p.x    , p.y + w, p.z, x1, y1, col));
						vertices.push_back(Vertex(p.x + w, p.y + w, p.z, x2, y1, col));
						vertices.push_back(Vertex(p.x + w, p.y    , p.z, x2, y2, col));
						vertices.push_back(Vertex(p.x    , p.y    , p.z, x1, y2, col));
						AddIndices();
					}

					if (blockHasFace(faces, FaceFlag::Back))
					{
						vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x1, y1, col));
						vertices.push_back(Vertex(p.x    , p.y + w, p.z + w, x2, y1, col));
						vertices.push_back(Vertex(p.x    , p.y    , p.z + w, x2, y2, col));
						vertices.push_back(Vertex(p.x + w, p.y    , p.z + w, x1, y2, col));
						AddIndices();
					}
				}
			}

			if (!vertices.empty())
			{
				noVertices = false;
				mesh.SetVertex(vertices);
				mesh.SetIndices(indices);
				mesh.SetDirty(SMesh::VERTEX_INDEX);
				mesh.BuildMesh();
			}
			else
			{
				noVertices = true;
				mesh.Clear();
			}
		}
	}

	bool hasVertices()
	{
		return !noVertices;
	}

	AABB getBounds()
	{
		return box;
	}

	void Render()
	{
		mesh.RenderMesh();
	}

	private void AddIndices()
	{
		uint n = vertices.length;
		indices.push_back(n - 4);
		indices.push_back(n - 3);
		indices.push_back(n - 1);
		indices.push_back(n - 3);
		indices.push_back(n - 2);
		indices.push_back(n - 1);
	}

	private bool blockHasFace(u8 flags, u8 face)
	{
		return (flags & face) == face;
	}
}
