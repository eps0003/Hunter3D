void LoadMap()
{
	RegisterFileExtensionScript("Scripts/MapLoaders/LoadPNGMap.as", "png");
	RegisterFileExtensionScript("Scripts/MapLoaders/GenerateFromKAGGen.as", "kaggen.cfg");

	LoadRules("Rules/Sandbox/gamemode.cfg");
	LoadMapCycle("Rules/Sandbox/mapcycle.cfg");
	LoadNextMap();
}
