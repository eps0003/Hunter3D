interface IModel
{
	bool LoadModel();
	bool isLoaded();
	ModelSegment@ getSegment(uint index);
	void Render(Object@ parent);
}
