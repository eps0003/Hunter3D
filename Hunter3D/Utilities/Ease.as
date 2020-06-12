enum EaseType
{
	linear, sine, quad, cubic, quart, quint, back,
	elastic, bounce
}

//https://github.com/ai/easings.net/blob/master/src/easings/easingsFunctions.ts
shared class Ease
{
	private float c1 = 1.70158f;
	private float c2 = c1 * 1.525f;
	private float c3 = c1 + 1.0f;
	private float c4 = (2.0f * Maths::Pi) / 3.0f;
	private float c5 = (2.0f * Maths::Pi) / 4.5f;

	float easeIn(float t, uint type)
	{
		switch (type)
		{
			case 0: return t; //linear
			case 1: return 1 - Maths::Cos(t * Maths::Pi / 2); //sine
			case 6: return c3 * t * t * t - c1 * t * t;
		}
		return Maths::Pow(t, type); //quad/cubic/quart/quint+
	}

	float easeOut(float t, uint type)
	{
		switch (type)
		{
			case 0: return t; //linear
			case 1: return Maths::Sin(t * Maths::Pi / 2); //sine
			case 6: return 1 + c3 * Maths::Pow(t - 1, 3) + c1 * Maths::Pow(t - 1, 2);
		}
		return 1 - Maths::Pow(1 - t, type); //quad/cubic/quart/quint+
	}

	float easeInOut(float t, uint type)
	{

		switch (type)
		{
			case 0: return t; //linear
			case 1: return -(Maths::Cos(Maths::Pi * t) - 1) / 2; //sine
			case 6: return t < 0.5f ? //back
				(Maths::Pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2 :
				(Maths::Pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2;
			//TODO: not sure if elastic works
			case 7: return t == 0 ? 0 : t == 1 ? 1 : t < 0.5f ? //elastic
				-(Maths::Pow(2, 20 * t - 10) * Maths::Sin((20 * t - 11.125f) * c5)) / 2 :
				Maths::Pow(2, -20 * t + 10) * Maths::Sin((20 * t - 11.125f) * c5) / 2 + 1;
		}
		return t < 0.5f ? //quad/cubic/quart/quint+
			Maths::Pow(2, type - 1) * Maths::Pow(t, type) :
			1 - Maths::Pow(-2 * t + 2, type) / 2;
	}
}
