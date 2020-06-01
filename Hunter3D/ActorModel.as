#include "IModel.as"
#include "ModelSegment.as"
#include "ImageUV.as"
#include "Camera.as"

namespace ActorModel
{
	enum Segments
	{
		Body,
		Head,
		UpperLeftArm,
		LowerLeftArm,
		UpperRightArm,
		LowerRightArm,
		UpperLeftLeg,
		LowerLeftLeg,
		UpperRightLeg,
		LowerRightLeg
	}
}

class ActorModel : IModel
{
	private ModelSegment@[] segments;
	string skin = "KnightSkin.png";

	ActorModel()
	{
		LoadSegments();
	}

	ActorModel(string skin)
	{
		this.skin = skin;
		LoadSegments();
	}

	void LoadModel()
	{
		if (!isLoaded())
		{
			CreateSegments();
			getRules().set("actor_model", segments);
			print("Loaded actor model");
		}
	}

	bool isLoaded()
	{
		return getRules().exists("actor_model");
	}

	void Render(Object@ parent)
	{
		if (isLoaded())
		{
			UpdateSegments(parent);

			float[] matrix;
			Matrix::MakeIdentity(matrix);

			Render::SetBackfaceCull(false);
			segments[0].Render(skin, matrix);
			Render::SetBackfaceCull(true);
		}
	}

	ModelSegment@ getSegment(uint index)
	{
		if (isLoaded() && index < segments.length)
		{
			return segments[index];
		}
		return null;
	}

	private void LoadSegments()
	{
		if (isLoaded())
		{
			getRules().get("actor_model", segments);
		}
	}

