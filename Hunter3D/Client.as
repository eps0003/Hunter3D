#include "Vec3f.as"
#include "Map.as"
#include "Mouse.as"
#include "Camera.as"
#include "Actor.as"
#include "TestMapGenerator.as"
#include "ActorManager.as"

#define CLIENT_ONLY

float interFrameTime;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);

	onRestart(this);
}

void onRestart(CRules@ this)
{
	Texture::createFromFile("pixel", "pixel.png");
}

void onTick(CRules@ this)
{
	interFrameTime = 0;

	getMouse3D().Update();

	if (getCamera3D().hasParent())
	{
		Actor@ myActor = getActorManager().getActor(getLocalPlayer());
		if (myActor !is null)
		{
			myActor.PreUpdate();
			myActor.Update();
			myActor.PostUpdate();
		}
	}
}

void onRender(CRules@ this)
{
	interFrameTime += getRenderApproximateCorrectionFactor();

	Actor@ myActor = getActorManager().getActor(getLocalPlayer());
	if (myActor !is null)
	{
		GUI::DrawText("position: " + myActor.position.toString(), Vec2f(10, 50), color_black);
		GUI::DrawText("rotation: " + myActor.rotation.toString(), Vec2f(10, 70), color_black);
		GUI::DrawText("velocity: " + myActor.velocity.toString(), Vec2f(10, 90), color_black);

		GUI::DrawText("interPosition: " + myActor.interPosition.toString(), Vec2f(10, 120), color_black);
		GUI::DrawText("interRotation: " + myActor.interRotation.toString(), Vec2f(10, 140), color_black);
		GUI::DrawText("interVelocity: " + myActor.interVelocity.toString(), Vec2f(10, 160), color_black);

		GUI::DrawText("mouseVelocity: " + getMouse3D().velocity.toString(), Vec2f(10, 190), color_black);
	}
}

void Render(int id)
{
	//background colour
	Vec2f screenDim = getDriver().getScreenDimensions();
	GUI::DrawRectangle(Vec2f_zero, screenDim, SColor(255, 165, 189, 200));

	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	getMouse3D().Render();

	Camera@ camera = getCamera3D();
	if (camera.hasParent())
	{
		getActorManager().Interpolate();

		camera.Render();
		getMap3D().Render();
		getActorManager().Render();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server map data"))
	{
		print("Received map");

		CPlayer@ me = getLocalPlayer();

		Map map(params);
		Vec3f mapCenter = map.getMapDimensions() / 2;

		this.set("map", map);

		map.GenerateMesh();
	}
	else if (cmd == this.getCommandID("server sync voxel"))
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
	else if (cmd == this.getCommandID("server sync actors"))
	{
		ActorManager@ actorManager = getActorManager();

		int count = params.read_u32();

		for (uint i = 0; i < count; i++)
		{
			Actor actor(params);
			if (!actor.player.isMyPlayer() || !actorManager.hasActor(actor.player))
			{
				actorManager.UpdateActor(actor);

				if (actor.player.isMyPlayer())
				{
					getCamera3D().SetParent(actorManager.getActor(actor.player));
					print("Spawned client at " + actor.position.toString());
				}
			}
		}
	}
}
