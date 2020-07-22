#include "AABB.as"
#include "Cylinder.as"

shared interface IBounds
{
	bool intersectsAABB(Vec3f thisPos, AABB other, Vec3f otherPos);
	bool intersectsCylinder(Vec3f thisPos, Cylinder other, Vec3f otherPos);
	bool intersectsSolid(Vec3f worldPos);
	bool intersectsNewSolid(Vec3f currentPos, Vec3f worldPos);
	bool intersectsVoxel(Vec3f worldPos, Vec3f voxelWorldPos);
	bool intersectsPoint(Vec3f worldPos, Vec3f point);
	bool intersectsMapEdge(Vec3f worldPos);
}
