namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.NetWork.Handler;
using Game.Repositories.World;
using Game.Services;
using Game.World.Events;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 15102)]
internal class ArdtaFeed : BasicCreatureScript
{
    public ArdtaFeed(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;
        CloseDoor(new("a9db9b60-59e4-11eb-83d8-000c29d63948")); // Door Spawn GUID

        _creature.Abilities.EndTargetAbilities(20364);

        _adds.SpawnGameObject(2000579, new(1261116, 1256925, 20496), _unit.Heading); // Solithex Mourkain Gem

        _adds.SpawnGameObject(2000579, new(1261986, 1256893, 20501), _unit.Heading); // Solithex Mourkain Gem

        _adds.SpawnGameObject(2000602, new(1261341, 1257348, 20499), _unit.Heading); // Slime Pound

        _adds.SpawnGameObject(2000602, new(1260966, 1257823, 20450), _unit.Heading); // Slime Pound

        _adds.SpawnGameObject(2000602, new(1261887, 1257203, 20505), _unit.Heading); // Slime Pound

        _adds.SpawnGameObject(2000602, new(1262216, 1257734, 20444), _unit.Heading); // Slime Pound

        _creature.Tasks.AddTask(CastCloudOfSquigs, 30 * 1000, 0);

        _creature.Tasks.AddTask(EatSnack, 10 * 1000, 0);

        foreach (WorldObject o in _unit.ObjectsInRange)
        {
            if (o is GameObject go && go.Entry == 98876) // Mourkain Henge
            {
                go.VfxState = 0;
                go.SendMeTo();
            }
        }

        _creature.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);
    }

    private void EatSnack()
    {
        if (_unit.Region is null)
        {
            return;
        }

        Creature? snack = GetCreatureFromRegion(2000945);
        if (snack is not null)
        {
            _creature.ReceiveHeal(snack, 10000);

            _creature.Say("'Ard ta Feed just swallowed one of the smaller squigs!", ChatLogFilter.MonsterEmote);
            snack.Destroy();
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);
        OpenDoor(new("a9db9b60-59e4-11eb-83d8-000c29d63948")); // Door Spawn GUID
        _creature.Abilities.EndTargetAbilities(20364); // Squig Frenzy

        _creature.Tasks.RemoveTask(CastCloudOfSquigs);

        _creature.Tasks.RemoveTask(EatSnack);

        foreach (WorldObject o in _creature.ObjectsInRange)
        {
            if (o is GameObject go)
            {
                if (go.Entry == 98876) // Mourkain Henge
                {
                    go.VfxState = 0;
                    go.SendMeTo();
                }

                if (go.Entry == 2000579)
                {
                    go.Destroy();
                }
            }

            if (o is Creature creature)
            {
                if (creature.Entry == 2000945) // Ard Food
                {
                    creature.Destroy();
                }

                if (creature.Entry == 2000941) // Mourkain Henge
                {
                    creature.Destroy();
                }
            }
        }

        _unit.Tasks.RemoveTask(ApplyOrRemoveArdRage);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        foreach (WorldObject o in obj.ObjectsInRange)
        {
            /*if (go is not null && go.Entry == 2000579) // This is the Mourkain Gem
            {
                //go.Interactable = false;
                foreach (Player player in go.PlayersInRange)
                {
                    go.SendMeTo(player);
                }
            }*/
            if (o is GameObject go && go.Entry == 98876)
            {
                go.VfxState = 0;
                go.SendMeTo();
            }
        }

        _creature.Tasks.RemoveTask(CastCloudOfSquigs);
        _creature.Tasks.RemoveTask(EatSnack);

        // Obj.ScdInterface.RemoveTask(ApplyTerrorToEveryoneInRadius);
        obj.Tasks.AddTask(DelayCreateExitPortal, 1000, 1);

        obj.Tasks.RemoveTask(ApplyOrRemoveArdRage);

        SpawnGoldChest(2001);
        EndPublicQuest(2001);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);
    }

    public override void DelayCreateExitPortal()
    {
        CreateExitPortal(1261649, 1258448, 20331, 0);
    }

    private void ArdRage()
    {
        // Ard Squig Frenzy Buff 20364
        DelayedBuff(_creature, 12801, "'Ard ta Feed roars in rage!");
    }

    public void ApplyOrRemoveArdRage()
    {
        if (_creature.Abilities.HasBuffById(12801))
        {
            ArdRage();
        }
        else
        {
            _creature.Tasks.RemoveTask(ApplyOrRemoveArdRage);
        }
    }

    private void SpawnSlimePounds()
    {
        foreach (WorldObject o in _creature.ObjectsInRange)
        {
            if (o is GameObject go && go.Entry == 2000602)
            {
                go.Destroy();
            }
        }

        _adds.SpawnGameObject(2000602, new(1261341, 1257348, 20499), _creature.Heading);
        _adds.SpawnGameObject(2000602, new(1260966, 1257823, 20450), _creature.Heading);
        _adds.SpawnGameObject(2000602, new(1261887, 1257203, 20505), _creature.Heading);
        _adds.SpawnGameObject(2000602, new(1262216, 1257734, 20444), _creature.Heading);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_creature.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.05 && _stageNum < 9 && !_creature.IsDead)
        {
            _creature.Say("'Ard ta Feed snatched all his snacks!", ChatLogFilter.MonsterSay);

            foreach (WorldObject o in _creature.ObjectsInRange)
            {
                if (o is GameObject go && go.Entry == 2000579)
                {
                    go.Destroy();
                }

                if (o is Creature creature && creature.Entry == 2000945) // Ard Food
                {
                    HealArd(creature);
                    creature.Destroy();
                }
            }

            _stageNum = 9;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.2 && _stageNum < 8 && !_creature.IsDead)
        {
            EnableGems();

            ArdRage();
            _creature.Tasks.AddTask(ApplyOrRemoveArdRage, 15 * 1000, 0);

            _stageNum = 8;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.25 && _stageNum < 7 && !_creature.IsDead)
        {
            SpawnSlimePounds();

            _stageNum = 7;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.4 && _stageNum < 6 && !_creature.IsDead)
        {
            EnableGems();

            ArdRage();
            _creature.Tasks.AddTask(ApplyOrRemoveArdRage, 15 * 1000, 0);

            _stageNum = 6;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.5 && _stageNum < 5 && !_creature.IsDead)
        {
            SpawnSlimePounds();

            _stageNum = 5;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.6 && _stageNum < 4 && !_creature.IsDead)
        {
            EnableGems();

            ArdRage();
            _creature.Tasks.AddTask(ApplyOrRemoveArdRage, 15 * 1000, 0);

            _stageNum = 4;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.75 && _stageNum < 3 && !_creature.IsDead)
        {
            SpawnSlimePounds();

            _stageNum = 3;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.8 && _stageNum < 2 && !_creature.IsDead)
        {
            EnableGems();

            ArdRage();
            _creature.Tasks.AddTask(ApplyOrRemoveArdRage, 15 * 1000, 0);

            _stageNum = 2;
        }
        else if (_creature.Health.Value < _creature.Health.Total && _stageNum < 1 && !_creature.IsDead)
        {
            _stageNum = 1;
        }
    }

    public void EnableGems()
    {
        foreach (WorldObject o in _unit.ObjectsInRange)
        {
            if (o is not GameObject go)
            {
                continue;
            }

            if (go.Entry == 2000579) // This is the Mourkain Gem
            {
                go.LastUsedTimestamp = 0;
                go.Say(
                    "*** As anger of 'Ard ta Feed start to boil the gem fills with wicked energy... Time is of the essence! ***",
                    ChatLogFilter.MonsterSay
                );
                go.PlayEffect(784);

                // go.Interactable = true;
                /*foreach (Player player in go.PlayersInRange)
                {
                    go.SendMeTo(player);
                }*/
            }

            if (go.Entry == 98876) // Mourkain Henge
            {
                go.VfxState = 1;
                go.SendMeTo();
            }
        }
    }

    public void CastCloudOfSquigs()
    {
        Player? target = GetRandomPlayerInRange();
        if (target is null)
        {
            return;
        }

        _adds.SpawnCreature(2000941, target.WorldPosition, _unit.Heading);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2000945);
    }

    public bool HealArd(Creature snack)
    {
        _unit.ReceiveHeal(snack, 10000);

        return true;
    }
}

