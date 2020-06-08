#include "Segment.as"

class SegmentChildren
{
	private Segment@[] children;

	SegmentChildren(string name, ConfigFile@ cfg)
	{
		Deserialize(name, cfg);
	}

	void AddChild(Segment@ segment)
	{
		if (!hasChild(segment.name))
		{
			children.push_back(segment);
		}
	}

	void RemoveChild(string name)
	{
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			if (child.name == name)
			{
				children.removeAt(i);
				return;
			}
		}
	}

	void RemoveDescendant(string name)
	{
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			if (child.name == name)
			{
				children.removeAt(i);
			}
			child.RemoveDescendant(name);
		}
	}

	void ClearChildren()
	{
		children.clear();
	}
	uint getChildCount()
	{
		return children.length;
	}

	uint getDescendantCount()
	{
		uint total = getChildCount();

		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			total += child.getDescendantCount();
		}

		return total;
	}

	void setChildren(Segment@[] children)
	{
		this.children = children;
	}

	Segment@[] getChildren()
	{
		return children;
	}

	Segment@[] getDescendants()
	{
		Segment@[] segments;

		getDescendants(@segments);

		return segments;
	}

	private void getDescendants(Segment@[]@ segments)
	{
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			segments.push_back(child);
			child.getDescendants(@segments);
		}
	}

	Segment@ getChild(string name)
	{
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			if (child.name == name)
			{
				return child;
			}
		}
		return null;
	}

	Segment@ getParent(string name)
	{
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ segment = children[i];
			Segment@ child = segment.getChild(name);

			if (child !is null)
			{
				return segment;
			}
			else
			{
				@segment = segment.getParent(name);
				if (segment !is null)
				{
					return segment;
				}
			}
		}

		return null;
	}

	Segment@ getDescendant(string name)
	{
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			if (child.name == name)
			{
				return child;
			}
			else
			{
				@child = child.getDescendant(name);
				if (child !is null)
				{
					return child;
				}
			}
		}
		return null;
	}

	bool hasChildren()
	{
		return !children.empty();
	}

	bool hasChild(string name)
	{
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			if (child.name == name)
			{
				return true;
			}
		}
		return false;
	}

	bool hasDescendant(string name)
	{
		for (uint i = 0; i < children.length; i++)
		{
			Segment@ child = children[i];
			if (child.name == name || child.hasDescendant(name))
			{
				return true;
			}
		}
		return false;
	}

	void Serialize(string name, ConfigFile@ cfg)
	{
		if (hasChildren())
		{
			string[] childrenNames;
			for (uint i = 0; i < children.length; i++)
			{
				Segment@ child = children[i];
				childrenNames.push_back(child.name);
				child.Serialize(cfg);
			}
			cfg.addArray_string(name + "_children", childrenNames);
		}
	}

	void Deserialize(string name, ConfigFile@ cfg)
	{
		string[] childrenNames;
		if (cfg.readIntoArray_string(childrenNames, name + "_children"))
		{
			for (uint i = 0; i < childrenNames.length; i++)
			{
				string name = childrenNames[i];
				Segment segment(name, cfg);
				children.push_back(segment);
			}
		}
	}
}
