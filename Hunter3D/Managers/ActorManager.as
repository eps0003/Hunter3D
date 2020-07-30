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

		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			actor.RenderNameplate();
		}
	}

	Actor@ getActor(Actor@ actor)
	{
		Actor@[] actors = getActors();

		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ a = actors[i];
			if (a == actor)
			{
				return a;
			}
		}

		return null;
	}

	Actor@ getActorByUsername(string username)
	{
		Actor@[] actors = getActors();

		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			if (actor.getPlayer().getUsername() == username)
			{
				return actor;
			}
		}

		return null;
	}

	Actor@ getActor(CPlayer@ player)
	{
		Actor@[] actors = getActors();

		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			if (actor.getPlayer() is player)
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

		for (uint i = 0; i < objects.size(); i++)
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

		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			Actor@ actor2 = cast<Actor>(object);

			if (actor2 !is null && actor == actor2)
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

		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			Actor@ actor = cast<Actor>(object);

			if (actor !is null && actor.getPlayer() is player)
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

		for (int i = objects.size() - 1; i >= 0; i--)
		{
			Object@ object = objects[i];
			Actor@ actor = cast<Actor>(object);

			if (actor !is null)
			{
				objectManager.RemoveObject(i);
			}
		}
	}

	uint getActorCount()
	{
		return getActors().size();
	}

	bool playerHasActor(CPlayer@ player)
	{
		return getActor(player) !is null;
	}

	private void RemoveActor(ObjectManager@ objectManager, Actor@ actor, uint index)
	{
		objectManager.RemoveObject(index);

		if (actor.getPlayer().isMyPlayer())
		{
			getCamera3D().SetParent(null);
		}
	}
}
