namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Events;
using Game.World.Objects;

/*
 * Cadaithaine Lion
 * at 80% he calls the Lioness 97405 to join the fight. She spawns at 330096, 525893, 4423, 3322
 * The Lioness ignores taunt and attacks whoever she pleases.
 * Every 10 seconds , she switch Aggro to a random player and this onscreen text is displayed : “The Cadaithaine Lioness charges <playername>”
 * When lioness die Ab buffcast 23810 1 on the lion
 * Every 20% , the lion will call 2 NpC 2000739 at 330096, 525893, 4423, 3322 and at 330056, 525853, 4423, 3322
 */
[GeneralScript(CreatureEntry = 97441)]
internal class CadaithaineLion : BasicCreatureScript
{
    private Creature? _lioness;
    private EventProxy<DieEvent>? _lionessSubscription;
    private new Stage _stage = Stage.Stage1;
    private bool _completed;

    public enum Stage
    {
        Stage1 = 1,
        Stage2 = 2,
        Stage3 = 3,
        Stage4 = 4,
        Stage5 = 5,
        Stage6 = 6,
    }

    public CadaithaineLion(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _adds.ClearOnDeath = false;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.AggroResetDistance = 3600;
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        switch (_stage)
        {
            case Stage.Stage1:
            {
                if (_creature.Health.Pct < 80)
                {
                    _stage = Stage.Stage2;
                    SpawnAdds();
                    SpawnLioness();
                }

                break;
            }

            case Stage.Stage2:
            {
                if (_creature.Health.Pct < 60)
                {
                    _stage = Stage.Stage3;
                    SpawnAdds();
                }

                break;
            }

            case Stage.Stage3:
            {
                if (_creature.Health.Pct < 40)
                {
                    _stage = Stage.Stage4;
                    SpawnAdds();
                }

                break;
            }

            case Stage.Stage4:
            {
                if (_creature.Health.Pct < 20)
                {
                    _stage = Stage.Stage5;
                    SpawnAdds();
                }

                break;
            }
        }
    }

    private void SpawnLioness()
    {
        _lioness = _adds.SpawnCreature(97405, new(330096, 525893, 4423), 3322);
        if (_lioness is not null)
        {
            _lionessSubscription = new(_lioness.Events, LionessDead);
        }
    }

    public override void OnLeaveCombat(Unit obj)
    {
        if (_completed)
        {
            return;
        }

        _stage = Stage.Stage1;
    }

    public override void OnDie(Unit obj)
    {
        _completed = true;
    }

    private void LionessDead(DieEvent eventValue)
    {
        _creature.Abilities.AddAbility(23810, _creature, _creature.EffectiveLevel);

        _lionessSubscription?.Unsubscribe();
        _lionessSubscription = null;
    }

    private void SpawnAdds()
    {
        _adds.SpawnCreature(2000739, new(330096, 525893, 4423), 3322);
        _adds.SpawnCreature(2000739, new(330056, 525853, 4423), 3322);
    }
}

[GeneralScript(CreatureEntry = 97405)]
internal class CadaithaineLioness : CreatureScript
{
    public CadaithaineLioness(Creature creature)
        : base(creature) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.AggroResetDistance = 4800;

        _creature.Tasks.AddTask(RandomCharge, 1000, 1);
    }

    public override void OnDie(Unit obj)
    {
        _creature.Tasks.RemoveTask(RandomCharge);
    }

    private void RandomCharge()
    {
        Unit? currentTarget = _creature.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY);

        Player? newTarget = _creature
            .PlayersInRange.Where(p =>
                p.IsWithin3DRadiusUnits(_creature, 4800)
                && p != currentTarget
                && !p.IsDead
                && !p.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                && !p.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
            )
            .RandomElement();
        if (newTarget is not null)
        {
            _creature.Movement.TurnTo(newTarget);
            _creature.Movement.Follow(newTarget, 60, 120);

            if (currentTarget is not null)
            {
                _creature.Aggro.RemoveHatred(currentTarget);
            }

            _creature.Aggro.AddHatred(newTarget, 100000);

            _creature.DispatchPacket(
                Player.BuildLocalizeString(
                    $"The Cadaithaine Lioness charges {newTarget.Name}{string.Empty}",
                    ChatLogFilter.CWhite
                ),
                false
            );
        }

        _creature.Tasks.AddTask(RandomCharge, 10000, 1);
    }
}

[GeneralScript(CreatureEntry = 2000739)]
internal class CadaithaineLionAdd : CreatureScript
{
    public CadaithaineLionAdd(Creature creature)
        : base(creature) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.AggroResetDistance = 4800;

        _creature.Tasks.AddTask(RandomCharge, 1000, 1);
    }

    public override void OnDie(Unit obj)
    {
        _creature.Tasks.RemoveTask(RandomCharge);
    }

    private void RandomCharge()
    {
        if (_creature.IsDead)
        {
            _creature.Tasks.RemoveTask(RandomCharge);
            return;
        }

        Player? newTarget = _creature.PlayersInRange.MinBy(_ => Guid.NewGuid());
        if (newTarget is null)
        {
            return;
        }

        _creature.Movement.TurnTo(newTarget);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.All); // This should grant immunity to CC
        _creature.Movement.Follow(newTarget, 60, 120);
        _creature.AiInterface.ProcessCombatStart(newTarget);
    }
}
