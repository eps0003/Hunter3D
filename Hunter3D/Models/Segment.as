#include "SegmentChildren.as"

shared class Segment : SegmentChildren
{
	string name;
	Vec3f dim;
	Vec3f origin;    //1. alignment of segment
	Vec3f orbit;     //2. rotation around parent origin
	Vec3f offset;    //3. offset from parent segment
	Vec3f rotation;  //4. rotation around segment origin
	// Vec3f rotation2; //5. secondary rotation after previous rotation

	SMesh@ mesh = SMesh();
	private Vertex[] vertices(24);
	private u16[] indices(36);
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
			for (uint i = 0; i < uvArr.size(); i++)
			{
				string serialized = uvArr[i];
				@UVs[i] = ImageUV(serialized);
			}
		}

		//vertices
		GenerateVertices();
	}

	void Render(float[] matrix)
	{
		//render myself
		if (!vertices.empty())
		{
			PositionAndRotate(@matrix);
			mesh.RenderMeshWithMaterial();
		}

		//render children
		for (uint i = 0; i < children.size(); i++)
		{
			Segment@ child = children[i];
			child.Render(matrix);
		}
	}

	void SetMaterial(SMaterial@ material)
	{
		mesh.SetMaterial(material);
	}

	void GenerateVertices()
	{
		Vec3f min = -origin;
		Vec3f max = dim - origin;
		SColor color = color_white;
		ImageUV@ uv;

		uint vi = 0;
		uint ii = 0;

		//back
		@uv = getUV(Direction::Back);
		if (uv.isVisible() && dim.x != 0 && dim.y != 0)
		{
			vertices[vi++] = Vertex(min.x, max.y, min.z, uv.min.x, uv.min.y, color);
			vertices[vi++] = Vertex(max.x, max.y, min.z, uv.max.x, uv.min.y, color);
			vertices[vi++] = Vertex(max.x, min.y, min.z, uv.max.x, uv.max.y, color);
			vertices[vi++] = Vertex(min.x, min.y, min.z, uv.min.x, uv.max.y, color);

			indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
			indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
		}

		//front
		@uv = getUV(Direction::Front);
		if (uv.isVisible() && dim.x != 0 && dim.y != 0)
		{
			vertices[vi++] = Vertex(max.x, min.y, max.z, uv.min.x, uv.max.y, color);
			vertices[vi++] = Vertex(max.x, max.y, max.z, uv.min.x, uv.min.y, color);
			vertices[vi++] = Vertex(min.x, max.y, max.z, uv.max.x, uv.min.y, color);
			vertices[vi++] = Vertex(min.x, min.y, max.z, uv.max.x, uv.max.y, color);

			indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
			indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
		}

		//up
		@uv = getUV(Direction::Up);
		if (uv.isVisible() && dim.x != 0 && dim.z != 0)
		{
			vertices[vi++] = Vertex(max.x, max.y, min.z, uv.min.x, uv.min.y, color);
			vertices[vi++] = Vertex(min.x, max.y, min.z, uv.max.x, uv.min.y, color);
			vertices[vi++] = Vertex(min.x, max.y, max.z, uv.max.x, uv.max.y, color);
			vertices[vi++] = Vertex(max.x, max.y, max.z, uv.min.x, uv.max.y, color);

			indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
			indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
		}

		//down
		@uv = getUV(Direction::Down);
		if (uv.isVisible() && dim.x != 0 && dim.z != 0)
		{
			vertices[vi++] = Vertex(min.x, min.y, max.z, uv.min.x, uv.max.y, color);
			vertices[vi++] = Vertex(min.x, min.y, min.z, uv.min.x, uv.min.y, color);
			vertices[vi++] = Vertex(max.x, min.y, min.z, uv.max.x, uv.min.y, color);
			vertices[vi++] = Vertex(max.x, min.y, max.z, uv.max.x, uv.max.y, color);

			indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
			indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
		}

		//right
		@uv = getUV(Direction::Right);
		if (uv.isVisible() && dim.y != 0 && dim.z != 0)
		{
			vertices[vi++] = Vertex(max.x, max.y, min.z, uv.min.x, uv.min.y, color);
			vertices[vi++] = Vertex(max.x, max.y, max.z, uv.max.x, uv.min.y, color);
			vertices[vi++] = Vertex(max.x, min.y, max.z, uv.max.x, uv.max.y, color);
			vertices[vi++] = Vertex(max.x, min.y, min.z, uv.min.x, uv.max.y, color);

			indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
			indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
		}

		//left
		@uv = getUV(Direction::Left);
		if (uv.isVisible() && dim.y != 0 && dim.z != 0)
		{
			vertices[vi++] = Vertex(min.x, min.y, max.z, uv.min.x, uv.max.y, color);
			vertices[vi++] = Vertex(min.x, max.y, max.z, uv.min.x, uv.min.y, color);
			vertices[vi++] = Vertex(min.x, max.y, min.z, uv.max.x, uv.min.y, color);
			vertices[vi++] = Vertex(min.x, min.y, min.z, uv.max.x, uv.max.y, color);

			indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
			indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
		}

		if (!vertices.empty())
		{
			mesh.SetVertex(vertices);
			mesh.SetIndices(indices);
			mesh.BuildMesh();
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
		for (uint i = 0; i < UVs.size(); i++)
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
