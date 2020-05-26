class Actor : Object
{
	CPlayer@ player;

	Actor(CPlayer@ player)
	{
		super();
		@this.player = player;
	}

	void Update()
	{
		Object::Update();
		Move();
		Rotate();
	}

	private void Move()
	{
		CControls@ controls = getControls();

		Vec2f dir(
			num(controls.isKeyPressed(KEY_KEY_D)) - num(controls.isKeyPressed(KEY_KEY_A)),
			num(controls.isKeyPressed(KEY_KEY_W)) - num(controls.isKeyPressed(KEY_KEY_S))
		);

		float len = dir.Length();

		if (len > 0)
		{
			dir /= len; //normalize
			dir = dir.RotateBy(rotation.y);
		}

		position.x += dir.x / 10.0f;
		position.z += dir.y / 10.0f;
		position.y += (num(controls.isKeyPressed(KEY_SPACE)) - num(controls.isKeyPressed(KEY_LSHIFT))) / 10.0f;
	}

	private void Rotate()
	{
		Vec2f dir = mouse.velocity;
		rotation.x += dir.y;
		rotation.y += dir.x;
	}
}
