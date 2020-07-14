#include "PhysicsObject.as"
#include "Mouse.as"
#include "ObjectManager.as"
#include "ActorModel.as"
#include "MovementStrategy.as"

shared class Actor : PhysicsObject, IRenderable, IHasTeam, IHasConfig
{
	CPlayer@ player;
	private Model@ model;
	private MovementStrategy@ movementStrategy = SmoothFly();

	float acceleration;
	float jumpForce;

	Actor(CPlayer@ player, Vec3f position)
	{
		super(position);
		name = "Actor";

		@this.player = player;
	}

	Actor(CBitStream@ bs)
	{
		super(bs);
		name = "Actor";
		LoadConfig(openConfig("Actor.cfg"));

		u16 playerID = bs.read_u16();
		@player = getPlayerByNetworkId(playerID);

		SetCollisionBox(AABB(Vec3f(0.6f, 1.6f, 0.6f)));
		SetCollisionFlags(CollisionFlag::Blocks);

		cameraHeight = 1.5f;
		@model = ActorModel("KnightSkin.png");
	}

	void opAssign(Actor actor)
	{
		opAssign(cast<PhysicsObject>(actor));
	}

	bool opEquals(Actor@ actor)
	{
		return opEquals(cast<PhysicsObject>(actor)) && player is actor.player;
	}

	void Update()
	{
		PhysicsObject::Update();

		if (hasMovementStrategy())
		{
			movementStrategy.Move(this);
			movementStrategy.Rotate(this);
		}

		PlaceBlock();
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

	bool isVisible()
	{
		Camera@ camera = getCamera3D();

		bool hasModel = model !is null;
		bool cameraParentNotMe = camera.hasParent() && camera.getParent() != cast<Object>(this);

		return hasModel && cameraParentNotMe;
	}

	void Render()
	{
		AABB@ collisionBox = getCollisionBox();
		if (collisionBox !is null)
		{
			collisionBox.Render(interPosition);
		}

		model.Render(this);
	}

	u8 getTeamNum()
	{
		return player.getTeamNum();
	}

	void SetTeamNum(u8 team)
	{
		player.server_setTeamNum(team);
	}

	void RenderHUD()
	{

	}

	void RenderNameplate()
	{
		Camera@ camera = getCamera3D();
		bool cameraNotAttached = camera.hasParent() && camera.getParent() != cast<Object>(this);

		if (isNameplateVisible() && cameraNotAttached && interPosition.isInFrontOfCamera())
		{
			Vec3f pos = interPosition + Vec3f(0, 2, 0);
			Vec2f screenPos = pos.projectToScreen();
			uint distance = (camera.getPosition() - pos).mag();

			GUI::DrawTextCentered(player.getCharacterName(), screenPos - Vec2f(0, 8), color_white);
			GUI::DrawTextCentered(distance + " " + String::plural(distance, "block"), screenPos + Vec2f(0, 8), color_white);
		}
	}

	void Interpolate()
	{
		PhysicsObject::Interpolate();

		float t = getInterFrameTime();

		interRotation = oldRotation.lerpAngle(rotation, t);
	}

	void Serialize(CBitStream@ bs)
	{
		PhysicsObject::Serialize(bs);
		bs.write_u16(player.getNetworkID());
	}

	bool hasMovementStrategy()
	{
		return movementStrategy !is null;
	}

	void SetMovementStrategy(MovementStrategy@ strategy)
	{
		@movementStrategy = strategy;
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		PhysicsObject::LoadConfig(cfg);

		acceleration = cfg.read_f32("acceleration");
		jumpForce = cfg.read_f32("jump_force");
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

	private void PlaceBlock()
	{
		CControls@ controls = player.getControls();
		Mouse@ mouse = getMouse3D();
		if (controls.isKeyJustPressed(KEY_LBUTTON) && mouse.isInControl())
		{
			Map@ map = getMap3D();
			u8 block = BlockType::OakWood;
			Vec3f worldPos = (position + Vec3f(0, cameraHeight, 0) + rotation.dir() * 2).floor();

			if (map.isValidBlock(worldPos) && map.getBlock(worldPos) != block)
			{
				map.SetBlock(worldPos, block);
				print("Placed block at " + worldPos.toString());

				Vec3f chunkPos = map.getChunkPos(worldPos);
				Chunk@ chunk = map.getChunk(chunkPos);
				chunk.SetRebuild();
			}
		}
	}

	private bool isNameplateVisible()
	{
		return getTeamNum() == getLocalPlayer().getTeamNum();
	}
}