	private void CreateSegments()
	{
		float dim = 0.15f;

		//create
		ModelSegment body("body", Vec3f(dim*2, dim*3, dim), Vec3f(dim, dim, dim/2.0f));
		body.SetUV(Direction::Left,  ImageUV(7.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f));
		body.SetUV(Direction::Right, ImageUV(4.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f));
		body.SetUV(Direction::Up,    ImageUV(5.0f/16.0f, 4.0f/16.0f, 2.0f/16.0f, 1.0f/16.0f));
		body.SetUV(Direction::Down,  ImageUV(7.0f/16.0f, 4.0f/16.0f, 2.0f/16.0f, 1.0f/16.0f));
		body.SetUV(Direction::Front, ImageUV(5.0f/16.0f, 5.0f/16.0f, 2.0f/16.0f, 3.0f/16.0f));
		body.SetUV(Direction::Back,  ImageUV(8.0f/16.0f, 5.0f/16.0f, 2.0f/16.0f, 3.0f/16.0f));
		body.GenerateVertices();

		ModelSegment head("head", Vec3f(dim*2, dim*2, dim*2), Vec3f(dim, 0.0f, dim));
		head.offset = Vec3f(0.0f, dim*2, 0.0f);
		head.SetUV(Direction::Left,  ImageUV(4.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f));
		head.SetUV(Direction::Right, ImageUV(0.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f));
		head.SetUV(Direction::Up,    ImageUV(2.0f/16.0f, 0.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f));
		head.SetUV(Direction::Down,  ImageUV(4.0f/16.0f, 0.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f));
		head.SetUV(Direction::Front, ImageUV(2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f));
		head.SetUV(Direction::Back,  ImageUV(6.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f));
		head.GenerateVertices();

		ModelSegment upperLeftArm("upper_left_arm", Vec3f(dim, dim*1.5f, dim), Vec3f(dim, dim*1.5f, dim/2.0f));
		upperLeftArm.offset = Vec3f(-dim, dim*2, 0.0f);
		upperLeftArm.SetUV(Direction::Left,  ImageUV( 8.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperLeftArm.SetUV(Direction::Right, ImageUV(10.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperLeftArm.SetUV(Direction::Up,    ImageUV( 9.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f));
		upperLeftArm.SetUV(Direction::Down,  ImageUV(0, 0, 0, 0));
		upperLeftArm.SetUV(Direction::Front, ImageUV( 9.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperLeftArm.SetUV(Direction::Back,  ImageUV(11.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperLeftArm.GenerateVertices();

		ModelSegment lowerLeftArm("lower_left_arm", Vec3f(dim, dim*1.5f, dim), Vec3f(dim/2.0f, dim*1.5f, 0.0f));
		lowerLeftArm.offset = Vec3f(-dim/2.0f, -dim*1.5f, -dim/2.0f);
		lowerLeftArm.SetUV(Direction::Left,  ImageUV( 8.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerLeftArm.SetUV(Direction::Right, ImageUV(10.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerLeftArm.SetUV(Direction::Up,    ImageUV(0, 0, 0, 0));
		lowerLeftArm.SetUV(Direction::Down,  ImageUV(10.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f));
		lowerLeftArm.SetUV(Direction::Front, ImageUV( 9.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerLeftArm.SetUV(Direction::Back,  ImageUV(11.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerLeftArm.GenerateVertices();

		ModelSegment upperRightArm("upper_right_arm", Vec3f(dim, dim*1.5f, dim), Vec3f(0.0f, dim*1.5f, dim/2.0f));
		upperRightArm.offset = Vec3f(dim, dim*2, 0.0f);
		upperRightArm.SetUV(Direction::Left,  ImageUV(12.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperRightArm.SetUV(Direction::Right, ImageUV(10.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperRightArm.SetUV(Direction::Up,    ImageUV(11.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f));
		upperRightArm.SetUV(Direction::Down,  ImageUV(0, 0, 0, 0));
		upperRightArm.SetUV(Direction::Front, ImageUV(11.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperRightArm.SetUV(Direction::Back,  ImageUV(13.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperRightArm.GenerateVertices();

		ModelSegment lowerRightArm("lower_right_arm", Vec3f(dim, dim*1.5f, dim), Vec3f(-dim/2.0f, dim*1.5f, 0.0f));
		lowerRightArm.offset = Vec3f(-dim/2.0f, -dim*1.5f, -dim/2.0f);
		lowerRightArm.SetUV(Direction::Left,  ImageUV(12.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerRightArm.SetUV(Direction::Right, ImageUV(10.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerRightArm.SetUV(Direction::Up,    ImageUV(0, 0, 0, 0));
		lowerRightArm.SetUV(Direction::Down,  ImageUV(12.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f));
		lowerRightArm.SetUV(Direction::Front, ImageUV(11.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerRightArm.SetUV(Direction::Back,  ImageUV(13.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerRightArm.GenerateVertices();

		ModelSegment upperLeftLeg("upper_left_leg", Vec3f(dim, dim*1.5f, dim), Vec3f(dim, dim*1.5f, dim/2.0f));
		upperLeftLeg.offset = Vec3f(0.0f, -dim, 0.0f);
		upperLeftLeg.SetUV(Direction::Left,  ImageUV(6.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperLeftLeg.SetUV(Direction::Right, ImageUV(4.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperLeftLeg.SetUV(Direction::Up,    ImageUV(5.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f));
		upperLeftLeg.SetUV(Direction::Down,  ImageUV(0, 0, 0, 0));
		upperLeftLeg.SetUV(Direction::Front, ImageUV(5.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperLeftLeg.SetUV(Direction::Back,  ImageUV(7.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperLeftLeg.GenerateVertices();

		ModelSegment lowerLeftLeg("lower_left_leg", Vec3f(dim, dim*1.5f, dim), Vec3f(dim, dim*1.5f, dim));
		lowerLeftLeg.offset = Vec3f(0.0f, -dim*1.5f, dim/2.0f);
		lowerLeftLeg.SetUV(Direction::Left,  ImageUV(6.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerLeftLeg.SetUV(Direction::Right, ImageUV(4.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerLeftLeg.SetUV(Direction::Up,    ImageUV(0, 0, 0, 0));
		lowerLeftLeg.SetUV(Direction::Down,  ImageUV(6.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f));
		lowerLeftLeg.SetUV(Direction::Front, ImageUV(5.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerLeftLeg.SetUV(Direction::Back,  ImageUV(7.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerLeftLeg.GenerateVertices();

		ModelSegment upperRightLeg("upper_right_leg", Vec3f(dim, dim*1.5f, dim), Vec3f(0.0f, dim*1.5f, dim/2.0f));
		upperRightLeg.offset = Vec3f(0.0f, -dim, 0.0f);
		upperRightLeg.SetUV(Direction::Left,  ImageUV(2.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperRightLeg.SetUV(Direction::Right, ImageUV(0.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperRightLeg.SetUV(Direction::Up,    ImageUV(1.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f));
		upperRightLeg.SetUV(Direction::Down,  ImageUV(0, 0, 0, 0));
		upperRightLeg.SetUV(Direction::Front, ImageUV(1.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperRightLeg.SetUV(Direction::Back,  ImageUV(3.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		upperRightLeg.GenerateVertices();

		ModelSegment lowerRightLeg("lower_right_leg", Vec3f(dim, dim*1.5f, dim), Vec3f(0.0f, dim*1.5f, dim));
		lowerRightLeg.offset = Vec3f(0.0f, -dim*1.5f, dim/2.0f);
		lowerRightLeg.SetUV(Direction::Left,  ImageUV(2.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerRightLeg.SetUV(Direction::Right, ImageUV(0.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerRightLeg.SetUV(Direction::Up,    ImageUV(0, 0, 0, 0));
		lowerRightLeg.SetUV(Direction::Down,  ImageUV(2.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f));
		lowerRightLeg.SetUV(Direction::Front, ImageUV(1.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerRightLeg.SetUV(Direction::Back,  ImageUV(3.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f));
		lowerRightLeg.GenerateVertices();

		//assemble
		body.AddChild(head);
		body.AddChild(upperLeftArm);
		upperLeftArm.AddChild(lowerLeftArm);
		body.AddChild(upperRightArm);
		upperRightArm.AddChild(lowerRightArm);
		body.AddChild(upperLeftLeg);
		upperLeftLeg.AddChild(lowerLeftLeg);
		body.AddChild(upperRightLeg);
		upperRightLeg.AddChild(lowerRightLeg);

		//apply
		segments.push_back(body);
		segments.push_back(head);
		segments.push_back(upperLeftArm);
		segments.push_back(lowerLeftArm);
		segments.push_back(upperRightArm);
		segments.push_back(lowerRightArm);
		segments.push_back(upperLeftLeg);
		segments.push_back(lowerLeftLeg);
		segments.push_back(upperRightLeg);
		segments.push_back(lowerRightLeg);
	}

	private void UpdateSegments(Object@ parent)
	{
		float vel = Vec2f(parent.interVelocity.x, parent.interVelocity.z).Length() * 5;

		float t = getInterGameTime();
		float sin = Maths::Sin(t / 2.5f) * vel;
		float cos = Maths::Cos(t / 2.5f) * vel;
		float limbSin = sin * 50;
		float limbCos = cos * 50;

		float cos2 = (Maths::Sin(t / (2.5f / 2.0f)) + 1) * vel; //sin

		getSegment(ActorModel::Body).offset = parent.interPosition;
		getSegment(ActorModel::Body).offset.y += (-1.7 * 4/8) + Maths::Abs(cos * 0.1f);
		getSegment(ActorModel::Body).rotation = Vec3f(cos2 * 3 - 4 * vel, parent.interRotation.y, 0.0f);

		getSegment(ActorModel::Head).rotation.x = parent.interRotation.x;

		getSegment(ActorModel::UpperLeftArm).rotation.x = -limbCos;
		getSegment(ActorModel::LowerLeftArm).rotation.x = Maths::Max(0, -limbCos);

		getSegment(ActorModel::UpperRightArm).rotation.x = limbCos;
		getSegment(ActorModel::LowerRightArm).rotation.x = Maths::Max(0, limbCos);

		getSegment(ActorModel::UpperLeftLeg).rotation.x = limbCos;
		getSegment(ActorModel::LowerLeftLeg).rotation.x = Maths::Min(0, limbSin);

		getSegment(ActorModel::UpperRightLeg).rotation.x = -limbCos;
		getSegment(ActorModel::LowerRightLeg).rotation.x = Maths::Min(0, -limbSin);
	}
}
