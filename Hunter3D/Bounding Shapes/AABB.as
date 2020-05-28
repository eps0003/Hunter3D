#include "IBounds.as"
#include "IHasParent.as"

class AABB : IBounds
{
	Vec3f dim;
	Vec3f min;
	Vec3f max;

	//origin is centered at bottom
	AABB(Vec3f dim_)
	{
		dim = dim_;
		min = Vec3f(-dim.x / 2.0f, 0, -dim.z / 2.0f);
		max = Vec3f(dim.x / 2.0f, dim.y, dim.z / 2.0f);
	}

	//relative to parent position
	AABB(Vec3f min_, Vec3f max_)
	{
		min = min_;
		max = max_;

		dim.x = Maths::Abs(max.x - min.x);
		dim.y = Maths::Abs(max.y - min.y);
		dim.z = Maths::Abs(max.z - min.z);
	}

	//intersects any solid voxel at specified position
	bool intersectsAt(Vec3f worldPos)
	{
		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			Vec3f pos(x, y, z);
			Voxel@ voxel = getMap3D().getVoxel(pos);

			if (voxel !is null && voxel.isSolid())
			{
				return true;
			}
		}
		return false;
	}

	//intersects any solid voxel at the specified position that isnt currently intersecting
	bool intersectsNewAt(Vec3f currentPos, Vec3f worldPos)
	{
		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
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
			Voxel@ voxel = getMap3D().getVoxel(pos);

			if (voxel !is null && voxel.isSolid())
			{
				return true;
			}
		}

		return false;
	}

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

	//intersects specific voxel at specific position
	bool intersectsAt(Vec3f worldPos, Vec3f voxelWorldPos)
	{
		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			if (Vec3f(x, y, z) == voxelWorldPos)
			{
				return true;
			}
		}
		return false;
	}

	//intersects map edge at specific position
	bool intersectsMapEdgeAt(Vec3f worldPos)
	{
		Vec3f dim = getMap3D().getMapDimensions();
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

	void Render(Vec3f worldPos, SColor col = SColor(100, 100, 255, 100))
	{
		Vec3f offset = worldPos - getCamera3D().getParent().interPosition;

		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::SetTranslation(matrix, offset.x, offset.y, offset.z);
		Render::SetModelTransform(matrix);

		Vertex[] vertices;

		//left
		vertices.push_back(Vertex(min.x, max.y, max.z, 0, 0, col));
		vertices.push_back(Vertex(min.x, max.y, min.z, 1, 0, col));
		vertices.push_back(Vertex(min.x, min.y, min.z, 1, 1, col));
		vertices.push_back(Vertex(min.x, min.y, max.z, 0, 1, col));

		//right
		vertices.push_back(Vertex(max.x, max.y, min.z, 0, 0, col));
		vertices.push_back(Vertex(max.x, max.y, max.z, 1, 0, col));
		vertices.push_back(Vertex(max.x, min.y, max.z, 1, 1, col));
		vertices.push_back(Vertex(max.x, min.y, min.z, 0, 1, col));

		//front
		vertices.push_back(Vertex(min.x, max.y, min.z, 0, 0, col));
		vertices.push_back(Vertex(max.x, max.y, min.z, 1, 0, col));
		vertices.push_back(Vertex(max.x, min.y, min.z, 1, 1, col));
		vertices.push_back(Vertex(min.x, min.y, min.z, 0, 1, col));

		//back
		vertices.push_back(Vertex(max.x, max.y, max.z, 0, 0, col));
		vertices.push_back(Vertex(min.x, max.y, max.z, 1, 0, col));
		vertices.push_back(Vertex(min.x, min.y, max.z, 1, 1, col));
		vertices.push_back(Vertex(max.x, min.y, max.z, 0, 1, col));

		// if (!isOnGround())
		{
			//down
			vertices.push_back(Vertex(max.x, min.y, max.z, 0, 0, col));
			vertices.push_back(Vertex(min.x, min.y, max.z, 1, 0, col));
			vertices.push_back(Vertex(min.x, min.y, min.z, 1, 1, col));
			vertices.push_back(Vertex(max.x, min.y, min.z, 0, 1, col));
		}

		//up
		vertices.push_back(Vertex(min.x, max.y, max.z, 0, 0, col));
		vertices.push_back(Vertex(max.x, max.y, max.z, 1, 0, col));
		vertices.push_back(Vertex(max.x, max.y, min.z, 1, 1, col));
		vertices.push_back(Vertex(min.x, max.y, min.z, 0, 1, col));

		// Render::SetBackfaceCull(false);
		Render::SetAlphaBlend(true);
		Render::RawQuads("pixel", vertices);
		Render::SetAlphaBlend(false);
		// Render::SetBackfaceCull(true);
	}
}
