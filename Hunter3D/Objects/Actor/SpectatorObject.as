shared class Spectator : Actor
{
	Spectator(CPlayer@ player, Vec3f position, Vec3f rotation = Vec3f(), Vec3f velocity = Vec3f())
	{
		super(player, position);

		this.rotation = rotation;
		this.velocity = velocity;
	}

	Spectator(CBitStream@ bs)
	{
		super(bs);
	}

	void Initialize()
	{
		Actor::Initialize();

		LoadConfig(openConfig("Spectator.cfg"));

		SetMovementStrategy(SmoothFly());
	}

	void opAssign(Spectator spectator)
	{
		opAssign(cast<Actor>(spectator));
	}

	bool opEquals(Spectator@ spectator)
	{
		return opEquals(cast<Actor>(spectator));
	}

	bool isVisible()
	{
		return false;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(ObjectType::Spectator);
		Actor::Serialize(bs);
	}
}