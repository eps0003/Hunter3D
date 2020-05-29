#include "Vec3f.as"

const string CONFIG_NAME = "Hunter3D.cfg";

ConfigFile openPreferences()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/" + CONFIG_NAME))
	{
		//set default values
		cfg.add_f32("fov", 70);
		cfg.add_f32("sensitivity", 1);

		//save to cache
		cfg.saveFile(CONFIG_NAME);
		print("Initialized preferences");
	}
	return cfg;
}

ConfigFile@ openConfig(string filePath)
{
	ConfigFile@ cfg = ConfigFile();
	if (cfg.loadFile(filePath))
	{
		return cfg;
	}
	print("Config file not found: " + filePath);
	return null;
}

s8 num(bool boolean)
{
	return boolean ? 1 : 0;
}

float getInterGameTime()
{
	return getRules().get_f32("inter_game_time");
}

float getInterFrameTime()
{
	return getRules().get_f32("inter_frame_time");
}

bool isModLoaded()
{
	return getRules().get_bool("mod loaded");
}

bool isPixelEmpty(SColor[][] pixels, float x, float y)
{
	return getPixel(pixels, x, y).getAlpha() == 0;
}

SColor getPixel(SColor[][] pixels, float x, float y)
{
	//invalid pixel
	if (x < 0 || x >= pixels.length || y < 0 || y >= pixels[0].length)
	{
		return SColor(0, 0, 0, 0);
	}
	return pixels[x][y];
}

uint XORRandomRange(uint min, uint max)
{
	return XORRandom(max - min) + min;
}

void DrawCrosshair(int spacing, int length, int thickness, SColor color)
{
	Driver@ driver = getDriver();
	Vec2f center = driver.getScreenCenterPos();

	Vec2f x1(length + spacing, thickness);
	Vec2f x2(spacing, -thickness);
	Vec2f y1(thickness, length + spacing);
	Vec2f y2(-thickness, spacing);

	// float t = Ease::easeOut(interScopeAmount / cfg.SCOPE_TIME, Ease::quad);
	// color.setAlpha(255 * (1 - t));

	//left/right
	GUI::DrawRectangle(center - x1, center - x2, color);
	GUI::DrawRectangle(center + x2, center + x1, color);

	//top/bottom
	GUI::DrawRectangle(center - y1, center - y2, color);
	GUI::DrawRectangle(center + y2, center + y1, color);
}

Vertex[] Rectangle(
	Vec3f bl, Vec3f tr,
	Vec2f dim,
	Vec2f la, Vec2f lb, Vec2f ra, Vec2f rb,
	Vec2f ua, Vec2f ub, Vec2f da, Vec2f db,
	Vec2f fa, Vec2f fb, Vec2f ba, Vec2f bb
) {
	Vertex[] vertices;

	float x1, y1, x2, y2;
	SColor color = color_white;

	//top 4 vertices of cube going clockwise looking from top
	Vec3f t1 = Vec3f(bl.x, bl.y, bl.z);
	Vec3f t2 = Vec3f(tr.x, bl.y, bl.z);
	Vec3f t3 = Vec3f(tr.x, bl.y, tr.z);
	Vec3f t4 = Vec3f(bl.x, bl.y, tr.z);

	//bottom 4 vertices of cube going clockwise looking from top
	Vec3f b1 = Vec3f(bl.x, tr.y, bl.z);
	Vec3f b2 = Vec3f(tr.x, tr.y, bl.z);
	Vec3f b3 = Vec3f(tr.x, tr.y, tr.z);
	Vec3f b4 = Vec3f(bl.x, tr.y, tr.z);

	//left -x
	x1 = la.x / dim.x;
	y1 = la.y / dim.x;
	x2 = lb.x / dim.x;
	y2 = lb.y / dim.x;
	vertices.push_back(Vertex(t1.x, t1.y, t1.z, x2, y2, color));
	vertices.push_back(Vertex(t4.x, t4.y, t4.z, x1, y2, color));
	vertices.push_back(Vertex(b4.x, b4.y, b4.z, x1, y1, color));
	vertices.push_back(Vertex(b1.x, b1.y, b1.z, x2, y1, color));

	//right +x
	x1 = ra.x / dim.x;
	y1 = ra.y / dim.x;
	x2 = rb.x / dim.x;
	y2 = rb.y / dim.x;
	vertices.push_back(Vertex(t3.x, t3.y, t3.z, x2, y2, color));
	vertices.push_back(Vertex(t2.x, t2.y, t2.z, x1, y2, color));
	vertices.push_back(Vertex(b2.x, b2.y, b2.z, x1, y1, color));
	vertices.push_back(Vertex(b3.x, b3.y, b3.z, x2, y1, color));

	//front -z
	x1 = fa.x / dim.x;
	y1 = fa.y / dim.x;
	x2 = fb.x / dim.x;
	y2 = fb.y / dim.x;
	vertices.push_back(Vertex(t4.x, t4.y, t4.z, x2, y2, color));
	vertices.push_back(Vertex(t3.x, t3.y, t3.z, x1, y2, color));
	vertices.push_back(Vertex(b3.x, b3.y, b3.z, x1, y1, color));
	vertices.push_back(Vertex(b4.x, b4.y, b4.z, x2, y1, color));

	//back +z
	x1 = ba.x / dim.x;
	y1 = ba.y / dim.x;
	x2 = bb.x / dim.x;
	y2 = bb.y / dim.x;
	vertices.push_back(Vertex(t2.x, t2.y, t2.z, x2, y2, color));
	vertices.push_back(Vertex(t1.x, t1.y, t1.z, x1, y2, color));
	vertices.push_back(Vertex(b1.x, b1.y, b1.z, x1, y1, color));
	vertices.push_back(Vertex(b2.x, b2.y, b2.z, x2, y1, color));

	//top +y
	x1 = ua.x / dim.x;
	y1 = ua.y / dim.x;
	x2 = ub.x / dim.x;
	y2 = ub.y / dim.x;
	vertices.push_back(Vertex(b2.x, b2.y, b2.z, x1, y1, color));
	vertices.push_back(Vertex(b1.x, b1.y, b1.z, x2, y1, color));
	vertices.push_back(Vertex(b4.x, b4.y, b4.z, x2, y2, color));
	vertices.push_back(Vertex(b3.x, b3.y, b3.z, x1, y2, color));

	//bottom -y
	x1 = da.x / dim.x;
	y1 = da.y / dim.x;
	x2 = db.x / dim.x;
	y2 = db.y / dim.x;
	vertices.push_back(Vertex(t1.x, t1.y, t1.z, x1, y1, color));
	vertices.push_back(Vertex(t2.x, t2.y, t2.z, x2, y1, color));
	vertices.push_back(Vertex(t3.x, t3.y, t3.z, x2, y2, color));
	vertices.push_back(Vertex(t4.x, t4.y, t4.z, x1, y2, color));

	return vertices;
}

