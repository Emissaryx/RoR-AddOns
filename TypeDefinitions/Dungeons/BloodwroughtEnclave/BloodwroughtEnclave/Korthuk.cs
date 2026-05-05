namespace WorldServer.World.Scripting.Dungeons.BloodwroughtEnclave;

using Common.Enums.GameData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2000757)]
internal class Korthuk : BasicCreatureScript
{
    public Korthuk(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 840;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        base.OnEnterCombat(owner, attacker);

        SpawnBloodwroughtWalls();

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        DestroyGameObjectInRegion(2000795);

        AddInfluenceToAllPlayersInRegion(200, 1000);
        AddInfluenceToAllPlayersInRegion(201, 1000);

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.25 && _stageNum < 3 && !_unit.IsDead)
        {
            SpawnGOs25();

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.5 && _stageNum < 2 && !_unit.IsDead)
        {
            SpawnGOs50();

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.75 && _stageNum < 1 && !_unit.IsDead)
        {
            SpawnGOs75();

            _stageNum = 1;
        }
    }

    public void SpawnGOs75()
    {
        _adds.SpawnGameObject(2000781, new Point3D(1576758, 1046434, 11076), 0);

        _adds.SpawnGameObject(100547, new Point3D(1576788, 1046057, 11078), 0);

        _adds.SpawnGameObject(100548, new Point3D(1576199, 1046918, 11189), 0);
    }

    public void SpawnGOs50()
    {
        _adds.SpawnGameObject(2000781, new Point3D(1576131, 1046015, 11123), 0);

        _adds.SpawnGameObject(100547, new Point3D(1576384, 1045448, 11203), 0);

        _adds.SpawnGameObject(100548, new Point3D(1576522, 1045831, 11087), 0);
    }

    public void SpawnGOs25()
    {
        _adds.SpawnGameObject(2000781, new Point3D(1577030, 1045770, 11087), 0);

        _adds.SpawnGameObject(100547, new Point3D(1576655, 1046712, 11089), 0);

        _adds.SpawnGameObject(100548, new Point3D(1576193, 1046452, 11114), 0);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2000758);
        SetRandomTargetToNpc(2000759);
    }
}

[GeneralScript(GameObjectEntry = 2000781)]
internal class KorthukGo1 : BasicGameObjectScript
{
    public KorthukGo1(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.NoRespawn = true;

        _adds.SpawnCreature(2001398, obj.WorldPosition, obj.Heading);
    }

    public override void OnDie(Unit obj)
    {
        foreach (WorldObject? o in obj.Region.Objects.ToList())
        {
            if (o is Creature c && c.Entry == 2001398)
            {
                c.Destroy();
                break;
            }
        }

        base.OnDie(obj);
    }
}

[GeneralScript(GameObjectEntry = 100547)]
internal class KorthukGo2 : BasicGameObjectScript
{
    public KorthukGo2(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.NoRespawn = true;
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        _adds.SpawnCreature(2001397, obj.WorldPosition, obj.Heading);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        GetCreatureFromRegion(2001397)?.Destroy();
    }
}

[GeneralScript(GameObjectEntry = 100548)]
internal class KorthukGo3 : BasicGameObjectScript
{
    public KorthukGo3(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.NoRespawn = true;
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        _adds.SpawnCreature(2001399, obj.WorldPosition, obj.Heading);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        GetCreatureFromRegion(2001399)?.Destroy();
    }
}

[GeneralScript(CreatureEntry = 2000758)]
internal class KorthukNpc1 : BasicCreatureScript
{
    public KorthukNpc1(Unit unit)
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

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2000757);
        SetRandomTargetToNpc(2000759);
    }
}

[GeneralScript(CreatureEntry = 2000759)]
internal class KorthukNpc2 : BasicCreatureScript
{
    public KorthukNpc2(Unit unit)
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

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2000758);
        SetRandomTargetToNpc(2000757);
    }
}

[GeneralScript(CreatureEntry = 2001398)]
internal class SomeNpc1 : BasicScript
{
    public SomeNpc1(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.SpeedInterface.Speed = 0;
        _unit.Movement.SetBaseSpeed(_unit.SpeedInterface.Speed);

        _unit.Tasks.AddTask(DCast, 100, 1);
        _unit.Tasks.AddTask(DCast, 20 * 1000, 0);
    }

    public void DCast()
    {
        _unit.AbilityCast.StartCast(5558, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(DCast);

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(DCast);

        if (obj.Region is not null)
        {
            foreach (WorldObject? o in obj.Region.Objects.ToList())
            {
                if (o is GameObject go && go.Entry == 2000781 && go.VfxState == 0)
                {
                    go.VfxState = 1;
                    go.SendMeTo();
                }
            }
        }

        base.OnDie(obj);
    }
}

[GeneralScript(CreatureEntry = 2001397)]
internal class SomeNpc2 : BasicScript
{
    public SomeNpc2(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.SpeedInterface.Speed = 0;
        _unit.Movement.SetBaseSpeed(_unit.SpeedInterface.Speed);

        _unit.Tasks.AddTask(DCast, 100, 1);
        _unit.Tasks.AddTask(DCast, 15 * 1000, 0);
    }

    public void DCast()
    {
        _unit.AbilityCast.StartCast(5562, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit?.Tasks.RemoveTask(DCast);

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(DCast);
        if (obj.Region is not null)
        {
            foreach (WorldObject? o in obj.Region.Objects.ToList())
            {
                if (o is GameObject go && go.Entry == 100547 && go.VfxState == 0)
                {
                    go.VfxState = 1;
                    go.SendMeTo();
                }
            }
        }

        base.OnDie(obj);
    }
}

[GeneralScript(CreatureEntry = 2001399)]
internal class SomeNpc3 : BasicScript
{
    public SomeNpc3(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.SpeedInterface.Speed = 0;
        _unit.Movement.SetBaseSpeed(_unit.SpeedInterface.Speed);

        _unit.Tasks.AddTask(DCast, 100, 1);
        _unit.Tasks.AddTask(DCast, 15 * 1000, 0);
    }

    public void DCast()
    {
        _unit.AbilityCast.StartCast(5563, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(DCast);

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(DCast);
        if (obj.Region is not null)
        {
            foreach (WorldObject? o in obj.Region.Objects.ToList())
            {
                if (o is GameObject go && go.Entry == 100548 && go.VfxState == 0)
                {
                    go.VfxState = 1;
                    go.SendMeTo();
                }
            }
        }

        base.OnDie(obj);
    }
}
