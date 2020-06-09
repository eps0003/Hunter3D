#include "Model.as"

shared interface IHasModel
{
	bool hasModel();
	void SetModel(Model@ model);
	Model@ getModel();
}