namespace ConfigFile
{
	Vec2f read_Vec2f(ConfigFile@ cfg, string key, Vec2f defaultVec)
	{
		float[] arr;
		if (cfg.readIntoArray_f32(arr, key) && arr.length >= 2)
		{
			return Vec2f(arr[0], arr[1]);
		}
		return defaultVec;
	}

	Vec3f read_Vec3f(ConfigFile@ cfg, string key, Vec3f defaultVec)
	{
		float[] arr;
		if (cfg.readIntoArray_f32(arr, key) && arr.length >= 3)
		{
			return Vec3f(arr[0], arr[1], arr[2]);
		}
		return defaultVec;
	}

	string[] readIntoArray_string(ConfigFile@ cfg, string key, string[] defaultArr)
	{
		string[] arr;
		if (cfg.readIntoArray_string(arr, key))
		{
			return arr;
		}
		return defaultArr;
	}
}

namespace Network
{
	bool isSingleplayer()
	{
		return isClient() && isServer();
	}

	bool isMultiplayer()
	{
		return !isSingleplayer();
	}
}

namespace Maths
{
	s8 Sign(float value)
	{
		if (value > 0)
			return 1;
		if (value < 0)
			return -1;
		return 0;
	}

	bool isOdd(int value)
	{
		return value % 2 == 1;
	}

	bool isEven(int value)
	{
		return value % 2 == 0;
	}

	float Clamp2(float value, float low, float high)
	{
		if (low > high)
		{
			float temp = low;
			low = high;
			high = temp;
		}

		return Maths::Clamp(value, low, high);
	}

	//TODO: use Random class
	float PreciseRandom(float max, uint precision = 1000)
	{
		return XORRandom(max * precision) / float(precision);
	}

	float AngleDifference(float a1, float a2)
	{
		float diff = (a2 - a1 + 180) % 360 - 180;
		return diff < -180 ? diff + 360 : diff;
	}

	float LerpAngle(float a1, float a2, float t)
	{
		return a1 + AngleDifference(a1, a2) * t;
	}
}

namespace Vec2f
{
	void Print(Vec2f vec)
	{
		print(vec.toString());
	}

	Vec2f random(float max)
	{
		return Vec2f(
			Maths::PreciseRandom(max),
			Maths::PreciseRandom(max)
		);
	}

	Vec2f lerp(Vec2f current, Vec2f desired, float t)
	{
		return Vec2f(
			current.x + t * (desired.x - current.x),
			current.y + t * (desired.y - current.y)
		);
	}

