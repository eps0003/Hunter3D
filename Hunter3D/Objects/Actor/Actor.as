#include "PhysicsObject.as"
#include "Mouse.as"
#include "ActorManager.as"
#include "ActorModel.as"
#include "IHasModel.as"

class Actor : PhysicsObject, IHasModel
{
	CPlayer@ player;

	private IModel@ model;

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

		// @hitbox = AABB(Vec3f(0.6f, 1.6f, 0.6f));0.7; 1.7; 0.7;
		@hitbox = AABB(Vec3f(-0.35f, -1.7 * 7/8, -0.3f), Vec3f(0.35f, 1.7 * 1/8, 0.35f));

		SetModel(ActorModel());
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

		if (hasModel() && !player.isMyPlayer())
		{
			model.Render(this);
		}
	}

	void Interpolate()
	{
		PhysicsObject::Interpolate();
	}

	void Serialize(CBitStream@ bs)
	{
		PhysicsObject::Serialize(bs);
		bs.write_u16(player.getNetworkID());
	}

	bool hasModel()
	{
		return model !is null;
	}

	void SetModel(IModel@ model)
	{
		@this.model = model;
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
