#include "Identifiable.as"

shared class Object : Identifiable
{
	Vec3f position;
	Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f rotation;
	Vec3f oldRotation;
	Vec3f interRotation;

	float cameraHeight = 0;

	Object(Vec3f position, Vec3f rotation = Vec3f(0, 0, 0))
	{
		this.position = position;
		this.rotation = rotation;
	}

	Object(CBitStream@ bs)
	{
		super(bs);

		position = Vec3f(bs);
		rotation = Vec3f(bs);
	}

	void Overwrite(Object object)
	{
		oldPosition = position;
		oldRotation = rotation;

		position = object.position;
		rotation = object.rotation;
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

	void Render()
	{

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

	void LoadConfig(ConfigFile@ cfg)
	{

	}
}
