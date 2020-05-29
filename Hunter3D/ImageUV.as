class ImageUV
{
	Vec2f min;
	Vec2f max;

	ImageUV()
	{
		min = Vec2f(0, 0);
		max = Vec2f(1, 1);
	}

	ImageUV(float x, float y, float w, float h)
	{
		min = Vec2f(x, y);
		max = min + Vec2f(w, h);
	}

	bool isVisible()
	{
		return min != max;
	}
}
