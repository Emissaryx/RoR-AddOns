namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 49164)]
internal class Chorek : BasicCreatureScript
{
    public const ushort StillnessOfTime = 5694;
    public const ushort ChaliceOfTheChosen = 5034;
    public const ushort TimeOut = 5695;
    public const ushort RageOfKhorne = 5064;
    public const ushort Enrange = 5567;

    public Chorek(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    private Player? _favouritePlayer;

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 4 && !_unit.IsDead)
        {
            BossStage();

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 3 && !_unit.IsDead)
        {
            BossStage();

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 2 && !_unit.IsDead)
        {
            BossStage();

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 1 && !_unit.IsDead)
        {
            BossStage();

            _stageNum = 1;
        }
    }

    private void BossStage()
    {
        Player? target = _unit
            .PlayersInRange.Where(p =>
                !p.IsDead
                && !p.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                && !p.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                && !p.Stealth.IsInGameMasterStealth
                && p != _unit.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY)
                && !p.Abilities.HasBuffById(TimeOut)
            )
            .RandomElement();

        if (target is null)
        {
            return;
        }

        // End previous boss stage
        BossStageEnd();

        _unit.Abilities.AddAbility(StillnessOfTime, target, _unit.EffectiveLevel);
        _unit.Abilities.AddAbility(ChaliceOfTheChosen, target, _unit.EffectiveLevel);

        _adds.SpawnCreature(43859, new(1026830, 996551, 14212), 0);
        _adds.SpawnCreature(43859, new(1027635, 996295, 14284), 0);
        _adds.SpawnCreature(43859, new(1027450, 996945, 14212), 0);
        _adds.SpawnCreature(43859, new(1026923, 996019, 14284), 0);
        _adds.SpawnCreature(43859, new(1026945, 997172, 14284), 0);
        _adds.SpawnCreature(43859, new(1027305, 996326, 14284), 0);
        _adds.SpawnCreature(43859, new(1027362, 996359, 14320), 0);

        _favouritePlayer = target;

        SendOnscreenMessageToAllPlayers(
            $"As Fireborn Sprites tries to imprison {target.Name} Chorek drinks from his Chalice of the Chosen!"
        );

        _unit.Tasks.AddTask(BossStageEnd, 15 * 1000, 1);
    }

    private void BossStageEnd()
    {
        if (_favouritePlayer is null)
        {
            return;
        }

        // Remove Stillness of Time
        _favouritePlayer.Abilities.EndTargetAbilities(StillnessOfTime);

        if (GetCreatureCountFromRegion(43859) > 0)
        {
            _unit.Abilities.AddAbility(TimeOut, _favouritePlayer, _unit.EffectiveLevel);
            _unit.Abilities.AddAbility(RageOfKhorne, _unit, _unit.EffectiveLevel);
            SendOnscreenMessageToAllPlayers(
                $"As Fireborn Sprites take {_favouritePlayer.Name} to the cage {_unit.Name} rage boils at the thought of future slaughter!"
            );
        }

        _favouritePlayer = null;
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        DestroyWall();

        base.OnDie(obj);
    }

    private void DestroyWall()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000971)
            {
                go.Destroy();
            }
        }
    }

    private void ClearStuff()
    {
        if (_unit.Region is null)
        {
            return;
        }

        _unit.Abilities.EndTargetAbilities(Enrange); // Removing rage
        _unit.Abilities.EndTargetAbilities(RageOfKhorne); // Removing rage
        _unit.Abilities.EndTargetAbilities(ChaliceOfTheChosen); // Removing iron skin
        _unit.Tasks.RemoveTask(DropAggro);

        foreach (Player plr in _unit.Region.Players)
        {
            plr.Abilities.EndTargetAbilities(StillnessOfTime);
            plr.Abilities.EndTargetAbilities(TimeOut);
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        // Pet
        _adds.SpawnCreaturesAroundPos(8530, _unit.WorldPosition, 360);

        _unit.Tasks.AddTask(DropAggro, 60 * 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    private void DropAggro()
    {
        Creature? juggernaut = GetCreatureFromRegion(8530);

        if (
            !_unit.IsDead
            && _unit.CombatFlag.IsInCombat
            && juggernaut is not null
            && !juggernaut.IsDead
            && juggernaut.CombatFlag.IsInCombat
        )
        {
            (_unit as Creature)?.Aggro.Reset();
            juggernaut.Aggro.Reset();
            _unit.Say("Your weakness disgusts me!", ChatLogFilter.MonsterSay);
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        // This will execute player
        ExecutePlayer();

        base.OnLeaveCombat(owner);
    }

    private void ExecutePlayer()
    {
        if (_unit.IsDead || _unit.Region is null)
        {
            return;
        }

        foreach (Player plr in _unit.Region.Players)
        {
            if (plr.IsDead || !plr.Abilities.HasBuffById(TimeOut))
            {
                continue;
            }

            SendOnscreenMessageToAllPlayers($"{_unit.Name} executed {plr.Name} before his rage evaporated");
            plr.Terminate();
        }
    }
}

[GeneralScript(CreatureEntry = 16081)]
internal class Beastraip : BasicScript
{
    public Beastraip(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 100, 1);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        Creature? creature = GetCreatureFromRegion(49164);

        if (creature is not null && !creature.IsDead && creature.CombatFlag.IsInCombat)
        {
            DelayedBuff(creature, Chorek.Enrange, "You will pay for this with your BLOOD!"); // Rage
        }

        base.OnDie(obj);
    }
}

[GeneralScript(CreatureEntry = 43859)]
internal class FirebornSprite : BasicCreatureScript
{
    public FirebornSprite(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        if (obj is Creature c)
        {
            if (GetCreatureCountFromRegion(c.Entry) < 1)
            {
                SendOnscreenMessageToAllPlayers($"All {c.Name} has been slain!");
                Creature? boss = GetCreatureFromRegion(0);
                if (boss is not null)
                {
                    boss.Abilities.EndTargetAbilities(Chorek.ChaliceOfTheChosen);
                }
            }
            else
            {
                SendOnscreenMessageToAllPlayers($"There are {GetCreatureCountFromRegion(c.Entry)} {c.Name} left!");
            }
        }

        base.OnDie(obj);
    }
}
