#include "Vec3f.as"
#include "Map.as"
#include "Mouse.as"
#include "Camera.as"
#include "ObjectManager.as"
#include "ModLoader.as"
#include "Utilities.as"
#include "MapSyncer.as"

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
	getMapSyncer().client_Deserialize();

	if (getModLoader().isLoading()) return;

	if (getCamera3D().hasParent())
	{
		Actor@ myActor = getActorManager().getActor(getLocalPlayer());
		if (myActor !is null)
		{
			myActor.PreUpdate();
			myActor.Update();
			myActor.PostUpdate();

			getMap3D().Update();

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

	if (getModLoader().isLoading()) return;

	Camera@ camera = getCamera3D();
	ActorManager@ actorManager = getActorManager();

	if (camera.hasParent())
	{
		DrawCrosshair(0, 8, 1, color_white);
		actorManager.RenderHUD();
	}

	Actor@ myActor = actorManager.getActor(getLocalPlayer());
	if (myActor !is null)
	{
		GUI::DrawText("position: " + myActor.position.toString(), Vec2f(10, 40), color_black);
		GUI::DrawText("rotation: " + myActor.rotation.toString(), Vec2f(10, 60), color_black);
		GUI::DrawText("velocity: " + myActor.velocity.toString(), Vec2f(10, 80), color_black);
		GUI::DrawText("vellen: " + Vec2f(myActor.interVelocity.x, myActor.interVelocity.z).Length(), Vec2f(10, 100), color_black);

		GUI::DrawText("interPosition: " + myActor.interPosition.toString(), Vec2f(10, 130), color_black);
		GUI::DrawText("interRotation: " + myActor.interRotation.toString(), Vec2f(10, 150), color_black);
		GUI::DrawText("interVelocity: " + myActor.interVelocity.toString(), Vec2f(10, 170), color_black);

		GUI::DrawText("mouseVelocity: " + getMouse3D().velocity.toString(), Vec2f(10, 200), color_black);
	}
}

void Render(int id)
{
	if (getModLoader().isLoading()) return;

	//background colour
	Vec2f screenDim = getDriver().getScreenDimensions();
	GUI::DrawRectangle(Vec2f_zero, screenDim, getSkyColor());

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
		CBitStream bs = params;
		bs.SetBitIndex(params.getBitIndex());
		getMapSyncer().AddMapPacket(bs);
	}
	else if (cmd == this.getCommandID("s_sync_block"))
	{
		uint index = params.read_u32();
		u8 block = params.read_u8();

		Map@ map = getMap3D();

		if (map is null || !map.isLoaded())
		{
			getModLoader().AddBlockToPlace(index, block);
		}
		else if (block != map.getBlock(index))
		{
			map.SetBlock(index, block);
			map.RebuildChunks(index);
		}
	}
	else if (cmd == this.getCommandID("s_revert_block"))
	{
		uint index = params.read_u32();
		u8 block = params.read_u8();

		Map@ map = getMap3D();

		map.SetBlock(index, block);
		map.RebuildChunks(index);
	}

	if (getModLoader().isLoading()) return;

	if (cmd == this.getCommandID("s_sync_objects"))
	{
		getActorManager().DeserializeActors(params);
		getFlagManager().DeserializeFlags(params);
		getObjectManager().DeserializeRemovedObjects(params);
	}
}
