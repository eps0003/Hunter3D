#include "Identifiable.as"
#include "IRenderable.as"
#include "IHasConfig.as"
#include "IHasParent.as"

shared class Object : Identifiable
{
	Vec3f position;
	Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f rotation;
	Vec3f oldRotation;
	Vec3f interRotation;

	float cameraHeight = 0;

	private uint createTime = 0;

	private u8 team = -1;

	private bool sync = true;
	private bool wasStatic;

	Object(Vec3f position, Vec3f rotation = Vec3f(0, 0, 0))
	{
		this.position = position;
		this.rotation = rotation;

		createTime = getGameTime();
	}

	Object(CBitStream@ bs)
	{
		super(bs);

		position = Vec3f(bs);
		rotation = Vec3f(bs);

		createTime = getGameTime();
	}

	void opAssign(Object object)
	{
		oldPosition = position;
		oldRotation = rotation;

		position = object.position;
		rotation = object.rotation;

		sync = true;
	}

	bool opEquals(Object@ object)
	{
		return opEquals(cast<Identifiable>(object));
	}

	void PreUpdate()
	{
		oldPosition = position;
		oldRotation = rotation;
	}

	void Update()
	{

	}

	void PostUpdate()
	{
		sync = sync || !wasStatic || !isStatic();
		wasStatic = isStatic();
	}

	void onCreate()
	{
		oldPosition = position;
		interPosition = position;

		oldRotation = rotation;
		interRotation = rotation;
	}

	void onRemove()
	{

	}

	uint getCreateTime()
	{
		return createTime;
	}

	bool shouldSync()
	{
		return sync;
	}

	void Synced()
	{
		sync = false;
	}

	bool isStatic()
	{
		return position == oldPosition && rotation == oldRotation;
	}

	u8 getTeamNum()
	{
		return team;
	}

	void SetTeamNum(u8 team)
	{
		this.team = team;
	}

	void Interpolate(float t)
	{
		if (oldPosition != position)
		{
			interPosition = oldPosition.lerp(position, t);
		}

		if (oldRotation != rotation)
		{
			interRotation = oldRotation.lerpAngle(rotation, t);
		}
	}

	void Serialize(CBitStream@ bs)
	{
		Identifiable::Serialize(bs);

		position.Serialize(bs);
		rotation.Serialize(bs);
	}
}
