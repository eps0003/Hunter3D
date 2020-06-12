#include "Utilities.as"
#include "TextureAtlas.as"

class SpriteProtruder
{
	private string sprite;
	private CFileImage@ image;
	private Vec2f dim;

	SMesh@ mesh = SMesh();
	SMaterial@ material = SMaterial();

	void Update()
	{
		CControls@ controls = getControls();
		bool pressingKey = false;

		if (controls.isKeyJustPressed(KEY_KEY_N))
		{
			CleanImage();
		}

		if (controls.isKeyJustPressed(KEY_KEY_K))
		{
			// LoadSprite("GrobberPistolNew.png");
			LoadSprite("BigIronNew.png");
		}

		if (controls.isKeyJustPressed(KEY_KEY_J))
		{
			SaveSprite();
		}

		if (controls.isKeyPressed(KEY_KEY_Z))
		{
			if (controls.mouseScrollUp)
			{
				pressingKey = true;
				RightPixel();
			}
			if (controls.mouseScrollDown)
			{
				pressingKey = true;
				LeftPixel();
			}
		}

		if (controls.isKeyPressed(KEY_KEY_X))
		{
			if (controls.mouseScrollUp)
			{
				pressingKey = true;
				DownPixel();
			}
			if (controls.mouseScrollDown)
			{
				pressingKey = true;
				UpPixel();
			}
		}

		if (!pressingKey)
		{
			if (controls.mouseScrollUp)
			{
				Protrude(image.getPixelPosition());
			}
			if (controls.mouseScrollDown)
			{
				Recess(image.getPixelPosition());
			}
		}

		// if (controls.isKeyJustPressed(KEY_LEFT))
		// {
		// 	LeftPixel();
		// }
		// if (controls.isKeyJustPressed(KEY_RIGHT))
		// {
		// 	RightPixel();
		// }
		// if (controls.isKeyJustPressed(KEY_UP))
		// {
		// 	UpPixel();
		// }
		// if (controls.isKeyJustPressed(KEY_DOWN))
		// {
		// 	DownPixel();
		// }

		// if (controls.mouseScrollUp)
		// {
		// 	Protrude();
		// }
		// if (controls.mouseScrollDown)
		// {
		// 	Recess();
		// }
	}

	void Render()
	{
		if (isImageLoaded())
		{
			float[] offset;
			Matrix::MakeIdentity(offset);
			// Matrix::SetScale(offset, 0.1f, 0.1f, 0.1f);
			Matrix::SetTranslation(offset, 10, 2, 0);
			Render::SetModelTransform(offset);

			mesh.RenderMeshWithMaterial();
		}
	}

	void CleanImage()
	{
		if (isImageLoaded())
		{
			Vec2f pos = image.getPixelPosition();
			image.ResetPixel();

			while (image.canRead())
			{
				SColor color = image.readPixel();

				if (color.getAlpha() > 0)
				{
					color.setAlpha(255);
				}
				else
				{
					color = SColor(0, 0, 0, 0);
				}

				image.setPixel(color);
				image.nextPixel();
			}

			image.setPixelPosition(pos);
			BuildMesh();
		}
	}

