#include "PhysicsObject.as"
#include "Mouse.as"
#include "ActorManager.as"

class Actor : PhysicsObject
{
	CPlayer@ player;

	Actor(CPlayer@ player, Vec3f position)
	{
		super(position);
		LoadConfig();

		@this.player = player;
	}

	Actor(CBitStream@ bs)
	{
		super(bs);
		LoadConfig();

		u16 playerID = bs.read_u16();
		@player = getPlayerByNetworkId(playerID);

		// @hitbox = AABB(Vec3f(0.6f, 1.6f, 0.6f));
		@hitbox = AABB(Vec3f(-0.3f, -1.4f, -0.3f), Vec3f(0.3f, 0.2f, 0.3f));
	}

	void Update()
	{
		PhysicsObject::Update();

		Move();
		Rotate();
		PlaceVoxel();
	}

	void PostUpdate()
	{
		PhysicsObject::PostUpdate();

		getActorManager().client_Sync(this);
	}

	void Render()
	{
		PhysicsObject::Render();

		hitbox.Render(interPosition);
	}

	void Serialize(CBitStream@ bs)
	{
		PhysicsObject::Serialize(bs);
		bs.write_u16(player.getNetworkID());
	}

	private void Move()
	{
		CControls@ controls = player.getControls();

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
			float jumpSpd;
			vars.get("jump_speed", jumpSpd);

			velocity.y = jumpSpd;
		}

		float moveSpd;
		vars.get("move_speed", moveSpd);

		velocity.x = dir.x * moveSpd;
		velocity.z = dir.y * moveSpd;
	}

	private void Rotate()
	{
		Vec2f dir = getMouse3D().velocity;
		rotation.x += dir.y;
		rotation.y += dir.x;

		rotation.x = Maths::Clamp(rotation.x, -90, 90);
		rotation.z = Maths::Clamp(rotation.z, -90, 90);
		rotation.y %= 360;
	}

	private void PlaceVoxel()
	{
		CControls@ controls = player.getControls();
		Mouse@ mouse = getMouse3D();
		if (controls.isKeyJustPressed(KEY_LBUTTON) && mouse.isInControl())
		{
			Vec3f worldPos = position + Vec3f(0, -1, 2);
			Voxel voxel(1, true);
			Map@ map = getMap3D();
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
		ConfigFile@ cfg = openConfig("Actor.cfg");
		vars.set("move_speed", cfg.read_f32("move_speed"));
		vars.set("jump_speed", cfg.read_f32("jump_speed"));
	}
}
