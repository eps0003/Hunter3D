#include "Object.as"

shared interface IHasParent
{
	void SetParent(Object@ parent);
	Object@ getParent();
	bool hasParent();
}
