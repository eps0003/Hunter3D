#include "PhysicsObject.as"
#include "Mouse.as"
#include "ActorManager.as"
#include "ActorModel.as"
#include "IHasModel.as"
#include "MovementStrategy.as"

shared class Actor : PhysicsObject, IHasModel
{
	CPlayer@ player;
	private Model@ model;
	private MovementStrategy@ movementStrategy = SmoothFly();

	float acceleration;
	float jumpForce;

	Actor(CPlayer@ player, Vec3f position)
	{
		super(position);

		@this.player = player;
	}

	Actor(CBitStream@ bs)
	{
		super(bs);
		LoadConfig(openConfig("Actor.cfg"));

		u16 playerID = bs.read_u16();
		@player = getPlayerByNetworkId(playerID);

		@hitbox = AABB(Vec3f(0.6f, 1.6f, 0.6f));
		cameraHeight = 1.5f;

		SetModel(ActorModel("KnightSkin.png"));
	}

	void Overwrite(Actor actor)
	{
		Overwrite(cast<PhysicsObject>(actor));
	}

	void Update()
	{
		PhysicsObject::Update();

		if (hasMovementStrategy())
		{
			movementStrategy.Move(this);
			movementStrategy.Rotate(this);
		}

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

	void RenderNameplate()
	{
		if (!player.isMyPlayer() && interPosition.isInFrontOfCamera())
		{
			Vec3f pos = interPosition + Vec3f(0, 2, 0);
			Vec2f screenPos = pos.projectToScreen();
			GUI::DrawTextCentered(player.getCharacterName(), screenPos, color_white);
		}
	}

	void Interpolate()
	{
		PhysicsObject::Interpolate();

		interRotation = oldRotation.lerpAngle(rotation, getInterFrameTime());
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

	bool hasMovementStrategy()
	{
		return movementStrategy !is null;
	}

	void SetMovementStrategy(MovementStrategy@ strategy)
	{
		@movementStrategy = strategy;
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
			velocity.y = jumpForce;
		}

		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;
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

	void LoadConfig(ConfigFile@ cfg)
	{
		PhysicsObject::LoadConfig(cfg);

		acceleration = cfg.read_f32("acceleration");
		jumpForce = cfg.read_f32("jump_force");
	}
}
