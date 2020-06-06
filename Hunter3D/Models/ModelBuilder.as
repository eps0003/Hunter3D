#include "Segment.as"
#include "Vec3f.as"
#include "Camera.as"
#include "Utilities.as"

class ModelBuilder
{
	private string skin = "pixel";
	private Object parent;
	private Model model;
	private string selectedSegment;
	private uint selectedProperty = 0;

	void Update()
	{
		if (isSegmentSelected())
		{
			CControls@ controls = getControls();
			Segment@ segment = getSelectedSegment();

			s8 scrollDir = num(controls.mouseScrollUp) - num(controls.mouseScrollDown);

			if (scrollDir != 0)
			{
				bool pressingKey = false;

				Vec3f@[] properties = { segment.dim, segment.origin, segment.offset, segment.orbit, segment.rotation };
				float[] preciseIncrement = { 0.01f, 0.01f, 0.01f, 1.0f, 1.0f };
				float[] fastIncrement = { 0.2f, 0.2f, 0.2f, 10.0f, 10.0f };
				bool[] generateVertices = { true, true, false, false, false };

				float incrementAmount = controls.isKeyPressed(KEY_LSHIFT) ? preciseIncrement[selectedProperty] : fastIncrement[selectedProperty];

				if (controls.isKeyPressed(KEY_KEY_Z))
				{
					pressingKey = true;
					properties[selectedProperty].x += incrementAmount * scrollDir;

					if (Maths::Abs(properties[selectedProperty].x) < 0.001f)
					{
						properties[selectedProperty].x = 0;
					}
				}

				if (controls.isKeyPressed(KEY_KEY_X))
				{
					pressingKey = true;
					properties[selectedProperty].y += incrementAmount * scrollDir;

					if (Maths::Abs(properties[selectedProperty].y) < 0.001f)
					{
						properties[selectedProperty].y = 0;
					}
				}

				if (controls.isKeyPressed(KEY_KEY_C))
				{
					pressingKey = true;
					properties[selectedProperty].z += incrementAmount * scrollDir;

					if (Maths::Abs(properties[selectedProperty].z) < 0.001f)
					{
						properties[selectedProperty].z = 0;
					}
				}

				if (!pressingKey)
				{
					selectedProperty = (selectedProperty + 5 - scrollDir) % 5;
				}
				else if (generateVertices[selectedProperty])
				{
					segment.GenerateVertices();
				}
			}
		}
	}

	void RenderModel()
	{
		model.Render(parent);
	}

	void RenderGUI()
	{
		if (isSegmentSelected())
		{
			Segment@ segment = getSelectedSegment();
			SColor selectedColor(255, 255, 0, 0);
			SColor color = color_black;

			GUI::DrawText("name: "     + segment.name,                Vec2f(10,  50), color_black);
			GUI::DrawText("dim: "      + segment.dim.toString(),      Vec2f(10,  70), selectedProperty == 0 ? selectedColor : color_black);
			GUI::DrawText("origin: "   + segment.origin.toString(),   Vec2f(10,  90), selectedProperty == 1 ? selectedColor : color_black);
			GUI::DrawText("offset: "   + segment.offset.toString(),   Vec2f(10, 110), selectedProperty == 2 ? selectedColor : color_black);
			GUI::DrawText("orbit: "    + segment.orbit.toString(),    Vec2f(10, 130), selectedProperty == 3 ? selectedColor : color_black);
			GUI::DrawText("rotation: " + segment.rotation.toString(), Vec2f(10, 150), selectedProperty == 4 ? selectedColor : color_black);
		}
	}

	Segment@ getSelectedSegment()
	{
		return model.getDescendant(selectedSegment);
	}

	void SelectSegment(string name)
	{
		if (model.hasDescendant(name))
		{
			selectedSegment = name;
			print("Selected segment: " + name);
		}
		else
		{
			warn("Cannot select nonexistent segment: " + name);
		}
	}

	void DeselectSegment()
	{
		selectedSegment = "";
	}

	bool isSegmentSelected()
	{
		return selectedSegment != "";
	}

	void CreateSegment(string name)
	{
		if (!model.hasDescendant(name))
		{
			Vec3f dim(1, 1, 1);
			Vec3f origin(0.5f, 0.5f, 0.5f);
			Segment segment(name, dim, origin);
			segment.GenerateVertices();
			model.AddChild(segment);
			print("Created segment: " + name);

			SelectSegment(name);
		}
		else
		{
			warn("Cannot create segment with name of existing segment: " + name);
		}
	}

	void RemoveSegment(string name)
	{
		Segment@ segment = model.getDescendant(name);
		if (segment !is null)
		{
			if (!segment.hasChildren())
			{
				model.RemoveDescendant(name);
				print("Removed segment: " + name);

				DeselectSegment();
			}
			else
			{
				warn("Cannot remove segment with children: " + name);
			}
		}
		else
		{
			warn("Cannot remove nonexistent segment: " + name);
		}
	}

	void AttachSegment(string childName, string parentName)
	{
		Segment@ child = model.getDescendant(childName);
		Segment@ parent = model.getDescendant(parentName);

		if (child !is null && parent !is null && child !is parent)
		{
			if (child.hasDescendant(parentName))
			{
				warn("Cannot attach '" + childName + "' to '" + parentName + "' because it leads to circular relationship");
				return;
			}

			Segment childCopy = child;

			Segment@ childParent = model.getParent(childName);
			if (childParent !is null)
			{
				childParent.RemoveChild(childName);
			}
			else
			{
				model.RemoveChild(childName);
			}

			parent.AddChild(childCopy);
			print("Attached '" + childName + "' to '" + parentName + "'");
			print("descendants: "+model.getDescendantCount());
		}
		else
		{
			warn("Cannot attach '" + childName + "' to '" + parentName + "'");
		}
	}

