#include "PlayerList.as"
#include "ObjectManager.as"
#include "GamemodeManager.as"

shared RespawnManager@ getRespawnManager()
{
	CRules@ rules = getRules();

	RespawnManager@ respawnManager;
	if (rules.get("respawn_manager", @respawnManager))
	{
		return respawnManager;
	}

	@respawnManager = RespawnManager();
	rules.set("respawn_manager", respawnManager);
	return respawnManager;
}

shared class RespawnManager
{
	private PlayerList queue;

	void Update()
	{
		for (uint i = 0; i < queue.getPlayerCount(); i++)
		{
			CPlayer@ player = queue.getPlayer(i);

			if (player is null || !canAddToQueue(player))
			{
				queue.RemoveIndex(i--);
			}
			else if (player.get_u32("respawn_time") < getGameTime())
			{
				AttemptRespawn(player);
			}
		}
	}

	void AddToQueue(CPlayer@ player, uint respawnTime)
	{
		if (player !is null && canAddToQueue(player))
		{
			if (!isRespawning(player))
			{
				queue.AddPlayer(player);
			}

			player.set_u32("respawn_time", getGameTime() + respawnTime);
			print("Added " + player.getUsername() + " to the respawn queue");
		}
	}

	void AddAllToQueue(uint respawnTime)
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null && canAddToQueue(player))
			{
				AddToQueue(player, respawnTime);
			}
		}
	}

	private void AttemptRespawn(CPlayer@ player)
	{
		Gamemode@ gamemode = getGamemodeManager().getGamemode();

		Actor@ actor;
		if (player !is null && gamemode.onPlayerAttemptRespawn(getRules(), player, actor))
		{
			RemoveFromQueue(player);
			getActorManager().RemoveActor(player);
			getObjectManager().AddObject(actor);
			print("Respawned " + player.getUsername() + " at " + actor.position.toString());

			//call gamemode event
			gamemode.onActorSpawned(getRules(), player, actor);
		}
	}

	void RemoveFromQueue(CPlayer@ player)
	{
		if (isRespawning(player))
		{
			queue.RemovePlayer(player);
			print("Removed " + player.getUsername() + " from the respawn queue");
		}
	}

	void ClearQueue()
	{
		queue.ClearPlayers();
		print("The respawn queue has been cleared");
	}

	bool isRespawning(CPlayer@ player)
	{
		return queue.hasPlayer(player);
	}

	private bool canAddToQueue(CPlayer@ player)
	{
		return player.getTeamNum() != getRules().getSpectatorTeamNum();
	}
}
