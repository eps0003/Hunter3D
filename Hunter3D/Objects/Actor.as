class Actor : PhysicsObject
{
	CPlayer@ player;

	Actor(CPlayer@ player, Vec3f position)
	{
		super(position);
		LoadConfig();

		@this.player = player;
		// @hitbox = AABB(this, Vec3f(0.6f, 1.6f, 0.6f));
		@hitbox = AABB(this, Vec3f(-0.3f, -1.4f, -0.3f), Vec3f(0.3f, 0.2f, 0.3f));
	}

	void Update()
	{
		PhysicsObject::Update();

		Move();
		Rotate();
		PlaceVoxel();
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

		if (controls.isKeyJustPressed(KEY_SPACE))
		{
			velocity.y = 0.3f;
		}

		velocity.x = dir.x / 4.0f;
		velocity.z = dir.y / 4.0f;
	}

	private void Rotate()
	{
		Vec2f dir = mouse.velocity;
		rotation.x += dir.y;
		rotation.y += dir.x;

		rotation.x = Maths::Clamp(rotation.x, -90, 90);
		rotation.z = Maths::Clamp(rotation.z, -90, 90);
		rotation.y %= 360;
	}

	private void PlaceVoxel()
	{
		CControls@ controls = player.getControls();
		if (controls.isKeyJustPressed(KEY_LBUTTON) && mouse.isInControl())
		{
			Vec3f worldPos = position + Vec3f(0, -1, 2);
			Voxel voxel(1, true);
			if (map.SetVoxel(worldPos, voxel))
			{
				Vec3f chunkPos = map.getChunkPos(worldPos);
				Chunk@ chunk = map.getChunk(chunkPos);
				chunk.GenerateMesh(chunkPos);

				voxel.client_Sync(worldPos);
			}

		}
	}

	private void LoadConfig()
	{
		string name = getCurrentScriptName();
		print(name);
	}
}
