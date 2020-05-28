#include "Identifiable.as"

class Object : Identifiable
{
	Vec3f position;
	Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f rotation;
	Vec3f oldRotation;
	Vec3f interRotation;

	Vec3f velocity;
	Vec3f oldVelocity;
	Vec3f interVelocity;

	dictionary vars;

	Object(Vec3f position, Vec3f rotation = Vec3f(0, 0, 0), Vec3f velocity = Vec3f(0, 0, 0))
	{
		this.position = position;
		this.rotation = rotation;
		this.velocity = velocity;
	}

	Object(CBitStream@ bs)
	{
		super(bs);

		position = Vec3f(bs);
		oldPosition = Vec3f(bs);

		rotation = Vec3f(bs);
		oldRotation = Vec3f(bs);

		velocity = Vec3f(bs);
		oldVelocity = Vec3f(bs);
	}

	void PreUpdate()
	{
		oldPosition = position;
		oldRotation = rotation;
		oldVelocity = velocity;
	}

	void Update()
	{

	}

	void PostUpdate()
	{

	}

	void Render()
	{

	}

	void Interpolate()
	{
		interPosition = oldPosition.lerp(oldPosition + velocity, getInterFrameTime());
		interPosition = interPosition.clamp(oldPosition, position);

		interVelocity = oldVelocity.lerp(velocity, getInterFrameTime());

		interRotation = oldRotation.lerpAngle(rotation, getInterFrameTime());
	}

	void Serialize(CBitStream@ bs)
	{
		Identifiable::Serialize(bs);

		position.Serialize(bs);
		oldPosition.Serialize(bs);

		rotation.Serialize(bs);
		oldRotation.Serialize(bs);

		velocity.Serialize(bs);
		oldVelocity.Serialize(bs);
	}
}
