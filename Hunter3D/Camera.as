#include "IHasParent.as"

Camera@ getCamera3D()
{
	CRules@ rules = getRules();

	Camera@ camera;
	if (rules.get("camera", @camera))
	{
		return camera;
	}

	@camera = Camera(null);
	rules.set("camera", camera);
	return camera;
}

class Camera : IHasParent
{
	private Object@ parent;
	float fov;

	Camera(Object@ parent)
	{
		SetParent(parent);
		LoadPreferences();
	}

	void Render()
	{
		if (hasParent())
		{
			float[] model = getModelMatrix();
			float[] view = getViewMatrix(parent.interPosition, parent.interRotation);
			float[] proj = getProjectionMatrix();
			Render::SetTransform(model, view, proj);
		}
	}

	void SetParent(Object@ parent)
	{
		@this.parent = parent;
	}

	Object@ getParent()
	{
		return parent;
	}

	bool hasParent()
	{
		return parent !is null;
	}

	private float[] getModelMatrix()
	{
		float[] matrix;
		Matrix::MakeIdentity(matrix);
		return matrix;
	}

	private float[] getProjectionMatrix()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		float ratio = float(screenDim.x) / float(screenDim.y);

		float[] matrix;
		Matrix::MakePerspective(matrix,
			fov * Maths::Pi / 180,
			ratio,
			0.01f, 1000
		);

		return matrix;
	}

	private float[] getViewMatrix(Vec3f position, Vec3f rotation)
	{
		float[] matrix;

		float[] translation;
		Matrix::MakeIdentity(translation);
		Matrix::SetTranslation(translation, -position.x, -position.y, -position.z);

		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, rotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, rotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, rotation.z);

		float[] thirdPerson;
		Matrix::MakeIdentity(thirdPerson);
		Matrix::SetTranslation(thirdPerson, 0, 0, 2);

		Matrix::Multiply(tempX, tempZ, matrix);
		Matrix::Multiply(matrix, tempY, matrix);
		Matrix::Multiply(matrix, translation, matrix);
		// Matrix::Multiply(thirdPerson, matrix, matrix);

		return matrix;
	}

	private void LoadPreferences()
	{
		ConfigFile cfg = openPreferences();
		fov = cfg.read_f32("fov", 70.0f);
	}
}
