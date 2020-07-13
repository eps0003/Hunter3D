shared class Tree
{
	private AABB bounds;
	private Chunk@[] chunks;
	private Tree@[] branches;
	private bool leaf = false;

	Tree(Map@ map, Vec3f min, Vec3f max)
	{
        bounds = AABB(min, max);
		bounds.dim.Print();
		Vec3f center = bounds.center;

		//check if branch can be subdivided
		if (max.y - min.y <= 2)
		{
			//leaf
            leaf = true;
			chunks.set_length(8);

			@chunks[0] = map.getChunkSafe(   min.x,    min.y,    min.z);
			@chunks[1] = map.getChunkSafe(center.x,    min.y,    min.z);
			@chunks[2] = map.getChunkSafe(center.x,    min.y, center.z);
			@chunks[3] = map.getChunkSafe(   min.x,    min.y, center.z);
			@chunks[4] = map.getChunkSafe(   min.x, center.y,    min.z);
			@chunks[5] = map.getChunkSafe(center.x, center.y,    min.z);
			@chunks[6] = map.getChunkSafe(center.x, center.y, center.z);
			@chunks[7] = map.getChunkSafe(   min.x, center.y, center.z);
		}
		else
		{
			//subdivide more
			branches.set_length(8);

			@branches[0] = Tree(map, min, center);
			@branches[1] = Tree(map, Vec3f(center.x,    min.y,    min.z), Vec3f(   max.x, center.y, center.z));
			@branches[2] = Tree(map, Vec3f(center.x,    min.y, center.z), Vec3f(   max.x, center.y,    max.z));
			@branches[3] = Tree(map, Vec3f(   min.x,    min.y, center.z), Vec3f(center.x, center.y,    max.z));
			@branches[4] = Tree(map, Vec3f(   min.x, center.y,    min.z), Vec3f(center.x,    max.y, center.z));
			@branches[5] = Tree(map, Vec3f(center.x, center.y,    min.z), Vec3f(   max.x,    max.y, center.z));
			@branches[6] = Tree(map, center, max);
			@branches[7] = Tree(map, Vec3f(   min.x, center.y, center.z), Vec3f(center.x,    max.y,    max.z));
		}
	}

	void GetVisibleChunks(Chunk@[]@ visibleChunks)
	{
		Camera@ camera = getCamera3D();
		Frustum frustum = camera.getFrustum();
		Vec3f camPos = camera.getPosition();

		if (frustum.containsSphere(bounds.center * CHUNK_SIZE - camPos, bounds.radius * CHUNK_SIZE))
        {
			if (leaf)
			{
				for (uint i = 0; i < chunks.length; i++)
				{
					Chunk@ chunk = chunks[i];

					if (chunk !is null && chunk.hasVertices())
					{
						AABB chunkBounds = chunk.getBounds();
						if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
						{
							visibleChunks.push_back(chunk);
						}
					}
				}
			}
			else
			{
				for (uint i = 0; i < branches.length; i++)
				{
					Tree@ tree = branches[i];
					tree.GetVisibleChunks(visibleChunks);
				}
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
