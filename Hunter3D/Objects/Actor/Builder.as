shared class Builder : Actor, IRenderable
{
	private Model@ model;
	private u8 blockType = BlockType::OakWood;

	Builder(CPlayer@ player, Vec3f position)
	{
		super(player, position);
	}

	Builder(CBitStream@ bs)
	{
		super(bs);
	}

	void Initialize()
	{
		Actor::Initialize();

		LoadConfig(openConfig("Builder.cfg"));

		cameraHeight = 1.4f;
		@model = ActorModel("KnightSkin.png");

		SetCollisionBox(AABB(Vec3f(0.6f, 1.6f, 0.6f)));
		SetCollisionFlags(CollisionFlag::All);
		SetMovementStrategy(Walking());
	}

	void opAssign(Builder builder)
	{
		opAssign(cast<Actor>(builder));
	}

	bool opEquals(Builder@ builder)
	{
		return opEquals(cast<Actor>(builder));
	}

	void Update()
	{
		Actor::Update();

		PlaceBlock();
		RemoveBlock();
		PickBlock();
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

	void RenderHUD()
	{
		Actor::RenderHUD();

		Map@ map = getMap3D();
		GUI::DrawIcon(map.texture, blockType * 4, Vec2f(16, 16), Vec2f(10, 70), 3);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(ObjectType::Builder);
		Actor::Serialize(bs);
	}

	private void PlaceBlock()
	{
		CBlob@ blob = player.getBlob();
		Mouse@ mouse = getMouse3D();
		if (blob.isKeyJustPressed(key_action1) && mouse.isInControl() && mouse.wasInControl())
		{
			Ray ray(getCamera3D().getPosition(), rotation.dir());
			RaycastInfo raycastInfo;
			if (ray.raycastBlock(5, false, raycastInfo))
			{
				Map@ map = getMap3D();
				u8 block = blockType;
				Vec3f worldPos = raycastInfo.hitWorldPos + raycastInfo.normal;

				AABB actorBounds = getCollisionBox();

				bool canSetBlock = true;

				if (map.isBlockSolid(block))
				{
					//check if object intersects block
					Object@[] objects = getObjectManager().getObjects();
					for (uint i = 0; i < objects.size(); i++)
					{
						PhysicsObject@ object = cast<PhysicsObject>(objects[i]);
						if (object !is null)
						{
							AABB@ bounds = object.getCollisionBox();
							if (bounds !is null && bounds.intersectsVoxel(object.position, worldPos))
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
		if (blob.isKeyJustPressed(key_action2) && mouse.isInControl() && mouse.wasInControl())
		{
			Ray ray(getCamera3D().getPosition(), rotation.dir());
			RaycastInfo raycastInfo;
			if (ray.raycastBlock(5, false, raycastInfo))
			{
				Map@ map = getMap3D();
				Vec3f worldPos = raycastInfo.hitWorldPos;
				u8 block = BlockType::Air;
				u8 existingBlock = map.getBlock(worldPos);

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
		if (controls.isKeyJustPressed(KEY_MBUTTON) && mouse.isInControl() && mouse.wasInControl())
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
}