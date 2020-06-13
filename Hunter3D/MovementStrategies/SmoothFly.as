shared class SmoothFly : MovementStrategy
{
	void Move(Actor@ actor)
	{
		CControls@ controls = actor.player.getControls();

		Vec2f dir(
			num(controls.isKeyPressed(KEY_KEY_D)) - num(controls.isKeyPressed(KEY_KEY_A)),
			num(controls.isKeyPressed(KEY_KEY_W)) - num(controls.isKeyPressed(KEY_KEY_S))
		);
		float verticalDir = num(controls.isKeyPressed(KEY_SPACE)) - num(controls.isKeyPressed(KEY_LSHIFT));

		float len = dir.Length();

		if (len > 0)
		{
			dir /= len; //normalize
			dir = dir.RotateBy(actor.rotation.y);
		}

		actor.velocity.x += dir.x * actor.acceleration - actor.friction * actor.velocity.x;
		actor.velocity.z += dir.y * actor.acceleration - actor.friction * actor.velocity.z;
		actor.velocity.y += verticalDir * actor.acceleration - actor.friction * actor.velocity.y;
	}
}
