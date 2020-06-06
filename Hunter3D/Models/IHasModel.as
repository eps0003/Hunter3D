#include "Model.as"

interface IHasModel
{
	bool hasModel();
	void SetModel(Model@ model);
	Model@ getModel();
}
