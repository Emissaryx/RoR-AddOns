namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Interfaces.UnitInterfaces;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 38829)]
internal class GlompdaSquigMasta : BasicCreatureScript
{
    private bool _squigForm;
    private ushort _baseRange;

    public GlompdaSquigMasta(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _baseRange = creature.Ranged;
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        _creature.Ranged = _baseRange;

        _creature.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        _creature.Ranged = _baseRange;

        SquigForm(false);
        _creature.Mount(0);
        _unit.PlayEffect(2185); // Mount puff effect
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        SquigForm(false);

        _creature.Mount(0);

        // Obj.PlayEffect(2185); // Mount puff effect
        // Obj.PlayEffect(2215); // Squig Explosion effect
        obj.PlayEffect(2795);
        obj.PlayEffect(2797);
        obj.Tasks.AddTask(PlayDelayedEffect, 1000, 1);

        obj.Tasks.AddTask(DelayCreateExitPortal, 1000, 1);

        SpawnGoldChest(2000);
        EndPublicQuest(2000);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);
    }

    private void PlayDelayedEffect()
    {
        _unit.PlayEffect(2206);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_creature.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }

        if (_creature.Health.Value < _creature.Health.Total * 0.3 && _stageNum < 5 && !_creature.IsDead) // At 20% HP he fails to summon anything
        {
            _creature.Mount(0);

            SquigForm(true);

            _creature.Say("I almost 'ad ya!", ChatLogFilter.MonsterSay);

            _creature.PlayEffect(2185); // Mount puff effect

            _stageNum = 5;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.4 && _stageNum < 4 && !_creature.IsDead)
        {
            _adds.SpawnCreature(2000866, new(929787, 930312, 27020), _creature.Heading); // Spikestabbin'Squigs

            _adds.SpawnCreature(2000866, new(930761, 931907, 27026), _creature.Heading); // Spikestabbin'Squigs

            _adds.SpawnCreature(2000866, new(929366, 932515, 27062), _creature.Heading); // Spikestabbin'Squigs

            _adds.SpawnCreature(2000866, new(928632, 931686, 26987), _creature.Heading); // Spikestabbin'Squigs

            _adds.SpawnCreature(2000866, new(928715, 930710, 27000), _creature.Heading); // Spikestabbin'Squigs

            ApplyIronSkin();

            _creature.Mount(136);
            _creature.Tasks.AddTask(
                () =>
                {
                    _creature.Mount(0);
                    RemoveIronSkin();
                },
                30 * 1000,
                1
            );

            _creature.Say("Spikestabba' Squigs, get out 'ere!", ChatLogFilter.MonsterSay);

            _creature.PlayEffect(1359); // Skull Effect
            _creature.PlayEffect(2185); // Mount puff effect

            _stageNum = 4;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.6 && _stageNum < 3 && !_creature.IsDead)
        {
            _adds.SpawnCreature(2000865, new(929787, 930312, 27020), _creature.Heading); // Stinkspewin'Squigs

            _adds.SpawnCreature(2000865, new(930761, 931907, 27026), _creature.Heading); // Stinkspewin'Squigs

            _adds.SpawnCreature(2000865, new(929366, 932515, 27062), _creature.Heading); // Stinkspewin'Squigs

            _adds.SpawnCreature(2000865, new(928632, 931686, 26987), _creature.Heading); // Stinkspewin'Squigs

            _adds.SpawnCreature(2000865, new(928715, 930710, 27000), _creature.Heading); // Stinkspewin'Squigs

            ApplyIronSkin();

            _creature.Mount(136);
            _creature.Tasks.AddTask(
                () =>
                {
                    _creature.Mount(0);
                    RemoveIronSkin();
                },
                30 * 1000,
                1
            );

            _creature.Say("Stinkspewin' Squigs, get out 'ere!", ChatLogFilter.MonsterSay);

            _creature.PlayEffect(1359); // Skull Effect
            _creature.PlayEffect(2185); // Mount puff effect

            _stageNum = 3;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.90 && _stageNum < 2 && !_creature.IsDead)
        {
            _adds.SpawnCreature(2000864, new(929787, 930312, 27020), _creature.Heading); // Skewering'Squigs

            _adds.SpawnCreature(2000864, new(930761, 931907, 27026), _creature.Heading); // Skewering'Squigs

            _adds.SpawnCreature(2000864, new(929366, 932515, 27062), _creature.Heading); // Skewering'Squigs

            _adds.SpawnCreature(2000864, new(928632, 931686, 26987), _creature.Heading); // Skewering'Squigs

            _adds.SpawnCreature(2000864, new(928715, 930710, 27000), _creature.Heading); // Skewering'Squigs

            ApplyIronSkin();
            // Squig Mount
            _creature.Mount(136);
            _creature.Tasks.AddTask(
                () =>
                {
                    _creature.Mount(0);
                    RemoveIronSkin();
                },
                30 * 1000,
                1
            );

            _creature.Say("Skewerin' Squigs, get out 'ere!", ChatLogFilter.MonsterSay);

            _creature.PlayEffect(1359); // Skull Effect
            _creature.PlayEffect(2185); // Mount puff effect

            _stageNum = 2;
        }
        else if (_creature.Health.Value < _creature.Health.Total && _stageNum < 1 && !_creature.IsDead)
        {
            _stageNum = 1;
        }
    }

    private bool ApplyIronSkin()
    {
        FreezeNpc();
        _unit.Abilities.AddAbility(5262, _unit, _unit.EffectiveLevel); // This is Iron Skin buff - Squig Commando
        return true;
    }

    private bool RemoveIronSkin()
    {
        UnfreezeNpc();
        _unit.Abilities.EndTargetAbilities(5262); // This is Iron Skin buff - Squig Commando
        return true;
    }

    private void SquigForm(bool enable)
    {
        if (_squigForm == enable)
        {
            return;
        }

        // Size increase
        if (enable)
        {
            _creature.AbilitySet.SetAbilitySet(48); // Squig Abilities
            _creature.Stats.AddItemBonusStat(Stats.Armor, 1500);
            _creature.Stats.AddItemBonusStat(Stats.Toughness, 300);
            // c.StsInterface.AddItemBonusStat(GameData.Stats.MeleeCritRate, 20);
            // c.StsInterface.AddItemBonusStat(GameData.Stats.Strength, 1300);
            _creature.Ranged = 180;
            _creature.ObjectState.AddEffect(ObjectEffectState.OBJECTEFFECTSTATE_SQUIG_ARMOR);
            _creature.ObjectState.AddEffect(ObjectEffectState.OBJECTEFFECTSTATE_BERSERK); // State 1 Champ, State 7 Super Champ
        }
        else
        {
            _creature.AbilitySet.SetAbilitySet(_creature.AbilitySetId); // Default ability set
            _creature.Stats.RemoveItemBonusStat(Stats.Armor, 1500);
            _creature.Stats.RemoveItemBonusStat(Stats.Toughness, 300);
            // c.StsInterface.RemoveItemBonusStat(GameData.Stats.MeleeCritRate, 20);
            // c.StsInterface.RemoveItemBonusStat(GameData.Stats.Strength, 1300);
            _creature.Ranged = _baseRange;
            _creature.ObjectState.RemoveEffect(ObjectEffectState.OBJECTEFFECTSTATE_SQUIG_ARMOR);
            _creature.ObjectState.RemoveEffect(ObjectEffectState.OBJECTEFFECTSTATE_BERSERK); // State 1 Champ, State 7 Super Champ
        }

        AggroInfo? aggro = _creature.Aggro.GetMaxHatred();

        if (aggro is not null)
        {
            foreach (Player player in _creature.PlayersInRange)
            {
                if (_creature.PlayersInRange.Count == 1 || (player is not null && aggro.Value.Oid != player.Oid))
                {
                    _creature.Movement.StopMove();
                    _creature.AiInterface.CurrentBrain.Chase(player, true);
                    break;
                }
            }
        }

        _squigForm = enable;
    }
}
