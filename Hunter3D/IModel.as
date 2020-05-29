#include "ModelSegment.as"
#include "Object.as"

interface IModel
{
	void LoadModel();
	bool isLoaded();
	ModelSegment@ getSegment(uint index);
	void Render(Object@ parent);
}
