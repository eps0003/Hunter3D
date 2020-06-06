#include "Segment.as"
#include "Object.as"

interface IModel
{
	void LoadModel();
	bool isLoaded();
	Segment@ getSegment(uint index);
	void Render(Object@ parent);
}
