#include "Object.as"
#include "AABB.as"

const float GRAVITY = 0.03f;

class PhysicsObject : Object
{
	AABB@ hitbox;

	private bool collisionX = false;
	private bool collisionY = false;
	private bool collisionZ = false;

	PhysicsObject(Vec3f position, Vec3f rotation = Vec3f(0, 0, 0), Vec3f velocity = Vec3f(0, 0, 0))
	{
		super(position, rotation, velocity);
	}

	PhysicsObject(CBitStream@ bs)
	{
		super(bs);
	}

	void PreUpdate()
	{
		Object::PreUpdate();

		//reset velocity from collision last tick
		if (collisionX)
		{
			velocity.x = 0;
			collisionX = false;
		}
		if (collisionY)
		{
			velocity.y = 0;
			collisionY = false;
		}
		if (collisionZ)
		{
			velocity.z = 0;
			collisionZ = false;
		}
	}

	void Update()
	{
		Object::Update();

		velocity.y -= GRAVITY;
		velocity.y = Maths::Clamp(velocity.y, -1, 1);
	}

	void PostUpdate()
	{
		Object::PostUpdate();

		CollisionResponse();
	}

	bool isOnGround()
	{
		return false;
	}

	void Serialize(CBitStream@ bs)
	{
		Object::Serialize(bs);
	}

	private void CollisionResponse()
	{
		//x collision
		Vec3f xPosition(position.x + velocity.x, position.y, position.z);
		if (hitbox.intersectsNewAt(position, xPosition) || hitbox.intersectsMapEdgeAt(xPosition))
		{
			if (velocity.x > 0)
			{
				position.x = Maths::Ceil(position.x + hitbox.max.x) - hitbox.max.x;
			}
			else if (velocity.x < 0)
			{
				position.x = Maths::Floor(position.x + hitbox.min.x) - hitbox.min.x;
			}
			collisionX = true;
		}

		if (!collisionX)
		{
			position.x += velocity.x;
		}

		//z collision
		Vec3f zPosition(position.x, position.y, position.z + velocity.z);
		if (hitbox.intersectsNewAt(position, zPosition) || hitbox.intersectsMapEdgeAt(zPosition))
		{
			if (velocity.z > 0)
			{
				position.z = Maths::Ceil(position.z + hitbox.max.z) - hitbox.max.z;
			}
			else if (velocity.z < 0)
			{
				position.z = Maths::Floor(position.z + hitbox.min.z) - hitbox.min.z;
			}
			collisionZ = true;
		}

		if (!collisionZ)
		{
			position.z += velocity.z;
		}

		//y collision
		Vec3f yPosition(position.x, position.y + velocity.y, position.z);
		if (hitbox.intersectsNewAt(position, yPosition) || hitbox.intersectsMapEdgeAt(yPosition))
		{
			if (velocity.y > 0)
			{
				position.y = Maths::Ceil(position.y + hitbox.max.y) - hitbox.max.y;
			}
			else if (velocity.y < 0)
			{
				position.y = Maths::Floor(position.y + hitbox.min.y) - hitbox.min.y;
			}
			collisionY = true;
		}

		if (!collisionY)
		{
			position.y += velocity.y;
		}
	}
}
