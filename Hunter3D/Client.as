#include "Utilities.as"
#include "Object.as"
#include "Vec3f.as"
#include "Mouse.as"
#include "Map.as"
#include "Camera.as"
#include "TestMapGenerator.as"

#define CLIENT_ONLY

float interFrameTime;
bool ready;

Mouse@ mouse;
Map@ map;
Actor@ actor;
Camera@ camera;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);

	onRestart(this);
}

void onRestart(CRules@ this)
{
	Texture::createFromFile("pixel", "pixel.png");

	ready = false;
}

void onTick(CRules@ this)
{
	interFrameTime = 0;

	if (ready)
	{
		mouse.Update();
		actor.PreUpdate();
		actor.Update();
		actor.PostUpdate();
	}
}

void onRender(CRules@ this)
{
	interFrameTime += getRenderApproximateCorrectionFactor();

	if (actor !is null)
	{
		GUI::DrawText(actor.position.toString(), Vec2f(10, 50), color_black);
		GUI::DrawText(actor.rotation.toString(), Vec2f(10, 70), color_black);
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

	if (ready)
	{
		mouse.Render();
		camera.Render();
		map.Render();
		actor.Render();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server map data"))
	{
		print("Received map");

		@map = Map(params);
		map.GenerateMesh();

		@mouse = Mouse();

		Vec3f mapDim = map.getMapDimensions();
		@actor = Actor(getLocalPlayer(), mapDim / 2);

		@camera = Camera(actor);

		ready = true;
	}
}
