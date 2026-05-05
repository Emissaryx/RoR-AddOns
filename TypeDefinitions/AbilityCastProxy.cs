namespace WorldServer.Scripting.MoonSharp.Proxies;

using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using World.Abilities;
using World.Objects;

public class AbilityCastProxy
{
    private readonly AbilityCast _abilityCast;

    [MoonSharpHidden]
    public AbilityCastProxy(AbilityCast abilityCast)
    {
        _abilityCast = abilityCast;
    }

    [PublicAPI]
    public ushort Id => _abilityCast.Ability.Id;

    [PublicAPI]
    public string Name => _abilityCast.Ability.Name ?? string.Empty;

    [PublicAPI]
    public uint CastTime => _abilityCast.CastTime;

    [PublicAPI]
    public ushort ActionPointCost => _abilityCast.Ap;

    [PublicAPI]
    public Unit Caster => _abilityCast.Caster;

    [PublicAPI]
    public Unit Target => _abilityCast.Target;
}
