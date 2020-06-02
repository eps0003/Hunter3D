#include "ModelSegment.as"
#include "Vec3f.as"
#include "Camera.as"
#include "Utilities.as"

class ModelBuilder
{
	private dictionary segments;
	private string skin = "pixel";
	private string selectedSegment;
	private uint selectedProperty = 0;
	private uint selectedAxis = 0;

	void Update()
	{
		CControls@ controls = getControls();

		if (controls.isKeyJustPressed(KEY_UP))
		{
			if (selectedProperty > 0)
			{
				selectedProperty--;
			}
			else
			{
				selectedProperty = 4;
			}
		}

		if (controls.isKeyJustPressed(KEY_DOWN))
		{
			if (selectedProperty < 4)
			{
				selectedProperty++;
			}
			else
			{
				selectedProperty = 0;
			}
		}

		if (controls.isKeyJustPressed(KEY_LEFT))
		{
			if (selectedAxis > 0)
			{
				selectedAxis--;
			}
			else
			{
				selectedAxis = 2;
			}
		}

		if (controls.isKeyJustPressed(KEY_RIGHT))
		{
			if (selectedAxis < 2)
			{
				selectedAxis++;
			}
			else
			{
				selectedAxis = 0;
			}
		}
	}

	void RenderModel()
	{
		if (hasSegments())
		{
			ModelSegment@ base = getSegment("base");
			Vec3f camPos = getCamera3D().getParent().interPosition;

			float[] matrix;
			Matrix::MakeIdentity(matrix);
			Matrix::SetTranslation(matrix, -camPos.x, -camPos.y, -camPos.z);

			Render::SetBackfaceCull(false);
			base.Render(skin, matrix);
			Render::SetBackfaceCull(true);
		}
	}

	void RenderGUI()
	{
		if (isSegmentSelected())
		{
			ModelSegment@ segment = getSelectedSegment();
			SColor selectedColor(255, 255, 0, 0);
			SColor color = color_black;

			//name
			GUI::DrawText("name: " + segment.name, Vec2f(10,  50), color_black);

			//properties
			GUI::DrawText("dim:",      Vec2f(10,  70), color_black);
			GUI::DrawText("origin:",   Vec2f(10,  90), color_black);
			GUI::DrawText("orbit:",    Vec2f(10, 110), color_black);
			GUI::DrawText("offset:",   Vec2f(10, 130), color_black);
			GUI::DrawText("rotation:", Vec2f(10, 150), color_black);

			//x-axis
			color = selectedAxis == 0 ? selectedColor : color_black;
			GUI::DrawText("" + segment.dim.x,      Vec2f(100,  70), selectedProperty == 0 ? color : color_black);
			GUI::DrawText("" + segment.origin.x,   Vec2f(100,  90), selectedProperty == 1 ? color : color_black);
			GUI::DrawText("" + segment.orbit.x,    Vec2f(100, 110), selectedProperty == 2 ? color : color_black);
			GUI::DrawText("" + segment.offset.x,   Vec2f(100, 130), selectedProperty == 3 ? color : color_black);
			GUI::DrawText("" + segment.rotation.x, Vec2f(100, 150), selectedProperty == 4 ? color : color_black);

			//y-axis
			color = selectedAxis == 1 ? selectedColor : color_black;
			GUI::DrawText("" + segment.dim.y,      Vec2f(160,  70), selectedProperty == 0 ? color : color_black);
			GUI::DrawText("" + segment.origin.y,   Vec2f(160,  90), selectedProperty == 1 ? color : color_black);
			GUI::DrawText("" + segment.orbit.y,    Vec2f(160, 110), selectedProperty == 2 ? color : color_black);
			GUI::DrawText("" + segment.offset.y,   Vec2f(160, 130), selectedProperty == 3 ? color : color_black);
			GUI::DrawText("" + segment.rotation.y, Vec2f(160, 150), selectedProperty == 4 ? color : color_black);

			//y-axis
			color = selectedAxis == 2 ? selectedColor : color_black;
			GUI::DrawText("" + segment.dim.z,      Vec2f(220,  70), selectedProperty == 0 ? color : color_black);
			GUI::DrawText("" + segment.origin.z,   Vec2f(220,  90), selectedProperty == 1 ? color : color_black);
			GUI::DrawText("" + segment.orbit.z,    Vec2f(220, 110), selectedProperty == 2 ? color : color_black);
			GUI::DrawText("" + segment.offset.z,   Vec2f(220, 130), selectedProperty == 3 ? color : color_black);
			GUI::DrawText("" + segment.rotation.z, Vec2f(220, 150), selectedProperty == 4 ? color : color_black);

			// GUI::DrawText("name: "     + segment.name,                Vec2f(10,  50), color_black);
			// GUI::DrawText("dim: "      + segment.dim.toString(),      Vec2f(10,  70), selectedProperty == 0 ? selectedColor : color_black);
			// GUI::DrawText("origin: "   + segment.origin.toString(),   Vec2f(10,  90), selectedProperty == 1 ? selectedColor : color_black);
			// GUI::DrawText("orbit: "    + segment.orbit.toString(),    Vec2f(10, 110), selectedProperty == 2 ? selectedColor : color_black);
			// GUI::DrawText("offset: "   + segment.offset.toString(),   Vec2f(10, 130), selectedProperty == 3 ? selectedColor : color_black);
			// GUI::DrawText("rotation: " + segment.rotation.toString(), Vec2f(10, 150), selectedProperty == 4 ? selectedColor : color_black);
		}
	}

