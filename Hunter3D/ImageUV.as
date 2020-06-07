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
			error("Unable to parse serialized ImageUV string: " + serialized);
		}
	}

	bool isVisible()
	{
		return min != max;
	}

	string toString(uint precision = 3)
	{
		return "(" + formatFloat(min.x, "", 0, precision) + ", " + formatFloat(min.y, "", 0, precision) + ") (" + formatFloat(max.x, "", 0, precision) + ", " + formatFloat(max.y, "", 0, precision) + ")";
	}

	string toString(string image)
	{
		Vec2f dim;
		GUI::GetImageDimensions(image, dim);

		int minX = dim.x * min.x;
		int minY = dim.y * min.y;
		int maxX = dim.x * max.x;
		int maxY = dim.y * max.y;

		return "(" + minX + ", " + minY + ") (" + maxX + ", " + maxY+ ")";
	}

	string serializeString()
	{
		return min.x + " " + min.y + " " + max.x + " " + max.y;
	}
}
