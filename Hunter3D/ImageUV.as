class ImageUV
{
	Vec2f min(0, 0);
	Vec2f max(1, 1);

	ImageUV() {}

	ImageUV(float x, float y, float w, float h)
	{
		min = Vec2f(x, y);
		max = min + Vec2f(w, h);
	}

	ImageUV(string serialized)
	{
		string[] values = serialized.split(" ");
		if (values.length == 4)
		{
			min.x = parseFloat(values[0]);
			min.y = parseFloat(values[1]);
			max.x = parseFloat(values[2]);
			max.y = parseFloat(values[3]);
		}
		else
		{
			print("Unable to parse serialized ImageUV string: " + serialized);
		}
	}

	bool isVisible()
	{
		return min != max;
	}

	string toString()
	{
		return min.x + " " + min.y + " " + max.x + " " + max.y;
	}
}