	void BuildMesh()
	{
		Vertex[] vertices;
		u16[] indices;

		uint vi = 0;
		uint ii = 0;

		// float w = 0.5f;

		// //left
		// vertices[vi++] = Vertex(-w,     0, dim.x, 1, 1, color_white);
		// vertices[vi++] = Vertex(-w, dim.y, dim.x, 1, 0, color_white);
		// vertices[vi++] = Vertex(-w, dim.y,     0, 0, 0, color_white);
		// vertices[vi++] = Vertex(-w,     0,     0, 0, 1, color_white);

		// indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
		// indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;

		// //right
		// vertices[vi++] = Vertex( w, dim.y,     0, 0, 0, color_white);
		// vertices[vi++] = Vertex( w, dim.y, dim.x, 1, 0, color_white);
		// vertices[vi++] = Vertex( w,     0, dim.x, 1, 1, color_white);
		// vertices[vi++] = Vertex( w,     0,     0, 0, 1, color_white);

		// indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
		// indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;

		for (uint x = 0; x < dim.x; x++)
		for (uint y = 0; y < dim.y; y++)
		{
			SColor color = getPixel(x, y);
			if (isPixelVisible(color))
			{
				u8 protrusion = getProtrusion(color);
				float w = protrusion / 2.0f;

				float x1 = x / dim.x;
				float y1 = y / dim.y;
				float x2 = (x + 1) / dim.x;
				float y2 = (y + 1) / dim.y;

				bool back = protrusion > getProtrusion(x - 1, y);
				bool front = protrusion > getProtrusion(x + 1, y);
				bool up = protrusion > getProtrusion(x, y - 1);
				bool down = protrusion > getProtrusion(x, y + 1);

				uint n = num(back) + num(front) + num(up) + num(down) + 2;
				vertices.set_length(vertices.length + 4 * n);
				indices.set_length(indices.length + 6 * n);

				//back
				if (back)
				{
					vertices[vi++] = Vertex( w, dim.y - y - 1, x, x2, y2, color_white);
					vertices[vi++] = Vertex(-w, dim.y - y - 1, x, x1, y2, color_white);
					vertices[vi++] = Vertex(-w, dim.y - y - 0, x, x1, y1, color_white);
					vertices[vi++] = Vertex( w, dim.y - y - 0, x, x2, y1, color_white);

					indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
					indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
				}

				//front
				if (front)
				{
					vertices[vi++] = Vertex(-w, dim.y - y - 0, x + 1, x2, y2, color_white);
					vertices[vi++] = Vertex(-w, dim.y - y - 1, x + 1, x1, y2, color_white);
					vertices[vi++] = Vertex( w, dim.y - y - 1, x + 1, x1, y1, color_white);
					vertices[vi++] = Vertex( w, dim.y - y - 0, x + 1, x2, y1, color_white);

					indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
					indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
				}

				//up
				if (up)
				{
					vertices[vi++] = Vertex(-w, dim.y - y, x + 0, x1, y1, color_white);
					vertices[vi++] = Vertex(-w, dim.y - y, x + 1, x1, y2, color_white);
					vertices[vi++] = Vertex( w, dim.y - y, x + 1, x2, y2, color_white);
					vertices[vi++] = Vertex( w, dim.y - y, x + 0, x2, y1, color_white);

					indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
					indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
				}

				//down
				if (down)
				{
					vertices[vi++] = Vertex( w, dim.y - y - 1, x + 1, x1, y1, color_white);
					vertices[vi++] = Vertex(-w, dim.y - y - 1, x + 1, x1, y2, color_white);
					vertices[vi++] = Vertex(-w, dim.y - y - 1, x + 0, x2, y2, color_white);
					vertices[vi++] = Vertex( w, dim.y - y - 1, x + 0, x2, y1, color_white);

					indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
					indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
				}

				//left
				vertices[vi++] = Vertex(-w, dim.y - y - 1, x + 1, x1, y1, color_white);
				vertices[vi++] = Vertex(-w, dim.y - y - 0, x + 1, x1, y2, color_white);
				vertices[vi++] = Vertex(-w, dim.y - y - 0, x + 0, x2, y2, color_white);
				vertices[vi++] = Vertex(-w, dim.y - y - 1, x + 0, x2, y1, color_white);

				indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
				indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;

				//right
				vertices[vi++] = Vertex( w, dim.y - y - 1, x + 0, x1, y1, color_white);
				vertices[vi++] = Vertex( w, dim.y - y - 1, x + 1, x1, y2, color_white);
				vertices[vi++] = Vertex( w, dim.y - y - 0, x + 1, x2, y2, color_white);
				vertices[vi++] = Vertex( w, dim.y - y - 0, x + 0, x2, y1, color_white);

				indices[ii++] = vi-4; indices[ii++] = vi-3; indices[ii++] = vi-1;
				indices[ii++] = vi-3; indices[ii++] = vi-2; indices[ii++] = vi-1;
			}
		}

		mesh.SetVertex(vertices);
		mesh.SetIndices(indices);
		mesh.BuildMesh();
	}

	void Protrude(Vec2f pos)
	{
		SColor color = getPixel(pos);
		if (isPixelVisible(color))
		{
			u8 alpha = color.getAlpha();
			if (alpha > 128)
			{
				color.setAlpha(alpha - 1);
				image.setPixel(color);
				BuildMesh();
			}
		}
	}

