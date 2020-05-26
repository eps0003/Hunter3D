class Cube : Object
{
	Vec3f size;
	SColor color;

	Cube(Vec3f position, Vec3f size, SColor color = color_white)
	{
		this.position = position;
		this.size = size;
		this.color = color;
	}

	void Render()
	{
		Vec3f a = position;
		Vec3f b = a + size;

		Vertex[] vertices = {
			//-z
			Vertex(a.x, b.y, a.z, 0, 0, color),
			Vertex(b.x, b.y, a.z, 1, 0, color),
			Vertex(b.x, a.y, a.z, 1, 1, color),
			Vertex(a.x, a.y, a.z, 0, 1, color),

			//+z
			Vertex(b.x, a.y, b.z, 0, 1, color),
			Vertex(b.x, b.y, b.z, 0, 0, color),
			Vertex(a.x, b.y, b.z, 1, 0, color),
			Vertex(a.x, a.y, b.z, 1, 1, color),

			//+y
			Vertex(a.x, b.y, b.z, 0, 0, color),
			Vertex(b.x, b.y, b.z, 1, 0, color),
			Vertex(b.x, b.y, a.z, 1, 1, color),
			Vertex(a.x, b.y, a.z, 0, 1, color),

			//-y
			Vertex(b.x, a.y, a.z, 0, 1, color),
			Vertex(b.x, a.y, b.z, 0, 0, color),
			Vertex(a.x, a.y, b.z, 1, 0, color),
			Vertex(a.x, a.y, a.z, 1, 1, color),

			//+x
			Vertex(b.x, b.y, a.z, 0, 0, color),
			Vertex(b.x, b.y, b.z, 1, 0, color),
			Vertex(b.x, a.y, b.z, 1, 1, color),
			Vertex(b.x, a.y, a.z, 0, 1, color),

			//-x
			Vertex(a.x, a.y, b.z, 0, 1, color),
			Vertex(a.x, b.y, b.z, 0, 0, color),
			Vertex(a.x, b.y, a.z, 1, 0, color),
			Vertex(a.x, a.y, a.z, 1, 1, color)
		};

		Render::RawQuads("pixel.png", vertices);
	}
}
