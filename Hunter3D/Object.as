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

	void PreUpdate()
	{

	}

	void Update()
	{

	}

	void PostUpdate()
	{
		oldPosition = position;
		oldRotation = rotation;
		oldVelocity = velocity;
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
