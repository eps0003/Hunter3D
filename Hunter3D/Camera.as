class Camera
{
	Object@ parent;
	float fov;

	Camera(Object@ parent)
	{
		@this.parent = parent;
		LoadPreferences();
	}

	void Render()
	{
		float[] model = getModelMatrix(parent.position);
		float[] view = getViewMatrix(parent.rotation);
		float[] proj = getProjectionMatrix();
		Render::SetTransform(model, view, proj);
	}

	private float[] getModelMatrix(Vec3f position)
	{
		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::SetTranslation(matrix, -position.x, -position.y, -position.z);
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

	private float[] getViewMatrix(Vec3f rotation)
	{
		float[] matrix;

		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, rotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, rotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, rotation.z);

		Matrix::Multiply(tempX, tempZ, matrix);
		Matrix::Multiply(matrix, tempY, matrix);

		return matrix;
	}

	private void LoadPreferences()
	{
		ConfigFile cfg = openPreferences();
		fov = cfg.read_f32("fov");
	}
}