[GeneralScript(CreatureEntry = 2000945)]
internal class ArdSquigFood : BasicScript, IEventListener
{
    private readonly IDisposable _subscription;

    public ArdSquigFood(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _subscription = unit.Events.Subscribe(this);
    }

    private readonly List<Creature> _ardList = new();

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        foreach (WorldObject o in obj.ObjectsInRange)
        {
            if (o is Creature c && c.Entry == 15102)
            {
                _ardList.Add(c);
                break;
            }
        }

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }

    public void OnDieEvent(ref DieEvent eventValue)
    {
        if (eventValue.Victim is Creature { Entry: 15102 } ard && ard.Health.Total - ard.Health.Value > 10001)
        {
            ard.Health.Value += 10000;
            ard.Say("'Ard ta Feed just swallowed one of the smaller squigs!", ChatLogFilter.MonsterEmote);
        }

        _subscription.Dispose();
    }
}

[GeneralScript(CreatureEntry = 2000941)]
internal class ArdCloudOfSquigs : BasicCreatureScript
{
    public ArdCloudOfSquigs(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);
        obj.Tasks.AddTask(DispellCloudOfSquigs, 30 * 1000, 1);
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        SetRandomTarget();

        obj.PlayEffect(213); // Squig Cloud
        obj.Tasks.AddTask(
            () =>
            {
                if (!_creature.IsDead)
                {
                    obj.PlayEffect(213);
                }
            },
            1 * 500,
            0
        ); // every 1.5 s

