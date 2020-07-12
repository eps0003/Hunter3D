#include "IHasParent.as"
#include "Frustum.as"

shared Camera@ getCamera3D()
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

shared class Camera : IHasParent
{
	private Object@ parent;
	private Frustum frustum;

	private float fov;
	private float renderDistance;

	private float[] modelMatrix;
	private float[] viewMatrix;
	private float[] projectionMatrix;
	private float[] rotationMatrix;

	Camera(Object@ parent)
	{
		SetParent(parent);
		LoadPreferences();

		Matrix::MakeIdentity(modelMatrix);
		Matrix::MakeIdentity(viewMatrix);
		Matrix::MakeIdentity(projectionMatrix);
		Matrix::MakeIdentity(rotationMatrix);

		Render::SetFog(getSkyColor(), SMesh::LINEAR, renderDistance * 0.9f, renderDistance, 0, false, true);
	}

	void Render()
	{
		if (hasParent())
		{
			UpdateViewMatrix();
			UpdateRotationMatrix();
			UpdateProjectionMatrix();

			Render::SetTransform(modelMatrix, viewMatrix, projectionMatrix);

			UpdateFrustum();
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

	Vec3f getPosition()
	{
		if (hasParent())
		{
			return parent.interPosition + Vec3f(0, parent.cameraHeight, 0);
		}
		else
		{
			return Vec3f();
		}
	}

	Vec3f getRotation()
	{
		if (hasParent())
		{
			return parent.interRotation;
		}
		else
		{
			return Vec3f();
		}
	}

	float[] getViewMatrix()
	{
		return viewMatrix;
	}

	float[] getProjectionMatrix()
	{
		return projectionMatrix;
	}

	Frustum getFrustum()
	{
		return frustum;
	}

	private void UpdateProjectionMatrix()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		float ratio = float(screenDim.x) / float(screenDim.y);

		Matrix::MakePerspective(projectionMatrix,
			fov * Maths::Pi / 180,
			ratio,
			0.01f, renderDistance
		);
	}

	private void UpdateViewMatrix()
	{
		Vec3f position = getPosition();

		float[] translation;
		Matrix::MakeIdentity(translation);
		Matrix::SetTranslation(translation, -position.x, -position.y, -position.z);

		float[] thirdPerson;
		Matrix::MakeIdentity(thirdPerson);
		Matrix::SetTranslation(thirdPerson, 0, 0, 10);

		Matrix::Multiply(rotationMatrix, translation, viewMatrix);
		// Matrix::Multiply(thirdPerson, matrix, viewMatrix);
	}

	private void UpdateRotationMatrix()
	{
		Vec3f rotation = getRotation();

		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, rotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, rotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, rotation.z);

		Matrix::Multiply(tempX, tempZ, rotationMatrix);
		Matrix::Multiply(rotationMatrix, tempY, rotationMatrix);
	}

	private void UpdateFrustum()
	{
		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::Multiply(projectionMatrix, rotationMatrix, matrix);

		frustum.Update(matrix);
	}

	private void LoadPreferences()
	{
		ConfigFile cfg = openPreferences();
		fov = cfg.read_f32("fov", 70.0f);
		renderDistance = cfg.read_f32("render_distance", 70.0f);
	}
}
