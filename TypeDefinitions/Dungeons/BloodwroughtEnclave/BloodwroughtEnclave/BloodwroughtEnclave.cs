namespace WorldServer.World.Scripting.Dungeons.BloodwroughtEnclave;

using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001410)]
internal class BloodwroughtDoorNpc1 : BasicScript
{
    public BloodwroughtDoorNpc1(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(() => _adds.SpawnGameObject(2000795, new Point3D(1570002, 1049449, 11116), 0), 5000, 1); // Door
    }
}