	void Recess(Vec2f pos)
	{
		SColor color = getPixel(pos);
		if (isPixelVisible(color))
		{
			u8 alpha = color.getAlpha();
			if (alpha < 255)
			{
				color.setAlpha(alpha + 1);
				image.setPixel(color);
				BuildMesh();
			}
		}
	}

	void LeftPixel()
	{
		if (isImageLoaded())
		{
			Vec2f pos = image.getPixelPosition() + Vec2f(-1, 0);
			if (pos.x < 0)
			{
				pos.x += dim.x;
			}
			image.setPixelPosition(pos);
		}
	}

	void RightPixel()
	{
		if (isImageLoaded())
		{
			Vec2f pos = image.getPixelPosition() + Vec2f(1, 0);
			if (pos.x >= dim.x)
			{
				pos.x -= dim.x;
			}
			image.setPixelPosition(pos);
		}
	}

	void UpPixel()
	{
		if (isImageLoaded())
		{
			Vec2f pos = image.getPixelPosition() + Vec2f(0, -1);
			if (pos.y < 0)
			{
				pos.y += dim.y;
			}
			image.setPixelPosition(pos);
		}
	}

	void DownPixel()
	{
		if (isImageLoaded())
		{
			Vec2f pos = image.getPixelPosition() + Vec2f(0, 1);
			if (pos.y >= dim.y)
			{
				pos.y -= dim.y;
			}
			image.setPixelPosition(pos);
		}
	}

	bool isValidPixel(int x, int y)
	{
		return x >= 0 && x < dim.x && y >= 0 && y < dim.y;
	}

	SColor getPixel(Vec2f pos)
	{
		return getPixel(pos.x, pos.y);
	}

	SColor getPixel(int x, int y)
	{
		SColor color(0, 0, 0, 0);
		if (isImageLoaded() && isValidPixel(x, y))
		{
			Vec2f pos = image.getPixelPosition();
			image.setPixelPosition(Vec2f(x, y));
			color = image.readPixel();
			image.setPixelPosition(pos);
		}
		return color;
	}

	void LoadSprite(string sprite)
	{
		this.sprite = sprite;
		@image = CFileImage(sprite);

		if (isImageLoaded())
		{
			print("Loaded sprite: " + sprite);

			dim = Vec2f(image.getWidth(), image.getHeight());
			SetMaterial(sprite);
			BuildMesh();
		}
		else
		{
			print("Unknown sprite: " + sprite);
		}
	}

	void SaveSprite()
	{
		image.Save();
	}

	bool isImageLoaded()
	{
		return image !is null && image.isLoaded();
	}

	bool isPixelVisible(SColor color)
	{
		return color.getAlpha() > 0;
	}

	bool isPixelVisible(int x, int y)
	{
		return isPixelVisible(getPixel(x, y));
	}

	bool isPixelVisible(Vec2f pos)
	{
		return isPixelVisible(getPixel(pos));
	}

	u8 getProtrusion(SColor color)
	{
		if (isPixelVisible(color))
		{
			return 256 - color.getAlpha();
		}
		return 0;
	}

	u8 getProtrusion(Vec2f pos)
	{
		return getProtrusion(getPixel(pos));
	}

	u8 getProtrusion(int x, int y)
	{
		return getProtrusion(getPixel(x, y));
	}

	void DrawDebugInfo()
	{
		if (isImageLoaded())
		{
			GUI::DrawText("sprite: " + sprite, Vec2f(10, 40), color_black);
			GUI::DrawText("pixel: " + image.getPixelPosition().toString(), Vec2f(10, 60), color_black);
			GUI::DrawText("protrusion: " + getProtrusion(image.getPixelPosition()), Vec2f(10, 80), color_black);

			TextureAtlas().Render(Vec2f(10, 110), 6, sprite, image.getPixelPosition(), isPixelVisible(image.getPixelPosition()));
		}
	}

	private void SetMaterial(string texture)
	{
		@material = SMaterial();
		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::BACK_FACE_CULLING, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);
		material.SetMaterialType(SMaterial::TRANSPARENT_ALPHA_CHANNEL_REF);
		mesh.SetMaterial(material);
	}
}
