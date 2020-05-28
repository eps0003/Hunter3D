#include "Camera.as"

Mouse@ getMouse3D()
{
	CRules@ rules = getRules();

	Mouse@ mouse;
	if (rules.get("mouse", @mouse))
	{
		return mouse;
	}

	@mouse = Mouse();
	rules.set("mouse", mouse);
	return mouse;
}

class Mouse
{
	Vec2f velocity;
	float sensitivity;

	private bool wasInControl = false;

	Mouse()
	{
		LoadPreferences();
	}

	void Update()
	{
		CalculateVelocity();
		wasInControl = isInControl();
	}

	void Render()
	{
		Visibility();
	}

	bool isInControl()
	{
		return isWindowFocused() && !isVisible();
	}

	bool isVisible()
	{
		return getCamera3D() is null || Menu::isMenuOpen();
	}

	private void Visibility()
	{
		if (isVisible())
		{
			getHUD().ShowCursor();
		}
		else
		{
			getHUD().HideCursor();
		}
	}

	private void CalculateVelocity()
	{
		velocity = Vec2f_zero;

		if (isInControl())
		{
			CControls@ controls = getControls();
			Driver@ driver = getDriver();

			Vec2f mousePos = controls.getMouseScreenPos();
			Vec2f center = driver.getScreenCenterPos();

			if (!wasInControl)
			{
				controls.setMousePosition(center);
				return;
			}

			velocity = center - mousePos;

			//apply sensitivity
			velocity *= sensitivity * 0.2f;

			//teleport mouse back to center
			if (velocity.LengthSquared() > 0)
			{
				controls.setMousePosition(center);
			}
		}
	}

	private void LoadPreferences()
	{
		ConfigFile cfg = openPreferences();
		sensitivity = cfg.read_f32("sensitivity");
	}
}
