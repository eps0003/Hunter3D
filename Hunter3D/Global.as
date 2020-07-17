void onInit(CRules@ this)
{
	this.addCommandID("s_map_data");
	this.addCommandID("c_sync_block");
	this.addCommandID("s_sync_block");
	this.addCommandID("s_revert_block");
	this.addCommandID("s_sync_objects");
	this.addCommandID("c_sync_actor");
	this.addCommandID("c_remove_actor");
	this.addCommandID("c_loaded");

	CFileImage::silent_errors = true; //shut the fuck up. my mod is flawless. dont be saying otherwise

	onRestart(this);
}

void onRestart(CRules@ this)
{
	this.set("camera", null);
	this.set("mouse", null);
	this.set("map", null);
	this.set("mod_loader", null);
	this.set("map_syncer", null);
	this.set("actor_manager", null);
	this.set("flag_manager", null);
	this.set("gamemode_manager", null);
	this.set("object_manager", null);
	this.set("respawn_manager", null);
}