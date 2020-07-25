#include "ModLoader.as"

shared Mouse@ getMouse3D()
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

shared class Mouse
{
	Vec2f velocity;
	Vec2f oldVelocity;
	Vec2f interVelocity;

	float sensitivity;

	private bool centerMouse = true;
	private bool[] previousControl;

	Mouse()
	{
		LoadPreferences();
	}

	void Update()
	{
		previousControl.push_back(isInControl());
		if (previousControl.size() > 2)
		{
			previousControl.removeAt(0);
		}

		oldVelocity = velocity;
		CalculateVelocity();
		centerMouse = !isInControl();
	}

	void Render()
	{
		Visibility();
		Interpolate();
	}

	bool wasInControl()
	{
		return previousControl.size() < 2 ? false : previousControl[0];
	}

	bool isInControl()
	{
		return isWindowFocused() && !isVisible() && !getModLoader().isLoading();
	}

	bool isVisible()
	{
		return getCamera3D() is null || Menu::isMenuOpen();
	}

	private void Interpolate()
	{
		float t = getInterFrameTime();

		interVelocity = Vec2f_lerp(oldVelocity, velocity, t);
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

			if (centerMouse)
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
		sensitivity = cfg.read_f32("sensitivity", 1.0f);
	}
}
