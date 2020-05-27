#include "AABB.as"
// #include "Cylinder.as"

interface IBounds
{
	bool intersects();
	bool intersectsAt(Vec3f worldPos);
	bool intersectsNewAt(Vec3f worldPos);

	// bool intersects(Vec3f pointPos);
	// bool intersectsAt(Vec3f worldPos, Vec3f pointPos);

	// bool intersects(AABB@ aabb);
	// bool intersectsAt(Vec3f worldPos, AABB@ aabb);

	// bool intersects(Cylinder@ cylinder);
	// bool intersectsAt(Vec3f worldPos, Cylinder@ cylinder);

	// bool intersects(Voxel@ voxel);
	// bool intersectsAt(Vec3f worldPos, Voxel@ voxel);

	bool intersectsMapEdge();
	bool intersectsMapEdgeAt(Vec3f worldPos);

	Vec3f randomPoint();
}
