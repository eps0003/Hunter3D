#include "Segment.as"
#include "ImageUV.as"
#include "Object.as"

class Model : SegmentChildren
{
	private string filePath = "";
	private string skin = "pixel";

	Model() {}

	Model(string filePath)
	{
		this.filePath = filePath;

		if (isLoaded())
		{
			Segment@[] segments;
			getRules().get(filePath, segments);
			setChildren(segments);
		}
		else
		{
			LoadModel(filePath);
		}
	}

	void SetSkin(string skin)
	{
		this.skin = skin;
	}

	bool isLoaded()
	{
		return filePath == "" || getRules().exists(filePath);
	}

	void Render(Object@ parent)
	{
		if (isLoaded())
		{
			float[] matrix;
			Matrix::MakeIdentity(matrix);

			Update(parent);

			Render::SetBackfaceCull(false);

			Segment@[] segments = getChildren();
			for (uint i = 0; i < segments.length; i++)
			{
				Segment@ segment = segments[i];
				Matrix::SetTranslation(matrix, parent.interPosition.x, parent.interPosition.y, parent.interPosition.z);
				segment.Render(skin, matrix);
			}

			Render::SetBackfaceCull(true);
		}
	}

	void LoadModel(string filePath)
	{
		ConfigFile cfg = ConfigFile();
		if (cfg.loadFile(filePath))
		{
			ClearChildren();

			//deserialize model
			Deserialize("model", cfg);
			getRules().set(filePath, getChildren());
			print("Loaded model: " + filePath + " (" + getDescendantCount() + " segments)");
		}
		else
		{
			error("Cannot load model: " + filePath);
		}
	}

	void Serialize(ConfigFile@ cfg)
	{
		Serialize("model", cfg);
	}

	//child must override
	private void Update(Object@ parent)
	{

	}
}
