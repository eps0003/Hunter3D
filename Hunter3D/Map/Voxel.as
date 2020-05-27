enum VoxelSide
{
	Left,
	Right,
	Down,
	Up,
	Front,
	Back
}

class Voxel
{
	Vec3f position;
	u8 type;
	u8 health;
	bool handPlaced;

	Voxel@[] neighbors;
	private uint vertexIndex;

	Voxel(Vec3f position, u8 type = 0)
	{
		this.position = position.floor();
		this.type = type;
		this.handPlaced = false;
		ResetHealth();
	}

	Voxel(u8 type = 0)
	{
		this.type = type;
		this.handPlaced = true;
		ResetHealth();
	}

	Voxel(CBitStream@ bs)
	{
		type = bs.read_u8();
		health = bs.read_u8();
		handPlaced = bs.read_bool();
	}

	bool opEquals(const Voxel &in voxel)
	{
		return (
			type == voxel.type &&
			health == voxel.health
		);
	}

	void opAssign(const Voxel &in voxel)
	{
		if (this != voxel && handPlaced)
		{
			//voxel placed. poof particles go here
		}

		type = voxel.type;
		health = voxel.health;
		handPlaced = voxel.handPlaced;
	}

	bool isVisible()
	{
		return type > 0;
	}

	bool isTransparent()
	{
		return !isVisible();
	}

	bool isSolid()
	{
		return isVisible();
	}

	bool isDestructable()
	{
		return isVisible();
	}

	bool isCollapsable()
	{
		return isVisible();
	}

	void ResetHealth()
	{
		health = 3;
	}

	void Damage(u8 damage)
	{
		health -= Maths::Max(0, health - damage);
		if (health <= 0)
		{
			Destroy();
		}
	}

	void Destroy()
	{
		type = 0;
		health = 0;

		//poof particles go here
	}

	private bool isVoxelTransparent(Voxel@ voxel)
	{
		return voxel is null || voxel.isTransparent();
	}

	void GenerateMesh(Chunk@ chunk, Vertex[]@ vertices)
	{
		if (!isVisible()) return;

		float x1 = 0;
		float y1 = 0;
		float x2 = 1;
		float y2 = 1;
		SColor col = SColor(255, type, 0, 0);
		bool allFaces = isTransparent();

		float o = 0.001f; //so faint lines dont appear between planes
		Vec3f p = position - Vec3f(o, o, o);
		float w = 1 + o * 2;

		vertexIndex = chunk.vertices.length;

		//add plane to array if neighbour is empty

		if (allFaces || isVoxelTransparent(neighbors[VoxelSide::Left]))
		{
			vertices.push_back(Vertex(p.x    , p.y + w, p.z + w, x1, y1, col));
			vertices.push_back(Vertex(p.x    , p.y + w, p.z    , x2, y1, col));
			vertices.push_back(Vertex(p.x    , p.y    , p.z    , x2, y2, col));
			vertices.push_back(Vertex(p.x    , p.y    , p.z + w, x1, y2, col));

			if (allFaces)
			{
				vertices.push_back(Vertex(p.x    , p.y + w, p.z    , x1, y1, col));
				vertices.push_back(Vertex(p.x    , p.y + w, p.z + w, x2, y1, col));
				vertices.push_back(Vertex(p.x    , p.y    , p.z + w, x2, y2, col));
				vertices.push_back(Vertex(p.x    , p.y    , p.z    , x1, y2, col));
			}
		}

		if (allFaces || isVoxelTransparent(neighbors[VoxelSide::Right]))
		{
			vertices.push_back(Vertex(p.x + w, p.y + w, p.z    , x1, y1, col));
			vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x2, y1, col));
			vertices.push_back(Vertex(p.x + w, p.y    , p.z + w, x2, y2, col));
			vertices.push_back(Vertex(p.x + w, p.y    , p.z    , x1, y2, col));

