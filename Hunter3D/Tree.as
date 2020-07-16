shared class Tree
{
	private Branch@ branch0;
	private Branch@ branch1;
	private Branch@ branch2;
	private Branch@ branch3;

	private Branch@ branch4;
	private Branch@ branch5;
	private Branch@ branch6;
	private Branch@ branch7;

	private Branch@ branch8;
	private Branch@ branch9;
	private Branch@ branch10;
	private Branch@ branch11;

	private Branch@ branch12;
	private Branch@ branch13;
	private Branch@ branch14;
	private Branch@ branch15;

	Tree(Map@ map)
	{
		Vec3f dim = map.getMapDimensions();

		@branch0  = Branch(map, Vec3f(0,	0, 0),						Vec3f(dim.x / 4, dim.y, dim.z / 4));
		@branch1  = Branch(map, Vec3f(dim.x / 4, 0, 0),					Vec3f(dim.x / 2, dim.y, dim.z / 4));
		@branch2  = Branch(map, Vec3f(0, 0, dim.z/4),					Vec3f(dim.x / 4, dim.y, dim.z / 2));
		@branch3  = Branch(map, Vec3f(dim.x / 4, 0, dim.z / 4),			Vec3f(dim.x / 2, dim.y, dim.z / 2));

		@branch4  = Branch(map, Vec3f(dim.x / 2, 0, 0),					Vec3f(dim.x / 4 * 3, dim.y, dim.z / 4));
		@branch5  = Branch(map, Vec3f(dim.x / 4 * 3, 0, 0),				Vec3f(dim.x, dim.y, dim.z / 4));
		@branch6  = Branch(map, Vec3f(dim.x / 2, 0, dim.z / 4),			Vec3f(dim.x / 4 * 3, dim.y, dim.z / 2));
		@branch7  = Branch(map, Vec3f(dim.x / 4 * 3, 0, dim.z / 4),		Vec3f(dim.x, dim.y, dim.z / 2));

		@branch8  = Branch(map, Vec3f(0, 0, dim.z / 2),					Vec3f(dim.x / 4, dim.y, dim.z / 4 * 3));
		@branch9  = Branch(map, Vec3f(dim.x / 4, 0, dim.z / 2),			Vec3f(dim.x / 2, dim.y, dim.z / 4 * 3));
		@branch10 = Branch(map, Vec3f(0, 0, dim.z / 4 * 3),				Vec3f(dim.x / 4, dim.y, dim.z));
		@branch11 = Branch(map, Vec3f(dim.x / 4, 0, dim.z / 4 * 3),		Vec3f(dim.x / 2, dim.y, dim.z));

		@branch12 = Branch(map, Vec3f(dim.x / 2, 0, dim.z / 2),			Vec3f(dim.x / 4 * 3, dim.y, dim.z / 4 * 3));
		@branch13 = Branch(map, Vec3f(dim.x / 4 * 3, 0, dim.z / 2),		Vec3f(dim.x, dim.y, dim.z / 4 * 3));
		@branch14 = Branch(map, Vec3f(dim.x / 2, 0, dim.z / 4 * 3),		Vec3f(dim.x / 4 * 3, dim.y, dim.z));
		@branch15 = Branch(map, Vec3f(dim.x / 4 * 3, 0, dim.z / 4 * 3),	Vec3f(dim.x, dim.y, dim.z));
	}

    void GetVisibleChunks(Chunk@[]@ visibleChunks)
    {
		Camera@ camera = getCamera3D();
		Frustum frustum = camera.getFrustum();
		Vec3f camPos = camera.getPosition();

		visibleChunks.clear();

        branch0.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch1.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch2.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch3.GetVisibleChunks(frustum, camPos, visibleChunks);

        branch4.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch5.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch6.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch7.GetVisibleChunks(frustum, camPos, visibleChunks);

        branch8.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch9.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch10.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch11.GetVisibleChunks(frustum, camPos, visibleChunks);

        branch12.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch13.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch14.GetVisibleChunks(frustum, camPos, visibleChunks);
        branch15.GetVisibleChunks(frustum, camPos, visibleChunks);
    }
}

