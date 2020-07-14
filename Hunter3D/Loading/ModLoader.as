#include "Model.as"

shared ModLoader@ getModLoader()
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

enum LoadState
{
	GenerateMap,
	DeserializeMap,
	GenerateChunks,
	// InitializeChunkTree,
	PreloadModels,
	Done
}

shared class ModLoader
{
	uint state = 0;
	uint index = 0;
	float progress = 0;
	string message;

	string[] models = {
		"Models/ActorModel.cfg"
	};

	void Load()
	{
		if (!isLoading()) return;

		switch (state)
		{
			case LoadState::GenerateMap:
			{
				message = "Generating map...";

				Map@ map = getMap3D();
				if (map !is null && (!isServer() || map.isLoaded()))
				{
					print("Map generated", ConsoleColour::CRAZY);
					NextState();
				}
			}
			break;

			case LoadState::DeserializeMap:
			{
				message = "Receiving map...";

				Map@ map = getMap3D();
				if (map !is null && map.isLoaded())
				{
					print("Map received", ConsoleColour::CRAZY);
					NextState();

					//immediately skip to next state if running localhost
					if (!isServer())
					{
						break;
					}
				}
				else
				{
					break;
				}
			}

			case LoadState::GenerateChunks:
			{
				Map@ map = getMap3D();

				if (index == 0)
				{
					map.InitChunks();
				}

				uint chunkCount = map.getChunkCount();
				message = "Generating chunks...";
				SetProgress(float(index) / float(chunkCount));
				// print("Generating chunk: " + (index + 1) + "/" + chunkCount);

				for (uint i = 0; i < 4; i++)
				{
					Chunk chunk(map, index);
					map.SetChunk(index, chunk);
					index++;

					if (index >= chunkCount)
					{
						print("Chunks generated", ConsoleColour::CRAZY);
						NextState();
						break;
					}
				}
			}
			break;

			// case LoadState::InitializeChunkTree:
			// {
			// 	message = "Organizing chunks...";
			// 	getMap3D().InitChunkTree();

			// 	print("Chunks organized", ConsoleColour::CRAZY);
			// 	NextState();
			// }
			// break;

			case LoadState::PreloadModels:
			{
				message = "Loading models...";
				SetProgress(float(index) / float(models.length));

				Model(models[index++]);

				if (index >= models.length)
				{
					print("Models loaded", ConsoleColour::CRAZY);
					NextState();
				}
			}
			break;

			case LoadState::Done:
			{
				message = "Hunter3D loaded!";
				print("Hunter3D loaded!", ConsoleColour::CRAZY);

				CBitStream bs;
				bs.write_u16(getLocalPlayer().getNetworkID());

				CRules@ rules = getRules();
				rules.SendCommand(rules.getCommandID("c_loaded"), bs, false);

				NextState();
			}
		}
	}

	void SetState(uint state)
	{
		this.state = state;
		index = 0;
		SetProgress(0);
	}

	void NextState()
	{
		SetState(state + 1);
	}

	bool isLoading()
	{
		return state <= LoadState::Done;
	}

	string getMessage()
	{
		return message;
	}

	float getProgress()
	{
		return progress;
	}

	void SetProgress(float progress)
	{
		this.progress = progress;
	}
}
