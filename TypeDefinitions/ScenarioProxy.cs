namespace WorldServer.Scripting.MoonSharp.Proxies;

using Common.Enums;
using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using Game.World.Scenarios;

[PublicAPI]
public sealed class ScenarioProxy
{
    private readonly Scenario _scenario;

    [MoonSharpHidden]
    public ScenarioProxy(Scenario scenario)
    {
        _scenario = scenario;
    }

    [PublicAPI]
    public ushort Id => _scenario.Info.Id;

    [PublicAPI]
    public string Name => _scenario.Info.Name;

    [PublicAPI]
    public bool HasStarted => _scenario.HasStarted;

    [PublicAPI]
    public bool HasEnded => _scenario.HasEnded;

    [PublicAPI]
    public uint GetScore(Realms realm) => _scenario.Score[realm.ScenarioTeam()];

    [PublicAPI]
    public int GetPlayerCount(Realms realm) => _scenario.GetTotalTeamCount(realm.ScenarioTeam());

    [PublicAPI]
    public int GetDurationSeconds() => (int)_scenario.Duration.TotalSeconds;

    [PublicAPI]
    public int GetTimeRemainingSeconds()
    {
        if (!_scenario.HasStarted || _scenario.HasEnded)
        {
            return 0;
        }

        TimeSpan remaining = _scenario.Duration - (DateTimeOffset.UtcNow - _scenario.StartTime);
        return Math.Max(0, (int)remaining.TotalSeconds);
    }

    [PublicAPI]
    public void Announce(string message) => _scenario.Packet.SendChatMessage(message);

    [PublicAPI]
    public void AddScore(Realms realm, uint points) => _scenario.GivePoints(realm, points);
}
