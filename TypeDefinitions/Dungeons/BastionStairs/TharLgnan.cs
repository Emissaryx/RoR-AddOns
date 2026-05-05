namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Common.Positions;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 45084)]
internal class TharLgnan : BasicCreatureScript
{
    private readonly GameObjectRepository _gameObjectRepository;

    private readonly Point3D[] _landingSpots =
    [
        new(1000022, 988348, 8886),
        new(997724, 988140, 8886),
        new(997416, 987174, 8886),
        new(997991, 985144, 8515),
        new(998294, 985792, 8497),
        new(999335, 985695, 8489),
        new(999931, 985068, 8563),
        new(999340, 986469, 8513),
        new(998609, 986976, 8575),
        new(1000234, 987384, 8886),
        new(998833, 986201, 8440),
        new(998808, 985718, 8490),
    ];

    public TharLgnan(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _gameObjectRepository = gameObjectRepository;
        _creature.Enrage.EnableRangeUnits = 3600;
    }

    private readonly List<Player> _deadPlayers = new();

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);
        _creature.Aggro.AggroResetDistance = 4800;
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.1 && _stageNum < 9 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 9;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 8 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 8;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.3 && _stageNum < 7 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 7;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 6 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 6;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.5 && _stageNum < 5 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 5;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 4 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.7 && _stageNum < 3 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 2 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.9 && _stageNum < 1 && !_unit.IsDead)
        {
            JumpPlayerAndDoStuff();

            _stageNum = 1;
        }
    }

    private void CheckForDeadPlayers()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (Player plr in _unit.Region.Players)
        {
            if (
                !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                && plr.IsDead
                && !_deadPlayers.Contains(plr)
            )
            {
                _unit.ReceiveHeal(_unit, (uint)(_unit.Health.Total * 0.25));
                DelayedBuff(_unit, 13449); // Healing for boss

                _deadPlayers.Add(plr);

                SendOnscreenMessageToAllPlayers("The scent of gore invigorates Thar'Lgnan!");
            }
        }
    }

    private void SpawnDogAroundPos(Point3D targetPos)
    {
        if (_unit.Zone is null)
        {
            return;
        }

        Point3D spawnPos = ScriptHelpers.GetSpawnPositionAround(targetPos, _unit.Zone, 72);

        _adds.SpawnCreature(45088, spawnPos, spawnPos.GetHeading(targetPos));
    }

    private void JumpPlayerAndDoStuff()
    {
        Player? plr = GetRandomPlayerInRange();

        if (plr is not null)
        {
            Point3D? targetPos = _landingSpots.RandomElement();
            if (targetPos is null)
            {
                return;
            }

            plr.Catapult(targetPos.Value, 4, 0x010F);

            SendOnscreenMessageToAllPlayers($"Thar’Lgnan tosses {plr.Name} to the frenzied Bloodsnouts!");

            _unit.Tasks.AddTask(() => SpawnDogAroundPos(targetPos.Value), "SpawnAdds", 3700, 1);
            _unit.Tasks.AddTask(() => SpawnDogAroundPos(targetPos.Value), "SpawnAdds", 3700, 1);

            _unit.Tasks.AddTask(() => AddBuffToPlayer(plr, 5063), "ApplyDebuff", 4000, 1); // Player Snare

            // We also apply Signal Buff so the Bloodsnouts know who to attack
            _unit.Tasks.AddTask(() => AddBuffToPlayer(plr, 60010), "ApplyDebuff", 4000, 1);

            (_unit as Creature)?.Aggro.RemoveHatred(plr);
        }
    }

    private void AddBuffToPlayer(Player target, ushort buffId)
    {
        _unit.Abilities.AddAbility(buffId, target, _unit.EffectiveLevel);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        DestroyGameObjectInRegion(2000791); // This destroy walls

        ClearStuff();

        DespawnBastionStairsWalls();

        if (obj.Region is null)
        {
            return;
        }

        GameObject? go = obj.Region.CreateGameObject(
            100532,
            new(_unit.WorldSpawnPoint.X, _unit.WorldSpawnPoint.Y, _unit.WorldSpawnPoint.Z),
            0
        );

        //AddInfluenceToAllPlayersInRegion(128, 2000);
        //AddInfluenceToAllPlayersInRegion(129, 2000);

        base.OnDie(obj);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(CheckForDeadPlayers, 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnBastionStairsWalls();

        ClearStuff();

        base.OnLeaveCombat(owner);
    }

    public void ClearStuff()
    {
        _unit.Tasks.RemoveTask(CheckForDeadPlayers);
        _unit.Tasks.RemoveTask("SpawnAdds");
        _unit.Tasks.RemoveTask("ApplyDebuff");

        _deadPlayers.Clear();

        if (_unit.Region is null)
        {
            return;
        }

        foreach (Player plr in _unit.Region.Players)
        {
            plr.Abilities.EndTargetAbilities(5063);
            plr.Abilities.EndTargetAbilities(60010);
        }

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature c && c.Entry == 45088)
            {
                c.Destroy();
            }
        }
    }
}

[GeneralScript(CreatureEntry = 45088)]
internal class Bloodsnout : BasicScript
{
    public Bloodsnout(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(TerminateCurrentTarget, 40000, 0);
        obj.Tasks.AddTask(SetTargetToBuffedCharacter, 400, 1);
        obj.Tasks.AddTask(SetTargetToBuffedCharacter, 3600, 0);
    }

    public virtual void SetTargetToBuffedCharacter()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (Player plr in _unit.Region.Players)
        {
            if (plr.Abilities.HasBuffById(5063) || plr.Abilities.HasBuffById(60010))
            {
                (_unit as Creature)?.Aggro.AddHatred(plr, 100000);
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
        Creature? boss = GetCreatureFromRegion(45084);

        if (boss is null)
        {
            return;
        }

        if (obj.IsWithin3DRadiusUnits(boss, 720))
        {
            boss.ReceiveHeal(boss, (uint)(boss.Health.Total * 0.05));
            boss.Say("I smell the fresh scent of gore!", ChatLogFilter.MonsterSay);
        }

        if (GetCreatureCountFromRegion(45088) == 0)
        {
            if (obj.Region is null)
            {
                return;
            }

            foreach (Player plr in obj.Region.Players)
            {
                plr.Abilities.EndTargetAbilities(5063);
                plr.Abilities.EndTargetAbilities(60010);
            }
        }

        ClearStuff();

        obj.Tasks.RemoveTask(TerminateCurrentTarget);
        obj.Tasks.RemoveTask(SetTargetToBuffedCharacter);

        base.OnDie(obj);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }

    private void TerminateCurrentTarget()
    {
        if (_unit.IsDead || _unit.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY) is not Player plr || plr.IsDead)
        {
            return;
        }

        SendOnscreenMessageToAllPlayers($"Bloodsnout shreded {plr.Name} to pieces!");

        plr.SendClientMessage("Bloodsnout shreded you to pieces!", ChatLogFilter.CSRTellReceive);
        plr.Terminate();
    }

    public void ClearStuff()
    {
        _unit.Tasks.RemoveTask(SetRandomTarget);
    }
}
