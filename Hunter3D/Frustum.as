#include "Plane.as"
#include "AABB.as"

shared class Frustum
{
	private Plane[] planes(6);

	Frustum() {}

	void Update(const float[]&in proj_view)
	{
		//left clipping plane
		planes[2].normal.x			= proj_view[3]  + proj_view[0];
		planes[2].normal.y			= proj_view[7]  + proj_view[4];
		planes[2].normal.z			= proj_view[11] + proj_view[8];
		planes[2].distanceToOrigin	= proj_view[15] + proj_view[12];

		//right clipping plane
		planes[3].normal.x			= proj_view[3]  - proj_view[0];
		planes[3].normal.y			= proj_view[7]  - proj_view[4];
		planes[3].normal.z			= proj_view[11] - proj_view[8];
		planes[3].distanceToOrigin	= proj_view[15] - proj_view[12];

		//top clipping plane
		planes[4].normal.x			= proj_view[3]  - proj_view[1];
		planes[4].normal.y			= proj_view[7]  - proj_view[5];
		planes[4].normal.z			= proj_view[11] - proj_view[9];
		planes[4].distanceToOrigin	= proj_view[15] - proj_view[13];

		//bottom clipping plane
		planes[5].normal.x			= proj_view[3]  + proj_view[1];
		planes[5].normal.y			= proj_view[7]  + proj_view[5];
		planes[5].normal.z			= proj_view[11] + proj_view[9];
		planes[5].distanceToOrigin	= proj_view[15] + proj_view[13];

		//far clipping plane
		planes[1].normal.x			= proj_view[3]  - proj_view[2];
		planes[1].normal.y			= proj_view[7]  - proj_view[6];
		planes[1].normal.z			= proj_view[11] - proj_view[10];
		planes[1].distanceToOrigin	= proj_view[15] - proj_view[14];

		//near clipping plane
		planes[0].normal.x			= proj_view[2];
		planes[0].normal.y			= proj_view[6];
		planes[0].normal.z			= proj_view[10];
		planes[0].distanceToOrigin	= proj_view[14];

		for (uint i = 0; i < planes.length; i++)
		{
			planes[i].Normalize();
		}
	}

	bool containsAABB(const AABB&in box)
	{
		for (uint i = 0; i < planes.length; i++)
		{
			if (!planes[i].intersects(box))
			{
				return false;
			}
		}
		return true;
	}

	bool containsPoint(const Vec3f&in point)
	{
		for (uint i = 0; i < planes.length; i++)
		{
			if (planes[i].distanceToPoint(point) < 0)
			{
				return false;
			}
		}
		return true;
	}

	bool containsSphere(const Vec3f&in point, float radius)
	{
		for (uint i = 0; i < planes.length; i++)
		{
			if (planes[i].distanceToPoint(point) < -radius)
			{
				return false;
			}
		}
		return true;
	}
}
