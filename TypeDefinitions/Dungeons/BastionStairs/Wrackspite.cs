namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 16078)]
internal class Wrackspite : BasicCreatureScript
{
    public const ushort SkullruinLikeness = 13815;
    public const ushort Heal = 4711;
    public const ushort Unstopppable = 403;
    public const ushort Immovable = 408;

    public Wrackspite(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 540;
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _adds.SpawnCreature(21945, new(1012976, 1022278, 7852), 3094);
        _adds.SpawnCreature(21945, new(1012966, 1023543, 7852), 3083);
        _adds.SpawnCreature(21945, new(1014126, 1023536, 7852), 1024);
        _adds.SpawnCreature(21945, new(1012980, 1022705, 7852), 3094);
        _adds.SpawnCreature(21945, new(1014129, 1022699, 7852), 1024);
        _adds.SpawnCreature(21945, new(1014133, 1022289, 7852), 1024);
        _adds.SpawnCreature(21945, new(1014137, 1023957, 7852), 1024);
        _adds.SpawnCreature(21945, new(1014127, 1023118, 7852), 1024);
        _adds.SpawnCreature(21945, new(1012977, 1023121, 7852), 3083);
        _adds.SpawnCreature(21945, new(1012975, 1023953, 7852), 3083);

        _unit.Abilities.EndTargetAbilities(SkullruinLikeness);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }

        if (_unit.Health.Value < _unit.Health.Total * 0.1 && _stageNum < 10 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 10;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 9 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 9;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.3 && _stageNum < 8 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 8;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 7 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 7;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.5 && _stageNum < 6 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 6;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 5 && !_unit.IsDead) // At 20% HP he fails to summon anything
        {
            AnimateCreature();

            _stageNum = 5;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.7 && _stageNum < 4 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 3 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.9 && _stageNum < 2 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total && _stageNum < 1 && !_unit.IsDead)
        {
            AnimateCreature();

            _stageNum = 1;
        }
    }

    private void AnimateCreature()
    {
        Creature? crea = GetCreatureFromRegion(21945);

        if (crea is not null)
        {
            // Spawn active creature
            _adds.SpawnCreature(2000680, crea.WorldPosition, crea.Heading);
            crea.Destroy();
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Abilities.EndTargetAbilities(SkullruinLikeness);

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        DespawnBastionStairsWalls();

        DestroyWall();

        base.OnDie(obj);
    }

    private void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000977)
            {
                go.Destroy();
            }
        }
    }
}

[GeneralScript(CreatureEntry = 21945)]
internal class WrackspiteStatisCreature : BasicCreatureScript
{
    public WrackspiteStatisCreature(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.SendAggroUpdate = false;

        base.OnObjectLoad(obj);
    }
}

[GeneralScript(CreatureEntry = 2000680)]
internal class WrackspiteAnimatedCreature : BasicCreatureScript
{
    public WrackspiteAnimatedCreature(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.SendAggroUpdate = false;

        _creature.AiInterface.AllowThinking = false;
        _creature.AiInterface.ResetSpeedAtCombatStart = false;

        _creature.Tasks.AddTask(CheckTargetAndCast, 1000, 0);
        _creature.Tasks.AddTask(StartGoToMommy, 1000, 1);

        _creature.AddCrowdControlImmunity(CrowdControlTypes.Disabled);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Disarm);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Knockdown);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Root);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Silence);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.Stagger);
        base.OnObjectLoad(obj);
    }

    public void StartGoToMommy()
    {
        GoToMommy(16078); // Here is mommy...
        _creature.Speed.SetBaseSpeed(50);
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        DelayedBuff(_creature, Wrackspite.Unstopppable);
        DelayedBuff(_creature, Wrackspite.Immovable);
    }

    private void CheckTargetAndCast()
    {
        foreach (WorldObject o in _creature.ObjectsInRange)
        {
            if (o is Creature crea && !crea.IsDead && crea.Entry == 16078 && _unit.IsWithin3DRadiusUnits(crea, 180))
            {
                crea.Abilities.AddAbility(Wrackspite.Heal, crea, crea.EffectiveLevel);
                crea.Abilities.AddAbility(Wrackspite.SkullruinLikeness, crea, crea.EffectiveLevel);

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
        _creature.PlayEffect(1847);
    }
}
