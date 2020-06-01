#include "Utilities.as"

class Voxel
{
	u8 type;
	u8 health;
	bool handPlaced;

	Voxel@[] neighbors;
	private uint vertexIndex;

	Voxel()
	{
		this.type = 0;
		this.handPlaced = false;
		ResetHealth();
	}

	Voxel(u8 type, bool handPlaced = false)
	{
		this.type = type;
		this.handPlaced = handPlaced;
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

	void GenerateMesh(Chunk@ chunk, Vec3f worldPos, Vertex[]@ vertices)
	{
		if (!isVisible()) return;

		float x1 = 0;
		float y1 = 0;
		float x2 = 1;
		float y2 = 1;
		SColor col = SColor(255, type, 0, 0);
		bool allFaces = isTransparent();

		float o = 0.001f; //so faint lines dont appear between planes
		Vec3f p = worldPos - Vec3f(o, o, o);
		float w = 1 + o * 2;

		vertexIndex = chunk.vertices.length;

		//add plane to array if neighbour is empty

		if (allFaces || isVoxelTransparent(neighbors[Direction::Left]))
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

		if (allFaces || isVoxelTransparent(neighbors[Direction::Right]))
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

		if (allFaces || isVoxelTransparent(neighbors[Direction::Down]))
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

		if (allFaces || isVoxelTransparent(neighbors[Direction::Up]))
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

		if (allFaces || isVoxelTransparent(neighbors[Direction::Front]))
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

		if (allFaces || isVoxelTransparent(neighbors[Direction::Back]))
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

	void FindNeighbors(Map@ map, Vec3f worldPos)
	{
		neighbors.set_length(6);

		@neighbors[Direction::Left]  = map.getVoxel(Vec3f(worldPos.x - 1, worldPos.y    , worldPos.z    ));
		@neighbors[Direction::Right] = map.getVoxel(Vec3f(worldPos.x + 1, worldPos.y    , worldPos.z    ));
		@neighbors[Direction::Down]  = map.getVoxel(Vec3f(worldPos.x    , worldPos.y - 1, worldPos.z    ));
		@neighbors[Direction::Up]    = map.getVoxel(Vec3f(worldPos.x    , worldPos.y + 1, worldPos.z    ));
		@neighbors[Direction::Front] = map.getVoxel(Vec3f(worldPos.x    , worldPos.y    , worldPos.z - 1));
		@neighbors[Direction::Back]  = map.getVoxel(Vec3f(worldPos.x    , worldPos.y    , worldPos.z + 1));
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(type);
		bs.write_u8(health);
		bs.write_bool(handPlaced);
	}

	void client_Sync(Vec3f worldPos)
	{
		CRules@ rules = getRules();
		CBitStream bs;
		bs.write_u16(getLocalPlayer().getNetworkID());
		worldPos.Serialize(bs);
		Serialize(bs);
		rules.SendCommand(rules.getCommandID("c_sync_voxel"), bs, false);
	}

	void server_Sync(Vec3f worldPos, CPlayer@ player)
	{
		CRules@ rules = getRules();
		CBitStream bs;
		bs.write_u16(player.getNetworkID());
		worldPos.Serialize(bs);
		Serialize(bs);
		rules.SendCommand(rules.getCommandID("s_sync_voxel"), bs, true);
	}
}
