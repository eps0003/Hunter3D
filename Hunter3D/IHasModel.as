#include "IModel.as"

interface IHasModel
{
	bool hasModel();
	void SetModel(IModel@ model);
}
