void onInit(CRules@ this)
{
	this.addCommandID("s_map_data");
	this.addCommandID("c_sync_voxel");
	this.addCommandID("s_sync_voxel");
	this.addCommandID("s_sync_objects");
	this.addCommandID("c_sync_actor");
	this.addCommandID("s_remove_actor");
	this.addCommandID("c_remove_actor");
	this.addCommandID("c_loaded");

	CFileImage::silent_errors = true; //shut the fuck up. my mod is flawless. dont be saying otherwise
}
