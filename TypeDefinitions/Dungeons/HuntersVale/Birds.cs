namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums;
using Game.World.Events;
using Game.World.Objects;

[GeneralScript(creatureEntry: 2400)]
internal class Birds : CreatureScript, IEventListener
{
    private IDisposable? _subscription;

    public Birds(Creature cre)
        : base(cre)
    {
        cre.Tasks.AddTask(CheckActivationRange, 5000, 0);
    }

    private void CheckActivationRange()
    {
        foreach (Player plr in _creature.PlayersInRange)
        {
            if (!plr.IsDead && !plr.Stealth.IsInGameMasterStealth && _creature.IsWithin3DRadiusUnits(plr, 600))
            {
                _creature.Tasks.RemoveTask(CheckActivationRange);
                Start();
                break;
            }
        }
    }

    private void Start()
    {
        _creature.Flying = true;
        _creature.AiInterface.AddWaypoint(
            new()
            {
                X = (uint)(
                    _creature.WorldPosition.X + (Random.Shared.Next(0, 2000) * ((Random.Shared.Next(0, 2) * 2) - 1))
                ),
                Y = (uint)(
                    _creature.WorldPosition.Y + (Random.Shared.Next(0, 2000) * ((Random.Shared.Next(0, 2) * 2) - 1))
                ),
                Z = (ushort)(_creature.WorldPosition.Z + 1000),
                WaitAtEnd = TimeSpan.Zero,
                Speed = 200,
            }
        );

        _subscription = _creature.Events.Subscribe(this);
    }

    public void OnFinishedWaypointEvent(ref FinishedWaypointEvent eventValue)
    {
        _subscription?.Dispose();
        _subscription = null;
        _creature.Destroy();
    }
}
