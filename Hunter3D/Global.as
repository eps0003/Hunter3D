void onInit(CRules@ this)
{
	this.addCommandID("server map data");
	this.addCommandID("client sync voxel");
	this.addCommandID("server sync voxel");
	this.addCommandID("server sync actors");
	this.addCommandID("server spawn actor");

	CFileImage::silent_errors = true; //shut the fuck up. my mod is flawless. dont be saying otherwise
}
