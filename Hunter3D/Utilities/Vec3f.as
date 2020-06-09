#include "Utilities.as"

shared class Vec3f
{
	float x = 0;
	float y = 0;
	float z = 0;

	Vec3f() {}

	Vec3f(float x, float y, float z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	Vec3f(Vec3f vec, float mag)
	{
		vec.Normalize();
		x = vec.x * mag;
		y = vec.y * mag;
		z = vec.z * mag;
	}

	Vec3f(CBitStream@ bs)
	{
		x = bs.read_f32();
		y = bs.read_f32();
		z = bs.read_f32();
	}

	Vec3f(string serialized)
	{
		string[] values = serialized.split(" ");
		if (values.length == 3)
		{
			x = parseFloat(values[0]);
			y = parseFloat(values[1]);
			z = parseFloat(values[2]);
		}
		else
		{
			print("Unable to parse serialized Vec3f string: " + serialized);
		}
	}

	Vec3f(float[] arr)
	{
		if (arr.length == 3)
		{
			x = arr[0];
			y = arr[1];
			z = arr[2];
		}
		else
		{
			warn("Invalid array length when initializing Vec3f");
		}
	}

	void Clear()
	{
		x = 0;
		y = 0;
		z = 0;
	}

	Vec3f opAdd(const Vec3f &in vec)
	{
		return Vec3f(x + vec.x, y + vec.y, z + vec.z);
	}

	Vec3f opAdd(const float &in val)
	{
		return Vec3f(x + val, y + val, z + val);
	}

	Vec3f opSub(const Vec3f &in vec)
	{
		return Vec3f(x - vec.x, y - vec.y, z - vec.z);
	}

	Vec3f opSub(const float &in val)
	{
		return Vec3f(x - val, y - val, z - val);
	}

	Vec3f opMul(const Vec3f &in vec)
	{
		return Vec3f(x * vec.x, y * vec.y, z * vec.z);
	}

	Vec3f opMul(const float &in val)
	{
		return Vec3f(x * val, y * val, z * val);
	}

	Vec3f opDiv(const Vec3f &in vec)
	{
		return Vec3f(x / vec.x, y / vec.y, z / vec.z);
	}

	Vec3f opDiv(const float &in val)
	{
		return Vec3f(x / val, y / val, z / val);
	}

	Vec3f opMod(const float &in val)
	{
		return Vec3f(x % val, y % val, z % val);
	}

	Vec3f opNeg()
	{
		return Vec3f(x, y, z) * -1;
	}

	bool opEquals(const Vec3f &in vec)
	{
		return x == vec.x && y == vec.y && z == vec.z;
	}

	void opAssign(const Vec3f &in vec)
	{
		x = vec.x;
		y = vec.y;
		z = vec.z;
	}

	void opAddAssign(const Vec3f &in vec)
	{
		x += vec.x;
		y += vec.y;
		z += vec.z;
	}

	void opSubAssign(const Vec3f &in vec)
	{
		x -= vec.x;
		y -= vec.y;
		z -= vec.z;
	}

	void opMulAssign(const float val)
	{
		x *= val;
		y *= val;
		z *= val;
	}

	void opMulAssign(const Vec3f &in vec)
	{
		x *= vec.x;
		y *= vec.y;
		z *= vec.z;
	}

	void opDivAssign(const float val)
	{
		x /= val;
		y /= val;
		z /= val;
	}

	void opDivAssign(const Vec3f &in vec)
	{
		x /= vec.x;
		y /= vec.y;
		z /= vec.z;
	}

	float opIndex(int index)
	{
		switch (index)
		{
			case 0: return x;
			case 1: return y;
			case 2: return z;
		}
		warn("Invalid Vec3f index: " + index);
		return 0;
	}

	void Print(uint precision = 3)
	{
		print(toString(precision));
	}

	string toString(uint precision = 3)
	{
		return "(" + formatFloat(x, "", 0, precision) + ", " + formatFloat(y, "", 0, precision) + ", " + formatFloat(z, "", 0, precision) + ")";
	}

	void Normalize()
	{
		float length = mag();
		if (length > 0)
		{
			x /= length;
			y /= length;
			z /= length;
		}
		else
		{
			x = 0;
			y = 0;
			z = 0;
		}
	}

	float mag()
	{
		return Maths::Sqrt(x*x + y*y + z*z);
	}

	float magSquared()
	{
		return x*x + y*y + z*z;
	}

	Vec3f dir()
	{
		float yRadians = y * Maths::Pi / 180;
		float xRadians = x * Maths::Pi / 180;
		return Vec3f(
			Maths::Sin(-yRadians) * Maths::Cos(-xRadians),
			Maths::Sin(xRadians),
			Maths::Cos(yRadians) * Maths::Cos(xRadians)
		);
	}

	Vec3f fastDir()
	{
		float yRadians = y * Maths::Pi / 180;
		float xRadians = x * Maths::Pi / 180;
		return Vec3f(
			Maths::FastSin(-yRadians) * Maths::FastCos(-xRadians),
			Maths::FastSin(xRadians),
			Maths::FastCos(yRadians) * Maths::FastCos(xRadians)
		);
	}

	Vec3f rotate(Vec3f rotation)
	{
		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, rotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, rotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, rotation.z);

		float[] m;
		Matrix::Multiply(tempX, tempZ, m);
		Matrix::Multiply(m, tempY, m);

		return Vec3f(
			x*m[0] + y*m[1] + z*m[2]  + m[3],
			x*m[4] + y*m[5] + z*m[6]  + m[7],
			x*m[8] + y*m[9] + z*m[10] + m[11]
		);
	}

	f32 dot(Vec3f vec)
	{
		return (x * vec.x) + (y * vec.y) + (z * vec.z);
	}

	Vec3f lerp(Vec3f desired, float t)
	{
		return this + (desired - this) * t;
	}

	Vec3f lerpAngle(Vec3f desired, float t)
	{
		return Vec3f(
			Maths::LerpAngle(x, desired.x, t),
			Maths::LerpAngle(y, desired.y, t),
			Maths::LerpAngle(z, desired.z, t)
		);
	}

	Vec3f clamp(Vec3f low, Vec3f high)
	{
		return Vec3f(
			Maths::Clamp2(x, low.x, high.x),
			Maths::Clamp2(y, low.y, high.y),
			Maths::Clamp2(z, low.z, high.z)
		);
	}

	Vec3f floor()
	{
		return Vec3f(
			Maths::Floor(x),
			Maths::Floor(y),
			Maths::Floor(z)
		);
	}

	Vec3f abs()
	{
		return Vec3f(
			Maths::Abs(x),
			Maths::Abs(y),
			Maths::Abs(z)
		);
	}

	Vec3f sign()
	{
		return Vec3f(
			Maths::Sign(x),
			Maths::Sign(y),
			Maths::Sign(z)
		);
	}

	//assuming the vector is a line
	Vec3f randomPoint()
	{
		return Vec3f(
			Maths::PreciseRandom(x),
			Maths::PreciseRandom(y),
			Maths::PreciseRandom(z)
		);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_f32(x);
		bs.write_f32(y);
		bs.write_f32(z);
	}

	string serializeString()
	{
		return x + " " + y + " " + z;
	}

	float[] toArray()
	{
		float[] arr = { x, y, z };
		return arr;
	}
}
