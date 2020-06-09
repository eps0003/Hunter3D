shared interface IBounds
{
	bool intersectsAt(Vec3f worldPos);
	bool intersectsNewAt(Vec3f currentPos, Vec3f worldPos);

	// bool intersects(Vec3f pointPos);
	// bool intersectsAt(Vec3f worldPos, Vec3f pointPos);

	// bool intersects(AABB@ aabb);
	// bool intersectsAt(Vec3f worldPos, AABB@ aabb);

	// bool intersects(Cylinder@ cylinder);
	// bool intersectsAt(Vec3f worldPos, Cylinder@ cylinder);

	// bool intersects(Voxel@ voxel);
	// bool intersectsAt(Vec3f worldPos, Voxel@ voxel);

	bool intersectsMapEdgeAt(Vec3f worldPos);

	Vec3f randomPoint();
}