	ModelSegment@ getSelectedSegment()
	{
		return getSegment(selectedSegment);
	}

	void SelectSegment(string name)
	{
		if (segmentExists(name))
		{
			selectedSegment = name;
			print("Selected segment: " + name);
		}
		else
		{
			print("Cannot select segment: " + name);
		}
	}

	bool isSegmentSelected()
	{
		return selectedSegment != "";
	}

	void CreateSegment(string name)
	{
		if (!segmentExists(name))
		{
			Vec3f dim(1, 1, 1);
			Vec3f origin(0.5f, 0.5f, 0.5f);
			ModelSegment segment(name, dim, origin);
			segment.GenerateVertices();

			segments.set(name, segment);
			print("Created segment: " + name);
		}
		else
		{
			print("Cannot create segment: " + name);
		}
	}

	void RemoveSegment(string name)
	{
		ModelSegment@ segment = getSegment(name);
		if (segment !is null)
		{
			if (!segment.hasChildren())
			{
				segments.delete(name);
				print("Removed segment: " + name);
			}
			else
			{
				print("Cannot remove segment with children: " + name);
			}
		}
		else
		{
			print("Cannot remove unknown segment: " + name);
		}
	}

	void ClearSegments()
	{
		segments.deleteAll();
		print("Cleared segments");
	}

	ModelSegment@ getSegment(string name)
	{
		ModelSegment@ segment;
		if (segments.get(name, @segment))
		{
			return segment;
		}
		print("Segment not found: " + name);
		return null;
	}

	void AttachSegment(string childName, string parentName)
	{
		ModelSegment@ child = getSegment(childName);
		ModelSegment@ parent = getSegment(parentName);

		if (child !is null && parent !is null && child !is parent)
		{
			//prevent parent-child loop
			child.RemoveChild(parent);

			parent.AddChild(child);
			print("Attached '" + childName + "' to '" + parentName + "'");
		}
		else
		{
			print("Cannot attach '" + childName + "' to '" + parentName + "'");
		}
	}

	void SetSegmentUV(string name, int side, float x = 0, float y = 0, float w = 1, float h = 1)
	{
		ModelSegment@ segment = getSegment(name);
		if (segment !is null)
		{
			segment.SetUV(side, ImageUV(x, y, w, h));
			segment.GenerateVertices();
			print("Set " + directionNames[side] + " UV: " + name);
		}
		else
		{
			print("Cannot set " + directionNames[side] + " UV: " + name);
		}
	}

	void SetSkin(string skin)
	{
		this.skin = skin;
		print("Set skin: " + skin);
	}

	void SaveModel(string filePath)
	{
		if (hasSegments())
		{
			ConfigFile cfg = ConfigFile();

			//serialize model
			getSegment("base").Serialize(cfg);

			cfg.saveFile(filePath);
			print("Saved model: " + filePath);
		}
	}

	void LoadModel(string filePath)
	{
		ConfigFile cfg = ConfigFile();
		if (cfg.loadFile(filePath))
		{
			ClearSegments();

			//deserialize model
			ModelSegment@ segment = ModelSegment("base", cfg);
			segments.set("base", segment);
			print("Loaded model: " + filePath);
		}
		else
		{
			print("Cannot load model: " + filePath);
		}
	}

	private bool segmentExists(string name)
	{
		return segments.exists(name);
	}

	private bool hasSegments()
	{
		return segments.getSize() > 0;
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
		else if (cmd == "origin")
		{
			if (args.length < 3) return;

			string name = args[0];
			string axis = args[1].toLower();
			float val = parseFloat(args[2]);

			ModelSegment@ segment = getSegment(name);
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

			ModelSegment@ segment = getSegment(name);
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

			ModelSegment@ segment = getSegment(name);
			if (segment !is null)
			{
				setAxis(@segment.offset, axis, val);
				print("Set '" + name + "' offset." + axis + " to " + val);
			}
		}
		else if (cmd == "rotation")
		{
			if (args.length < 3) return;

			string name = args[0];
			string axis = args[1].toLower();
			float val = parseFloat(args[2]);

			ModelSegment@ segment = getSegment(name);
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

			ModelSegment@ segment = getSegment(name);
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

			string filePath = args[0];
			SaveModel(filePath);
		}
		else if (cmd == "load")
		{
			if (args.length < 1) return;

			string filePath = args[0];
			LoadModel(filePath);
		}
	}
}