shared class Branch
{
	private AABB bounds;
	private bool leaf = false;

	private Branch@ branch0;
	private Branch@ branch1;
	private Branch@ branch2;
	private Branch@ branch3;
	private Branch@ branch4;
	private Branch@ branch5;
	private Branch@ branch6;
	private Branch@ branch7;

	private Chunk@ chunk0;
	private Chunk@ chunk1;
	private Chunk@ chunk2;
	private Chunk@ chunk3;
	private Chunk@ chunk4;
	private Chunk@ chunk5;
	private Chunk@ chunk6;
	private Chunk@ chunk7;

	Branch(Map@ map, Vec3f min, Vec3f max)
	{
        bounds = AABB(min, max);
		Vec3f center = bounds.center;

		//check if branch can be subdivided
		if (bounds.dim.y <= 2 * CHUNK_SIZE)
		{
			//leaf
            leaf = true;

            Vec3f chunkPos = map.getChunkPos(min);

			@chunk0 = map.getChunkSafe(chunkPos.x    , chunkPos.y    , chunkPos.z    );
			@chunk1 = map.getChunkSafe(chunkPos.x + 1, chunkPos.y    , chunkPos.z    );
			@chunk2 = map.getChunkSafe(chunkPos.x + 1, chunkPos.y    , chunkPos.z + 1);
			@chunk3 = map.getChunkSafe(chunkPos.x    , chunkPos.y    , chunkPos.z + 1);
			@chunk4 = map.getChunkSafe(chunkPos.x    , chunkPos.y + 1, chunkPos.z    );
			@chunk5 = map.getChunkSafe(chunkPos.x + 1, chunkPos.y + 1, chunkPos.z    );
			@chunk6 = map.getChunkSafe(chunkPos.x + 1, chunkPos.y + 1, chunkPos.z + 1);
			@chunk7 = map.getChunkSafe(chunkPos.x    , chunkPos.y + 1, chunkPos.z + 1);
		}
		else
		{
            Vec3f size = bounds.dim / 2;

			//subdivide more
			@branch0 = Branch(map, min, min + size);
			@branch1 = Branch(map, min + size * Vec3f(1, 0, 0), max - size * Vec3f(0, 1, 1));
			@branch2 = Branch(map, min + size * Vec3f(0, 0, 1), max - size * Vec3f(1, 1, 0));
			@branch3 = Branch(map, min + size * Vec3f(1, 0, 1), max - size * Vec3f(0, 1, 0));
			@branch4 = Branch(map, min + size * Vec3f(0, 1, 0), max - size * Vec3f(1, 0, 1));
			@branch5 = Branch(map, min + size * Vec3f(1, 1, 0), max - size * Vec3f(0, 0, 1));
			@branch6 = Branch(map, min + size * Vec3f(0, 1, 1), max - size * Vec3f(1, 0, 0));
			@branch7 = Branch(map, min + size, max);
		}
	}

	void GetVisibleChunks(Frustum frustum, Vec3f camPos, Chunk@[]@ visibleChunks)
	{
		if (frustum.containsSphere(bounds.center - camPos, bounds.radius))
        {
			if (leaf)
			{
				if (chunk0 !is null)
				if (chunk0.hasVertices())
				{
					// chunk0.GenerateMesh();
					AABB chunkBounds = chunk0.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						visibleChunks.push_back(chunk0);
					}
				}

				if (chunk1 !is null)
				if (chunk1.hasVertices())
				{
					//chunk1.GenerateMesh();
					AABB chunkBounds = chunk1.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						visibleChunks.push_back(chunk1);
					}
				}

				if (chunk2 !is null)
				if (chunk2.hasVertices())
				{
					//chunk2.GenerateMesh();
					AABB chunkBounds = chunk2.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						visibleChunks.push_back(chunk2);
					}
				}

				if (chunk3 !is null)
				if (chunk3.hasVertices())
				{
					//chunk3.GenerateMesh();
					AABB chunkBounds = chunk3.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						visibleChunks.push_back(chunk3);
					}
				}

				if (chunk4 !is null)
				if (chunk4.hasVertices())
				{
					//chunk4.GenerateMesh();
					AABB chunkBounds = chunk4.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						visibleChunks.push_back(chunk4);
					}
				}

				if (chunk5 !is null)
				if (chunk5.hasVertices())
				{
					//chunk5.GenerateMesh();
					AABB chunkBounds = chunk5.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						visibleChunks.push_back(chunk5);
					}
				}

				if (chunk6 !is null)
				if (chunk6.hasVertices())
				{
					//chunk6.GenerateMesh();
					AABB chunkBounds = chunk6.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						visibleChunks.push_back(chunk6);
					}
				}

				if (chunk7 !is null)
				if (chunk7.hasVertices())
				{
					//chunk7.GenerateMesh();
					AABB chunkBounds = chunk7.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						visibleChunks.push_back(chunk7);
					}
				}
			}
			else
			{
				branch0.GetVisibleChunks(frustum, camPos, visibleChunks);
				branch1.GetVisibleChunks(frustum, camPos, visibleChunks);
				branch2.GetVisibleChunks(frustum, camPos, visibleChunks);
				branch3.GetVisibleChunks(frustum, camPos, visibleChunks);
				branch4.GetVisibleChunks(frustum, camPos, visibleChunks);
				branch5.GetVisibleChunks(frustum, camPos, visibleChunks);
				branch6.GetVisibleChunks(frustum, camPos, visibleChunks);
				branch7.GetVisibleChunks(frustum, camPos, visibleChunks);
			}
		}
	}
}

//https://stackoverflow.com/questions/466204/rounding-up-to-next-power-of-2
shared Vec3f nearestPower(Vec3f vec)
{
	uint v = Maths::Max(vec.x, vec.y);
	v = Maths::Max(v, vec.z);

	v--;
	v |= v >> 1;
	v |= v >> 2;
	v |= v >> 4;
	v |= v >> 8;
	v |= v >> 16;
	v++;

	return Vec3f(v, v, v);
}