	void Serialize(Vec2f vec, CBitStream@ params)
	{
		params.write_f32(vec.x);
		params.write_f32(vec.y);
	}

	Vec2f Deserialize(CBitStream@ params)
	{
		return Vec2f(
			params.read_f32(),
			params.read_f32()
		);
	}
}

namespace String
{
	string join(string[] strings)
	{
		string text;
		for (uint i = 0; i < strings.length; i++)
		{
			text += strings[i];

			if (i < int(strings.length - 2))
			{
				text += ", ";
			}
			else if (i < strings.length - 1)
			{
				text += " and ";
			}
		}
		return text;
	}

	string plural(float value, string singular, string plural)
	{
		return value != 1 ? plural : singular;
	}

	string plural(float value, string singular)
	{
		return value != 1 ? singular + "s" : singular;
	}
}

namespace Array
{
	float sum(float[] arr)
	{
		float sum = 0;
		for (uint i = 0; i < arr.length; i++)
		{
			sum += arr[i];
		}
		return sum;
	}

	float mean(float[] arr)
	{
		if (arr.length == 0) return 0;
		return sum(arr) / arr.length;
	}

	float median(float[] arr)
	{
		if (arr.length == 0) return 0;
		arr.sortAsc();
		uint i = int(arr.length / 2.0f);
		if (Maths::isOdd(arr.length)) return arr[i];
		return (arr[i - 1] + arr[i]) / 2.0f;
	}
}

namespace Menu
{
	bool isMainMenuOpen()
	{
		return Menu::getMainMenu() !is null;
	}

	bool isMenuOpen()
	{
		return isMainMenuOpen() || getHUD().hasMenus();
	}
}

namespace Text
{
	void addTextToChat(string text)
	{
		CRules@ rules = getRules();
		CBitStream params;
		params.write_string(text);
		params.write_bool(false);
		rules.SendCommand(rules.getCommandID("server add text to chat"), params, true);
	}

	void addTextToChat(string text, SColor color)
	{
		CRules@ rules = getRules();
		CBitStream params;
		params.write_string(text);
		params.write_bool(true);
		params.write_u32(color.color);
		rules.SendCommand(rules.getCommandID("server add text to chat"), params, true);
	}

	void addTextToPlayerChat(string text, CPlayer@ player)
	{
		if (player.isMyPlayer())
		{
			client_AddToChat(text);
		}
		else
		{
			CRules@ rules = getRules();
			CBitStream params;
			params.write_string(text);
			params.write_bool(false);
			rules.SendCommand(rules.getCommandID("server add text to chat"), params, player);
		}
	}

	void addTextToPlayerChat(string text, SColor color, CPlayer@ player)
	{
		if (player.isMyPlayer())
		{
			client_AddToChat(text, color);
		}
		else
		{
			CRules@ rules = getRules();
			CBitStream params;
			params.write_string(text);
			params.write_bool(true);
			params.write_u32(color.color);
			rules.SendCommand(rules.getCommandID("server add text to chat"), params, player);
		}
	}

	void addTextToTeamChat(string text, u8 team)
	{
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player.getTeamNum() == team)
			{
				addTextToPlayerChat(text, player);
			}
		}
	}

	void addTextToTeamChat(string text, SColor color, u8 team)
	{
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player.getTeamNum() == team)
			{
				addTextToPlayerChat(text, color, player);
			}
		}
	}
}

//https://github.com/ai/easings.net/blob/master/src/easings/easingsFunctions.ts
namespace Ease
{
	const float c1 = 1.70158f;
	const float c2 = c1 * 1.525f;
	const float c3 = c1 + 1.0f;
	const float c4 = (2.0f * Maths::Pi) / 3.0f;
	const float c5 = (2.0f * Maths::Pi) / 4.5f;

