namespace WorldServer.World.Scripting.Dungeons.LostVale;

using Common.Enums.GameData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 6842)]
internal class Sarthain : BasicCreatureScript
{
    public Sarthain(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public bool CorruptorsSpawning = false;

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.SpeedInterface.Speed = 0;
        _unit.Movement.SetBaseSpeed(_unit.SpeedInterface.Speed);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);

        CorruptorsSpawning = false;
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        SpawnCorruptors();
        _unit.Tasks.AddTask(SpawnAdditionalCorruptors, 1000, 0);

        _unit.Abilities.EndTargetAbilities((ushort)5567);

        base.OnEnterCombat(owner, attacker);
    }

    public void SpawnAdditionalCorruptors()
    {
        if (!CorruptorsSpawning)
        {
            CorruptorsSpawning = true;
            _unit.Tasks.AddTask(SpawnCorruptors, 45 * 1000, 1);

            _unit.Tasks.AddTask(CheckForPlayersNearBossAndSpawnNpCs, 10 * 1000, 4);
        }
    }

    public void CheckForPlayersNearBossAndSpawnNpCs()
    {
        foreach (Player plr in _unit.Region.Players)
        {
            if (_unit.IsWithin3DRadiusUnits(plr, 180))
            {
                return;
            }
        }

        List<Player> screwedPlayers = new();

        byte i = 0;
        byte count = 0;
        while (i < 100)
        {
            if (count > 2)
            {
                break;
            }

            Player? plr = GetRandomPlayerInRange();
            if (plr is not null && !screwedPlayers.Contains(plr))
            {
                screwedPlayers.Add(plr);

                _adds.SpawnCreaturesAroundPos(2000733, plr.WorldPosition, 300);
                _adds.SpawnCreaturesAroundPos(6849, plr.WorldPosition, 300);
                _adds.SpawnCreaturesAroundPos(6822, plr.WorldPosition, 300);

                count++;
            }

            i++;
        }
    }

    public void SpawnCorruptors()
    {
        CorruptorsSpawning = true;

        _adds.SpawnCreature(2001615, new Point3D(1422150, 1565330, 8208), 3000); // Corruptor 1

        _adds.SpawnCreature(23681, new Point3D(1424425, 1567019, 8222), 1843); // Corruptor 2

        _adds.SpawnCreature(2001616, new Point3D(1423654, 1563177, 8339), 3948); // Corruptor 3

        _unit.Tasks.AddTask(SetCorruptorsNotSpawning, 75 * 1000 + 100, 1);
    }

    public void SetCorruptorsNotSpawning()
    {
        CorruptorsSpawning = false;
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
        SetCorruptorsNotSpawning();

        _unit.Tasks.RemoveTask(SetCorruptorsNotSpawning);
        _unit.Tasks.RemoveTask(SpawnAdditionalCorruptors);
        _unit.Tasks.RemoveTask(SpawnCorruptors);
        _unit.Tasks.RemoveTask(CheckForPlayersNearBossAndSpawnNpCs);

        _unit.Abilities.EndTargetAbilities((ushort)13682);
        _unit.Abilities.EndTargetAbilities((ushort)13685);
        _unit.Abilities.EndTargetAbilities((ushort)5101);
        _unit.Abilities.EndTargetAbilities((ushort)5103);

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature crea && (crea.Entry == 2001615 || crea.Entry == 23681 || crea.Entry == 2001616 || crea.Entry == 2000733 || crea.Entry == 6849 || crea.Entry == 6822))
            {
                crea.Destroy();
            }
        }

        foreach (Player plr in _unit.Region.Players)
        {
            plr.Abilities.EndTargetAbilities((ushort)5100);
        }
    }
}

internal class Corruptor : BasicCreatureScript
{
    protected ushort _bossBuffEntry;

    public Corruptor(Unit unit, ushort bossBuff)
        : base(unit)
    {
        _bossBuffEntry = bossBuff;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _creature.SpeedInterface.Speed = 0;
        _creature.Movement.SetBaseSpeed(_creature.SpeedInterface.Speed);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.All);
        _creature.AiInterface.AllowThinking = false;
        _creature.Aggro.SendAggroUpdate = false;
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        BuffBoss();
        obj.Tasks.AddTask(BuffBoss, 30 * 1000, 0);
        SendOnscreenMessageToAllPlayers(_creature.Name + " is now vulnerable!");

        DelayedBuff(_creature, 4388); // Taunt Immunity

        CastChannelAtBoss();
    }

    public void BuffBoss()
    {
        Creature? boss = GetCreatureFromRegion(6842);
        if (boss is not null)
        {
            boss.Abilities.AddAbility(_bossBuffEntry, boss, boss.EffectiveLevel);
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (!_creature.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted) && !_creature.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked))
        {
            if (_stageNum < 0 && !_creature.IsDead)
            {
                _stageNum = 0; // Setting control value to 0
            }
            else if (_creature.Health.Value < _creature.Health.Total && _stageNum < 1 && !_creature.IsDead)
            {
                obj.Tasks.AddTask(BossCheck, 45 * 1000, 1);

                _stageNum = 1;
            }
        }
    }

    public void BossCheck()
    {
        Creature? boss = GetCreatureFromRegion(6842);
        bool playerNearBoss = false;

        if (boss is not null)
        {
            foreach (Player plr in _unit.Region.Players)
            {
                _creature.Abilities.AddAbility(5100, plr, _creature.EffectiveLevel);

                if (boss.IsWithin3DRadiusUnits(plr, 180))
                {
                    playerNearBoss = true;
                }
            }

            if (!playerNearBoss)
            {
                boss.Abilities.AddAbility(13682, boss, boss.EffectiveLevel);
            }
        }
    }

    public void CastChannelAtBoss()
    {
        Creature? boss = GetCreatureFromRegion(6842);

        if (boss is not null)
        {
            _creature.Targets.Set(TargetTypes.TARGETTYPES_TARGET_ALLY, boss.Oid);
            _creature.AbilityCast.StartCast(13310, 0);
        }
    }

    public void DisableInv()
    {
        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _unit.SendMeTo();

        SendOnscreenMessageToAllPlayers(_unit.Name + " is now vulnerable!");
    }

    public override void OnDie(Unit obj)
    {
        Creature? boss = GetCreatureFromRegion(6842);
        if (boss is not null)
        {
            boss.Abilities.EndTargetAbilities(_bossBuffEntry);
        }

        base.OnDie(obj);
    }
}

[GeneralScript(CreatureEntry = 2001615)]
internal class Corruptor1 : Corruptor
{
    public Corruptor1(Unit unit)
        : base(unit, 13685)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
        _unit.SendMeTo();

        obj.Tasks.AddTask(DisableInv, 30 * 1000, 1);
    }
}

[GeneralScript(CreatureEntry = 23681)]
internal class Corruptor2 : Corruptor
{
    public Corruptor2(Unit unit)
        : base(unit, 5101)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
        _creature.SendMeTo();

        obj.Tasks.AddTask(DisableInv, 15 * 1000, 1);
    }
}

[GeneralScript(CreatureEntry = 2001616)]
internal class Corruptor3 : Corruptor
{
    public Corruptor3(Unit unit)
        : base(unit, 5103)
    {
    }
}
