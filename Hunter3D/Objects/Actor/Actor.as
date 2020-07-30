#include "PhysicsObject.as"
#include "Mouse.as"
#include "ObjectManager.as"
#include "ActorModel.as"
#include "MovementStrategy.as"
#include "Ray.as"
#include "Builder.as"
#include "SpectatorObject.as"

shared class Actor : PhysicsObject, IHasConfig
{
	private CPlayer@ player;
	private MovementStrategy@ movementStrategy;

	float acceleration;
	float jumpForce;

	Actor(CPlayer@ player, Vec3f position)
	{
		super(position);

		@this.player = player;
		SetTeamNum(player.getTeamNum());

		Initialize();
	}

	Actor(CBitStream@ bs)
	{
		super(bs);

		u16 playerID = bs.read_u16();
		@player = getPlayerByNetworkId(playerID);

		Initialize();
	}

	void Initialize()
	{

	}

	void opAssign(Actor actor)
	{
		opAssign(cast<PhysicsObject>(actor));
	}

	bool opEquals(Actor@ actor)
	{
		return opEquals(cast<PhysicsObject>(actor)) && player is actor.player;
	}

	void Update()
	{
		PhysicsObject::Update();

		if (movementStrategy !is null)
		{
			movementStrategy.Move(this);
			movementStrategy.Rotate(this);
		}
	}

	void PostUpdate()
	{
		PhysicsObject::PostUpdate();

		//sync to server
		if (Network::isMultiplayer() && shouldSync())
		{
			CBitStream bs;
			Serialize(bs);
			CRules@ rules = getRules();
			rules.SendCommand(rules.getCommandID("c_sync_actor"), bs, false);
		}
	}

	void Render()
	{

	}

	bool isVisible()
	{
		Camera@ camera = getCamera3D();
		bool cameraParentNotMe = camera.hasParent() && camera.getParent() != cast<Object>(this);
		return cameraParentNotMe;
	}

	CPlayer@ getPlayer()
	{
		return player;
	}

	void SetTeamNum(u8 team)
	{
		PhysicsObject::SetTeamNum(team);
		player.server_setTeamNum(team);
	}

	void RenderHUD()
	{
		GUI::DrawText("position: " + position.toString(), Vec2f(10, 40), color_black);
	}

	void RenderNameplate()
	{
		if (isNameplateVisible())
		{
			Camera@ camera = getCamera3D();

			Vec3f pos = interPosition + Vec3f(0, 2, 0);
			Vec2f screenPos = pos.projectToScreen();
			uint distance = (camera.getPosition() - pos).mag();

			SColor teamColor = getRules().getTeam(getTeamNum()).color;

			GUI::DrawTextCentered(player.getCharacterName(), screenPos - Vec2f(0, 8), teamColor);
			GUI::DrawTextCentered(distance + " " + String::plural(distance, "block"), screenPos + Vec2f(0, 8), color_white);
		}
	}

	void Interpolate(float t)
	{
		PhysicsObject::Interpolate(t);

		interRotation = oldRotation.lerpAngle(rotation, t);
	}

	void Serialize(CBitStream@ bs)
	{
		PhysicsObject::Serialize(bs);
		bs.write_u16(player.getNetworkID());
	}

	void SetMovementStrategy(MovementStrategy@ strategy)
	{
		@movementStrategy = strategy;
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		PhysicsObject::LoadConfig(cfg);

		acceleration = cfg.read_f32("acceleration", 0.1f);
		jumpForce = cfg.read_f32("jump_force", 0.3f);
	}

	private bool isNameplateVisible()
	{
		Camera@ camera = getCamera3D();

		u8 team = getTeamNum();
		u8 myTeam = getLocalPlayer().getTeamNum();
		u8 specTeam = getRules().getSpectatorTeamNum();

		bool teammate = team == myTeam || myTeam == specTeam;
		bool notSpectator = team != specTeam;
		bool visibleToCam = interPosition.isInFrontOfCamera();
		bool cameraNotAttached = !camera.hasParent() || camera.getParent() != cast<Object>(this);

		return teammate && notSpectator && visibleToCam && cameraNotAttached;
	}
}
