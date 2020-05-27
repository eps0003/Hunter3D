class AABB : IBounds
{
	Object@ parent;

	Vec3f dim;
	Vec3f min;
	Vec3f max;

	//origin is centered at bottom
	AABB(Object@ parent, Vec3f dim_)
	{
		@this.parent = parent;

		dim = dim_;
		min = Vec3f(-dim.x / 2.0f, 0, -dim.z / 2.0f);
		max = Vec3f(dim.x / 2.0f, dim.y, dim.z / 2.0f);
	}

	//relative to parent position
	AABB(Object@ parent, Vec3f min_, Vec3f max_)
	{
		@this.parent = parent;

		min = min_;
		max = max_;

		dim.x = Maths::Abs(max.x - min.x);
		dim.y = Maths::Abs(max.y - min.y);
		dim.z = Maths::Abs(max.z - min.z);
	}

	//intersects any solid tile at parent position
	bool intersects()
	{
		return intersectsAt(parent.position);
	}

	//intersects any solid tile at specified position
	bool intersectsAt(Vec3f worldPos)
	{
		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			Vec3f pos(x, y, z);
			Voxel@ voxel = map.getVoxel(pos);

			if (voxel !is null && voxel.isSolid())
			{
				return true;
			}
		}
		return false;
	}

	//intersects any solid tile at the specified position that isnt currently intersecting
	bool intersectsNewAt(Vec3f worldPos)
	{
		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			Vec3f currentPos = parent.position;
			bool alreadyIntersecting = (
				x >= Maths::Floor(currentPos.x + min.x) && x < Maths::Ceil(currentPos.x + max.x) &&
				y >= Maths::Floor(currentPos.y + min.y) && y < Maths::Ceil(currentPos.y + max.y) &&
				z >= Maths::Floor(currentPos.z + min.z) && z < Maths::Ceil(currentPos.z + max.z)
			);

			//ignore voxels the actor is currently intersecting
			if (alreadyIntersecting)
			{
				continue;
			}

			Vec3f pos(x, y, z);
			Voxel@ voxel = map.getVoxel(pos);

			if (voxel.isSolid())
			{
				return true;
			}
		}

		return false;
	}

	// //intersects point at parent position
	// bool intersects(Vec3f pointPos)
	// {
	// 	return intersects(parent.position, pointPos);
	// }

	// //intersects point at specified position
	// bool intersectsAt(Vec3f worldPos, Vec3f pointPos)
	// {
	// 	return (
	// 		pointPos.x > worldPos.x + min.x &&
	// 		pointPos.x < worldPos.x + max.x &&
	// 		pointPos.y > worldPos.y + min.y &&
	// 		pointPos.y < worldPos.y + max.y &&
	// 		pointPos.z > worldPos.z + min.z &&
	// 		pointPos.z < worldPos.z + max.z
	// 	);
	// }

	//intersects specific voxel at parent position
	bool intersects(Voxel@ voxel)
	{
		return intersectsAt(parent.position, voxel);
	}

	//intersects specific voxel at specific position
	bool intersectsAt(Vec3f worldPos, Voxel@ voxel)
	{
		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			if (Vec3f(x, y, z) == voxel.position)
			{
				return true;
			}
		}
		return false;
	}

	//intersects map edge at parent position
	bool intersectsMapEdge()
	{
		return intersectsMapEdgeAt(parent.position);
	}

	//intersects map edge at specific position
	bool intersectsMapEdgeAt(Vec3f worldPos)
	{
		Vec3f dim = map.getMapDimensions();
		return (
			worldPos.x + min.x < 0 ||
			worldPos.x + max.x > dim.x ||
			worldPos.z + min.z < 0 ||
			worldPos.z + max.z > dim.z
		);
	}

	//get random point within bounds
	Vec3f randomPoint()
	{
		Random random();
		return Vec3f(
			min.x + random.Next() * dim.x,
			min.y + random.Next() * dim.y,
			min.z + random.Next() * dim.z
		);
	}
}
