#include "PhysicsObject.as"
#include "Mouse.as"
#include "ObjectManager.as"
#include "ActorModel.as"
#include "MovementStrategy.as"
#include "Ray.as"

shared class Actor : PhysicsObject, IRenderable, IHasTeam, IHasConfig
{
	CPlayer@ player;
	private Model@ model;
	private MovementStrategy@ movementStrategy = Walking();

	float acceleration;
	float jumpForce;

	u8 blockType = BlockType::OakWood;

	Actor(CPlayer@ player, Vec3f position)
	{
		super(position);
		@this.player = player;

		Initialize();
	}

	Actor(CBitStream@ bs)
	{
		super(bs);

		u16 playerID = bs.read_u16();
		@player = getPlayerByNetworkId(playerID);

		cameraHeight = 1.5f;
		@model = ActorModel("KnightSkin.png");

		Initialize();
	}

	private void Initialize()
	{
		LoadConfig(openConfig("Actor.cfg"));

		SetCollisionBox(AABB(Vec3f(0.6f, 1.6f, 0.6f)));
		SetCollisionFlags(CollisionFlag::All);
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
		RemoveBlock();
		PickBlock();
	}

	void PostUpdate()
	{
		PhysicsObject::PostUpdate();

		//sync to server
		if (Network::isMultiplayer() && shouldSync())
		{
			CBitStream bs;
			Serialize(bs);
			CRules@ rules = getRules();
			rules.SendCommand(rules.getCommandID("c_sync_actor"), bs, false);

			Synced();
		}
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
		CBlob@ blob = player.getBlob();
		Mouse@ mouse = getMouse3D();
		if (blob.isKeyJustPressed(key_action1) && mouse.isInControl())
		{
			Ray ray(getCamera3D().getPosition(), rotation.dir());
			RaycastInfo raycastInfo;
			if (ray.raycastBlock(5, false, raycastInfo))
			{
				Map@ map = getMap3D();
				u8 block = blockType;
				Vec3f worldPos = raycastInfo.hitWorldPos + raycastInfo.normal;

				AABB actorBounds = getCollisionBox();
				AABB blockBounds(worldPos, worldPos + 1);

				bool canSetBlock = true;

				if (map.isBlockSolid(block))
				{
					//check if object intersects block
					Object@[] objects = getObjectManager().getObjects();
					for (uint i = 0; i < objects.length; i++)
					{
						PhysicsObject@ object = cast<PhysicsObject>(objects[i]);
						if (object !is null)
						{
							AABB@ bounds = object.getCollisionBox();
							AABB blockBounds(worldPos, worldPos + 1);
							if (bounds !is null && bounds.intersects(object.position, blockBounds))
							{
								canSetBlock = false;
								break;
							}
						}
					}
				}

				if (map.isValidBlock(worldPos) && map.getBlock(worldPos) != block && canSetBlock)
				{
					map.SetBlock(worldPos, block);
					map.RebuildChunks(worldPos);
					print("Placed block at " + worldPos.toString());

					CBitStream params;
					params.write_u16(player.getNetworkID());
					params.write_u32(map.toIndex(worldPos));
					params.write_u8(block);

					CRules@ rules = getRules();
					rules.SendCommand(rules.getCommandID("c_sync_block"), params, false);
				}
			}
		}
	}

	private void RemoveBlock()
	{
		CBlob@ blob = player.getBlob();
		Mouse@ mouse = getMouse3D();
		if (blob.isKeyJustPressed(key_action2) && mouse.isInControl())
		{
			Ray ray(getCamera3D().getPosition(), rotation.dir());
			RaycastInfo raycastInfo;
			if (ray.raycastBlock(5, false, raycastInfo))
			{
				Map@ map = getMap3D();
				Vec3f worldPos = raycastInfo.hitWorldPos;
				u8 block = BlockType::Air;
				u8 existingBlock = map.getBlock(worldPos);

				AABB actorBounds = getCollisionBox();
				AABB blockBounds(worldPos, worldPos + 1);

				if (map.isValidBlock(worldPos) && map.isBlockDestructable(existingBlock) && existingBlock != block)
				{
					map.SetBlock(worldPos, block);
					map.RebuildChunks(worldPos);
					print("Removed block at " + worldPos.toString());

					CBitStream params;
					params.write_u16(player.getNetworkID());
					params.write_u32(map.toIndex(worldPos));
					params.write_u8(block);

					CRules@ rules = getRules();
					rules.SendCommand(rules.getCommandID("c_sync_block"), params, false);
				}
			}
		}
	}

	private void PickBlock()
	{
		CControls@ controls = player.getControls();
		Mouse@ mouse = getMouse3D();
		if (controls.isKeyJustPressed(KEY_MBUTTON) && mouse.isInControl())
		{
			Ray ray(getCamera3D().getPosition(), rotation.dir());
			RaycastInfo raycastInfo;
			if (ray.raycastBlock(5, false, raycastInfo))
			{
				Map@ map = getMap3D();
				Vec3f worldPos = raycastInfo.hitWorldPos;
				blockType = map.getBlock(worldPos);
			}
		}

		if (controls.isKeyPressed(MOUSE_SCROLL_UP))
		{
			blockType--;
			if (blockType <= 0)
			{
				blockType += BlockType::Total - 2;
			}
		}

		if (controls.isKeyPressed(MOUSE_SCROLL_DOWN))
		{
			blockType++;
			if (blockType >= BlockType::Total - 2)
			{
				blockType = 1;
			}
		}
	}

	private bool isNameplateVisible()
	{
		return getTeamNum() == getLocalPlayer().getTeamNum();
	}
}
