#include "Plane.as"
#include "IBounds.as"

shared class Frustum
{
	private Plane plane0;
	private Plane plane1;
	private Plane plane2;
	private Plane plane3;
	private Plane plane4;
	private Plane plane5;

	Frustum() {}

	void Update(const float[]&in proj_view)
	{
		//left clipping plane
		plane2.normal.x			= proj_view[3]  + proj_view[0];
		plane2.normal.y			= proj_view[7]  + proj_view[4];
		plane2.normal.z			= proj_view[11] + proj_view[8];
		plane2.distanceToOrigin	= proj_view[15] + proj_view[12];

		//right clipping plane
		plane3.normal.x			= proj_view[3]  - proj_view[0];
		plane3.normal.y			= proj_view[7]  - proj_view[4];
		plane3.normal.z			= proj_view[11] - proj_view[8];
		plane3.distanceToOrigin	= proj_view[15] - proj_view[12];

		//top clipping plane
		plane4.normal.x			= proj_view[3]  - proj_view[1];
		plane4.normal.y			= proj_view[7]  - proj_view[5];
		plane4.normal.z			= proj_view[11] - proj_view[9];
		plane4.distanceToOrigin	= proj_view[15] - proj_view[13];

		//bottom clipping plane
		plane5.normal.x			= proj_view[3]  + proj_view[1];
		plane5.normal.y			= proj_view[7]  + proj_view[5];
		plane5.normal.z			= proj_view[11] + proj_view[9];
		plane5.distanceToOrigin	= proj_view[15] + proj_view[13];

		//far clipping plane
		plane1.normal.x			= proj_view[3]  - proj_view[2];
		plane1.normal.y			= proj_view[7]  - proj_view[6];
		plane1.normal.z			= proj_view[11] - proj_view[10];
		plane1.distanceToOrigin	= proj_view[15] - proj_view[14];

		//near clipping plane
		plane0.normal.x			= proj_view[2];
		plane0.normal.y			= proj_view[6];
		plane0.normal.z			= proj_view[10];
		plane0.distanceToOrigin	= proj_view[14];

		plane0.Normalize();
		plane1.Normalize();
		plane2.Normalize();
		plane3.Normalize();
		plane4.Normalize();
		plane5.Normalize();
	}

	bool containsAABB(const AABB&in box)
	{
		if (!plane0.intersects(box))
			return false;
		if (!plane1.intersects(box))
			return false;
		if (!plane2.intersects(box))
			return false;
		if (!plane3.intersects(box))
			return false;
		if (!plane4.intersects(box))
			return false;
		if (!plane5.intersects(box))
			return false;
		return true;
	}

	bool containsPoint(const Vec3f&in point)
	{
		if (plane0.distanceToPoint(point) < 0)
			return false;
		if (plane1.distanceToPoint(point) < 0)
			return false;
		if (plane2.distanceToPoint(point) < 0)
			return false;
		if (plane3.distanceToPoint(point) < 0)
			return false;
		if (plane4.distanceToPoint(point) < 0)
			return false;
		if (plane5.distanceToPoint(point) < 0)
			return false;
		return true;
	}

	bool containsSphere(const Vec3f&in point, float radius)
	{
		if (plane0.distanceToPoint(point) < -radius)
			return false;
		if (plane1.distanceToPoint(point) < -radius)
			return false;
		if (plane2.distanceToPoint(point) < -radius)
			return false;
		if (plane3.distanceToPoint(point) < -radius)
			return false;
		if (plane4.distanceToPoint(point) < -radius)
			return false;
		if (plane5.distanceToPoint(point) < -radius)
			return false;
		return true;
	}

	AABB getBounds()
	{
		Vec3f camPos = getCamera3D().getPosition();

		Vec3f FLU = getFarLeftUp() + camPos;
		Vec3f FLD = getFarLeftDown() + camPos;
		Vec3f FRU = getFarRightUp() + camPos;
		Vec3f FRD = getFarRightDown() + camPos;
		Vec3f NLU = getNearLeftUp() + camPos;
		Vec3f NLD = getNearLeftDown() + camPos;
		Vec3f NRU = getNearRightUp() + camPos;
		Vec3f NRD = getNearRightDown() + camPos;

		Vec3f min = FLU.min(FLD).min(FRU).min(FRD).min(NLU).min(NLD).min(NRU).min(NRD);
		Vec3f max = FLU.max(FLD).max(FRU).max(FRD).max(NLU).max(NLD).max(NRU).max(NRD);

		return AABB(min, max);
	}

	// stolen from irrlicht :)
	Vec3f getFarLeftUp()
	{
		Vec3f p;
		plane1.getIntersectionWithPlanes(plane4, plane2, p);
		return p;
	}

	Vec3f getFarLeftDown()
	{
		Vec3f p;
		plane1.getIntersectionWithPlanes(plane5, plane2, p);
		return p;
	}

	Vec3f getFarRightUp()
	{
		Vec3f p;
		plane1.getIntersectionWithPlanes(plane4, plane3, p);
		return p;
	}

	Vec3f getFarRightDown()
	{
		Vec3f p;
		plane1.getIntersectionWithPlanes(plane5, plane3, p);
		return p;
	}

	Vec3f getNearLeftUp()
	{
		Vec3f p;
		plane0.getIntersectionWithPlanes(plane4, plane2, p);
		return p;
	}

	Vec3f getNearLeftDown()
	{
		Vec3f p;
		plane0.getIntersectionWithPlanes(plane5, plane2, p);
		return p;
	}

	Vec3f getNearRightUp()
	{
		Vec3f p;
		plane0.getIntersectionWithPlanes(plane4,plane3, p);
		return p;
	}

	Vec3f getNearRightDown()
	{
		Vec3f p;
		plane0.getIntersectionWithPlanes(plane5, plane3, p);
		return p;
	}
}
