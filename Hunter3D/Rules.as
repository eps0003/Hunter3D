#define SERVER_ONLY;

void onInit(CRules@ this)
{
	print("initialized");
}

void onRestart(CRules@ this)
{
	print("restarted");
}

void onTick(CRules@ this)
{

}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	string username = player.getUsername();
	print(username + " joined");
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	string username = player.getUsername();
	print(username + " left");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{

}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newTeam)
{
	string username = player.getUsername();
	print(username + " requested team change");
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	string username = victim.getUsername();
	print(username + " died");
}
