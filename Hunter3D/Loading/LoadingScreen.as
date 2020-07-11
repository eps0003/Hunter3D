#include "ModLoader.as"

#define CLIENT_ONLY

void onTick(CRules@ this)
{
	getModLoader().Load();
}

void onRender(CRules@ this)
{
	ModLoader@ modLoader = getModLoader();

	if (modLoader.isLoading())
	{
		//background colour
		Vec2f screenDim = getDriver().getScreenDimensions();
		SColor color(255, 165, 189, 200);
		GUI::DrawRectangle(Vec2f_zero, screenDim, color);

		DrawLoadingBar(modLoader.getMessage(), modLoader.getProgress());
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
