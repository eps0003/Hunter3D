#include "Model.as"

ModLoader@ getModLoader()
{
	CRules@ rules = getRules();

	ModLoader@ modLoader;
	if (rules.get("mod_loader", @modLoader))
	{
		return modLoader;
	}

	@modLoader = ModLoader();
	rules.set("mod_loader", modLoader);
	return modLoader;
}

class ModLoader
{
	private float progress = 0;
	private string status = "Loading mod...";

	private string[] models = {
		"Models/ActorModel.cfg"
	};
	private int modelsLoaded = 0;

	void LoadMod()
	{
		if (!isLoaded())
		{
			//preload model
			Model(models[modelsLoaded++]);
		}
	}

	bool isLoaded()
	{
		return isModelsLoaded();
	}

	string getStatusMessage()
	{
		if (!isModelsLoaded())
		{
			return "Loading models...";
		}

		return "Hunter3D loaded!";
	}

	float getProgress()
	{
		if (!isModelsLoaded())
		{
			return float(modelsLoaded) / float(models.length);
		}

		return 1;
	}

	private bool isModelsLoaded()
	{
		return modelsLoaded >= models.length;
	}
}
