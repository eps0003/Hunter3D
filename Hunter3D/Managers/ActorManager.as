#include "ObjectManager.as"
#include "Actor.as"

shared ActorManager@ getActorManager()
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

shared class ActorManager
{
	void RenderHUD()
	{
		Actor@[] actors = getActors();

		for (uint i = 0; i < actors.length; i++)
		{
			Actor@ actor = actors[i];
			actor.RenderNameplate();
			actor.RenderHUD();
		}
	}

	Actor@ getActor(Actor@ actor)
	{
		Actor@[] actors = getActors();

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
		Actor@[] actors = getActors();

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

	Actor@ getActor(CPlayer@ player)
	{
		Actor@[] actors = getActors();

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
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();
		Actor@[] actors;

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			Actor@ actor = cast<Actor>(object);

			if (actor !is null)
			{
				actors.push_back(actor);
			}
		}

		return actors;
	}

	void RemoveActor(Actor@ actor)
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			Actor@ actor2 = cast<Actor>(object);

			if (actor2 !is null && actor.isSameAs(actor2))
			{
				RemoveActor(objectManager, actor2, i);
				return;
			}
		}
	}

	void RemoveActor(CPlayer@ player)
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			Actor@ actor = cast<Actor>(object);

			if (actor !is null && actor.player is player)
			{
				RemoveActor(objectManager, actor, i);
				return;
			}
		}
	}

	void ClearActors()
	{
		ObjectManager@ objectManager = getObjectManager();
		Object@[] objects = objectManager.getObjects();

		for (uint i = 0; i < objects.length; i++)
		{
			Object@ object = objects[i];
			Actor@ actor = cast<Actor>(object);

			if (actor !is null)
			{
				objectManager.RemoveObject(i--);
			}
		}
	}

	uint getActorCount()
	{
		return getActors().length;
	}

	bool playerHasActor(CPlayer@ player)
	{
		return getActor(player) !is null;
	}

	void SerializeActors(CBitStream@ bs)
	{
		Actor@[] actors = getActors();

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
				getObjectManager().AddObject(actor);

				if (actor.player.isMyPlayer())
				{
					getCamera3D().SetParent(actor);
				}
			}
		}
	}

	private void RemoveActor(ObjectManager@ objectManager, Actor@ actor, uint index)
	{
		objectManager.RemoveObject(index);

		if (actor.player.isMyPlayer())
		{
			getCamera3D().SetParent(null);
		}

		if (isServer())
		{
			CRules@ rules = getRules();
			CBitStream bs;
			actor.Serialize(bs);
			rules.SendCommand(rules.getCommandID("s_remove_actor"), bs, true);
		}
	}
}
