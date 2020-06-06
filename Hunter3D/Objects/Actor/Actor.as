#include "PhysicsObject.as"
#include "Mouse.as"
#include "ActorManager.as"
#include "ActorModel.as"
#include "IHasModel.as"

class Actor : PhysicsObject, IHasModel
{
	CPlayer@ player;

	private Model@ model;

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

		SetModel(ActorModel("KnightSkin.png"));
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

		//sync to server
		CBitStream bs;
		Serialize(bs);
		CRules@ rules = getRules();
		rules.SendCommand(rules.getCommandID("c_sync_actor"), bs, false);
	}

	void Render()
	{
		PhysicsObject::Render();

		if (!player.isMyPlayer())
		{
			hitbox.Render(interPosition);

			if (hasModel())
			{
				model.Render(this);
			}
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

	void SetModel(Model@ model)
	{
		@this.model = model;
	}

	Model@ getModel()
	{
		return model;
	}

	bool isSameAs(Actor@ actor)
	{
		return PhysicsObject::isSameAs(actor) && player is actor.player;
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
			float jumpForce;
			vars.get("jump_force", jumpForce);

			velocity.y = jumpForce;
		}

		float acceleration;
		vars.get("acceleration", acceleration);

		float friction;
		vars.get("friction", friction);

		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;

		//set velocity to zero if low enough
		if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
		if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
		if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;
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
		vars.set("acceleration", cfg.read_f32("acceleration"));
		vars.set("friction", cfg.read_f32("friction"));
		vars.set("jump_force", cfg.read_f32("jump_force"));
	}
}
