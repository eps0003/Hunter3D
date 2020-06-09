#include "SmoothFly.as"
#include "Walking.as"
#include "Mouse.as"

shared class MovementStrategy
{
	void Move(Actor@ actor)
	{

	}

	void Rotate(Actor@ actor)
	{
		Vec2f dir = getMouse3D().velocity;
		actor.rotation.x += dir.y;
		actor.rotation.y += dir.x;

		actor.rotation.x = Maths::Clamp(actor.rotation.x, -90, 90);
		actor.rotation.z = Maths::Clamp(actor.rotation.z, -90, 90);
		actor.rotation.y %= 360;
	}
}
