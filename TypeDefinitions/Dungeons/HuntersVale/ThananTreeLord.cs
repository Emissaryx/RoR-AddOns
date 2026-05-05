namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums.GameData;
using Game.World.Objects;

public sealed class Position
{
    public uint X;
    public uint Y;
    public ushort Z;
    public ushort O;
}

[GeneralScript(CreatureEntry = 97425)]
internal class ThananTreeLord : CreatureScript
{
    private static readonly Position[] _bloodriteDryadPositions =
    [
        new()
        {
            X = 327044,
            Y = 531103,
            Z = 4180,
            O = 3913,
        },
        new()
        {
            X = 326896,
            Y = 531104,
            Z = 4182,
            O = 362,
        },
        new()
        {
            X = 326790,
            Y = 531093,
            Z = 4173,
            O = 558,
        },
        new()
        {
            X = 326717,
            Y = 531025,
            Z = 4159,
            O = 1170,
        },
    ];

    private readonly BloodriteDryad[] _dryads = new BloodriteDryad[_bloodriteDryadPositions.Length];

    public ThananTreeLord(Creature creature)
        : base(creature) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
        SpawnBloodriteDryads();
    }

    private int _dryadDead;

    public void DryadDeath()
    {
        _dryadDead++;

        if (_dryadDead == _dryads.Length)
        {
            _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
            Player? plr = _creature.PlayersInRange.FirstOrDefault();
            if (plr is not null)
            {
                _creature.AiInterface.ProcessCombatStart(plr);
            }
        }
    }

    private bool _started;

    public void StartEncounter()
    {
        if (_started)
        {
            return;
        }

        _started = true;

        foreach (BloodriteDryad dryad in _dryads)
        {
            dryad.Attack();
        }
    }

    public void ResetEncounter()
    {
        for (uint i = 0; i < _dryads.Length; ++i)
        {
            _dryads[i].Destroy();
        }

        SpawnBloodriteDryads();
        _dryadDead = 0;
        _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
        _started = false;
    }

    public override void OnLeaveCombat(Unit obj)
    {
        if (!_creature.IsDead)
        {
            ResetEncounter();
        }
    }

    private void SpawnBloodriteDryads()
    {
        for (uint i = 0; i < _bloodriteDryadPositions.Length; ++i)
        {
            Creature? dryad = _creature.Region?.CreateCreature(
                97422,
                new(_bloodriteDryadPositions[i].X, _bloodriteDryadPositions[i].Y, _bloodriteDryadPositions[i].Z),
                _bloodriteDryadPositions[i].O
            );

            if (dryad == null)
            {
                return;
            }

            _dryads[i] = new(dryad, this, i);
            dryad.Scripts.Scripts.Add(_dryads[i]);
        }
    }
}

internal sealed class BloodriteDryad : CreatureScript
{
    private readonly ThananTreeLord _lord;
    private readonly uint _dyadId;
    private readonly AddsTracker _adds;

    private static readonly Position[] _addsPositions =
    [
        new()
        {
            X = 327354,
            Y = 532645,
            Z = 4358,
            O = 1996,
        },
        new()
        {
            X = 326161,
            Y = 532547,
            Z = 4319,
            O = 2297,
        },
        new()
        {
            X = 325556,
            Y = 531477,
            Z = 4128,
            O = 2709,
        },
        new()
        {
            X = 325907,
            Y = 530118,
            Z = 4155,
            O = 3267,
        },
    ];

    public BloodriteDryad(Creature creature, ThananTreeLord lord, uint dyadId)
        : base(creature)
    {
        _lord = lord;
        _dyadId = dyadId;
        _adds = new(creature) { ClearOnDeath = false };
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        // These ones are bigger
        _creature.SetScale(100);
    }

    public void Attack()
    {
        if (_creature.PlayersInRange.OrderBy(_ => Guid.NewGuid()).FirstOrDefault() is { } plr)
        {
            _creature.AiInterface.ProcessCombatStart(plr);
        }
    }

    public override void OnDie(Unit obj)
    {
        _lord.DryadDeath();
        _creature.Tasks.RemoveTask(SpawnAdds);
    }

    public override void OnEnterCombat(Unit obj, Unit? attacker)
    {
        _lord.StartEncounter();
        _creature.Tasks.AddTask(SpawnAdds, 15000, 0);
    }

    public override void OnLeaveCombat(Unit obj)
    {
        if (!_creature.IsDead)
        {
            _lord.ResetEncounter();
        }

        _creature.Tasks.RemoveTask(SpawnAdds);
    }

    public void Destroy()
    {
        _creature.Destroy();
    }

    private void SpawnAdds()
    {
        int count = 4;

        for (int i = 0; i < count; ++i)
        {
            _adds.SpawnCreature(
                97406,
                new(
                    (uint)(
                        _addsPositions[_dyadId].X + Random.Shared.Next(20, 100) * ((Random.Shared.Next(0, 2) * 2) - 1)
                    ),
                    (uint)(
                        _addsPositions[_dyadId].Y + Random.Shared.Next(20, 100) * ((Random.Shared.Next(0, 2) * 2) - 1)
                    ),
                    _addsPositions[_dyadId].Z
                ),
                _addsPositions[_dyadId].O
            );
        }
    }
}

[GeneralScript(CreatureEntry = 97406)]
internal class ThananTreeLordSprite : CreatureScript
{
    public ThananTreeLordSprite(Creature creature)
        : base(creature) { }

    public override void OnEnterWorld(WorldObject obj)
    {
        _creature.Tasks.AddTask(StartAttack, 1000, 1);
    }

    private void StartAttack()
    {
        var plr = _creature.PlayersInRange.RandomElement();

        if (plr is null)
        {
            return;
        }

        _creature.AiInterface.ProcessCombatStart(plr);
    }

    public override void OnLeaveCombat(Unit obj)
    {
        _creature.Destroy();
    }
}
