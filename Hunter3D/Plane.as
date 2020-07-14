shared class Plane
{
	Vec3f normal;
	float distanceToOrigin = 0;

	Plane() {}

	Plane(float x, float y, float z, float scalar)
	{
		normal = Vec3f(x, y, z);
		distanceToOrigin = scalar;
	}

	bool intersects(AABB &in box)
	{
		float d = box.center.dot(normal);
		float r = box.dim.x * Maths::Abs(normal.x) + box.dim.y * Maths::Abs(normal.y) + box.dim.z * Maths::Abs(normal.z);
		float dpr = d + r;

		if (dpr < -distanceToOrigin)
		{
			return false;
		}

		return true;
	}

	float distanceToPoint(Vec3f &in point)
	{
		return normal.dot(point) + distanceToOrigin;
	}

	void Normalize()
	{
		float mag = normal.mag();

		normal /= mag;
		distanceToOrigin /= mag;
	}

	//stolen from irrlicht
	bool getIntersectionWithPlane(Plane &in other, Vec3f &out LinePoint, Vec3f &out LineVect)
	{
		float fn00 = normal.mag();
		float fn01 = normal.dot(other.normal);
		float fn11 = other.normal.mag();
		float det = fn00 * fn11 - fn01 * fn01;

		if (Maths::Abs(det) < 0.0000001f)
		{
			return false;
		}

		float invdet = 1.0 / det;
		float fc0 = (fn11 * -distanceToOrigin + fn01 * other.distanceToOrigin) * invdet;
		float fc1 = (fn00 * -other.distanceToOrigin + fn01 * distanceToOrigin) * invdet;

		LineVect = normal.cross(other.normal);
		LinePoint = normal * fc0 + other.normal * fc1;
		return true;
	}

	bool getIntersectionWithPlanes(Plane &in o1, Plane &in o2, Vec3f &out Point)
	{
		Vec3f linePoint, lineVect;
		if (getIntersectionWithPlane(o1, linePoint, lineVect))
		{
			return o2.getIntersectionWithLine(linePoint, lineVect, Point);
		}
		return false;
	}

	bool getIntersectionWithLine(Vec3f linePoint, Vec3f lineVect, Vec3f &out Intersection)
	{
		float t2 = normal.dot(lineVect);

		if (t2 == 0)
		{
			return false;
		}

		float t = -(normal.dot(linePoint) + distanceToOrigin) / t2;
		Intersection = linePoint + (lineVect * t);
		return true;
	}
}
