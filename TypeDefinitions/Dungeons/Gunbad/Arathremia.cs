namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums;
using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;
using WorldCommon.Network.Model.Server;

[GeneralScript(CreatureEntry = 41620)]
internal class Arathremia : BasicCreatureScript
{
    public Arathremia(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_creature.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.05 && _stageNum < 8 && !_creature.IsDead)
        {
            // KillTraitors();
            _stageNum = 8;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.15 && _stageNum < 7 && !_creature.IsDead)
        {
            // TraitorousSouls();
            _stageNum = 7;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.30 && _stageNum < 6 && !_creature.IsDead)
        {
            _creature.Say("I'd like you to meet some friends of mine!", ChatLogFilter.MonsterSay);

            // Deceived Souls
            SpawnDeceivedSouls();

            _stageNum = 6;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.4 && _stageNum < 5 && !_creature.IsDead)
        {
            // KillTraitors();
            _stageNum = 5;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.55 && _stageNum < 4 && !_creature.IsDead)
        {
            // TraitorousSouls();
            _stageNum = 4;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.7 && _stageNum < 3 && !_creature.IsDead)
        {
            _creature.Say("I am never alone!", ChatLogFilter.MonsterSay);

            // Deceived Souls
            SpawnDeceivedSouls();

            _stageNum = 3;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.8 && _stageNum < 2 && !_creature.IsDead)
        {
            _creature.Say("I'd like you to meet some friends of mine!", ChatLogFilter.MonsterSay);

            // Deceived Souls
            SpawnDeceivedSouls();

            _stageNum = 2;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.9 && _stageNum < 1 && !_creature.IsDead)
        {
            _creature.Say("I am never alone!", ChatLogFilter.MonsterSay);

            // Deceived Souls
            SpawnDeceivedSouls();

            _stageNum = 1;
        }
    }

    private void SpawnDeceivedSouls()
    {
        _adds.SpawnCreaturesAroundPos(41619, _unit.WorldSpawnPoint, 180, 6);
    }

    public override void OnDie(Unit obj)
    {
        DestroyWall();

        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(181); // pq ID

        AddInfluenceToAllPlayersInRegion(64, 65, 800);

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        if (_creature.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _creature.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100011)
            {
                go.Destroy();
            }
        }
    }

    public void TraitorousSouls()
    {
        uint entry = 0;
        int count = 0;

        foreach (Player player in _creature.PlayersInRange)
        {
            if (player.Realm == Realms.Order)
            {
                count++;
            }
            else
            {
                count--;
            }
        }

        if (count > 0)
        {
            entry = 2000883;
        }
        else
        {
            entry = 2000884;
        }

        foreach (Unit unit in _adds.GetUnits())
        {
            if (unit is not Creature creature)
            {
                continue;
            }

            if (creature.Entry == 41619 && !creature.IsDead)
            {
                creature.CombatFlag.LeaveCombat();

                int i = Random.Shared.Next(0, 2);
                switch (i)
                {
                    case 0:
                        creature.Say("She weakens... strike now sisters!", ChatLogFilter.MonsterSay);
                        break;
                    case 1:
                        creature.Say("We will do your bidding no more!", ChatLogFilter.MonsterSay);
                        break;
                }

                _adds.SpawnCreature(entry, creature.WorldPosition, creature.Heading);

                creature.Destroy();

                // creature.MvtInterface.Follow((Creature)Obj, 5, 10);
                // creature.CbtInterface.SetTarget(Obj.Oid, GameData.TargetTypes.TARGETTYPES_TARGET_ENEMY);
            }
        }
    }

    public void KillTraitors()
    {
        bool say = false;
        foreach (Unit unit in _adds.GetUnits())
        {
            if (unit is not Creature creature)
            {
                continue;
            }

            if (!creature.IsDead)
            {
                creature.Health.Value = 0;
            }

            if (!say)
            {
                _creature.Say("Traitors!", ChatLogFilter.MonsterSay);
                say = true;
            }

            creature.States.Add(CreatureState.Dead); // Death State

            creature.DispatchPacket(
                new ObjectDeath { Oid = creature.Oid, Flags = ObjectDeath.ObjectDeathFlags.DeathState },
                true
            );

            creature.Tasks.AddTask(creature.Destroy, 10 * 1000, 1);
        }
    }

    public void CaseSleep() { }
}

[GeneralScript(CreatureEntry = 41619)]
internal class DeceivedSoulArathremia : BasicScript
{
    public DeceivedSoulArathremia(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }
}

[GeneralScript(CreatureEntry = 2000883)]
internal class OrderDeceivedSoulArathremia : BasicCreatureScript
{
    public OrderDeceivedSoulArathremia(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        Creature? arathremia = null;

        foreach (WorldObject obj in _creature.ObjectsInRange)
        {
            if (obj is Creature creature && creature.Entry == 41620)
            {
                arathremia = creature;
            }
        }

        if (arathremia is not null)
        {
            _creature.Aggro.AddHatred(arathremia, 5000);
            _creature.Targets.Set(TargetTypes.TARGETTYPES_TARGET_ENEMY, arathremia.Oid);
        }
    }
}

[GeneralScript(CreatureEntry = 2000884)]
internal class DestroDeceivedSoulArathremia : BasicCreatureScript
{
    public DestroDeceivedSoulArathremia(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        Creature? arathremia = null;

        foreach (WorldObject obj in _creature.ObjectsInRange)
        {
            if (obj is Creature creature && creature.Entry == 41620)
            {
                arathremia = creature;
            }
        }

        if (arathremia is not null)
        {
            _creature.Aggro.AddHatred(arathremia, 5000);
            _creature.Targets.Set(TargetTypes.TARGETTYPES_TARGET_ENEMY, arathremia.Oid);
        }
    }
}
