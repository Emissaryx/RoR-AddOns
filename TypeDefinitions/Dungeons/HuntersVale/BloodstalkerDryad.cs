namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums.GameData;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 97423)]
internal class BloodstalkerDryad : CreatureScript
{
    public BloodstalkerDryad(Creature creature)
        : base(creature) { }

    public override void OnEnterCombat(Unit obj, Unit? attacker)
    {
        _creature.DormantInfo &= ~DormantFlags.NameHidden;
    }

    public override void OnLeaveCombat(Unit obj)
    {
        _creature.DormantInfo |= DormantFlags.NameHidden;
    }

    public override void OnDie(Unit obj)
    {
        int count = 2;

        for (int i = 0; i < count; ++i)
        {
            _creature.Region?.CreateCreature(
                97407,
                new(
                    (uint)(
                        _creature.WorldPosition.X + Random.Shared.Next(20, 100) * ((Random.Shared.Next(0, 2) * 2) - 1)
                    ),
                    (uint)(
                        _creature.WorldPosition.Y + Random.Shared.Next(20, 100) * ((Random.Shared.Next(0, 2) * 2) - 1)
                    ),
                    _creature.WorldPosition.Z
                ),
                (ushort)Random.Shared.Next(4096)
            );
        }
    }
}
