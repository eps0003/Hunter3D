#include "Utilities.as"
#include "ModLoader.as"
#include "Ease.as"

#define CLIENT_ONLY

const float FADE_DURATION = 60.0f;

float loadOpacity;
uint loadTime;
float oldProgress;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	loadOpacity = 255;
	loadTime = 0;
}

void onTick(CRules@ this)
{
	ModLoader@ modLoader = getModLoader();
	oldProgress = modLoader.getProgress();
	modLoader.LoadMod();
}

void onRender(CRules@ this)
{
	if (loadOpacity > 0)
	{
		//background colour
		Vec2f screenDim = getDriver().getScreenDimensions();
		SColor color(loadOpacity, 165, 189, 200);
		GUI::DrawRectangle(Vec2f_zero, screenDim, color);

		ModLoader@ modLoader = getModLoader();
		if (!modLoader.isLoaded())
		{
			//loading bar
			float progress = modLoader.getProgress();
			string status = modLoader.getStatusMessage();
			float interProgress = Maths::Lerp(oldProgress, progress, getInterFrameTime());
			DrawLoadingBar(status, interProgress);
		}
		else
		{
			//fade out
			if (loadTime == 0)
			{
				loadTime = getGameTime();
			}

			float t = Maths::Clamp01((getInterGameTime() - loadTime) / FADE_DURATION);
			loadOpacity = Maths::Lerp(255, 0, Ease().easeOut(t, EaseType::quad));
		}
	}
}

void DrawLoadingBar(string text, float percent)
{
	Driver@ driver = getDriver();

	Vec2f dim = driver.getScreenDimensions();
	Vec2f center = driver.getScreenCenterPos();

	uint halfWidth = (dim.x * 0.8f) / 2.0f;

	Vec2f textDim;
	GUI::GetTextDimensions(text, textDim);

	Vec2f tl(center.x - halfWidth, center.y - textDim.y);
	Vec2f br(center.x + halfWidth, center.y + textDim.y);

	GUI::DrawProgressBar(tl, br, percent);
	GUI::DrawTextCentered(text, center, color_white);
}
