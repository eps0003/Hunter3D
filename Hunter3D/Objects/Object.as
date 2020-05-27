#include "Identifiable.as"
#include "PhysicsObject.as"

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

	Object(Vec3f position, Vec3f rotation = Vec3f(0, 0, 0), Vec3f velocity = Vec3f(0, 0, 0))
	{
		this.position = position;
		this.rotation = rotation;
		this.velocity = velocity;
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
		Interpolate();
	}

	private void Interpolate()
	{
		interPosition = oldPosition.lerp(oldPosition + velocity, getInterFrameTime());
		interPosition = interPosition.clamp(oldPosition, position);

		interVelocity = oldVelocity.lerp(velocity, getInterFrameTime());

		interRotation = oldRotation.lerpAngle(rotation, getInterFrameTime());
	}
}
