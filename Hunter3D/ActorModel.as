#include "IModel.as"
#include "ModelSegment.as"
#include "ImageUV.as"

class ActorModel : IModel
{
	private ModelSegment@[] segments;
	string skin = "SteveSkin.png";

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

		ModelSegment leftArm(Vec3f(dim, dim*3, dim), Vec3f(dim, dim*3, dim/2.0f));
		leftArm.offset = Vec3f(-dim, dim*2, 0.0f);
		leftArm.leftUV  = ImageUV( 8.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		leftArm.rightUV = ImageUV(10.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		leftArm.upUV    = ImageUV( 9.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		leftArm.downUV  = ImageUV(10.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		leftArm.frontUV = ImageUV( 9.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		leftArm.backUV  = ImageUV(11.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		leftArm.GenerateVertices();

		ModelSegment rightArm(Vec3f(dim, dim*3, dim), Vec3f(0.0f, dim*3, dim/2.0f));
		rightArm.offset = Vec3f(dim, dim*2, 0.0f);
		rightArm.leftUV  = ImageUV(12.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		rightArm.rightUV = ImageUV(10.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		rightArm.upUV    = ImageUV(11.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		rightArm.downUV  = ImageUV(12.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		rightArm.frontUV = ImageUV(11.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		rightArm.backUV  = ImageUV(13.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		rightArm.GenerateVertices();

		ModelSegment leftLeg(Vec3f(dim, dim*3, dim), Vec3f(dim, dim*3, dim/2.0f));
		leftLeg.offset = Vec3f(0.0f, -dim, 0.0f);
		leftLeg.leftUV  = ImageUV(6.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		leftLeg.rightUV = ImageUV(4.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		leftLeg.upUV    = ImageUV(5.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		leftLeg.downUV  = ImageUV(6.0f/16.0f, 12.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		leftLeg.frontUV = ImageUV(5.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		leftLeg.backUV  = ImageUV(7.0f/16.0f, 13.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		leftLeg.GenerateVertices();

		ModelSegment rightLeg(Vec3f(dim, dim*3, dim), Vec3f(0.0f, dim*3, dim/2.0f));
		rightLeg.offset = Vec3f(0.0f, -dim, 0.0f);
		rightLeg.leftUV  = ImageUV(2.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		rightLeg.rightUV = ImageUV(0.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		rightLeg.upUV    = ImageUV(1.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		rightLeg.downUV  = ImageUV(2.0f/16.0f, 4.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f);
		rightLeg.frontUV = ImageUV(1.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		rightLeg.backUV  = ImageUV(3.0f/16.0f, 5.0f/16.0f, 1.0f/16.0f, 3.0f/16.0f);
		rightLeg.GenerateVertices();

		//assemble
		body.AddChild(head);
		body.AddChild(leftArm);
		body.AddChild(rightArm);
		body.AddChild(leftLeg);
		body.AddChild(rightLeg);

		//apply
		segments.push_back(body);
		segments.push_back(head);
		segments.push_back(leftArm);
		segments.push_back(rightArm);
		segments.push_back(leftLeg);
		segments.push_back(rightLeg);
	}

	private void UpdateSegments(Object@ parent)
	{
		segments[0].offset = parent.interPosition - getCamera3D().getParent().interPosition;
		segments[2].rotation.x = Maths::Sin(getInterGameTime() / 10.0f) * 40;
		segments[3].rotation.x = -segments[2].rotation.x;
		segments[4].rotation.x = segments[3].rotation.x;
		segments[5].rotation.x = segments[2].rotation.x;
	}
}