	void RenameSegment(string name, string newName)
	{
		Segment@ segment = model.getDescendant(name);
		if (segment !is null)
		{
			if (name == newName || !model.hasDescendant(newName))
			{
				segment.name = newName;
				print("Renamed segment: " + name + " -> " + newName);

				if (selectedSegment == name)
				{
					selectedSegment = newName;
				}
			}
			else
			{
				warn("Cannot rename segment to name of existing segment: " + name);
			}
		}
		else
		{
			warn("Cannot rename nonexistent segment: " + name);
		}
	}

	void SetSegmentUV(string name, int side, float x = 0, float y = 0, float w = 1, float h = 1)
	{
		Segment@ segment = model.getDescendant(name);
		if (segment !is null)
		{
			segment.SetUV(side, ImageUV(x, y, w, h));
			segment.GenerateVertices();
			print("Set " + directionNames[side] + " UV: " + name);
		}
		else
		{
			warn("Cannot set UV of nonexistent segment: " + name);
		}
	}

	void SetSkin(string skin)
	{
		model.SetSkin(skin);
		print("Set skin: " + skin);
	}

	void SaveModel(string filePath)
	{
		if (model.hasChildren())
		{
			ConfigFile cfg = ConfigFile();
			model.Serialize(cfg);
			cfg.saveFile(filePath);
			print("Saved model: " + filePath);
		}
	}

	void LoadModel(string filePath)
	{
		DeselectSegment();
		model.LoadModel(filePath);
	}

	private float divide(string str)
	{
		string[] vals = str.split("/");

		if (vals.length == 1)
		{
			return parseFloat(str);
		}

		float v1 = parseFloat(vals[0]);
		float v2 = parseFloat(vals[1]);
		return v1 / v2;
	}

	private void setAxis(Vec3f@ vec, string axis, float value)
	{
		if (axis == "x")
		{
			vec.x = value;
		}
		else if (axis == "y")
		{
			vec.y = value;
		}
		else if (axis == "z")
		{
			vec.z = value;
		}
	}

	void CommandHandler(string text)
	{
		string[] args = text.split(" ");
		string cmd = args[0].toLower();
		args.removeAt(0);

		if (cmd == "select")
		{
			if (args.length < 1) return;

			string name = args[0];
			SelectSegment(name);
		}
		else if (cmd == "create")
		{
			if (args.length < 1) return;

			string name = args[0];
			CreateSegment(name);
		}
		else if (cmd == "remove")
		{
			if (args.length < 1) return;

			string name = args[0];
			RemoveSegment(name);
		}
		else if (cmd == "attach")
		{
			if (args.length < 2) return;

			string child = args[0];
			string parent = args[1];
			AttachSegment(child, parent);
		}
		else if (cmd == "rename")
		{
			if (args.length < 2) return;

			string name = args[0];
			string newName = args[1];
			RenameSegment(name, newName);
		}
		else if (cmd == "origin")
		{
			if (args.length < 3) return;

			string name = args[0];
			string axis = args[1].toLower();
			float val = parseFloat(args[2]);

			Segment@ segment = model.getDescendant(name);
			if (segment !is null)
			{
				setAxis(@segment.origin, axis, val);
				segment.GenerateVertices();
				print("Set '" + name + "' origin." + axis + " to " + val);
			}
		}
		else if (cmd == "orbit")
		{
			if (args.length < 3) return;

			string name = args[0];
			string axis = args[1].toLower();
			float val = parseFloat(args[2]);

			Segment@ segment = model.getDescendant(name);
			if (segment !is null)
			{
				setAxis(@segment.orbit, axis, val);
				print("Set '" + name + "' orbit." + axis + " to " + val);
			}
		}
		else if (cmd == "offset")
		{
			if (args.length < 3) return;

			string name = args[0];
			string axis = args[1].toLower();
			float val = parseFloat(args[2]);

			Segment@ segment = model.getDescendant(name);
			if (segment !is null)
			{
				setAxis(@segment.offset, axis, val);
				print("Set '" + name + "' offset." + axis + " to " + val);
			}
		}
		else if (cmd == "rotation" || cmd == "rotate")
		{
			if (args.length < 3) return;

			string name = args[0];
			string axis = args[1].toLower();
			float val = parseFloat(args[2]);

			Segment@ segment = model.getDescendant(name);
			if (segment !is null)
			{
				setAxis(@segment.rotation, axis, val);
				print("Set '" + name + "' rotation." + axis + " to " + val);
			}
		}
		else if (cmd == "dim")
		{
			if (args.length < 3) return;

			string name = args[0];
			string axis = args[1].toLower();
			float val = parseFloat(args[2]);

			Segment@ segment = model.getDescendant(name);
			if (segment !is null)
			{
				setAxis(@segment.dim, axis, val);
				segment.GenerateVertices();
				print("Set '" + name + "' dim." + axis + " to " + val);
			}
		}
		else if (cmd == "uv")
		{
			if (args.length < 6) return;

			string name = args[0];
			int side = directionNames.find(args[1]);
			float x = divide(args[2]);
			float y = divide(args[3]);
			float w = divide(args[4]);
			float h = divide(args[5]);

			if (side > -1)
			{
				SetSegmentUV(name, side, x, y, w, h);
			}
		}
		else if (cmd == "skin")
		{
			if (args.length < 1) return;

			SetSkin(args[0]);
		}
		else if (cmd == "save")
		{
			if (args.length < 1) return;

			SaveModel(args[0]);
		}
		else if (cmd == "load")
		{
			if (args.length < 1) return;

			LoadModel(args[0]);
		}
	}
}
