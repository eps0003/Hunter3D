#include "Actor.as"
#include "PlayerList.as"

ActorManager@ getActorManager()
{
	CRules@ rules = getRules();

	ActorManager@ actorManager;
	if (rules.get("actor_manager", @actorManager))
	{
		return actorManager;
	}

	@actorManager = ActorManager();
	rules.set("actor_manager", actorManager);
	return actorManager;
}

class ActorManager
{
	void Interpolate()
	{
		Actor@[] actors = getActors();

		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			actor.Interpolate();
		}
	}

	void Render()
	{
		Actor@[] actors = getActors();

		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			actor.Render();
		}
	}

	void CreateActor(CPlayer@ player, Vec3f position)
	{
		player.set("actor", Actor(player, position));
	}

	void UpdateActor(Actor@ actor)
	{
		actor.player.set("actor", actor);
	}

	Actor@ getActor(CPlayer@ player)
	{
		if (player !is null)
		{
			Actor@ actor;
			player.get("actor", @actor);
			return actor;
		}
		return null;
	}

	Actor@[] getActors()
	{
		Actor@[] actors;

		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			Actor@ actor = getActor(player);

			if (actor !is null)
			{
				actors.push_back(actor);
			}
		}

		return actors;
	}

	void RemoveActor(CPlayer@ player)
	{
		if (player != null)
		{
			player.set("actor", null);
		}
	}

	void RemoveAllActors()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			RemoveActor(player);
		}
	}

	bool hasActor(CPlayer@ player)
	{
		return getActor(player) !is null;
	}

	void server_Sync()
	{
		Actor@[] actors = getActors();

		CBitStream bs;
		bs.write_u32(actors.length);

		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			actor.Serialize(bs);
		}

		CRules@ rules = getRules();
		rules.SendCommand(rules.getCommandID("s_sync_actors"), bs, true);
	}

	void client_Sync(Actor@ actor)
	{
		CBitStream bs;
		actor.Serialize(bs);

		CRules@ rules = getRules();
		rules.SendCommand(rules.getCommandID("c_sync_actor"), bs, false);
	}
}
