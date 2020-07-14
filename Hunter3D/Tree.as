shared class Tree
{
	private AABB bounds;
	private bool leaf = false;

	private Tree@ branch0;
	private Tree@ branch1;
	private Tree@ branch2;
	private Tree@ branch3;
	private Tree@ branch4;
	private Tree@ branch5;
	private Tree@ branch6;
	private Tree@ branch7;

	private Chunk@ chunk0;
	private Chunk@ chunk1;
	private Chunk@ chunk2;
	private Chunk@ chunk3;
	private Chunk@ chunk4;
	private Chunk@ chunk5;
	private Chunk@ chunk6;
	private Chunk@ chunk7;

	Tree(Map@ map, Vec3f min, Vec3f max)
	{
        bounds = AABB(min, max);
		Vec3f center = bounds.center;

		//check if branch can be subdivided
		if (max.y - min.y <= 2)
		{
			//leaf
            leaf = true;

			@chunk0 = map.getChunkSafe(   min.x,    min.y,    min.z);
			@chunk1 = map.getChunkSafe(center.x,    min.y,    min.z);
			@chunk2 = map.getChunkSafe(center.x,    min.y, center.z);
			@chunk3 = map.getChunkSafe(   min.x,    min.y, center.z);
			@chunk4 = map.getChunkSafe(   min.x, center.y,    min.z);
			@chunk5 = map.getChunkSafe(center.x, center.y,    min.z);
			@chunk6 = map.getChunkSafe(center.x, center.y, center.z);
			@chunk7 = map.getChunkSafe(   min.x, center.y, center.z);
		}
		else
		{
			//subdivide more
			@branch0 = Tree(map, min, center);
			@branch1 = Tree(map, Vec3f(center.x,    min.y,    min.z), Vec3f(   max.x, center.y, center.z));
			@branch2 = Tree(map, Vec3f(center.x,    min.y, center.z), Vec3f(   max.x, center.y,    max.z));
			@branch3 = Tree(map, Vec3f(   min.x,    min.y, center.z), Vec3f(center.x, center.y,    max.z));
			@branch4 = Tree(map, Vec3f(   min.x, center.y,    min.z), Vec3f(center.x,    max.y, center.z));
			@branch5 = Tree(map, Vec3f(center.x, center.y,    min.z), Vec3f(   max.x,    max.y, center.z));
			@branch6 = Tree(map, center, max);
			@branch7 = Tree(map, Vec3f(   min.x, center.y, center.z), Vec3f(center.x,    max.y,    max.z));
		}
	}

	void GetVisibleChunks(Camera@ camera, Chunk@[]@ visibleChunks)
	{
		Frustum frustum = camera.getFrustum();
		Vec3f camPos = camera.getPosition();

		if (frustum.containsSphere(bounds.center * CHUNK_SIZE - camPos, bounds.radius * CHUNK_SIZE))
        {
			if (leaf)
			{
				if (chunk0 !is null && chunk0.hasVertices())
				{
					AABB chunkBounds = chunk0.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						chunk0.GenerateMesh();
						visibleChunks.push_back(chunk0);
					}
				}

				if (chunk1 !is null && chunk1.hasVertices())
				{
					AABB chunkBounds = chunk1.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						chunk1.GenerateMesh();
						visibleChunks.push_back(chunk1);
					}
				}

				if (chunk2 !is null && chunk2.hasVertices())
				{
					AABB chunkBounds = chunk2.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						chunk2.GenerateMesh();
						visibleChunks.push_back(chunk2);
					}
				}

				if (chunk3 !is null && chunk3.hasVertices())
				{
					AABB chunkBounds = chunk3.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						chunk3.GenerateMesh();
						visibleChunks.push_back(chunk3);
					}
				}

				if (chunk4 !is null && chunk4.hasVertices())
				{
					AABB chunkBounds = chunk4.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						chunk4.GenerateMesh();
						visibleChunks.push_back(chunk4);
					}
				}

				if (chunk5 !is null && chunk5.hasVertices())
				{
					AABB chunkBounds = chunk5.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						chunk5.GenerateMesh();
						visibleChunks.push_back(chunk5);
					}
				}

				if (chunk6 !is null && chunk6.hasVertices())
				{
					AABB chunkBounds = chunk6.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						chunk6.GenerateMesh();
						visibleChunks.push_back(chunk6);
					}
				}

				if (chunk7 !is null && chunk7.hasVertices())
				{
					AABB chunkBounds = chunk7.getBounds();
					if (frustum.containsSphere(chunkBounds.center - camPos, chunkBounds.radius))
					{
						chunk7.GenerateMesh();
						visibleChunks.push_back(chunk7);
					}
				}
			}
			else
			{
				branch0.GetVisibleChunks(camera, visibleChunks);
				branch1.GetVisibleChunks(camera, visibleChunks);
				branch2.GetVisibleChunks(camera, visibleChunks);
				branch3.GetVisibleChunks(camera, visibleChunks);
				branch4.GetVisibleChunks(camera, visibleChunks);
				branch5.GetVisibleChunks(camera, visibleChunks);
				branch6.GetVisibleChunks(camera, visibleChunks);
				branch7.GetVisibleChunks(camera, visibleChunks);
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
