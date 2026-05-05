namespace Game.Scripts.Dungeons.ICSacellum;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(GameObjectEntry = 2000773)]
internal class MobPuller1 : BasicScript
{
    public MobPuller1(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }

    public override void OnEnterRange(WorldObject obj, WorldObject distObj)
    {
        if (distObj is Player)
        {
            obj.Tasks.AddTask(CheckRange, 1000, 0);
        }
    }

    public void CheckRange()
    {
        foreach (Player plr in _unit.PlayersInRange)
        {
            if (_unit.IsWithin3DRadiusUnits(plr, 360))
            {
                foreach (WorldObject o in _unit.ObjectsInRange)
                {
                    if (o is GameObject g && g.Entry == 2000775)
                    {
                        g.VfxState = 1;
                    }

                    if (
                        o is Creature c
                        && c.Entry == 33178
                        && !c.IsDead
                        && !c.CombatFlag.IsInCombat
                        && _unit.IsWithin3DRadiusUnits(o, 1560)
                    )
                    {
                        c.Movement.Move(_unit.WorldSpawnPoint);
                    }
                }

                break;
            }
        }
    }

    public override void OnLeaveRange(WorldObject obj, WorldObject distObj)
    {
        if (distObj is Player)
        {
            obj.Tasks.RemoveTask(CheckRange);
        }
    }
}

[GeneralScript(GameObjectEntry = 2000774)]
internal class MobPuller2 : BasicScript
{
    public MobPuller2(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }

    public override void OnEnterRange(WorldObject obj, WorldObject distObj)
    {
        if (distObj is Player)
        {
            obj.Tasks.AddTask(CheckRange, 1000, 0);
        }
    }

    public void CheckRange()
    {
        foreach (Player plr in _unit.PlayersInRange)
        {
            if (_unit.IsWithin3DRadiusUnits(plr, 360))
            {
                foreach (WorldObject o in _unit.ObjectsInRange)
                {
                    if (o is GameObject g && g.Entry == 2000776)
                    {
                        g.VfxState = 1;
                    }

                    if (
                        o is Creature c
                        && c.Entry == 33178
                        && !c.IsDead
                        && !c.CombatFlag.IsInCombat
                        && _unit.IsWithin3DRadiusUnits(o, 1560)
                    )
                    {
                        c.Movement.Move(_unit.WorldSpawnPoint);
                    }
                }

                break;
            }
        }
    }

    public override void OnLeaveRange(WorldObject obj, WorldObject distObj)
    {
        if (distObj is Player)
        {
            obj.Tasks.RemoveTask(CheckRange);
        }
    }
}