			if (allFaces)
			{
				vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x1, y1, col));
				vertices.push_back(Vertex(p.x + w, p.y + w, p.z    , x2, y1, col));
				vertices.push_back(Vertex(p.x + w, p.y    , p.z    , x2, y2, col));
				vertices.push_back(Vertex(p.x + w, p.y    , p.z + w, x1, y2, col));
			}
		}

		if (allFaces || isVoxelTransparent(neighbors[VoxelSide::Down]))
		{
			vertices.push_back(Vertex(p.x + w, p.y    , p.z + w, x1, y1, col));
			vertices.push_back(Vertex(p.x    , p.y    , p.z + w, x2, y1, col));
			vertices.push_back(Vertex(p.x    , p.y    , p.z    , x2, y2, col));
			vertices.push_back(Vertex(p.x + w, p.y    , p.z    , x1, y2, col));

			if (allFaces)
			{
				vertices.push_back(Vertex(p.x    , p.y    , p.z + w, x1, y1, col));
				vertices.push_back(Vertex(p.x + w, p.y    , p.z + w, x2, y1, col));
				vertices.push_back(Vertex(p.x + w, p.y    , p.z    , x2, y2, col));
				vertices.push_back(Vertex(p.x    , p.y    , p.z    , x1, y2, col));
			}
		}

		if (allFaces || isVoxelTransparent(neighbors[VoxelSide::Up]))
		{
			vertices.push_back(Vertex(p.x    , p.y + w, p.z + w, x1, y1, col));
			vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x2, y1, col));
			vertices.push_back(Vertex(p.x + w, p.y + w, p.z    , x2, y2, col));
			vertices.push_back(Vertex(p.x    , p.y + w, p.z    , x1, y2, col));

			if (allFaces)
			{
				vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x1, y1, col));
				vertices.push_back(Vertex(p.x    , p.y + w, p.z + w, x2, y1, col));
				vertices.push_back(Vertex(p.x    , p.y + w, p.z    , x2, y2, col));
				vertices.push_back(Vertex(p.x + w, p.y + w, p.z    , x1, y2, col));
			}
		}

		if (allFaces || isVoxelTransparent(neighbors[VoxelSide::Front]))
		{
			vertices.push_back(Vertex(p.x    , p.y + w, p.z    , x1, y1, col));
			vertices.push_back(Vertex(p.x + w, p.y + w, p.z    , x2, y1, col));
			vertices.push_back(Vertex(p.x + w, p.y    , p.z    , x2, y2, col));
			vertices.push_back(Vertex(p.x    , p.y    , p.z    , x1, y2, col));

			if (allFaces)
			{
				vertices.push_back(Vertex(p.x + w, p.y + w, p.z    , x1, y1, col));
				vertices.push_back(Vertex(p.x    , p.y + w, p.z    , x2, y1, col));
				vertices.push_back(Vertex(p.x    , p.y    , p.z    , x2, y2, col));
				vertices.push_back(Vertex(p.x + w, p.y    , p.z    , x1, y2, col));
			}
		}

		if (allFaces || isVoxelTransparent(neighbors[VoxelSide::Back]))
		{
			vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x1, y1, col));
			vertices.push_back(Vertex(p.x    , p.y + w, p.z + w, x2, y1, col));
			vertices.push_back(Vertex(p.x    , p.y    , p.z + w, x2, y2, col));
			vertices.push_back(Vertex(p.x + w, p.y    , p.z + w, x1, y2, col));

			if (allFaces)
			{
				vertices.push_back(Vertex(p.x    , p.y + w, p.z + w, x1, y1, col));
				vertices.push_back(Vertex(p.x + w, p.y + w, p.z + w, x2, y1, col));
				vertices.push_back(Vertex(p.x + w, p.y    , p.z + w, x2, y2, col));
				vertices.push_back(Vertex(p.x    , p.y    , p.z + w, x1, y2, col));
			}
		}
	}

	void FindNeighbors(Map@ map)
	{
		neighbors.set_length(6);

		@neighbors[VoxelSide::Left]  = map.getVoxel(Vec3f(position.x - 1, position.y    , position.z    ));
		@neighbors[VoxelSide::Right] = map.getVoxel(Vec3f(position.x + 1, position.y    , position.z    ));
		@neighbors[VoxelSide::Down]  = map.getVoxel(Vec3f(position.x    , position.y - 1, position.z    ));
		@neighbors[VoxelSide::Up]    = map.getVoxel(Vec3f(position.x    , position.y + 1, position.z    ));
		@neighbors[VoxelSide::Front] = map.getVoxel(Vec3f(position.x    , position.y    , position.z - 1));
		@neighbors[VoxelSide::Back]  = map.getVoxel(Vec3f(position.x    , position.y    , position.z + 1));
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(type);
		bs.write_u8(health);
		bs.write_bool(handPlaced);
	}

	void client_Sync()
	{
		CRules@ rules = getRules();
		CBitStream bs;
		bs.write_u16(getLocalPlayer().getNetworkID());
		position.Serialize(bs);
		Serialize(bs);
		rules.SendCommand(rules.getCommandID("client sync voxel"), bs, false);
	}
}
