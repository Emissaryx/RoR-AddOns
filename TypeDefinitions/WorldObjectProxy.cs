namespace WorldServer.Scripting.MoonSharp.Proxies;

using Common.Positions;
using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using WorldServer.World.Objects;

[PublicAPI]
public class WorldObjectProxy
{
    private readonly WorldObject _worldObject;

    [MoonSharpHidden]
    public WorldObjectProxy(WorldObject worldObject)
    {
        _worldObject = worldObject;
    }

    [PublicAPI]
    public string Name => _worldObject.Name;

    [PublicAPI]
    public void PlaySound(ushort soundId) => _worldObject.PlaySound(soundId);

    [PublicAPI]
    public void PlayEffect(ushort effectId) => _worldObject.PlayEffect(effectId);

    [PublicAPI]
    public HashSet<Player> PlayersInRange => _worldObject.PlayersInRange;

    [PublicAPI]
    public HashSet<WorldObject> ObjectsInRange => _worldObject.ObjectsInRange;

    [PublicAPI]
    public List<Player> GetPlayersInRange(uint range = 2400) => _worldObject.PlayersInRange.Where(p => p.WorldPosition.IsWithin3DRadiusUnits(_worldObject.WorldPosition, range)).ToList();

    [PublicAPI]
    public List<GameObject> GetGameObjectsInRange(uint range = 2400, uint? gameObjectEntryId = null) => _worldObject.ObjectsInRange.Where(o => o is GameObject gameObject && (gameObjectEntryId is null || gameObject.Entry == gameObjectEntryId) && gameObject.WorldPosition.IsWithin3DRadiusUnits(_worldObject.WorldPosition, range)).OfType<GameObject>().ToList();

    [PublicAPI]
    public List<Creature> GetCreaturesInRange(uint range = 2400, uint? creatureEntryId = null) => _worldObject.ObjectsInRange.Where(o => o is Creature creature && (creatureEntryId is null || creature.Entry == creatureEntryId) && creature.WorldPosition.IsWithin3DRadiusUnits(_worldObject.WorldPosition, range)).OfType<Creature>().ToList();

    [PublicAPI]
    public GameObject? SpawnGameObject(uint gameObjectProtoId, uint x, uint y, ushort z, ushort o) => _worldObject.Region?.CreateGameObject(gameObjectProtoId, new Point3D(x, y, z), o) ?? null;

    [PublicAPI]
    public GameObject? GetNearestGameObject(uint range = 2400, uint? gameObjectEntryId = null) => _worldObject.ObjectsInRange.Where(o => o is GameObject gameObject && (gameObjectEntryId is null || gameObject.Entry == gameObjectEntryId) && gameObject.WorldPosition.IsWithin3DRadiusUnits(_worldObject.WorldPosition, range)).MinBy(o => o.Get3DDistanceUnits(_worldObject)) as GameObject;

    [PublicAPI]
    public Creature? GetNearestCreature(uint range = 2400, uint? creatureEntryId = null) => _worldObject.ObjectsInRange.Where(o => o is Creature creature && (creatureEntryId is null || creature.Entry == creatureEntryId) && creature.WorldPosition.IsWithin3DRadiusUnits(_worldObject.WorldPosition, range)).MinBy(o => o.Get3DDistanceUnits(_worldObject)) as Creature;

    [PublicAPI]
    public Player? GetNearestPlayer(uint range = 2400, uint? gameObjectEntryId = null) => _worldObject.PlayersInRange.Where(p => p.WorldPosition.IsWithin3DRadiusUnits(_worldObject.WorldPosition, range)).MinBy(p => p.Get3DDistanceUnits(_worldObject));

    [PublicAPI]
    public double GetDistanceTo(Unit other) => _worldObject.WorldPosition.Get3DDistanceUnits(other.WorldPosition);

    #region World

    [PublicAPI]
    public ushort RegionId => _worldObject.Region?.RegionId ?? 0;

    [PublicAPI]
    public ushort ZoneId => _worldObject.ZoneId;

    [PublicAPI]
    public uint X => _worldObject.WorldPosition.X;

    [PublicAPI]
    public uint Y => _worldObject.WorldPosition.Y;

    [PublicAPI]
    public uint Z => _worldObject.WorldPosition.Z;

    [PublicAPI]
    public uint O => _worldObject.Heading;

    [PublicAPI]
    public bool IsWithin3DRadiusFeet(WorldObject worldObject, uint range) => _worldObject.IsWithin3DRadiusFeet(worldObject, range);

    #endregion

    #region Is

    [PublicAPI]
    public bool IsPlayer => _worldObject is Player;

    [PublicAPI]
    public bool IsCreature => _worldObject is Creature;

    [PublicAPI]
    public bool IsGameObject => _worldObject is GameObject;

    [PublicAPI]
    public bool IsUnit => _worldObject is Unit;

    [PublicAPI]
    public Player? AsPlayer => _worldObject as Player;

    [PublicAPI]
    public Creature? AsCreature => _worldObject as Creature;

    [PublicAPI]
    public GameObject? AsGameObject => _worldObject as GameObject;

    [PublicAPI]
    public Unit? AsUnit => _worldObject as Unit;

    #endregion
}
