namespace WorldServer.World.Scripting.Dungeons.WarpbladeTunnels;

using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001402)]
internal class GreySeerAdd : BasicScript
{
    public GreySeerAdd(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.SpeedInterface.Speed = 0;
        _unit.Movement.SetBaseSpeed(_unit.SpeedInterface.Speed);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2001371);
    }
}
