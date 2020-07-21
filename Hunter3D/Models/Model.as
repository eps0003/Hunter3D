#include "Segment.as"
#include "ImageUV.as"
#include "Object.as"
#include "Vec3f.as"

shared class Model : SegmentChildren
{
	private string filePath = "";
	private string texture = "pixel";
	private SMaterial@ material = SMaterial();

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

		SetMaterial(texture);
	}

	void SetTexture(string texture)
	{
		this.texture = texture;
		SetMaterial(texture);
	}

	string getTexture()
	{
		return texture;
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

			Segment@[] segments = getChildren();
			for (uint i = 0; i < segments.size(); i++)
			{
				Segment@ segment = segments[i];
				Matrix::SetTranslation(matrix, parent.interPosition.x, parent.interPosition.y, parent.interPosition.z);
				segment.Render(matrix);
			}
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

	private void SetMaterial(string texture)
	{
		//create new material with texture
		@material = SMaterial();
		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::BACK_FACE_CULLING, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);

		//apply material to all segments
		Segment@[] segments = getDescendants();
		for (uint i = 0; i < segments.size(); i++)
		{
			Segment@ segment = segments[i];
			segment.SetMaterial(material);
		}
	}

	//child must override
	private void Update(Object@ parent)
	{

	}
}
