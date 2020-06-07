#include "ImageUV.as"

class UVEditor
{
	void Render(Vec2f position, string skin, ImageUV@[] UVs, uint selectedUV)
	{
		float scale = 4;

		Vec2f dim;
		GUI::GetImageDimensions(skin, dim);
		dim *= scale;

		Vec2f tl = position;
		Vec2f br = tl + dim;

		GUI::DrawRectangle(tl - Vec2f(1, 1), br + Vec2f(1, 1), color_black);
		GUI::DrawRectangle(tl, br, color_white);
		GUI::DrawIcon(skin, tl, scale / 2.0f);

		for (uint i = 0; i < UVs.length; i++)
		{
			ImageUV@ uv = UVs[i];
			Vec2f min = tl + Vec2f(dim.x * uv.min.x, dim.y * uv.min.y);
			Vec2f max = tl + Vec2f(dim.x * uv.max.x, dim.y * uv.max.y);
			SColor color = selectedUV == i ? SColor(255, 0, 255, 0) : SColor(255, 255, 0, 0);
			DrawOutlinedRectangle(min, max, color);
		}
	}

	private void DrawOutlinedRectangle(Vec2f tl, Vec2f br, SColor color, uint thickness = 1)
	{
		Vec2f dim = br - tl;
		Vec2f tr = tl + Vec2f(dim.x, 0);
		Vec2f bl = tl + Vec2f(0, dim.y);

		//top bottom
		GUI::DrawRectangle(tl, tr + Vec2f(0, thickness), color);
		GUI::DrawRectangle(bl + Vec2f(0, -thickness), br, color);

		//left right
		GUI::DrawRectangle(tl, bl + Vec2f(thickness, 0), color);
		GUI::DrawRectangle(tr + Vec2f(-thickness, 0), br, color);
	}
}
