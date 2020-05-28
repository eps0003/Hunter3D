void onInit(CRules@ this)
{
	this.addCommandID("s_map_data");
	this.addCommandID("c_sync_voxel");
	this.addCommandID("s_sync_voxel");
	this.addCommandID("s_sync_actors");
	this.addCommandID("c_sync_actor");

	CFileImage::silent_errors = true; //shut the fuck up. my mod is flawless. dont be saying otherwise
}
