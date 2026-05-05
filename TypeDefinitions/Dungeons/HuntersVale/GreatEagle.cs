namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums;
using Common.Positions;
using Game.NetWork.Handler;
using Game.Repositories.World;
using Game.World.Events;
using Game.World.Objects;
using WarEmu.Database.World.Database.Creatures;

[GeneralScript(CreatureEntry = 50004)]
internal class EagleShadow : CreatureScript
{
    private readonly CreatureProtoRepository _creatureProtoRepository;

    public EagleShadow(Creature creature, CreatureProtoRepository creatureProtoRepository)
        : base(creature)
    {
        _creatureProtoRepository = creatureProtoRepository;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        obj.Tasks.AddTask(SpawnEagle, 500, 1);
    }

    private void SpawnEagle()
    {
        CreatureProto? proto = _creatureProtoRepository.GetCreatureProto(50000);
        if (proto is null)
        {
            return;
        }

        _creature.Region?.CreateCreature(
            proto,
            new(_creature.WorldPosition.X, _creature.WorldPosition.Y, _creature.WorldPosition.Z),
            _creature.Heading
        );
    }
}

[GeneralScript(CreatureEntry = 50000)]
internal class GreatEagle : CreatureScript, IEventListener
{
    private Player? _carry;
    private IDisposable? _subscription;

    private static readonly Point3D[] _waypointsUp =
    [
        new(331385, 529436, 5076),
        new(331797, 529969, 5274),
        new(332115, 530583, 5556),
        new(331898, 531576, 5652),
        new(331037, 531713, 5793),
        new(329981, 531363, 6046),
        new(329156, 530589, 6450),
        new(328019, 529072, 7042),
        new(327152, 527588, 7589),
        new(326673, 526483, 7947),
        new(326395, 525553, 8013),
        new(326318, 525108, 8013),
    ];

    private static readonly Point3D[] _waypointsDown = [new(327317, 526196, 7521), new(329487, 528215, 6224)];

    public GreatEagle(Creature creature)
        : base(creature)
    {
        _subscription = creature.Events.Subscribe(this);
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        // Random 170 or 171
        obj.Tasks.AddTask(
            () =>
            {
                _creature.SendAnimation2((ushort)(Random.Shared.Next(2) == 0 ? 170 : 171));
            },
            500,
            1
        );
    }

    public override bool OnInteract(WorldObject obj, Player p, InteractMenu menu)
    {
        if (p.MountObject is null)
        {
            _carry = p;
            p.Mount(_creature);
            _creature.AiInterface.ClearWaypoints(false);
            _creature.Flying = true;

            _creature.AiInterface.CurrentWaypointType = CreatureWaypoint.WaypointType.StartToEnd;
            _creature.AiInterface.CurrentWaypointId = 0;

            _creature.AiInterface.AddWaypoint(
                new()
                {
                    Speed = 300,
                    WaitAtEnd = TimeSpan.Zero,
                    X = _creature.WorldPosition.X,
                    Y = _creature.WorldPosition.Y,
                    Z = (ushort)(_waypointsUp[0].Z + 200),
                }
            );

            foreach (Point3D point in _waypointsUp)
            {
                _creature.AiInterface.AddWaypoint(
                    new()
                    {
                        Speed = 300,
                        WaitAtEnd = TimeSpan.Zero,
                        X = point.X,
                        Y = point.Y,
                        Z = point.Z,
                    }
                );
            }
        }

        return true;
    }

    public void OnFinishedWaypointsEvent(ref FinishedWaypointsEvent eventValue)
    {
        if (_carry is not null)
        {
            // We reached top
            _carry.Mount(0);
            _carry = null;
            _creature.AiInterface.ClearWaypoints(false);
            _creature.AiInterface.CurrentWaypointId = 0;

            foreach (Point3D point in _waypointsDown)
            {
                _creature.AiInterface.AddWaypoint(
                    new()
                    {
                        Speed = 300,
                        WaitAtEnd = TimeSpan.Zero,
                        X = point.X,
                        Y = point.Y,
                        Z = point.Z,
                    }
                );
            }

            _creature.AiInterface.AddWaypoint(
                new()
                {
                    Speed = 300,
                    WaitAtEnd = TimeSpan.Zero,
                    X = _creature.WorldSpawnPoint.X,
                    Y = _creature.WorldSpawnPoint.Y,
                    Z = _creature.WorldSpawnPoint.Z,
                }
            );
        }
        else
        {
            // We returned to bottom
            _creature.Flying = false;
        }
    }
}
