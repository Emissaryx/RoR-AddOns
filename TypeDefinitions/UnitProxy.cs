namespace WorldServer.Scripting.MoonSharp.Proxies;

using Common.Enums.MythicAbilities;
using Common.Enums.SystemData;
using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using World.Objects;

[PublicAPI]
public class UnitProxy : WorldObjectProxy
{
    private readonly Unit _unit;

    [MoonSharpHidden]
    public UnitProxy(Unit unit)
        : base(unit)
    {
        _unit = unit;
    }

    [PublicAPI]
    public void Say(string message, ChatLogFilters chatFilter = ChatLogFilters.CHATLOGFILTERS_SAY) => _unit.Say(message, (ChatLogFilter)chatFilter);

    [PublicAPI]
    public uint Health => _unit.Health.Value;

    [PublicAPI]
    public uint HealthPercent => _unit.Health.Pct;

    [PublicAPI]
    public uint HealthMax => _unit.Health.Total;

    [PublicAPI]
    public bool IsDead => _unit.IsDead;

    [PublicAPI]
    public void Destroy() => _unit.Destroy();

    [PublicAPI]
    public int Realm => (int)_unit.Realm;

    [PublicAPI]
    public ushort Model { get => _unit.Model; set => _unit.Model = value; }

    [PublicAPI]
    public bool CastAbility(ushort abilityId, Unit? target = null) => _unit.AbilityCast.StartCast(abilityId, 0, allowNonAbilitySet: true, target: target) == AbilityResult.Ok;

    [PublicAPI]
    public bool HasAbility(ushort abilityId) => _unit.Abilities.HasAbilityById(abilityId);

    [PublicAPI]
    public bool HasLineOfSight(WorldObject other) => _unit.LosHit(other);

    #region Summoning

    [PublicAPI]
    public Creature? SummonCreature(uint protoId, uint x, uint y, ushort z, ushort o, SummonType summonType, int despawnTimer) => _unit.Region?.CreateSummonCreature(protoId, x, y, z, o, (SummonCreature.SummonType)summonType, _unit, despawnTimer);

    #endregion
}
