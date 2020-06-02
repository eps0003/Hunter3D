#include "Object.as"
#include "ModelSegment.as"
#include "ImageUV.as"

class Model
{
	private string filePath;
	private string skin = "pixel";

	private float[] matrix;

	private dictionary segments;

	Model(string filePath)
	{
		this.filePath = filePath;
		Matrix::MakeIdentity(matrix);
		LoadModelFromConfig(filePath);
	}

	void SetSkin(string skin)
	{
		this.skin = skin;
	}

	void AddSegment(ModelSegment@ segment)
	{
		segments.set(segment.name, segment);
	}

	void RemoveSegment(string name)
	{
		if (segments.exists(name))
		{
			segments.delete(name);
		}
	}

	ModelSegment@ getSegment(string segmentName)
	{
		ModelSegment@ segment;
		segments.get(segmentName, @segment);
		return segment;
	}

	void LoadModel()
	{
		if (!isLoaded())
		{
			CreateSegments();
			getRules().set(filePath, segments);
			print("Loaded model: " + filePath);
		}
	}

	void LoadSegments()
	{
		if (isLoaded())
		{
			getRules().get(filePath, segments);
		}
	}

	bool isLoaded()
	{
		return getRules().exists(filePath);
	}

	void Render(Object@ parent)
	{
		if (isLoaded())
		{
			UpdateSegments(parent);

			Render::SetBackfaceCull(false);
			getSegment("base").Render(skin, matrix);
			Render::SetBackfaceCull(true);
		}
	}

	private void LoadModelFromConfig(string filePath)
	{
		if (!isLoaded())
		{
			ConfigFile cfg = ConfigFile();
			if (cfg.loadFile(filePath))
			{
				segments.deleteAll();

				//deserialize model
				segments.set("base", ModelSegment("base", cfg));
				getRules().set(filePath, segments);
				print("Loaded model: " + filePath);
			}
			else
			{
				print("Cannot load model: " + filePath);
			}
		}
	}

	//child must override
	private void CreateSegments()
	{

	}

	//child must override
	private void UpdateSegments(Object@ parent)
	{

	}
}
