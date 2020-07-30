shared class Walking : MovementStrategy
{
	void Move(Actor@ actor)
	{
		CControls@ controls = actor.getPlayer().getControls();

		Vec2f dir(
			num(controls.isKeyPressed(KEY_KEY_D)) - num(controls.isKeyPressed(KEY_KEY_A)),
			num(controls.isKeyPressed(KEY_KEY_W)) - num(controls.isKeyPressed(KEY_KEY_S))
		);

		float len = dir.Length();

		if (len > 0)
		{
			dir /= len; //normalize
			dir = dir.RotateBy(actor.rotation.y);
		}

		if (controls.isKeyPressed(KEY_SPACE) && actor.getCollisionBox().intersectsNewSolid(actor.position, actor.position + Vec3f(0, -0.001f, 0)))
		{
			actor.velocity.y = actor.jumpForce;
		}

		actor.velocity.x += dir.x * actor.acceleration - actor.friction * actor.velocity.x;
		actor.velocity.z += dir.y * actor.acceleration - actor.friction * actor.velocity.z;
	}
}
