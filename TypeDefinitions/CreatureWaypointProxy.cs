namespace WorldServer.Scripting.MoonSharp.Proxies;

using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using WarEmu.Database.World.Database.Creatures;

public class CreatureWaypointProxy
{
    private readonly  CreatureWaypoint _creatureWaypoint;

    [MoonSharpHidden]
    public CreatureWaypointProxy( CreatureWaypoint creatureWaypoint)
    {
        _creatureWaypoint = creatureWaypoint;
    }

    [PublicAPI]
    public Guid Id => _creatureWaypoint.Id;

    [PublicAPI]
    public uint X => _creatureWaypoint.X;

    [PublicAPI]
    public uint Y => _creatureWaypoint.Y;

    [PublicAPI]
    public ushort Z => _creatureWaypoint.Z;

    [PublicAPI]
    public ushort Heading => _creatureWaypoint.O;
}
