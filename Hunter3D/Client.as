#include "Utilities.as"
#include "Object.as"
#include "Vec3f.as"
#include "Mouse.as"
#include "Camera.as"
#include "Actor.as"
#include "Cube.as"

#define CLIENT_ONLY

float interFrameTime;

Mouse@ mouse;
Actor@ actor;
Camera@ camera;
Cube@ cube;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@mouse = Mouse();
	@actor = Actor(getLocalPlayer());
	@camera = Camera(actor);
	@cube = Cube(Vec3f(0, 0, 2), Vec3f(1, 1, 1), color_black);
}

void onTick(CRules@ this)
{
	interFrameTime = 0;

	mouse.Update();
	actor.PreUpdate();
	actor.Update();
	actor.PostUpdate();
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

	camera.Render();
	actor.Render();
	cube.Render();
}
