#include "IBounds.as"

shared class Cylinder : IBounds, IHasParent
{
	Vec3f dim;
	Vec3f min;
	Vec3f max;

	float radius;
	float height;

	Cylinder(Object@ parent, float radius)
	{
		SetParent(parent);
		this.radius = radius;
	}

	bool intersects(Vec3f worldPos)
	{
		Vec2f myPos(parent.position.x, parent.position.z);
		Vec2f pointPos(worldPos.x, worldPos.z);
		float lenSq = (myPos - pointPos).LengthSquared();
		if (lenSq > radius * radius)
		{
			return false;
		}

		float myY = parent.position.y;
		float pointY = worldPos.Y;
		if (pointY < myY || pointY >= myY + height)
		{
			return false;
		}

		return true;
	}

	bool intersects(Vec3f worldPos, AABB@ hitbox2)
	{
		for (int x = worldPos.x + hitbox2.min.x; x < worldPos.x + hitbox2.max.x; x++)
		for (int y = worldPos.y + hitbox2.min.y; y < worldPos.y + hitbox2.max.y; y++)
		for (int z = worldPos.z + hitbox2.min.z; z < worldPos.z + hitbox2.max.z; z++)
		{
			if ( //ignore voxels the player is currently inside
				x >= Maths::Floor(position.x + min.x) && x < Maths::Ceil(position.x + max.x) &&
				y >= Maths::Floor(position.y + min.y) && y < Maths::Ceil(position.y + max.y) &&
				z >= Maths::Floor(position.z + min.z) && z < Maths::Ceil(position.z + max.z)
			) {
				continue;
			}

			if (get3dMap().isVoxelSolid(Vec3f(x, y, z)))
			{
				return true;
			}
		}
		return false;
	}

	bool intersectsPoint(Vec3f worldPos)
	{
		return (
			worldPos.x > interPosition.x + min.x &&
			worldPos.x < interPosition.x + max.x &&
			worldPos.y > interPosition.y + min.y &&
			worldPos.y < interPosition.y + max.y &&
			worldPos.z > interPosition.z + min.z &&
			worldPos.z < interPosition.z + max.z
		);
	}

	bool intersectsMapEdge(Vec3f worldPos)
	{
		return (
			worldPos.x + min.x < 0 ||
			worldPos.x + max.x > MAP_SIZE.x ||
			worldPos.z + min.z < 0 ||
			worldPos.z + max.z > MAP_SIZE.z
		);
	}

	bool intersectsVoxel(Vec3f worldPos, Vec3f voxelWorldPos)
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
}
