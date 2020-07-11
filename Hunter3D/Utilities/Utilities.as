enum Direction
{
	Left,
	Right,
	Down,
	Up,
	Front,
	Back
}

shared SColor getSkyColor()
{
	return SColor(255, 165, 189, 200);
}

shared string[] getDirectionNames()
{
	string[] directionNames = { "left", "right", "down", "up", "front", "back" };
	return directionNames;
}

shared string[] getDirectionLetters()
{
	string[] directionLetters = { "l", "r", "d", "u", "f", "b" };
	return directionLetters;
}

shared ConfigFile openPreferences()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/Hunter3D.cfg"))
	{
		//set default values
		cfg.add_f32("fov", 70.0f);
		cfg.add_f32("sensitivity", 1.0f);
		cfg.add_f32("render_distance", 70.0f);

		//save to cache
		cfg.saveFile("Hunter3D.cfg");
		print("Initialized preferences");
	}
	return cfg;
}

shared ConfigFile@ openConfig(string filePath)
{
	ConfigFile@ cfg = ConfigFile();
	if (cfg.loadFile(filePath))
	{
		return cfg;
	}
	print("Config file not found: " + filePath);
	return null;
}

shared s8 num(bool boolean)
{
	return boolean ? 1 : 0;
}

shared float getInterGameTime()
{
	return getRules().get_f32("inter_game_time");
}

shared float getInterFrameTime()
{
	return getRules().get_f32("inter_frame_time");
}

shared uint XORRandomRange(uint min, uint max)
{
	return XORRandom(max - min) + min;
}

shared void DrawCrosshair(int spacing, int length, int thickness, SColor color)
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

namespace Network
{
	shared bool isSingleplayer()
	{
		return isClient() && isServer();
	}

	shared bool isMultiplayer()
	{
		return !isSingleplayer();
	}
}

namespace Maths
{
	shared s8 Sign(float value)
	{
		if (value > 0)
			return 1;
		if (value < 0)
			return -1;
		return 0;
	}

	shared bool isOdd(int value)
	{
		return value % 2 == 1;
	}

	shared bool isEven(int value)
	{
		return value % 2 == 0;
	}

	shared float Clamp2(float value, float low, float high)
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
	shared float PreciseRandom(float max, uint precision = 1000)
	{
		return XORRandom(max * precision) / float(precision);
	}

	shared float AngleDifference(float a1, float a2)
	{
		float diff = (a2 - a1 + 180) % 360 - 180;
		return diff < -180 ? diff + 360 : diff;
	}

	shared float LerpAngle(float a1, float a2, float t)
	{
		return a1 + AngleDifference(a1, a2) * t;
	}
}

namespace Vec2f
{
	shared void Print(Vec2f vec)
	{
		print(vec.toString());
	}

	shared Vec2f random(float max)
	{
		return Vec2f(
			Maths::PreciseRandom(max),
			Maths::PreciseRandom(max)
		);
	}

	shared void Serialize(Vec2f vec, CBitStream@ params)
	{
		params.write_f32(vec.x);
		params.write_f32(vec.y);
	}

	shared Vec2f Deserialize(CBitStream@ params)
	{
		return Vec2f(
			params.read_f32(),
			params.read_f32()
		);
	}
}

namespace String
{
	shared string join(string[] strings)
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

	shared string plural(float value, string singular, string plural)
	{
		return value != 1 ? plural : singular;
	}

	shared string plural(float value, string singular)
	{
		return value != 1 ? singular + "s" : singular;
	}
}

namespace Array
{
	shared float sum(float[] arr)
	{
		float sum = 0;
		for (uint i = 0; i < arr.length; i++)
		{
			sum += arr[i];
		}
		return sum;
	}

	shared float mean(float[] arr)
	{
		if (arr.length == 0) return 0;
		return sum(arr) / arr.length;
	}

	shared float median(float[] arr)
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
	shared bool isMainMenuOpen()
	{
		return Menu::getMainMenu() !is null;
	}

	shared bool isMenuOpen()
	{
		return isMainMenuOpen() || getHUD().hasMenus();
	}
}

namespace Text
{
	shared void addTextToChat(string text)
	{
		CRules@ rules = getRules();
		CBitStream params;
		params.write_string(text);
		params.write_bool(false);
		rules.SendCommand(rules.getCommandID("server add text to chat"), params, true);
	}

	shared void addTextToChat(string text, SColor color)
	{
		CRules@ rules = getRules();
		CBitStream params;
		params.write_string(text);
		params.write_bool(true);
		params.write_u32(color.color);
		rules.SendCommand(rules.getCommandID("server add text to chat"), params, true);
	}

	shared void addTextToPlayerChat(string text, CPlayer@ player)
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

	shared void addTextToPlayerChat(string text, SColor color, CPlayer@ player)
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

	shared void addTextToTeamChat(string text, u8 team)
	{
		uint count = getPlayersCount();
		for (uint i = 0; i < count; i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null && player.getTeamNum() == team)
			{
				addTextToPlayerChat(text, player);
			}
		}
	}

	shared void addTextToTeamChat(string text, SColor color, u8 team)
	{
		uint count = getPlayersCount();
		for (uint i = 0; i < count; i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null && player.getTeamNum() == team)
			{
				addTextToPlayerChat(text, color, player);
			}
		}
	}
}