        DelayedBuff(_unit, 4388); // Taunt Immunity
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker) { }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        foreach (WorldObject obj in _unit.ObjectsInRange)
        {
            if (obj is GameObject go && go.Entry == 2000602)
            {
                go.Destroy();
            }

            if (obj is Creature creature)
            {
                if (creature.Entry == 2000945)
                {
                    creature.Destroy();
                }

                if (creature.Entry == 2000941)
                {
                    creature.Destroy();
                }
            }
        }
    }

    public override void SetRandomTarget()
    {
        Player? target = GetRandomPlayerInRange();
        if (target is not null)
        {
            _unit.Movement.TurnTo(target);
            _unit.Speed.SetBaseSpeed(110);
            _unit.Movement.Follow(target, 60, 120);
            (_unit as Creature)?.Aggro.AddHatred(target, 100000);

            _unit.Say($"*** A horde of wild squigs chase {target.Name}! ***", ChatLogFilter.MonsterSay);
        }
    }

    private void DispellCloudOfSquigs() => _unit.Destroy();
}

[GeneralScript(GameObjectEntry = 2000579)]
internal class MourkainGemArdtaFeed : BasicGameObjectScript
{
    public MourkainGemArdtaFeed(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.CaptureDuration = TimeSpan.FromSeconds(4);

        _go.LastUsedTimestamp = 0;

        // go.Interactable = false;
        _go.SendMeTo();
    }
}

[GeneralScript(GameObjectEntry = 2000602)]
internal class ArdSlime : BasicGameObjectScript
{
    public ArdSlime(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.NoRespawn = true;

        obj.Tasks.AddTask(
            () => _adds.SpawnCreature(2000945, obj.WorldPosition, (ushort)Random.Shared.Next(0, 4096)),
            "SpawnAdd",
            20 * 1000,
            0
        );
    }
}

[GeneralScript(GameObjectEntry = 2000579)]
internal class MourkainGem : BasicCreatureScript
{
    public MourkainGem(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override bool OnInteract(WorldObject obj, Player player, InteractMenu menu)
    {
        if (obj is not GameObject goMe)
        {
            return false;
        }

        if (goMe.LastUsedTimestamp == 0)
        {
            _creature.Say("*** Sinister energy is gone from the gem... ***", ChatLogFilter.MonsterSay);
        }

        goMe.LastUsedTimestamp = WorldService.RegionTimestampMS;

        bool removeBuff = false;

        foreach (WorldObject o in obj.ObjectsInRange)
        {
            if (o is GameObject go && go != obj && go.Entry == 2000579) // This is 2nd Mourkain Gem
            {
                if (goMe.LastUsedTimestamp != 0 && (goMe.LastUsedTimestamp - go.LastUsedTimestamp < 2001))
                {
                    goMe.LastUsedTimestamp = 0;
                    go.LastUsedTimestamp = 0;
                    removeBuff = true;
                }
                else if (go.LastUsedTimestamp != 0)
                {
                    goMe.LastUsedTimestamp = 0;
                    go.LastUsedTimestamp = 0;
                    _creature.Say("*** You are too late! Better hurry and try again! ***", ChatLogFilter.MonsterSay);
                }
            }
        }

        if (removeBuff)
        {
            foreach (WorldObject ob in obj.ObjectsInRange) // This is looking for ard to feed in range
            {
                if (ob is Creature c && c.Entry == 15102) // This is ard ta feed
                {
                    c.Abilities.EndTargetAbilities(12801);

                    c.AbilityCast.StartCast(5308, 0);
                    _creature.Say(
                        "*** Wicked energy evaporates from the cursed jewel... ***",
                        ChatLogFilter.MonsterSay
                    );
                    c.Say("*** Monstrous squig calms a bit... ***", ChatLogFilter.MonsterSay);
                }

                if (ob is GameObject gobject && gobject.Entry == 98876) // This is Mourkain Henge
                {
                    gobject.VfxState = 0;
                    gobject.SendMeTo();
                }
            }
        }

        return true;
    }
}
