#include "Vec3f.as"
#include "Map.as"
#include "Mouse.as"
#include "Camera.as"
#include "Actor.as"
#include "TestMapGenerator.as"
#include "ObjectManager.as"
#include "ModLoader.as"

#define CLIENT_ONLY

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);

	onRestart(this);
}

void onRestart(CRules@ this)
{
	Texture::createFromFile("pixel", "Pixel.png");
}

void onTick(CRules@ this)
{
	this.set_f32("inter_frame_time", 0);
	this.set_f32("inter_game_time", getGameTime());

	getMouse3D().Update();

	if (!getModLoader().isLoaded()) return;

	if (getCamera3D().hasParent())
	{
		Actor@ myActor = getActorManager().getActor(getLocalPlayer());
		if (myActor !is null)
		{
			getMap3D().Update();

			myActor.PreUpdate();
			myActor.Update();
			myActor.PostUpdate();

			if (getControls().isKeyJustPressed(KEY_KEY_L))
			{
				CBitStream bs;
				myActor.Serialize(bs);
				this.SendCommand(this.getCommandID("c_remove_actor"), bs, false);
			}
		}
	}
}

void onRender(CRules@ this)
{
	float correction = getRenderApproximateCorrectionFactor();
	this.add_f32("inter_frame_time", correction);
	this.add_f32("inter_game_time", correction);

	getMouse3D().Render();

	if (!getModLoader().isLoaded()) return;

	Camera@ camera = getCamera3D();
	ActorManager@ actorManager = getActorManager();

	if (camera.hasParent())
	{
		actorManager.RenderHUD();
	}

	Actor@ myActor = actorManager.getActor(getLocalPlayer());
	if (myActor !is null)
	{
		// GUI::DrawText("position: " + myActor.position.toString(), Vec2f(10, 40), color_black);
		// GUI::DrawText("rotation: " + myActor.rotation.toString(), Vec2f(10, 60), color_black);
		// GUI::DrawText("velocity: " + myActor.velocity.toString(), Vec2f(10, 80), color_black);
		// GUI::DrawText("vellen: " + Vec2f(myActor.interVelocity.x, myActor.interVelocity.z).Length(), Vec2f(10, 100), color_black);

		// GUI::DrawText("interPosition: " + myActor.interPosition.toString(), Vec2f(10, 130), color_black);
		// GUI::DrawText("interRotation: " + myActor.interRotation.toString(), Vec2f(10, 150), color_black);
		// GUI::DrawText("interVelocity: " + myActor.interVelocity.toString(), Vec2f(10, 170), color_black);

		// GUI::DrawText("mouseVelocity: " + getMouse3D().velocity.toString(), Vec2f(10, 200), color_black);
	}
}

void Render(int id)
{
	if (!getModLoader().isLoaded()) return;

	//background colour
	SColor skyColor = getSkyColor();
	Vec2f screenDim = getDriver().getScreenDimensions();
	GUI::DrawRectangle(Vec2f_zero, screenDim, skyColor);
	Render::SetFog(skyColor, SMesh::LINEAR, 100, 120, 0, false, false);

	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	Camera@ camera = getCamera3D();
	if (camera.hasParent())
	{
		ObjectManager@ objectManager = getObjectManager();

		objectManager.Interpolate();

		camera.Render();
		getMap3D().Render();
		objectManager.Render();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("s_map_data"))
	{
		print("Received map");

		Map map(params);
		Vec3f mapCenter = map.getMapDimensions() / 2;

		this.set("map", map);
	}
	else if (cmd == this.getCommandID("s_sync_voxel"))
	{
		u16 playerID = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(playerID);
		Vec3f worldPos(params);
		Voxel voxel(params);

		if (player.isMyPlayer())
		{
			if (voxel.handPlaced)
			{
				if (voxel.isVisible())
				{
					//voxel successfully destroyed. poof particles
				}
				else
				{
					//voxel successfully placed. poof particles
				}
			}
		}
		else
		{
			Map@ map = getMap3D();
			map.SetVoxel(worldPos, voxel);

			print("Received voxel from server at " + worldPos.toString());

			Vec3f chunkPos = map.getChunkPos(worldPos);
			Chunk@ chunk = map.getChunk(chunkPos);
			chunk.GenerateMesh(chunkPos);

			//poof particles
		}
	}
	else if (cmd == this.getCommandID("s_sync_objects"))
	{
		getActorManager().DeserializeActors(params);
		getFlagManager().DeserializeFlags(params);
	}
	else if (cmd == this.getCommandID("s_remove_actor"))
	{
		Actor actor(params);
		getActorManager().RemoveActor(actor);
	}
}
