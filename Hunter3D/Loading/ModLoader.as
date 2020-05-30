#include "ActorModel.as"

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

	private IModel@[] models = {
		ActorModel()
	};
	private int totalModels = models.length;

	void LoadMod()
	{
		if (!isLoaded())
		{
			if (!models.empty())
			{
				IModel@ model = models[0];
				model.LoadModel();
				models.removeAt(0);
			}
		}
	}

	bool isLoaded()
	{
		return models.empty();
	}

	string getStatusMessage()
	{
		if (!models.empty())
		{
			return "Loading models...";
		}

		return "Hunter3D loaded!";
	}

	float getProgress()
	{
		if (!models.empty())
		{
			return 1 - (float(models.length) / float(totalModels));
		}

		return 1;
	}
}
