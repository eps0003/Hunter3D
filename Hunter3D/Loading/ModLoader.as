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
	PlaceExtraBlocks,
	InitializeBlockFaces,
	GenerateChunks,
	InitializeChunkTree,
	PreloadModels,
	Done
}

shared class ModLoader
{
	private uint state = 0;
	private uint index = 0;
	private float progress = 0;
	private string message;
	private BlockToPlace[] blocksToPlace;

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
					if (!isServer())
					{
						print("Map generated", ConsoleColour::CRAZY);
					}
					NextState();
				}
			}
			break;

			case LoadState::DeserializeMap:
			{
				message = "Receiving map...";

				if (!isServer())
				{
					break;
				}
				else
				{
					//immediately skip to next state if running localhost
					NextState();
				}
			}

			case LoadState::PlaceExtraBlocks:
			{
				message = "Finalizing map...";

				Map@ map = getMap3D();
				map.SetLoaded();

				NextState();

				if (!blocksToPlace.empty())
				{
					for (uint i = 0; i < blocksToPlace.size(); i++)
					{
						BlockToPlace btp = blocksToPlace[i];

						uint index = btp.index;
						u8 block = btp.block;

						map.SetBlock(index, block);
					}

					break;
				}
			}

			case LoadState::InitializeBlockFaces:
			{
				Map@ map = getMap3D();
				Vec3f mapDim = map.getMapDimensions();
				uint n = mapDim.x * mapDim.y * mapDim.z;

				message = "Initializing block faces...";
				SetProgress(float(index) / float(n));

				for (uint i = 0; i < 4000; i++)
				{
					map.UpdateBlockFaces(index);
					index++;

					if (index >= n)
					{
						print("Block faces initialized", ConsoleColour::CRAZY);
						NextState();
						break;
					}
				}
			}
			break;

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

				for (uint i = 0; i < 16; i++)
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

			case LoadState::InitializeChunkTree:
			{
				message = "Organizing chunks...";
				getMap3D().InitChunkTree();

				print("Chunks organized", ConsoleColour::CRAZY);
				NextState();
			}
			break;

			case LoadState::PreloadModels:
			{
				message = "Loading models...";
				SetProgress(float(index) / float(models.size()));

				Model(models[index++]);

				if (index >= models.size())
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

	void AddBlockToPlace(uint index, u8 block)
	{
		blocksToPlace.push_back(BlockToPlace(index, block));
	}
}


shared class BlockToPlace
{
	uint index;
	u8 block;

	BlockToPlace(uint index, u8 block)
	{
		this.index = index;
		this.block = block;
	}
}