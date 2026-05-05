namespace WorldServer.World.Scripting.Dungeons.LostVale;

using Common.Enums.GameData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 62147)]
internal class Nkari : BasicCreatureScript
{
    public Nkari(Unit unit)
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

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }

        if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 5 && !_unit.IsDead) // At 20% HP he fails to summon anything
        {
            SpawnNpCs();

            _stageNum = 5;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 4 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 3 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 2 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total && _stageNum < 1 && !_unit.IsDead)
        {
            _stageNum = 1;
        }
    }

    public void SpawnNpCs()
    {
        _adds.SpawnCreature(123543, _unit.WorldPosition, _unit.Heading);
        _adds.SpawnCreature(123542, _unit.WorldPosition, _unit.Heading);
        _adds.SpawnCreature(123544, _unit.WorldPosition, _unit.Heading);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        _unit.Tasks.RemoveTask(SpawnNpCs);

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature crea && (crea.Entry == 123543 || crea.Entry == 123542 || crea.Entry == 123544))
            {
                crea.Destroy();
            }
        }

        foreach (Player plr in _unit.Region.Players)
        {
            plr.Abilities.EndTargetAbilities((ushort)5428);
            plr.Abilities.EndTargetAbilities((ushort)5429);
            plr.Abilities.EndTargetAbilities((ushort)5430);
        }
    }
}

[GeneralScript(CreatureEntry = 123543)]
internal class NkariNpc1 : BasicCreatureScript
{
    public NkariNpc1(Unit unit)
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
        _creature.Tasks.AddTask(CheckPlayerAndCast, 500, 0);

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
        DelayedBuff(_unit, 5431); // NPC Slow Move

        GoToCoordinates();
    }

    public virtual void GoToCoordinates()
    {
        Point3D destination = new()
        {
            X = 1432694,
            Y = 1547672,
            Z = 11006,
        };

        _creature.Movement.TurnTo(destination);
        _creature.Movement.Move(destination);
    }

    public void CheckPlayerAndCast()
    {
        Point3D destination = new()
        {
            X = 1432694,
            Y = 1547672,
            Z = 11006,
        };

        if (_creature.WorldPosition.IsWithin3DRadiusUnits(destination, 60))
        {
            foreach (Player plr in _unit.PlayersInRange)
            {
                if (plr is not null && !plr.IsDead && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted) &&
                    !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked) && plr.Stealth.StealthLevel < 2 &&
                    _unit.IsWithin3DRadiusUnits(plr, 60) && plr.Abilities.HasBuffById(5436))
                {
                    plr.Abilities.AddAbility(5428, plr, plr.EffectiveLevel);

                    _creature.Tasks.AddTask(_creature.Destroy, 100, 1);

                    break;
                }
            }
        }
    }
}

[GeneralScript(CreatureEntry = 123542)]
internal class NkariNpc2 : BasicCreatureScript
{
    public NkariNpc2(Unit unit)
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
        _creature.Tasks.AddTask(CheckPlayerAndCast, 500, 0);

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
        DelayedBuff(_unit, 5431); // NPC Slow Move

        GoToCoordinates();
    }

    public virtual void GoToCoordinates()
    {
        Point3D destination = new()
        {
            X = 1432578,
            Y = 1547549,
            Z = 11004,
        };

        _creature.Movement.TurnTo(destination);
        _creature.Movement.Move(destination);
    }

    public void CheckPlayerAndCast()
    {
        Point3D destination = new()
        {
            X = 1432578,
            Y = 1547549,
            Z = 11004,
        };

        if (_creature.WorldPosition.IsWithin3DRadiusUnits(destination, 60))
        {
            foreach (Player plr in _unit.PlayersInRange)
            {
                if (plr is not null && !plr.IsDead && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted) &&
                    !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked) && plr.Stealth.StealthLevel < 2 &&
                    _unit.IsWithin3DRadiusUnits(plr, 60) && !plr.Abilities.HasBuffById(5438))
                {
                    plr.Abilities.AddAbility(5430, plr, plr.EffectiveLevel);

                    _creature.Tasks.AddTask(_creature.Destroy, 100, 1);

                    break;
                }
            }
        }
    }
}

[GeneralScript(CreatureEntry = 123544)]
internal class NkariNpc3 : BasicCreatureScript
{
    public NkariNpc3(Unit unit)
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
        _creature.Tasks.AddTask(CheckPlayerAndCast, 500, 0);

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
        DelayedBuff(_unit, 5431); // NPC Slow Move

        GoToCoordinates();
    }

    public virtual void GoToCoordinates()
    {
        Point3D destination = new()
        {
            X = 1432890,
            Y = 1547588,
            Z = 11000,
        };

        _unit.Movement.TurnTo(destination);
        _unit.Movement.Move(destination);
    }

    public void CheckPlayerAndCast()
    {
        Point3D destination = new()
        {
            X = 1432890,
            Y = 1547588,
            Z = 11000,
        };

        if (_creature.WorldPosition.IsWithin3DRadiusUnits(destination, 60))
        {
            foreach (Player plr in _unit.PlayersInRange)
            {
                if (plr is not null && !plr.IsDead && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted) &&
                    !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked) && plr.Stealth.StealthLevel < 2 &&
                    _unit.IsWithin3DRadiusUnits(plr, 60) && !plr.Abilities.HasBuffById(5437))
                {
                    plr.Abilities.AddAbility(5429, plr, plr.EffectiveLevel);

                    _unit.Tasks.AddTask(_unit.Destroy, 100, 1);

                    break;
                }
            }
        }
    }
}