	enum Type {
		linear, sine, quad, cubic, quart, quint, back,
		elastic, bounce
	}

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

namespace Matrix
{
	//TODO: test if this works
	//https://stackoverflow.com/a/1148405
	bool Invert(float[] m, float[] &out invOut)
	{
		float[] inv(16);

		inv[0] = m[5]  * m[10] * m[15] -
				 m[5]  * m[11] * m[14] -
				 m[9]  * m[6]  * m[15] +
				 m[9]  * m[7]  * m[14] +
				 m[13] * m[6]  * m[11] -
				 m[13] * m[7]  * m[10];

		inv[4] = -m[4]  * m[10] * m[15] +
				  m[4]  * m[11] * m[14] +
				  m[8]  * m[6]  * m[15] -
				  m[8]  * m[7]  * m[14] -
				  m[12] * m[6]  * m[11] +
				  m[12] * m[7]  * m[10];

		inv[8] = m[4]  * m[9]  * m[15] -
				 m[4]  * m[11] * m[13] -
				 m[8]  * m[5]  * m[15] +
				 m[8]  * m[7]  * m[13] +
				 m[12] * m[5]  * m[11] -
				 m[12] * m[7]  * m[9];

		inv[12] = -m[4]  * m[9]  * m[14] +
				   m[4]  * m[10] * m[13] +
				   m[8]  * m[5]  * m[14] -
				   m[8]  * m[6]  * m[13] -
				   m[12] * m[5]  * m[10] +
				   m[12] * m[6]  * m[9];

		inv[1] = -m[1]  * m[10] * m[15] +
				  m[1]  * m[11] * m[14] +
				  m[9]  * m[2]  * m[15] -
				  m[9]  * m[3]  * m[14] -
				  m[13] * m[2]  * m[11] +
				  m[13] * m[3]  * m[10];

		inv[5] = m[0]  * m[10] * m[15] -
				 m[0]  * m[11] * m[14] -
				 m[8]  * m[2]  * m[15] +
				 m[8]  * m[3]  * m[14] +
				 m[12] * m[2]  * m[11] -
				 m[12] * m[3]  * m[10];

		inv[9] = -m[0]  * m[9]  * m[15] +
				  m[0]  * m[11] * m[13] +
				  m[8]  * m[1]  * m[15] -
				  m[8]  * m[3]  * m[13] -
				  m[12] * m[1]  * m[11] +
				  m[12] * m[3]  * m[9];

		inv[13] = m[0]  * m[9]  * m[14] -
				  m[0]  * m[10] * m[13] -
				  m[8]  * m[1]  * m[14] +
				  m[8]  * m[2]  * m[13] +
				  m[12] * m[1]  * m[10] -
				  m[12] * m[2]  * m[9];

		inv[2] = m[1]  * m[6] * m[15] -
				 m[1]  * m[7] * m[14] -
				 m[5]  * m[2] * m[15] +
				 m[5]  * m[3] * m[14] +
				 m[13] * m[2] * m[7] -
				 m[13] * m[3] * m[6];

		inv[6] = -m[0]  * m[6] * m[15] +
				  m[0]  * m[7] * m[14] +
				  m[4]  * m[2] * m[15] -
				  m[4]  * m[3] * m[14] -
				  m[12] * m[2] * m[7] +
				  m[12] * m[3] * m[6];

		inv[10] = m[0]  * m[5] * m[15] -
				  m[0]  * m[7] * m[13] -
				  m[4]  * m[1] * m[15] +
				  m[4]  * m[3] * m[13] +
				  m[12] * m[1] * m[7] -
				  m[12] * m[3] * m[5];

		inv[14] = -m[0]  * m[5] * m[14] +
				   m[0]  * m[6] * m[13] +
				   m[4]  * m[1] * m[14] -
				   m[4]  * m[2] * m[13] -
				   m[12] * m[1] * m[6] +
				   m[12] * m[2] * m[5];

		inv[3] = -m[1] * m[6] * m[11] +
				  m[1] * m[7] * m[10] +
				  m[5] * m[2] * m[11] -
				  m[5] * m[3] * m[10] -
				  m[9] * m[2] * m[7] +
				  m[9] * m[3] * m[6];

		inv[7] = m[0] * m[6] * m[11] -
				 m[0] * m[7] * m[10] -
				 m[4] * m[2] * m[11] +
				 m[4] * m[3] * m[10] +
				 m[8] * m[2] * m[7] -
				 m[8] * m[3] * m[6];

		inv[11] = -m[0] * m[5] * m[11] +
				   m[0] * m[7] * m[9] +
				   m[4] * m[1] * m[11] -
				   m[4] * m[3] * m[9] -
				   m[8] * m[1] * m[7] +
				   m[8] * m[3] * m[5];

		inv[15] = m[0] * m[5] * m[10] -
				  m[0] * m[6] * m[9] -
				  m[4] * m[1] * m[10] +
				  m[4] * m[2] * m[9] +
				  m[8] * m[1] * m[6] -
				  m[8] * m[2] * m[5];

		float det = m[0] * inv[0] + m[1] * inv[4] + m[2] * inv[8] + m[3] * inv[12];

		if (det == 0) return false;

		det = 1.0f / det;

		for (uint i = 0; i < 16; i++)
		{
			invOut[i] = inv[i] * det;
		}

		return true;
	}

	Vec3f getTranslation(float[] m)
	{
		// float x = m[12];
		// float y = m[13];
		// float z = m[14];

		// return Vec3f(m[12], m[13], m[14]);

		return Vec3f(
			m[0] + m[1] + m[2]  + m[3],
			m[4] + m[5] + m[6]  + m[7],
			m[8] + m[9] + m[10] + m[11]
		);
	}
}
