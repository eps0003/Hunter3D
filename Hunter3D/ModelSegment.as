#include "ImageUV.as"

class ModelSegment
{
	Vertex[] vertices;
	ModelSegment@[] children;

	private Vec3f min;
	private Vec3f max;

	ImageUV leftUV;
	ImageUV rightUV;
	ImageUV downUV;
	ImageUV upUV;
	ImageUV frontUV;
	ImageUV backUV;

	Vec3f orbit; //rotation around parent origin
	Vec3f offset; //offset from parent segment
	Vec3f rotation; //rotation around segment origin

	ModelSegment(Vec3f dim, Vec3f origin)
	{
		this.min = -origin;
		this.max = dim - origin;
	}

	void Render(string skin, float[] matrix)
	{
		RenderMyself(skin, @matrix);
		RenderChildren(skin, matrix);
	}

	void AddChild(ModelSegment@ child)
	{
		this.children.push_back(child);
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

	void GenerateVertices()
	{
		Vec3f a = min;
		Vec3f b = max;
		SColor color = color_white;

		vertices.clear();

		//back
		if (backUV.isVisible())
		{
			vertices.push_back(Vertex(min.x, max.y, min.z, backUV.min.x, backUV.min.y, color));
			vertices.push_back(Vertex(max.x, max.y, min.z, backUV.max.x, backUV.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, backUV.max.x, backUV.max.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, backUV.min.x, backUV.max.y, color));
		}

		//front
		if (frontUV.isVisible())
		{
			vertices.push_back(Vertex(max.x, min.y, max.z, frontUV.min.x, frontUV.max.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, frontUV.min.x, frontUV.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, frontUV.max.x, frontUV.min.y, color));
			vertices.push_back(Vertex(min.x, min.y, max.z, frontUV.max.x, frontUV.max.y, color));
		}

		//up
		if (upUV.isVisible())
		{
			vertices.push_back(Vertex(max.x, max.y, min.z, upUV.min.x, upUV.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, min.z, upUV.max.x, upUV.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, upUV.max.x, upUV.max.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, upUV.min.x, upUV.max.y, color));
		}

		//down
		if (downUV.isVisible())
		{
			vertices.push_back(Vertex(min.x, min.y, max.z, downUV.min.x, downUV.max.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, downUV.min.x, downUV.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, downUV.max.x, downUV.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, max.z, downUV.max.x, downUV.max.y, color));
		}

		//right
		if (rightUV.isVisible())
		{
			vertices.push_back(Vertex(max.x, max.y, min.z, rightUV.min.x, rightUV.min.y, color));
			vertices.push_back(Vertex(max.x, max.y, max.z, rightUV.max.x, rightUV.min.y, color));
			vertices.push_back(Vertex(max.x, min.y, max.z, rightUV.max.x, rightUV.max.y, color));
			vertices.push_back(Vertex(max.x, min.y, min.z, rightUV.min.x, rightUV.max.y, color));
		}

		//left
		if (leftUV.isVisible())
		{
			vertices.push_back(Vertex(min.x, min.y, max.z, leftUV.min.x, leftUV.max.y, color));
			vertices.push_back(Vertex(min.x, max.y, max.z, leftUV.min.x, leftUV.min.y, color));
			vertices.push_back(Vertex(min.x, max.y, min.z, leftUV.max.x, leftUV.min.y, color));
			vertices.push_back(Vertex(min.x, min.y, min.z, leftUV.max.x, leftUV.max.y, color));
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
