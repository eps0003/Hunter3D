#include "Actor.as"

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
	private Actor@[] actors;

	void Interpolate()
	{
		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			actor.Interpolate();
		}
	}

	void Render()
	{
		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			actor.Render();
		}
	}

	Actor@ getActor(Actor@ actor)
	{
		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ a = actors[i];
			if (a.isSameAs(actor))
			{
				return a;
			}
		}

		return null;
	}

	Actor@ getActorByUsername(string username)
	{
		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			if (actor.player.getUsername() == username)
			{
				return actor;
			}
		}

		return null;
	}

	Actor@ getActorByID(uint id)
	{
		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			if (actor.id == id)
			{
				return actor;
			}
		}

		return null;
	}

	Actor@ getActor(CPlayer@ player)
	{
		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			if (actor.player is player)
			{
				return actor;
			}
		}

		return null;
	}

	Actor@[] getActors()
	{
		return actors;
	}

	void AddActor(Actor@ actor)
	{
		if (isServer())
		{
			actor.AssignUniqueID();
		}

		actors.push_back(actor);
	}

	void AddActor(CPlayer@ player, Vec3f position)
	{
		Actor actor(player, position);
		AddActor(actor);
	}

	void RemoveActor(Actor@ actor)
	{
		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ a = actors[i];
			if (a.isSameAs(actor))
			{
				actors.removeAt(i);

				if (isClient())
				{
					getCamera3D().SetParent(null);
				}

				if (isServer())
				{
					CRules@ rules = getRules();
					CBitStream bs;
					a.Serialize(bs);
					rules.SendCommand(rules.getCommandID("s_remove_actor"), bs, true);
				}

				return;
			}
		}
	}

	void RemoveActor(CPlayer@ player)
	{
		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			if (actor.player is player)
			{
				actors.removeAt(i);

				if (isServer())
				{
					CRules@ rules = getRules();
					CBitStream bs;
					actor.Serialize(bs);
					rules.SendCommand(rules.getCommandID("s_remove_actor"), bs, true);
				}

				return;
			}
		}
	}

	void ClearActors()
	{
		actors.clear();
	}

	uint getActorCount()
	{
		return actors.length;
	}

	bool playerHasActor(CPlayer@ player)
	{
		return getActor(player) !is null;
	}

	void SerializeActors(CBitStream@ bs)
	{
		bs.write_u32(actors.length);

		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			actor.Serialize(bs);
		}
	}

	void DeserializeActors(CBitStream@ bs)
	{
		uint count = bs.read_u32();

		for (uint i = 0; i < count; i++)
		{
			Actor actor(bs);
			Actor@ existingActor = getActor(actor);

			if (existingActor !is null)
			{
				//update actors that arent mine
				if (!actor.player.isMyPlayer())
				{
					existingActor = actor;
				}
			}
			else
			{
				//spawn actor
				AddActor(actor);

				if (actor.player.isMyPlayer())
				{
					getCamera3D().SetParent(actor);
				}
			}
		}
	}
}
