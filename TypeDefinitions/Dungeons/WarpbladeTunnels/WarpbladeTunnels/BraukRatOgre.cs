namespace WorldServer.World.Scripting.Dungeons.WarpbladeTunnels;

using Common.Enums.GameData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001370)]
internal class BraukRatOgre : BasicCreatureScript
{
    public BraukRatOgre(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        if (_unit is Creature)
        {
            _stageNum = -1;
        }
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        foreach (WorldObject objInRange in obj.ObjectsInRange)
        {
            if (objInRange is Creature creature && creature.Entry == 2001369)
            {
                DelayedBuff(creature, 13711, "You will die-die for this-this!"); // Rage
            }
        }

        base.OnDie(obj);
    }
}
