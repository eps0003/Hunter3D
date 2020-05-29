#include "IModel.as"
#include "ModelSegment.as"
#include "ImageUV.as"

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

	bool LoadModel()
	{
		if (!isLoaded())
		{
			CreateSegments();
			getRules().set("actor_model", segments);
			print("Loaded actor model");
			return false;
		}
		return true;
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
		ModelSegment body(Vec3f(dim*2, dim*3, dim), Vec3f(dim, dim, dim/2.0f));
		body.leftUV  = ImageUV(7.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		body.rightUV = ImageUV(4.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		body.upUV    = ImageUV(5.0f/16.0f, 4.0f/16.0f, 2.0f/16.0f, 1.0f/16.0f);
		body.downUV  = ImageUV(7.0f/16.0f, 4.0f/16.0f, 2.0f/16.0f, 1.0f/16.0f);
		body.frontUV = ImageUV(5.0f/16.0f, 5.0f/16.0f, 2.0f/16.0f, 3.0f/16.0f);
		body.backUV  = ImageUV(8.0f/16.0f, 5.0f/16.0f, 2.0f/16.0f, 3.0f/16.0f);
		body.GenerateVertices();

		ModelSegment head(Vec3f(dim*2, dim*2, dim*2), Vec3f(dim, 0.0f, dim));
		head.offset = Vec3f(0.0f, dim*2, 0.0f);
		head.leftUV  = ImageUV(4.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f);
		head.rightUV = ImageUV(0.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f);
		head.upUV    = ImageUV(2.0f/16.0f, 0.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f);
		head.downUV  = ImageUV(4.0f/16.0f, 0.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f);
		head.frontUV = ImageUV(2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f);
		head.backUV  = ImageUV(6.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f, 2.0f/16.0f);
		head.GenerateVertices();

		ModelSegment upperLeftArm(Vec3f(dim, dim*1.5f, dim), Vec3f(dim, dim*1.5f, dim/2.0f));
		upperLeftArm.offset = Vec3f(-dim, dim*2, 0.0f);
		upperLeftArm.leftUV  = ImageUV( 8.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperLeftArm.rightUV = ImageUV(10.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperLeftArm.upUV    = ImageUV( 9.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		upperLeftArm.downUV  = ImageUV(0, 0, 0, 0);
		upperLeftArm.frontUV = ImageUV( 9.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperLeftArm.backUV  = ImageUV(11.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperLeftArm.GenerateVertices();

		ModelSegment lowerLeftArm(Vec3f(dim, dim*1.5f, dim), Vec3f(dim/2.0f, dim*1.5f, 0.0f));
		lowerLeftArm.offset = Vec3f(-dim/2.0f, -dim*1.5f, -dim/2.0f);
		lowerLeftArm.leftUV  = ImageUV( 8.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerLeftArm.rightUV = ImageUV(10.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerLeftArm.upUV    = ImageUV(0, 0, 0, 0);
		lowerLeftArm.downUV  = ImageUV(10.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		lowerLeftArm.frontUV = ImageUV( 9.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerLeftArm.backUV  = ImageUV(11.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerLeftArm.GenerateVertices();

		ModelSegment upperRightArm(Vec3f(dim, dim*1.5f, dim), Vec3f(0.0f, dim*1.5f, dim/2.0f));
		upperRightArm.offset = Vec3f(dim, dim*2, 0.0f);
		upperRightArm.leftUV  = ImageUV(12.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperRightArm.rightUV = ImageUV(10.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperRightArm.upUV    = ImageUV(11.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		upperRightArm.downUV  = ImageUV(0, 0, 0, 0);
		upperRightArm.frontUV = ImageUV(11.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperRightArm.backUV  = ImageUV(13.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperRightArm.GenerateVertices();

		ModelSegment lowerRightArm(Vec3f(dim, dim*1.5f, dim), Vec3f(-dim/2.0f, dim*1.5f, 0.0f));
		lowerRightArm.offset = Vec3f(-dim/2.0f, -dim*1.5f, -dim/2.0f);
		lowerRightArm.leftUV  = ImageUV(12.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerRightArm.rightUV = ImageUV(10.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerRightArm.upUV    = ImageUV(0, 0, 0, 0);
		lowerRightArm.downUV  = ImageUV(12.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		lowerRightArm.frontUV = ImageUV(11.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerRightArm.backUV  = ImageUV(13.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerRightArm.GenerateVertices();

		ModelSegment upperLeftLeg(Vec3f(dim, dim*1.5f, dim), Vec3f(dim, dim*1.5f, dim/2.0f));
		upperLeftLeg.offset = Vec3f(0.0f, -dim, 0.0f);
		upperLeftLeg.leftUV  = ImageUV(6.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperLeftLeg.rightUV = ImageUV(4.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperLeftLeg.upUV    = ImageUV(5.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		upperLeftLeg.downUV  = ImageUV(0, 0, 0, 0);
		upperLeftLeg.frontUV = ImageUV(5.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperLeftLeg.backUV  = ImageUV(7.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperLeftLeg.GenerateVertices();

		ModelSegment lowerLeftLeg(Vec3f(dim, dim*1.5f, dim), Vec3f(dim, dim*1.5f, dim));
		lowerLeftLeg.offset = Vec3f(0.0f, -dim*1.5f, dim/2.0f);
		lowerLeftLeg.leftUV  = ImageUV(6.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerLeftLeg.rightUV = ImageUV(4.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerLeftLeg.upUV    = ImageUV(0, 0, 0, 0);
		lowerLeftLeg.downUV  = ImageUV(6.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		lowerLeftLeg.frontUV = ImageUV(5.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerLeftLeg.backUV  = ImageUV(7.0f/16.0f, 14.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerLeftLeg.GenerateVertices();

		ModelSegment upperRightLeg(Vec3f(dim, dim*1.5f, dim), Vec3f(0.0f, dim*1.5f, dim/2.0f));
		upperRightLeg.offset = Vec3f(0.0f, -dim, 0.0f);
		upperRightLeg.leftUV  = ImageUV(2.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperRightLeg.rightUV = ImageUV(0.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperRightLeg.upUV    = ImageUV(1.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		upperRightLeg.downUV  = ImageUV(0, 0, 0, 0);
		upperRightLeg.frontUV = ImageUV(1.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperRightLeg.backUV  = ImageUV(3.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		upperRightLeg.GenerateVertices();

		ModelSegment lowerRightLeg(Vec3f(dim, dim*1.5f, dim), Vec3f(0.0f, dim*1.5f, dim));
		lowerRightLeg.offset = Vec3f(0.0f, -dim*1.5f, dim/2.0f);
		lowerRightLeg.leftUV  = ImageUV(2.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerRightLeg.rightUV = ImageUV(0.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerRightLeg.upUV    = ImageUV(1.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		lowerRightLeg.downUV  = ImageUV(2.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		lowerRightLeg.frontUV = ImageUV(1.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
		lowerRightLeg.backUV  = ImageUV(3.0f/16.0f, 6.5f/16.0f, 1.0f/16.0f, 1.5f/16.0f);
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

		getSegment(ActorModel::Body).offset = parent.interPosition - getCamera3D().getParent().interPosition;
		getSegment(ActorModel::Body).offset.y = (-1.7 * 4/8) + Maths::Abs(cos * 0.1f);
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
