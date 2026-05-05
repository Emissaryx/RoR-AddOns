namespace WorldServer.World.Scripting.Dungeons.WarpbladeTunnels;

using Common.Enums.GameData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001406)]
internal class DoorNpc2 : BasicScript
{
    public DoorNpc2(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(() => _adds.SpawnGameObject(2000788, new Point3D(1596892, 210312, 8218), 22), 5000, 1); // Door

        _unit.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
    }
}
