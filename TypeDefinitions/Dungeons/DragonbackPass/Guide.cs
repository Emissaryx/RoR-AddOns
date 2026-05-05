namespace Game.Scripts.Dungeons.DragonbackPass;

using Game.World.Objects;

public class GuideScript : CreatureScript
{
    private readonly ushort _encounterId;

    protected GuideScript(Creature creature, ushort encounterId)
        : base(creature)
    {
        _encounterId = encounterId;
    }

    private long _nextCheck = 0;

    public override void OnWorldUpdate(WorldObject obj, long tick)
    {
        if (tick < _nextCheck)
        {
            return;
        }

        if (_creature.Region?.Instance?.HasCompletedEncounter(_encounterId) ?? false)
        {
            _creature.Destroy();
            return;
        }

        _nextCheck = (long)(tick + TimeSpan.FromSeconds(1).TotalMilliseconds);
    }
}

[GeneralScript(CreatureEntry = 100901)]
public class OrderGuide1(Creature creature) : GuideScript(creature, 1);

[GeneralScript(CreatureEntry = 100961)]
public class OrderGuide2(Creature creature) : GuideScript(creature, 2);

[GeneralScript(CreatureEntry = 100965)]
public class OrderGuide3(Creature creature) : GuideScript(creature, 3);

[GeneralScript(CreatureEntry = 100921)]
public class DestructionGuide1(Creature creature) : GuideScript(creature, 1);

[GeneralScript(CreatureEntry = 100985)]
public class DestructionGuide2(Creature creature) : GuideScript(creature, 2);

[GeneralScript(CreatureEntry = 100986)]
public class DestructionGuide3(Creature creature) : GuideScript(creature, 3);
