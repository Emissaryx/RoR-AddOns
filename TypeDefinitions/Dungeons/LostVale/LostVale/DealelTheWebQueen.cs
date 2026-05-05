namespace WorldServer.World.Scripting.Dungeons.LostVale;

using Common.Enums.GameData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 6843)]
internal class DealelTheWebQueen : BasicCreatureScript
{
    public DealelTheWebQueen(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 3600;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 500, 0);
        obj.Tasks.AddTask(CheckForBuffsAround, 1000, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public void CheckForBuffsAround()
    {
        foreach (WorldObject o in _unit.ObjectsInRange)
        {
            if (o is Creature crea &&
                crea.Entry == 6806 &&
                !crea.IsDead &&
                crea.Abilities.HasBuffById(4378) &&
                _unit.IsWithin3DRadiusUnits(crea, 360))
            {
                _unit.Abilities.AddAbility(4375, _unit, _unit.EffectiveLevel);
            }
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }

        if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 5 && !_unit.IsDead) // At 20% HP he fails to summon anything
        {
            SpawnSpidersAndDoStuff();
            _unit.Tasks.AddTask(SpawnSpidersAndDoStuff, 15 * 1000, 1);
            _unit.Tasks.AddTask(SpawnSpidersAndDoStuff, 30 * 1000, 1);

            _stageNum = 5;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 4 && !_unit.IsDead)
        {
            SpawnSpidersAndDoStuff();
            _unit.Tasks.AddTask(SpawnSpidersAndDoStuff, 15 * 1000, 1);
            _unit.Tasks.AddTask(SpawnSpidersAndDoStuff, 30 * 1000, 1);

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 3 && !_unit.IsDead)
        {
            SpawnSpidersAndDoStuff();
            _unit.Tasks.AddTask(SpawnSpidersAndDoStuff, 15 * 1000, 1);
            _unit.Tasks.AddTask(SpawnSpidersAndDoStuff, 30 * 1000, 1);

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 2 && !_unit.IsDead)
        {
            SpawnSpidersAndDoStuff();
            _unit.Tasks.AddTask(SpawnSpidersAndDoStuff, 15 * 1000, 1);
            _unit.Tasks.AddTask(SpawnSpidersAndDoStuff, 30 * 1000, 1);

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total && _stageNum < 1 && !_unit.IsDead)
        {
            _stageNum = 1;
        }
    }

    public void SpawnSpidersAndDoStuff()
    {
        _unit.Abilities.AddAbility(4379, _unit, _unit.EffectiveLevel);

        if (!_unit.IsDead)
        {
            _adds.SpawnCreature(6806, new Point3D(1397181, 1561025, 6324), 1678);
            _adds.SpawnCreature(6806, new Point3D(1396218, 1562019, 6471), 1656);
            _adds.SpawnCreature(6806, new Point3D(1395819, 1561156, 6458), 576);
            _adds.SpawnCreature(6806, new Point3D(1395063, 1561960, 6475), 2342);
            _adds.SpawnCreature(6806, new Point3D(1394999, 1559858, 6182), 3454);
            _adds.SpawnCreature(6806, new Point3D(1395736, 1560180, 6174), 2798);
            _adds.SpawnCreature(6806, new Point3D(1397368, 1560091, 6193), 696);
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        obj.Tasks.RemoveTask(CheckForBuffsAround);

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature crea && crea.Entry == 6806)
            {
                crea.Destroy();
            }
        }

        _unit.Abilities.EndTargetAbilities((ushort)4379);
        _unit.Abilities.EndTargetAbilities((ushort)4377);
        _unit.Abilities.EndTargetAbilities((ushort)4375);
        _unit.Abilities.EndTargetAbilities((ushort)4378);

        _unit.Tasks.RemoveTask(SpawnSpidersAndDoStuff);
        _unit.Tasks.RemoveTask(SpawnSpidersAndDoStuff);
        _unit.Tasks.RemoveTask(SpawnSpidersAndDoStuff);
    }
}

[GeneralScript(CreatureEntry = 6806)]
internal class DealelAdd : BasicCreatureScript
{
    public DealelAdd(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.SendAggroUpdate = false;

        _creature.AiInterface.AllowThinking = false;
        _creature.AiInterface.ResetSpeedAtCombatStart = false;

        // c.SpeedInterface.Speed = 10;
        // c.MvtInterface.SetBaseSpeed(c.StsInterface.Speed);
        _creature.Tasks.AddTask(CheckTargetAndCast, 1000, 0);

        _creature.AddCrowdControlImmunity(CrowdControlTypes.Disabled);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Disarm);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Knockdown);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Root);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Silence);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Stagger);

        base.OnObjectLoad(obj);
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        DelayedBuff(_creature, 60009); // NPC Slow Move

        DelayedBuff(_creature, 402); // NPC Slow Move

        DelayedBuff(_creature, 403); // NPC Slow Move

        DelayedBuff(_creature, 408); // NPC Slow Move

        GoToMommy(6843); // Here is mommy...
    }

    public void CheckTargetAndCast()
    {
        foreach (WorldObject o in _creature.ObjectsInRange)
        {
            if (o is Creature crea && !crea.IsDead && crea.Entry == 6843 && _unit.IsWithin3DRadiusUnits(crea, 360))
            {
                _creature.AbilityCast.StartCast(4377, 0);

                crea.Abilities.AddAbility(4375, crea, crea.EffectiveLevel);

                _creature.Tasks.AddTask(_creature.Destroy, 100, 1);

                break;
            }
        }
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        obj.PlayEffect(1847);
        obj.Destroy();
    }
}
