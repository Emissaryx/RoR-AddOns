namespace Game.Scripts.Dungeons.SigmarsCrypt;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.NetWork.Handler;
using Game.Repositories.World;
using Game.World.Objects;
using WarEmu.Database.World.Database.Creatures;

[GeneralScript(CreatureEntry = 52868)]
internal class Seraphine : BasicCreatureScript
{
    public Seraphine(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 820;
        _creature.Enrage.StartPosition = new(1496892, 222061, 8649);
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        Creature? c = obj as Creature;
        c?.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_unit.Region is null)
        {
            return;
        }

        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 4 && !_unit.IsDead)
        {
            foreach (WorldObject? o in _unit.Region.Objects.ToList())
            {
                if (o is not null && o is Creature crea && crea.Entry == 2001459)
                {
                    crea.Destroy();
                    break;
                }
            }

            _unit.Say(
                "Wait! Wait! Hold your blade! I have a proposition, one that could benefits the both of us...",
                ChatLogFilter.MonsterSay
            );
            _adds.SpawnCreature(2001365, _unit.WorldPosition, _unit.Heading);

            // Seraphine near doors, persistent spawn
            CreatureProto? cproto = CreatureProtoRepository.Instance.GetCreatureProto(2001447);
            if (cproto is not null)
            {
                _unit.Region.AddObject(Creature.Create(Global.ServiceProvider, cproto), 1499145, 219868, 8872, 3034);
            }

            _unit.Tasks.AddTask(_unit.Destroy, 250, 1);

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 3 && !_unit.IsDead)
        {
            Player? p = GetRandomPlayerInRange();

            if (p is not null)
            {
                _unit.Say(
                    $"Ah {p.Name}, we’ve been tracking your movement for some time yet. You’ve earned quite the fortune for yourself. I won’t mind taking my cut!",
                    ChatLogFilter.MonsterSay
                );

                _unit.Abilities.AddAbility(21339, p, _unit.EffectiveLevel);

                SendOnscreenMessageToAllPlayers($"Destroy Treasure Chests to help {p.Name}!");
            }

            _adds.SpawnGameObject(2000783, new(1496677, 222085, 8574), 2682);

            _adds.SpawnGameObject(2000784, new(1496903, 221748, 8574), 432);

            _adds.SpawnGameObject(2000785, new(1497054, 222040, 8574), 328);

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 2 && !_unit.IsDead)
        {
            Player? p = GetRandomPlayerInRange();

            if (p is not null)
            {
                _unit.Say(
                    $"Ah {p.Name}, we’ve been tracking your movement for some time yet. You’ve earned quite the fortune for yourself. I won’t mind taking my cut!",
                    ChatLogFilter.MonsterSay
                );

                _unit.Abilities.AddAbility(21339, p, _unit.EffectiveLevel);

                SendOnscreenMessageToAllPlayers($"Destroy Treasure Chests to help {p.Name}!");
            }

            _adds.SpawnGameObject(2000783, new(1496677, 222085, 8574), 2682);

            _adds.SpawnGameObject(2000784, new(1496903, 221748, 8574), 432);

            _adds.SpawnGameObject(2000785, new(1497054, 222040, 8574), 328);

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 1 && !_unit.IsDead)
        {
            Player? p = GetRandomPlayerInRange();

            if (p is not null)
            {
                _unit.Say(
                    $"Ah {p.Name}, we’ve been tracking your movement for some time yet. You’ve earned quite the fortune for yourself. I won’t mind taking my cut!",
                    ChatLogFilter.MonsterSay
                );

                _unit.Abilities.AddAbility(21339, p, _unit.EffectiveLevel);

                SendOnscreenMessageToAllPlayers($"Destroy Treasure Chests to help {p.Name}!");
            }

            _adds.SpawnGameObject(2000783, new(1496677, 222085, 8574), 2682);

            _adds.SpawnGameObject(2000784, new(1496903, 221748, 8574), 432);

            _adds.SpawnGameObject(2000785, new(1497054, 222040, 8574), 328);

            _stageNum = 1;
        }
    }

    public void SpawnRobbers()
    {
        _unit.Say("They’re Dead. They weren't going to make use of the jewels", ChatLogFilter.MonsterSay);
        _adds.SpawnCreature(2001364, new(1496896, 222066, 8649), 26);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(ZCheck, 1000, 0);

        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        SpawnRobbers();
        _unit.Tasks.AddTask(SpawnRobbers, "SpawnAdd", 25 * 1000, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(ZCheck);
        _unit.Tasks.RemoveTask(StartZCheck);
        _unit.Tasks.RemoveTask(SpawnRobbers);

        base.OnLeaveCombat(owner);
    }

    public void ZCheck()
    {
        if (_unit.WorldPosition.Z > 8655)
        {
            _unit.Tasks.RemoveTask(ZCheck);
            _unit.Tasks.AddTask(StartZCheck, 10 * 1000, 1);

            CastAbility(5567); // Stuff
        }
    }

    public void StartZCheck()
    {
        if (_unit is Creature c && c.CombatFlag.IsInCombat && !c.IsDead)
        {
            c.Tasks.AddTask(ZCheck, 1000, 0);
        }
    }
}

[GeneralScript(GameObjectEntry = 2000785)]
internal class SeraphineGo : BasicScript
{
    public SeraphineGo(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnDie(Unit obj)
    {
        _unit.PlayEffect(3529);

        ClearCommonEvents();

        foreach (Player plr in obj.Region.Players.ToList())
        {
            if (plr is not null)
            {
                plr.Abilities.EndTargetAbilities(21339); // Removing gimp buff
            }
        }

        _unit.Destroy();
    }
}

[GeneralScript(CreatureEntry = 2001365)]
internal class SeraphimeFriendly : BasicScript
{
    public SeraphimeFriendly(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override bool OnInteract(WorldObject obj, Player target, InteractMenu menu)
    {
        _unit.Say(
            "Go and kill Tobias the Fallen and Sister Eudocia. When you are done meet me at Lector Door and I will open them for you.",
            ChatLogFilter.MonsterSay
        );
        return true;
    }
}

[GeneralScript(CreatureEntry = 2001447)]
internal class SeraphimeFriendlyDoors : BasicScript
{
    public SeraphimeFriendlyDoors(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override bool OnInteract(WorldObject obj, Player target, InteractMenu menu)
    {
        if (
            _unit.Region.Instance.HasCompletedEncounter(4)
            && // Tobias & SisterEudecia
            _unit.Region.Instance.HasCompletedEncounter(5)
        )
        {
            _unit.Say(
                "I may be a rogue, but I am one of my word. As agreed, I'll pick the lock.",
                ChatLogFilter.MonsterSay
            );
            _unit.Region.Instance.CompletedEncounter(6);
            _unit.Tasks.AddTask(
                () =>
                {
                    _unit.Say("And done! Farewell, it was nice knowing you!", ChatLogFilter.MonsterSay);
                },
                2000,
                1
            );
            _unit.Tasks.AddTask(
                () =>
                {
                    _unit.Movement.PathTo(1499451, 222040, 9000);
                },
                4000,
                1
            );
            _unit.Tasks.AddTask(
                () =>
                {
                    _unit.Destroy();
                },
                20000,
                1
            );
        }
        else
        {
            _unit.Say(
                "Get back to me when you dealt with Tobias the Fallen and Sister Eudocia!",
                ChatLogFilter.MonsterSay
            );
        }

        return true;
    }
}
