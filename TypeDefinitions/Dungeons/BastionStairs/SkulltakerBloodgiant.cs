namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;
using WarEmu.Database.World.Database.Maps;

[GeneralScript(CreatureEntry = 16083)]
internal class SkulltakerBloodgiant : BasicCreatureScript
{
    private readonly ZoneRepository _zoneRepository;

    public SkulltakerBloodgiant(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository,
        ZoneRepository zoneRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _zoneRepository = zoneRepository;
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.15 && _stageNum < 6 && !_unit.IsDead)
        {
            _stageNum = 6;

            BossStage();
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.3 && _stageNum < 5 && !_unit.IsDead)
        {
            _stageNum = 5;

            BossStage();
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.45 && _stageNum < 4 && !_unit.IsDead)
        {
            _stageNum = 4;

            BossStage();
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 3 && !_unit.IsDead)
        {
            _stageNum = 3;

            BossStage();
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.75 && _stageNum < 2 && !_unit.IsDead)
        {
            _stageNum = 2;

            BossStage();
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.9 && _stageNum < 1 && !_unit.IsDead)
        {
            _stageNum = 1;

            BossStage();
        }

        return;
    }

    public void BossStage()
    {
        GameObject? go = GetGameObjectFromRegion((uint)(2000957 + _stageNum));

        if (go is not null)
        {
            go.VfxState = 1;
            _unit.Tasks.AddTask(() => go.VfxState = 0, 60 * 1000, 1);

            ZoneJump? jump = null;
            jump = _zoneRepository.GetZoneJump((uint)GetZoneJumpFromStage(_stageNum));
            if (jump is not null)
            {
                _adds.SpawnCreature(49163, new(jump.WorldX, jump.WorldY, jump.WorldZ), jump.WorldO); // Spawn add
            }

            jump = _zoneRepository.GetZoneJump((uint)(GetZoneJumpFromStage(_stageNum) + 1));
            if (jump is not null)
            {
                _adds.SpawnCreature(16084, new(jump.WorldX, jump.WorldY, jump.WorldZ), jump.WorldO); // Spawn add
            }

            jump = _zoneRepository.GetZoneJump((uint)(GetZoneJumpFromStage(_stageNum) + 2));
            if (jump is not null)
            {
                _adds.SpawnCreature(16087, new(jump.WorldX, jump.WorldY, jump.WorldZ), jump.WorldO); // Spawn add
            }
        }
    }

    public int GetZoneJumpFromStage(int stage)
    {
        return stage switch
        {
            1 => 99,
            2 => 102,
            3 => 105,
            4 => 108,
            5 => 111,
            6 => 114,
            _ => 0,
        };
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        SendOnscreenMessageToAllPlayers("Savage roar comes from the gate!");

        GameObject? go = GetGameObjectFromRegion(2000957);

        if (go is not null)
        {
            go.VfxState = 1;
            go.SendMeTo();
        }

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (WorldObject? obj in _unit.Region.Objects)
        {
            if (
                obj is Creature creature
                && (creature.Entry == 49163 || creature.Entry == 16084 || creature.Entry == 16087)
            )
            {
                creature.Destroy();
            }
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        for (byte i = 0; i < 6; i++)
        {
            GameObject? go = GetGameObjectFromRegion((uint)(2000958 + i));

            if (go is not null)
            {
                go.VfxState = 0;
            }
        }

        base.OnLeaveCombat(owner);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(49163);
        SetRandomTargetToNpc(16084);
        SetRandomTargetToNpc(16087);
    }
}

[GeneralScript(CreatureEntry = 49163)]
internal class SkulltakerAdd1 : BasicScript
{
    public SkulltakerAdd1(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ChangeSpawnAndMove, 1000, 1);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public void ChangeSpawnAndMove()
    {
        Creature? boss = GetCreatureFromRegion(16083);
        if (boss is not null)
        {
            _unit.WorldSpawnPoint.X = boss.WorldSpawnPoint.X;
            _unit.WorldSpawnPoint.Y = boss.WorldSpawnPoint.Y;
            _unit.WorldSpawnPoint.Z = boss.WorldSpawnPoint.Z;

            _unit.Movement.Move(boss);
        }
    }
}

[GeneralScript(CreatureEntry = 16084)]
internal class SkulltakerAdd2 : BasicScript
{
    public SkulltakerAdd2(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ChangeSpawnAndMove, 1000, 1);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public void ChangeSpawnAndMove()
    {
        Creature? boss = GetCreatureFromRegion(16083);
        if (boss is not null)
        {
            _unit.WorldSpawnPoint.X = boss.WorldSpawnPoint.X;
            _unit.WorldSpawnPoint.Y = boss.WorldSpawnPoint.Y;
            _unit.WorldSpawnPoint.Z = boss.WorldSpawnPoint.Z;

            _unit.WorldSpawnPoint.X = boss.WorldSpawnPoint.X;
            _unit.WorldSpawnPoint.Y = boss.WorldSpawnPoint.Y;
            _unit.WorldSpawnPoint.Z = boss.WorldSpawnPoint.Z;

            _unit.Movement.Move(boss);
        }
    }
}

[GeneralScript(CreatureEntry = 16087)]
internal class SkulltakerAdd3 : BasicScript
{
    public SkulltakerAdd3(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ChangeSpawnAndMove, 1000, 1);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public void ChangeSpawnAndMove()
    {
        Creature? boss = GetCreatureFromRegion(16083);
        if (boss is not null)
        {
            _unit.WorldSpawnPoint.X = boss.WorldSpawnPoint.X;
            _unit.WorldSpawnPoint.Y = boss.WorldSpawnPoint.Y;
            _unit.WorldSpawnPoint.Z = boss.WorldSpawnPoint.Z;

            _unit.Movement.Move(boss);
        }
    }
}
