#include "Map.as"

shared class Gamemode
{
	string name;
	string shortName;

	void onInit(CRules@ this) {}
	void onRestart(CRules@ this) {}
	void onTick(CRules@ this) {}
	void onNewPlayerJoin(CRules@ this, CPlayer@ player) {}
	void onPlayerLeave(CRules@ this, CPlayer@ player) {}
	void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData) {}
	void onCommand(CRules@ this, u8 cmd, CBitStream@ params) {}

	Vec3f getRespawnPoint(CPlayer@ player)
	{
		Vec3f dim = getMap3D().getMapDimensions();
		return Vec3f(dim.x / 2, dim.y, dim.z / 2);
	}

	bool canRespawn(CPlayer@ player)
	{
		return true;
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		name = cfg.read_string("name", "Unknown Gamemode");
		shortName = cfg.read_string("short_name", "???");
	}
}
