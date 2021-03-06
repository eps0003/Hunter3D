#include "Object.as"
#include "IBounds.as"
#include "Map.as"
#include "CollisionFlags.as"

shared class PhysicsObject : Object, IHasConfig
{
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

	private AABB@ collisionBox;
	private uint collisionFlags = 0;

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

	bool opEquals(PhysicsObject@ physicsObject)
	{
		return opEquals(cast<Object>(physicsObject));
	}

	void ClearPhysics()
	{
		velocity.Clear();
		oldVelocity.Clear();

		angularVelocity.Clear();
		oldAngularVelocity.Clear();
	}

	void onCreate()
	{
		Object::onCreate();

		oldVelocity = velocity;
		interVelocity = velocity;
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
		//set velocity to zero if low enough
		if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
		if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
		if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;

		CollisionResponse();

		Object::PostUpdate();
	}

	void Interpolate(float t)
	{
		if (oldPosition != position)
		{
			interPosition = oldPosition.lerp(oldPosition + velocity, t);
			interPosition = interPosition.clamp(oldPosition, position);
		}

		if (oldVelocity != velocity)
		{
			interVelocity = oldVelocity.lerp(velocity, t);
		}

		if (oldAngularVelocity != angularVelocity)
		{
			interAngularVelocity = oldAngularVelocity.lerp(angularVelocity, t);
		}

		if (oldRotation != rotation)
		{
			interRotation = oldRotation.lerpAngle(oldRotation + angularVelocity, t);
		}
	}

	void Serialize(CBitStream@ bs)
	{
		Object::Serialize(bs);

		velocity.Serialize(bs);
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		Identifiable::LoadConfig(cfg);

		gravity = cfg.read_f32("gravity", 0.03f);
		friction = cfg.read_f32("friction", 0.01f);
		airResitance = cfg.read_f32("air_resistance", 0.0f);
		angularFriction = cfg.read_f32("angular_friction", 0.0f);
		elasticity = cfg.read_f32("elasticity", 0.0f);
	}

	bool isStatic()
	{
		return Object::isStatic() && velocity == oldVelocity;
	}

	void SetCollisionBox(AABB@ aabb)
	{
		@collisionBox = aabb;
	}

	AABB@ getCollisionBox()
	{
		return collisionBox;
	}

	void SetCollisionFlags(u8 flags)
	{
		collisionFlags = flags;
	}

	private bool hasCollisionFlags(u8 flags)
	{
		return (collisionFlags & flags) == flags;
	}

	private void CollisionResponse()
	{
		AABB@ collisionBox = getCollisionBox();
		if (collisionBox !is null)
		{
			bool collideBlocks = hasCollisionFlags(CollisionFlag::Blocks);
			bool collideMapEdge = hasCollisionFlags(CollisionFlag::MapEdge);
			Vec3f mapDim = getMap3D().getMapDimensions();

			//x collision
			if (velocity.x != 0)
			{
				collisionX = true;
				Vec3f xPosition(position.x + velocity.x, position.y, position.z);

				if (collideBlocks && collisionBox.intersectsNewSolid(position, xPosition))
				{
					if (velocity.x > 0)
					{
						position.x = Maths::Ceil(position.x + collisionBox.max.x) - collisionBox.max.x;
					}
					else if (velocity.x < 0)
					{
						position.x = Maths::Floor(position.x + collisionBox.min.x) - collisionBox.min.x;
					}
				}
				else if (collideMapEdge && collisionBox.intersectsMapEdge(xPosition))
				{
					if (velocity.x > 0)
					{
						position.x = mapDim.x - collisionBox.max.x;
					}
					else if (velocity.x < 0)
					{
						position.x = -collisionBox.min.x;
					}
				}
				else
				{
					collisionX = false;
					position.x += velocity.x;
				}

				if (position.x == oldPosition.x)
				{
					velocity.x = 0;
				}
			}

			//z collision
			collisionZ = true;
			if (velocity.z != 0)
			{
				Vec3f zPosition(position.x, position.y, position.z + velocity.z);

				if (collideBlocks && collisionBox.intersectsNewSolid(position, zPosition))
				{
					if (velocity.z > 0)
					{
						position.z = Maths::Ceil(position.z + collisionBox.max.z) - collisionBox.max.z;
					}
					else if (velocity.z < 0)
					{
						position.z = Maths::Floor(position.z + collisionBox.min.z) - collisionBox.min.z;
					}
				}
				else if (collideMapEdge && collisionBox.intersectsMapEdge(zPosition))
				{
					if (velocity.z > 0)
					{
						position.z = mapDim.z - collisionBox.max.z;
					}
					else if (velocity.x < 0)
					{
						position.z = -collisionBox.min.z;
					}
				}
				else
				{
					collisionZ = false;
					position.z += velocity.z;
				}

				if (position.z == oldPosition.z)
				{
					velocity.z = 0;
				}
			}

			//y collision
			if (velocity.y != 0)
			{
				collisionY = true;
				Vec3f yPosition(position.x, position.y + velocity.y, position.z);

				if (collideBlocks && collisionBox.intersectsNewSolid(position, yPosition))
				{
					if (velocity.y > 0)
					{
						position.y = Maths::Ceil(position.y + collisionBox.max.y) - collisionBox.max.y;
					}
					else if (velocity.y < 0)
					{
						position.y = Maths::Floor(position.y + collisionBox.min.y) - collisionBox.min.y;
					}
				}
				else
				{
					collisionY = false;
					position.y += velocity.y;
				}

				if (position.y == oldPosition.y)
				{
					velocity.y = 0;
				}
			}
		}
		else
		{
			position += velocity;
		}
	}
}
