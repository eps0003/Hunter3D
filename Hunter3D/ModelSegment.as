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

		Vertex[] v = {
			//back
			Vertex(a.x, b.y, a.z, backUV.min.x, backUV.min.y, color),
			Vertex(b.x, b.y, a.z, backUV.max.x, backUV.min.y, color),
			Vertex(b.x, a.y, a.z, backUV.max.x, backUV.max.y, color),
			Vertex(a.x, a.y, a.z, backUV.min.x, backUV.max.y, color),

			//front
			Vertex(b.x, a.y, b.z, frontUV.min.x, frontUV.max.y, color),
			Vertex(b.x, b.y, b.z, frontUV.min.x, frontUV.min.y, color),
			Vertex(a.x, b.y, b.z, frontUV.max.x, frontUV.min.y, color),
			Vertex(a.x, a.y, b.z, frontUV.max.x, frontUV.max.y, color),

			//up
			Vertex(a.x, b.y, b.z, upUV.min.x, upUV.min.y, color),
			Vertex(b.x, b.y, b.z, upUV.max.x, upUV.min.y, color),
			Vertex(b.x, b.y, a.z, upUV.max.x, upUV.max.y, color),
			Vertex(a.x, b.y, a.z, upUV.min.x, upUV.max.y, color),

			//down
			Vertex(b.x, a.y, a.z, downUV.min.x, downUV.max.y, color),
			Vertex(b.x, a.y, b.z, downUV.min.x, downUV.min.y, color),
			Vertex(a.x, a.y, b.z, downUV.max.x, downUV.min.y, color),
			Vertex(a.x, a.y, a.z, downUV.max.x, downUV.max.y, color),

			//right
			Vertex(b.x, b.y, a.z, rightUV.min.x, rightUV.min.y, color),
			Vertex(b.x, b.y, b.z, rightUV.max.x, rightUV.min.y, color),
			Vertex(b.x, a.y, b.z, rightUV.max.x, rightUV.max.y, color),
			Vertex(b.x, a.y, a.z, rightUV.min.x, rightUV.max.y, color),

			//left
			Vertex(a.x, a.y, b.z, leftUV.min.x, leftUV.max.y, color),
			Vertex(a.x, b.y, b.z, leftUV.min.x, leftUV.min.y, color),
			Vertex(a.x, b.y, a.z, leftUV.max.x, leftUV.min.y, color),
			Vertex(a.x, a.y, a.z, leftUV.max.x, leftUV.max.y, color)
		};

		vertices = v;
	}

	private void PositionAndRotate(float[]@ matrix)
	{
		float[] offsetMatrix;
		Matrix::MakeIdentity(offsetMatrix);
		Matrix::SetTranslation(offsetMatrix, offset.x, offset.y, offset.z);

		float[] rotationMatrix;
		Matrix::MakeIdentity(rotationMatrix);
		Matrix::SetRotationDegrees(rotationMatrix, rotation.x, rotation.y, rotation.z);

		Matrix::MultiplyImmediate(matrix, offsetMatrix);
		Matrix::MultiplyImmediate(matrix, rotationMatrix);

		Render::SetModelTransform(matrix);
	}
}
