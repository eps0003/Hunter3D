#include "Segment.as"
#include "Object.as"

shared interface IModel
{
	void LoadModel();
	bool isLoaded();
	Segment@ getSegment(uint index);
	void Render(Object@ parent);
}
