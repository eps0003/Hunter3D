#include "Identifiable.as"
#include "IRenderable.as"
#include "IHasTeam.as"
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

	Object(Vec3f position, Vec3f rotation = Vec3f(0, 0, 0))
	{
		this.position = position;
		this.rotation = rotation;
		this.createTime =  getGameTime();
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

	}

	uint getCreateTime()
	{
		return createTime;
	}

	bool isStatic()
	{
		return position == oldPosition && rotation == oldRotation;
	}

	void Interpolate()
	{
		float t = getInterFrameTime();

		interPosition = oldPosition.lerp(position, t);
		interRotation = oldRotation.lerpAngle(rotation, t);
	}

	void Serialize(CBitStream@ bs)
	{
		Identifiable::Serialize(bs);

		position.Serialize(bs);
		rotation.Serialize(bs);
	}
}
