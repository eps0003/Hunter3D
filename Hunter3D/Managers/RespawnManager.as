#include "PlayerList.as"
#include "ActorManager.as"
#include "Vec3f.as"
#include "Map.as"

RespawnManager@ getRespawnManager()
{
	CRules@ rules = getRules();

	RespawnManager@ respawnManager;
	if (rules.get("respawn manager", @respawnManager))
	{
		return respawnManager;
	}

	@respawnManager = RespawnManager();
	rules.set("respawn manager", respawnManager);
	return respawnManager;
}

class RespawnManager
{
	PlayerList queue;
	int respawnTime = 60;

	void Update()
	{
		if (canCountdownRespawnTimer())
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
					Respawn(player);
				}
			}
		}
	}

	void AddToQueue(CPlayer@ player)
	{
		if (player !is null)
		{
			if (isRespawning(player))
			{
				print(player.getUsername() + " is already in the respawn queue");
			}
			else if (canAddToQueue(player))
			{
				getActorManager().RemoveActor(player);
				queue.AddPlayer(player);
				player.set_u32("respawn time", getGameTime() + respawnTime);
				print("Added " + player.getUsername() + " to the respawn queue");
			}
			else
			{
				print(player.getUsername() + " is unable to join the respawn queue");
			}
		}
	}

	void Respawn(CPlayer@ player)
	{
		if (player !is null)
		{
			RemoveFromQueue(player);

			Vec3f position = getRespawnPoint(player);
			getActorManager().CreateActor(player, position);

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

	Vec3f getRespawnPoint(CPlayer@ player)
	{
		return getMap3D().getMapDimensions() / 2;
	}

	private bool isRespawning(CPlayer@ player)
	{
		return queue.hasPlayer(player);
	}

	private bool canAddToQueue(CPlayer@ player)
	{
		return !isRespawning(player);
	}

	private bool canRespawn(CPlayer@ player)
	{
		return player !is null && (
			player.get_u32("respawn time") < getGameTime() ||
			canInstantRespawn(player)
		);
	}

	private bool canInstantRespawn(CPlayer@ player)
	{
		return false;
	}

	private bool canCountdownRespawnTimer()
	{
		return getMap3D() !is null;
	}
}
