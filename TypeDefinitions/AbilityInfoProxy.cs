namespace WorldServer.Scripting.MoonSharp.Proxies;

using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using WarEmu.Database.World.Database.MythicAbilities;

public sealed class AbilityInfoProxy
{
    private readonly AbilityInfo _abilityInfo;

    [MoonSharpHidden]
    public AbilityInfoProxy(AbilityInfo abilityInfo)
    {
        _abilityInfo = abilityInfo;
    }

    [PublicAPI]
    public ushort Id => _abilityInfo.Id;

    [PublicAPI]
    public string Name => _abilityInfo.Name ?? string.Empty;

    [PublicAPI]
    public uint CastTime => _abilityInfo.CastTime;

    [PublicAPI]
    public byte ActionPointCost => _abilityInfo.AP;
}
