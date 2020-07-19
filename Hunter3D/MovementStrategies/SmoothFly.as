shared class SmoothFly : MovementStrategy
{
	void Move(Actor@ actor)
	{
		CBlob@ blob = actor.player.getBlob();
		CControls@ controls = actor.player.getControls();

		Vec2f dir(
			num(blob.isKeyPressed(key_right)) - num(blob.isKeyPressed(key_left)),
			num(blob.isKeyPressed(key_up)) - num(blob.isKeyPressed(key_down))
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
