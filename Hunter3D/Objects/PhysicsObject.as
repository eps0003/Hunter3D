#include "Object.as"
#include "AABB.as"

shared class PhysicsObject : Object
{
	AABB@ hitbox;

	float gravity;
	float friction;
	float airResitance;
	float angularFriction;
	float elasticity;

	Vec3f velocity;
	Vec3f oldVelocity;
	Vec3f interVelocity;

	Vec3f angularVelocity;
	Vec3f oldAngularVelocity;
	Vec3f interAngularVelocity;

	private bool collisionX = false;
	private bool collisionY = false;
	private bool collisionZ = false;

	PhysicsObject(Vec3f position, Vec3f rotation = Vec3f(0, 0, 0), Vec3f velocity = Vec3f(0, 0, 0))
	{
		super(position, rotation);

		this.velocity = velocity;
	}

	PhysicsObject(CBitStream@ bs)
	{
		super(bs);

		velocity = Vec3f(bs);
	}

	void opAssign(PhysicsObject physicsObject)
	{
		opAssign(cast<Object>(physicsObject));

		oldVelocity = velocity;
		velocity = physicsObject.velocity;
	}

	void PreUpdate()
	{
		Object::PreUpdate();

		oldVelocity = velocity;

		//elasticity from collision last tick
		if (collisionX)
		{
			velocity.x *= -elasticity;
			collisionX = false;
		}
		if (collisionY)
		{
			velocity.y *= -elasticity;
			collisionY = false;
		}
		if (collisionZ)
		{
			velocity.z *= -elasticity;
			collisionZ = false;
		}
	}

	void Update()
	{
		Object::Update();

		//gravity
		velocity.y -= gravity;
		velocity.y = Maths::Clamp(velocity.y, -1, 1);

		//angular friction
		angularVelocity.x -= angularFriction * angularVelocity.x;
		angularVelocity.y -= angularFriction * angularVelocity.y;
		angularVelocity.z -= angularFriction * angularVelocity.z;
	}

	void PostUpdate()
	{
		Object::PostUpdate();

		//set velocity to zero if low enough
		if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
		if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
		if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;

		CollisionResponse();
	}

	void Interpolate()
	{
		float t = getInterFrameTime();

		interPosition = oldPosition.lerp(oldPosition + velocity, t);
		interPosition = interPosition.clamp(oldPosition, position);

		interVelocity = oldVelocity.lerp(velocity, t);
		interAngularVelocity = oldAngularVelocity.lerp(angularVelocity, t);

		interRotation = oldRotation.lerpAngle(oldRotation + angularVelocity, t);
	}

	void Serialize(CBitStream@ bs)
	{
		Object::Serialize(bs);

		velocity.Serialize(bs);
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		Object::LoadConfig(cfg);

		gravity = cfg.read_f32("gravity", 0.03f);
		friction = cfg.read_f32("friction", 0.01f);
		airResitance = cfg.read_f32("air_resistance", 0.0f);
		angularFriction = cfg.read_f32("angular_friction", 0.0f);
		elasticity = cfg.read_f32("elasticity", 0.0f);
	}

	private void CollisionResponse()
	{
		if (hitbox !is null)
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
}
