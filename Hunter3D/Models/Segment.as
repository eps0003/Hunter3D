#include "ImageUV.as"
#include "SegmentChildren.as"

class Segment : SegmentChildren
{
	string name;
	Vec3f dim;
	Vec3f origin;    //1. alignment of segment
	Vec3f orbit;     //2. rotation around parent origin
	Vec3f offset;    //3. offset from parent segment
	Vec3f rotation;  //4. rotation around segment origin
	// Vec3f rotation2; //5. secondary rotation after previous rotation

	private Vertex[] vertices;
	private ImageUV@[] UVs;

	Segment(string name, Vec3f dim, Vec3f origin)
	{
		this.name = name;
		this.dim = dim;
		this.origin = origin;

		UVs.set_length(6);
		for (uint i = 0; i < 6; i++)
		{
			@UVs[i] = ImageUV();
		}
	}

	Segment(string name, ConfigFile@ cfg)
	{
		//properties
		this.name = name;
		this.dim = Vec3f(cfg.read_string(name + "_dim", ""));
		this.origin = Vec3f(cfg.read_string(name + "_origin", ""));
		this.orbit = Vec3f(cfg.read_string(name + "_orbit", ""));
		this.offset = Vec3f(cfg.read_string(name + "_offset", ""));
		this.rotation = Vec3f(cfg.read_string(name + "_rotation", ""));

		//children
		super(name, cfg);

		//uv
		UVs.set_length(6);
		string[] uvArr;
		if (cfg.readIntoArray_string(uvArr, name + "_uv"))
		{
			for (uint i = 0; i < uvArr.length; i++)
			{
				string serialized = uvArr[i];
				@UVs[i] = ImageUV(serialized);
			}
		}

		//vertices
		GenerateVertices();
	}

	void Render(string skin, float[] matrix)
	{
		//render myself
		PositionAndRotate(@matrix);
		Render::RawQuads(skin, vertices);

		//render children
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			child.Render(skin, matrix);
		}
	}

	void GenerateVertices()
	{
		Vec3f min = -origin;
		Vec3f max = dim - origin;
		SColor color = color_white;
		ImageUV@ uv;

		vertices.clear();

		//back
		@uv = getUV(Direction::Back);
		if (uv.isVisible() && dim.x != 0 && dim.y != 0)
		{
			vertices.push_back(Vertex(min.x, max.y, min.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, max.y, min.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, uv.max.x, uv.max.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, uv.min.x, uv.max.y, color));
		}

		//front
		@uv = getUV(Direction::Front);
		if (uv.isVisible() && dim.x != 0 && dim.y != 0)
		{
			vertices.push_back(Vertex(max.x, min.y, max.z, uv.min.x, uv.max.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, min.y, max.z, uv.max.x, uv.max.y, color));
		}

		//up
		@uv = getUV(Direction::Up);
		if (uv.isVisible() && dim.x != 0 && dim.z != 0)
		{
			vertices.push_back(Vertex(max.x, max.y, min.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, min.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, uv.max.x, uv.max.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, uv.min.x, uv.max.y, color));
		}

		//down
		@uv = getUV(Direction::Down);
		if (uv.isVisible() && dim.x != 0 && dim.z != 0)
		{
			vertices.push_back(Vertex(min.x, min.y, max.z, uv.min.x, uv.max.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, max.z, uv.max.x, uv.max.y, color));
		}

		//right
		@uv = getUV(Direction::Right);
		if (uv.isVisible() && dim.y != 0 && dim.z != 0)
		{
			vertices.push_back(Vertex(max.x, max.y, min.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, max.z, uv.max.x, uv.max.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, uv.min.x, uv.max.y, color));
		}

		//left
		@uv = getUV(Direction::Left);
		if (uv.isVisible() && dim.y != 0 && dim.z != 0)
		{
			vertices.push_back(Vertex(min.x, min.y, max.z, uv.min.x, uv.max.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, min.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, uv.max.x, uv.max.y, color));
		}
	}

	ImageUV@[] getUVs()
	{
		return UVs;
	}

	ImageUV@ getUV(int side)
	{
		return UVs[side];
	}

	void SetUV(int side, ImageUV@ uv)
	{
		UVs[side] = uv;
	}

	void Serialize(ConfigFile@ cfg)
	{
		//properties
		cfg.add_string(name + "_dim", dim.serializeString());
		cfg.add_string(name + "_origin", origin.serializeString());
		cfg.add_string(name + "_orbit", orbit.serializeString());
		cfg.add_string(name + "_offset", offset.serializeString());
		cfg.add_string(name + "_rotation", rotation.serializeString());

		//children
		SegmentChildren::Serialize(name, cfg);

		//uv
		string[] uvArr;
		for (uint i = 0; i < UVs.length; i++)
		{
			ImageUV@ uv = getUV(i);
			uvArr.push_back(uv.serializeString());
		}
		cfg.addArray_string(name + "_uv", uvArr);
	}

	private void PositionAndRotate(float[]@ matrix)
	{
		float[] orbitMatrix;
		Matrix::MakeIdentity(orbitMatrix);
		Matrix::SetRotationDegrees(orbitMatrix, -orbit.x, -orbit.y, -orbit.z);

		float[] offsetMatrix;
		Matrix::MakeIdentity(offsetMatrix);
		Matrix::SetTranslation(offsetMatrix, offset.x, offset.y, offset.z);

		float[] rotationMatrix;
		Matrix::MakeIdentity(rotationMatrix);
		Matrix::SetRotationDegrees(rotationMatrix, -rotation.x, -rotation.y, -rotation.z);

		Matrix::MultiplyImmediate(matrix, orbitMatrix);
		Matrix::MultiplyImmediate(matrix, offsetMatrix);
		Matrix::MultiplyImmediate(matrix, rotationMatrix);

		Render::SetModelTransform(matrix);
	}
}
