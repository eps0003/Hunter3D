#include "PlayerList.as"
#include "ActorManager.as"
#include "GamemodeManager.as"
#include "Vec3f.as"
#include "Map.as"

RespawnManager@ getRespawnManager()
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

class RespawnManager
{
	private PlayerList queue;

	void Update()
	{
		for (uint i = 0; i < queue.getPlayerCount(); i++)
		{
			CPlayer@ player = queue.getPlayer(i);

			if (player is null)
			{
				queue.RemoveIndex(i--);
			}
			else if (canRespawn(player))
			{
				Vec3f position = getGamemodeManager().getGamemode().getRespawnPoint(player);
				Respawn(player, position);
			}
		}
	}

	void AddToQueue(CPlayer@ player, uint respawnTime)
	{
		if (player !is null)
		{
			if (!isRespawning(player))
			{
				getActorManager().RemoveActor(player);
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
			AddToQueue(player, respawnTime);
		}
	}

	void Respawn(CPlayer@ player, Vec3f position)
	{
		if (player !is null)
		{
			RemoveFromQueue(player);
			Actor@ actor = Actor(player, position);
			getActorManager().AddActor(actor);
			print("Respawned " + player.getUsername() + " at " + position.toString());
		}
	}

	void RemoveFromQueue(CPlayer@ player)
	{
		if (player !is null)
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

	private bool canRespawn(CPlayer@ player)
	{
		return (
			player !is null &&
			player.get_u32("respawn_time") < getGameTime() &&
			getGamemodeManager().getGamemode().canRespawn(player)
		);
	}
}
