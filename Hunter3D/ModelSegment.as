#include "ImageUV.as"

class ModelSegment
{
	private Vertex[] vertices;
	private ModelSegment@[] children;

	ImageUV[] UVs;

	string name;
	Vec3f dim;
	Vec3f origin;
	Vec3f orbit; //rotation around parent origin
	Vec3f offset; //offset from parent segment
	Vec3f rotation; //rotation around segment origin

	ModelSegment(string name, Vec3f dim, Vec3f origin)
	{
		this.name = name;
		this.dim = dim;
		this.origin = origin;
		UVs.set_length(6);
	}

	ModelSegment(string name, ConfigFile@ cfg)
	{
		this.name = name;
		this.dim = Vec3f(cfg.read_string(name + "_dim", ""));
		this.origin = Vec3f(cfg.read_string(name + "_origin", ""));
		this.orbit = Vec3f(cfg.read_string(name + "_orbit", ""));
		this.offset = Vec3f(cfg.read_string(name + "_offset", ""));
		this.rotation = Vec3f(cfg.read_string(name + "_rotation", ""));

		string[] childrenNames;
		if (cfg.readIntoArray_string(childrenNames, name + "_children"))
		{
			for (uint i = 0; i < childrenNames.length; i++)
			{
				string name = childrenNames[i];
				ModelSegment segment(name, cfg);
				segment.GenerateVertices();
				children.push_back(segment);
			}
		}

		UVs.set_length(6);
		string[] uvArr;
		if (cfg.readIntoArray_string(uvArr, name + "_uv"))
		{
			for (uint i = 0; i < uvArr.length; i++)
			{
				string serialized = uvArr[i];
				UVs[i] = ImageUV(serialized);
			}
		}

		GenerateVertices();
	}

	void Render(string skin, float[] matrix)
	{
		RenderMyself(skin, @matrix);
		RenderChildren(skin, matrix);
	}

	void AddChild(ModelSegment@ segment)
	{
		if (!hasChild(segment))
		{
			children.push_back(segment);
		}
	}

	void RemoveChild(ModelSegment@ segment)
	{
		for (uint i = 0; i < children.length; i++)
		{
			ModelSegment@ child = children[i];
			if (child is segment)
			{
				children.removeAt(i);
				return;
			}
		}
	}

	ModelSegment@[] getChildren()
	{
		return children;
	}

	bool hasChildren()
	{
		return !children.empty();
	}

	bool hasChild(ModelSegment@ child)
	{
		for (uint i = 0; i < children.length; i++)
		{
			ModelSegment@ segment = children[i];
			if (segment.hasChild(child))
			{
				return true;
			}
		}

		return false;
	}

	void GenerateVertices()
	{
		Vec3f min = -origin;
		Vec3f max = dim - origin;
		SColor color = color_white;
		ImageUV uv;

		vertices.clear();

		//back
		uv = getUV(Direction::Back);
		if (uv.isVisible())
		{
			vertices.push_back(Vertex(min.x, max.y, min.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, max.y, min.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, uv.max.x, uv.max.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, uv.min.x, uv.max.y, color));
		}

		//front
		uv = getUV(Direction::Front);
		if (uv.isVisible())
		{
			vertices.push_back(Vertex(max.x, min.y, max.z, uv.min.x, uv.max.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, min.y, max.z, uv.max.x, uv.max.y, color));
		}

		//up
		uv = getUV(Direction::Up);
		if (uv.isVisible())
		{
			vertices.push_back(Vertex(max.x, max.y, min.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, min.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, uv.max.x, uv.max.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, uv.min.x, uv.max.y, color));
		}

		//down
		uv = getUV(Direction::Down);
		if (uv.isVisible())
		{
			vertices.push_back(Vertex(min.x, min.y, max.z, uv.min.x, uv.max.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, max.z, uv.max.x, uv.max.y, color));
		}

		//right
		uv = getUV(Direction::Right);
		if (uv.isVisible())
		{
			vertices.push_back(Vertex(max.x, max.y, min.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, max.z, uv.max.x, uv.max.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, uv.min.x, uv.max.y, color));
		}

		//left
		uv = getUV(Direction::Left);
		if (uv.isVisible())
		{
			vertices.push_back(Vertex(min.x, min.y, max.z, uv.min.x, uv.max.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, uv.min.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, min.z, uv.max.x, uv.min.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, uv.max.x, uv.max.y, color));
		}
	}

	void SetUV(int side, ImageUV uv)
	{
		UVs[side] = uv;
	}

	void Serialize(ConfigFile@ cfg)
	{
		cfg.add_string(name + "_dim", dim.serializeString());
		cfg.add_string(name + "_origin", origin.serializeString());
		cfg.add_string(name + "_orbit", orbit.serializeString());
		cfg.add_string(name + "_offset", offset.serializeString());
		cfg.add_string(name + "_rotation", rotation.serializeString());

		string[] childrenNames;
		for (uint i = 0; i < children.length; i++)
		{
			ModelSegment@ child = children[i];
			childrenNames.push_back(child.name);
			child.Serialize(cfg);
		}

		if (!childrenNames.empty())
		{
			cfg.addArray_string(name + "_children", childrenNames);
		}

		string[] uvArr;
		for (uint i = 0; i < UVs.length; i++)
		{
			ImageUV uv = getUV(i);
			uvArr.push_back(uv.toString());
		}
		cfg.addArray_string(name + "_uv", uvArr);
	}

	private ImageUV getUV(int side)
	{
		return UVs[side];
	}

	private void RenderMyself(string skin, float[]@ matrix)
	{
		PositionAndRotate(@matrix);
		Render::RawQuads(skin, vertices);
	}

	private void RenderChildren(string skin, float[] matrix)
	{
		for (uint i = 0; i < children.length; i++)
		{
			ModelSegment@ child = children[i];
			child.Render(skin, matrix);
		}
	}

	private void PositionAndRotate(float[]@ matrix)
	{
		float[] offsetMatrix;
		Matrix::MakeIdentity(offsetMatrix);
		Matrix::SetTranslation(offsetMatrix, offset.x, offset.y, offset.z);

		float[] rotationMatrix;
		Matrix::MakeIdentity(rotationMatrix);
		Matrix::SetRotationDegrees(rotationMatrix, -rotation.x, -rotation.y, -rotation.z);

		Matrix::MultiplyImmediate(matrix, offsetMatrix);
		Matrix::MultiplyImmediate(matrix, rotationMatrix);

		Render::SetModelTransform(matrix);
	}
}
