namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums;
using Game.World.Objects;

/*
 * Spellbiter
 * Has loads of sprites all around, these will respwan quickly unless the spellbiter is killed
 * It is possible to bypass as the ads arent hostile, only the spellbiter, if you cast any spell
 * in the area close to the spellbiter, all the sprites will swarm you, you will have to then
 * kill the spellbiter to stop them respawning.
 */
[GeneralScript(CreatureEntry = 97443)]
internal class Spellbiter : CreatureScript
{
    public Spellbiter(Creature c)
        : base(c) { }

    private sealed class SpritePosition
    {
        public uint X;
        public uint Y;
        public ushort Z;
        public ushort O;
    }

    private static readonly SpritePosition[] _sprites =
    [
        new()
        {
            X = 323424,
            Y = 532057,
            Z = 4552,
            O = 284,
        },
        new()
        {
            X = 322719,
            Y = 532108,
            Z = 4278,
            O = 2531,
        },
        new()
        {
            X = 322882,
            Y = 531871,
            Z = 4272,
            O = 3668,
        },
        new()
        {
            X = 323304,
            Y = 532228,
            Z = 4296,
            O = 2306,
        },
        new()
        {
            X = 323191,
            Y = 532376,
            Z = 4025,
            O = 1318,
        },
        new()
        {
            X = 322786,
            Y = 533121,
            Z = 4135,
            O = 1822,
        },
        new()
        {
            X = 323216,
            Y = 532913,
            Z = 4427,
            O = 1045,
        },
        new()
        {
            X = 322383,
            Y = 532656,
            Z = 4026,
            O = 2406,
        },
        new()
        {
            X = 322525,
            Y = 532052,
            Z = 4094,
            O = 3497,
        },
        new()
        {
            X = 322580,
            Y = 532072,
            Z = 4117,
            O = 3317,
        },
        new()
        {
            X = 322719,
            Y = 532107,
            Z = 4278,
            O = 2965,
        },
        new()
        {
            X = 322860,
            Y = 531953,
            Z = 4552,
            O = 194,
        },
        new()
        {
            X = 322885,
            Y = 533394,
            Z = 3975,
            O = 2024,
        },
        new()
        {
            X = 323406,
            Y = 531795,
            Z = 4278,
            O = 537,
        },
        new()
        {
            X = 323447,
            Y = 532109,
            Z = 4511,
            O = 3826,
        },
        new()
        {
            X = 322846,
            Y = 531822,
            Z = 4252,
            O = 3040,
        },
        new()
        {
            X = 322515,
            Y = 533072,
            Z = 4406,
            O = 2183,
        },
        new()
        {
            X = 323424,
            Y = 532009,
            Z = 4040,
            O = 993,
        },
    ];

    private readonly Creature?[] _spriteCreatures = new Creature?[_sprites.Length];

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Tasks.AddTask(SpawnSprites, 5000, 0);
    }

    public override void OnEnterCombat(Unit obj, Unit? attacker)
    {
        SetSpritesHostileStatus();
    }

    public override void OnLeaveCombat(Unit obj)
    {
        SetSpritesHostileStatus();
    }

    public override void OnDie(Unit obj)
    {
        _creature.Tasks.RemoveTask(SpawnSprites);
    }

    private void SetSpritesHostileStatus()
    {
        foreach (Creature? sprite in _spriteCreatures)
        {
            if (sprite is not null && !sprite.IsDead)
            {
                SetSpriteHostileStatus(sprite);
            }
        }
    }

    private void SetSpriteHostileStatus(Creature sprite)
    {
        if (_creature.CombatFlag.IsInCombat)
        {
            sprite.Aggressive = true;
        }
        else
        {
            sprite.Aggressive = false;
        }
    }

    private void SpawnSprites()
    {
        for (uint i = 0; i < _sprites.Length; ++i)
        {
            // Don't respawn living sprites
            if (_spriteCreatures[i] is { IsDead: false })
            {
                continue;
            }

            _spriteCreatures[i]?.Destroy();

            _spriteCreatures[i] = _creature.Region?.CreateCreature(
                2000729,
                new(_sprites[i].X, _sprites[i].Y, _sprites[i].Z),
                _sprites[i].O,
                sprite =>
                {
                    sprite.Roam = 50;
                    sprite.Aggro.MaxAggroRange = 6000;
                    sprite.Aggro.AggroResetDistance = 6000;
                    sprite.DisableLoot = true;
                    sprite.DisableGatheringLoot = true;
                    SetSpriteHostileStatus(sprite);
                }
            );
        }
    }
}
