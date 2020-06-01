#include "ModelSegment.as"
#include "Vec3f.as"
#include "Camera.as"
#include "Utilities.as"

class ModelBuilder
{
	private dictionary segments;
	private string baseSegment;
	private string skin = "pixel";

	void Render()
	{
		if (hasSegments())
		{
			ModelSegment@ base = getSegment(baseSegment);
			Vec3f camPos = getCamera3D().getParent().interPosition;

			float[] matrix;
			Matrix::MakeIdentity(matrix);
			Matrix::SetTranslation(matrix, -camPos.x, -camPos.y, -camPos.z);

			Render::SetBackfaceCull(false);
			base.Render(skin, matrix);
			Render::SetBackfaceCull(true);
		}
	}

	void CreateSegment(string name)
	{
		if (!segmentExists(name))
		{
			Vec3f dim(1, 1, 1);
			Vec3f origin(0.5f, 0.5f, 0.5f);
			ModelSegment segment(name, dim, origin);
			segment.GenerateVertices();

			if (!hasSegments())
			{
				baseSegment = name;
			}

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

				if (!hasSegments())
				{
					baseSegment = "";
				}
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

			if (childName == baseSegment)
			{
				baseSegment = parentName;
			}

			parent.AddChild(child);
			print("Attached '" + childName + "' to '" + parentName + "'");
		}
		else
		{
			print("Cannot attach '" + childName + "' to '" + parentName + "'");
		}
	}

	void SetSegmentOrbit(string name, float x = 0, float y = 0, float z = 0)
	{
		ModelSegment@ segment = getSegment(name);
		if (segment !is null)
		{
			segment.orbit = Vec3f(x, y, z);
			print("Set orbit: " + name);
			segment.orbit.Print();
		}
		else
		{
			print("Cannot set orbit: " + name);
		}
	}

	void SetSegmentOffset(string name, float x = 0, float y = 0, float z = 0)
	{
		ModelSegment@ segment = getSegment(name);
		if (segment !is null)
		{
			segment.offset = Vec3f(x, y, z);
			print("Set offset: " + name);
			segment.offset.Print();
		}
		else
		{
			print("Cannot set offset: " + name);
		}
	}

	void SetSegmentRotation(string name, float x = 0, float y = 0, float z = 0)
	{
		ModelSegment@ segment = getSegment(name);
		if (segment !is null)
		{
			segment.rotation = Vec3f(x, y, z);
			print("Set rotation: " + name);
			segment.rotation.Print();
		}
		else
		{
			print("Cannot set rotation: " + name);
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
	}

	void SaveModel(string filePath)
	{
		if (hasSegments())
		{
			ConfigFile cfg = ConfigFile();

			//serialize model
			cfg.add_string("base_segment", baseSegment);
			getSegment(baseSegment).Serialize(cfg);

			cfg.saveFile(filePath);
			print("Saved model: " + filePath);
		}
	}

	void LoadModel(string filePath)
	{
		ConfigFile cfg = ConfigFile();
		if (cfg.loadFile(filePath) && cfg.exists("base_segment"))
		{
			ClearSegments();

			//deserialize model
			baseSegment = cfg.read_string("base_segment");
			segments.set(baseSegment, ModelSegment(baseSegment, cfg));
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

		if (cmd == "create")
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
		else if (cmd == "uv")
		{
			if (args.length < 6) return;

			string name = args[0];
			int side = directionLetters.find(args[1]);
			float x = parseFloat(args[2]);
			float y = parseFloat(args[3]);
			float w = parseFloat(args[4]);
			float h = parseFloat(args[5]);

			if (side > 0)
			{
				SetSegmentUV(name, side, x, y, w, h);
			}
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
