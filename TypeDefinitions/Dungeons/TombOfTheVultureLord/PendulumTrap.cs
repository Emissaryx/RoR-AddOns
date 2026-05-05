namespace Game.Scripts.Dungeons.TombOfTheVultureLord;

using Game.Repositories.World;
using Game.World.Objects;
using WarEmu.Database.World.Database.GameObjects;

public struct Position
{
    public uint X;
    public uint Y;
    public ushort Z;
    public ushort O;
}

public class PendulumTrapController : GameObjectScript
{
    private readonly Position[] _leverSpawns;
    private readonly Position[] _pendulumSpawns;
    private readonly Position[] _exitLeverSpawns;
    private readonly (Position Position, uint DoorId)[] _doorSpawns;

    public PendulumTrapController(
        GameObject gameObject,
        Position[] levers,
        Position[] pendulums,
        Position[] exitLevers,
        (Position Position, uint DoorId)[] doors
    )
        : base(gameObject)
    {
        _leverSpawns = levers;
        _pendulumSpawns = pendulums;
        _exitLeverSpawns = exitLevers;
        _doorSpawns = doors;
        _leversCompleted = new bool[levers.Length];
    }

    private readonly List<Lever> _levers = [];
    private readonly List<Pendulum> _pendulums = [];
    private readonly List<ExitLever> _exitLevers = [];
    private readonly List<Door> _doors = [];
    private readonly bool[] _leversCompleted;

    public bool IsComplete;

    public override void OnObjectLoad(WorldObject obj)
    {
        SpawnLevers();
        SpawnPendulums();
        SpawnExitLevers();
        SpawnDoors();
    }

    private void SpawnLevers()
    {
        GameObjectProto? proto = GameObjectRepository.Instance.GetGameObjectProto(98886);

        if (proto is null)
        {
            return;
        }

        for (uint i = 0; i < _leverSpawns.Length; ++i)
        {
            GameObjectSpawn spawn = new()
            {
                Entry = proto.Id,
                ZoneId = 179,
                WorldX = _leverSpawns[i].X,
                WorldY = _leverSpawns[i].Y,
                WorldZ = _leverSpawns[i].Z,
                WorldO = _leverSpawns[i].O,
            };
            spawn.BuildFromProto(proto);

            GameObject? marker = _gameObject.Region?.CreateGameObject(
                proto,
                new(_leverSpawns[i].X, _leverSpawns[i].Y, _leverSpawns[i].Z),
                _leverSpawns[i].O
            );

            if (marker is null)
            {
                return;
            }

            var script = new Lever(marker, this, i);
            _levers.Add(script);
            marker.Scripts.Scripts.Add(script);
        }
    }

    private void SpawnPendulums()
    {
        GameObjectProto? proto = GameObjectRepository.Instance.GetGameObjectProto(98908);

        if (proto is null)
        {
            return;
        }

        for (uint i = 0; i < _pendulumSpawns.Length; ++i)
        {
            GameObject? marker = _gameObject.Region?.CreateGameObject(
                proto,
                new(_pendulumSpawns[i].X, _pendulumSpawns[i].Y, _pendulumSpawns[i].Z),
                _pendulumSpawns[i].O
            );

            if (marker is null)
            {
                return;
            }

            var script = new Pendulum(marker, this);
            _pendulums.Add(script);
            marker.Scripts.Scripts.Add(script);
        }
    }

    private void SpawnExitLevers()
    {
        GameObjectProto? proto = GameObjectRepository.Instance.GetGameObjectProto(98886);

        if (proto is null)
        {
            return;
        }

        for (uint i = 0; i < _exitLeverSpawns.Length; ++i)
        {
            GameObject? marker = _gameObject.Region?.CreateGameObject(
                proto,
                new(_exitLeverSpawns[i].X, _exitLeverSpawns[i].Y, _exitLeverSpawns[i].Z),
                _exitLeverSpawns[i].O
            );

            if (marker is null)
            {
                return;
            }

            var script = new ExitLever(marker, this);
            _exitLevers.Add(script);
            marker.Scripts.Scripts.Add(script);
        }
    }

    private void SpawnDoors()
    {
        GameObjectProto? proto = GameObjectRepository.Instance.GetGameObjectProto(200202351);

        if (proto is null)
        {
            return;
        }

        for (uint i = 0; i < _doorSpawns.Length; ++i)
        {
            GameObjectSpawn spawn = new()
            {
                Entry = proto.Id,
                ZoneId = 179,
                WorldX = _doorSpawns[i].Position.X,
                WorldY = _doorSpawns[i].Position.Y,
                WorldZ = _doorSpawns[i].Position.Z,
                WorldO = _doorSpawns[i].Position.O,
                DoorId = _doorSpawns[i].DoorId,
            };
            spawn.BuildFromProto(proto);

            GameObject? marker = _gameObject.Region?.CreateGameObject(spawn);

            if (marker is null)
            {
                return;
            }

            var script = new Door(marker);
            _doors.Add(script);
            marker.Scripts.Scripts.Add(script);
        }
    }

    public void LeverCompleted(uint leverId)
    {
        _leversCompleted[leverId] = true;

        if (!_gameObject.Tasks.HasTask(CheckLevers))
        {
            _gameObject.Tasks.AddTask(CheckLevers, 15000, 1);
        }
    }

    public void SetTrapStatus(bool completed)
    {
        IsComplete = completed;

        foreach (var exitLever in _exitLevers)
        {
            exitLever.SetLeverState(completed);
        }

        foreach (var lever in _levers)
        {
            lever.SetLeverState(completed);
        }

        foreach (var door in _doors)
        {
            door.DoorState(completed);
        }
    }

    private void CheckLevers()
    {
        for (int i = 0; i < _leversCompleted.Length; ++i)
        {
            if (!_leversCompleted[i])
            {
                foreach (var lever in _levers)
                {
                    lever.SetLeverState(false);
                }

                return;
            }
        }

        SetTrapStatus(true);
    }
}

public sealed class Lever : GameObjectScript
{
    private readonly PendulumTrapController _controller;
    private readonly uint _leverId;

    public Lever(GameObject gameObject, PendulumTrapController controller, uint leverId)
        : base(gameObject)
    {
        _controller = controller;
        _leverId = leverId;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _gameObject.Interactable = true;
    }

    public override void NotifyInteractionComplete(WorldObject obj, Player interactor)
    {
        _controller.LeverCompleted(_leverId);
        SetLeverState(true);
    }

    public void SetLeverState(bool completed)
    {
        if (completed)
        {
            if (!_gameObject.Interactable)
            {
                return;
            }

            _gameObject.VfxState = 1;
            _gameObject.Interactable = false;
        }
        else
        {
            if (_gameObject.Interactable)
            {
                return;
            }

            _gameObject.Interactable = true;
            _gameObject.VfxState = 2;
        }
    }
}

public sealed class ExitLever : GameObjectScript
{
    private readonly PendulumTrapController _controller;

    public ExitLever(GameObject gameObject, PendulumTrapController controller)
        : base(gameObject)
    {
        _controller = controller;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _gameObject.Interactable = true;
    }

    public override void NotifyInteractionComplete(WorldObject obj, Player interactor)
    {
        _controller.SetTrapStatus(!_controller.IsComplete);
    }

    public void SetLeverState(bool complete)
    {
        if (complete)
        {
            _gameObject.VfxState = 1;
        }
        else
        {
            _gameObject.VfxState = 2;
        }
    }
}

public sealed class Door : GameObjectScript
{
    public Door(GameObject gameObject)
        : base(gameObject) { }

    public void DoorState(bool open)
    {
        if (open)
        {
            _gameObject.VfxState = 1;
        }
        else
        {
            _gameObject.VfxState = 0;
        }
    }
}

public sealed class Pendulum : GameObjectScript
{
    /*
        Pendulum VFX
        0 - Idle_Right  (stay right)
        1 - Swing_clockwise 1.5s (start right end left)
        2 - idle_left (stay left)
        3 - swing_counterclockwise 1.5s (start left end right)
        4 - 5swingLeft 6s (start right end left)
        5 - 5swingRight 6s (start left end right)
        6 - 10swing 8s (start right end right)
     */
    private static readonly (byte State, int Duration)[][] _sequence =
    [
        // Total 13s - 2s downtime
        [(0, 1000), (1, 1500), (3, 1500), (0, 1500), (4, 6000), (3, 1500)],
        // Total 13s - 1s downtime
        [(4, 6000), (5, 6000), (0, 1000)],
        // Total 13s - 2s downtime
        [(6, 8000), (0, 1000), (1, 1500), (2, 1000), (3, 1500)],
        // Total 13s - 2s downtime
        [(1, 1500), (2, 2000), (3, 1500), (6, 8000)],
        // Total 13s - 1.5s downtime
        [(1, 1500), (2, 1000), (3, 1500), (0, 1000), (1, 1500), (5, 6000), (0, 500)],
        // Total 19s - 1s downtime
        [(4, 6000), (5, 6000), (4, 6000), (2, 1000)],
        // Total 9s - 1s downtime
        [(6, 8000), (0, 1000)],
    ];

    private long _nextUpdate;
    private byte _sequencePosition;
    private readonly byte _pattern;

    private readonly PendulumTrapController _controller;

    public Pendulum(GameObject gameObject, PendulumTrapController controller)
        : base(gameObject)
    {
        _controller = controller;
        _pattern = (byte)Random.Shared.Next(0, _sequence.Length);
    }

    public override void OnWorldUpdate(WorldObject obj, long tick)
    {
        if (tick < _nextUpdate)
        {
            return;
        }

        // If the controller says the trap is complete and we are in state 0 or 2 hold it here
        if (_controller.IsComplete && _sequence[_pattern][_sequencePosition].State is 0 or 2)
        {
            _nextUpdate = tick + 5000;
            return;
        }

        var nextSequence = _sequence[_pattern][_sequencePosition++];

        if (_sequencePosition == _sequence[_pattern].Length)
        {
            _sequencePosition = 0;
        }

        _gameObject.VfxState = nextSequence.State;
        _nextUpdate = tick + nextSequence.Duration;
    }
}

[GeneralScript(GameObjectEntry = 200202349)]
public class RightPendulumTrapController : PendulumTrapController
{
    private static readonly Position[] _levers =
    [
        // Left 1
        new()
        {
            X = 347880,
            Y = 280236,
            Z = 12697,
            O = 2048,
        },
        // Left 2
        new()
        {
            X = 347696,
            Y = 280236,
            Z = 12709,
            O = 2048,
        },
        // Right 1
        new()
        {
            X = 347882,
            Y = 279823,
            Z = 12697,
            O = 11,
        },
    ];

    private static readonly Position[] _exitLevers =
    [
        new()
        {
            X = 347167,
            Y = 280536,
            Z = 12634,
            O = 2048,
        },
    ];

    private static readonly Position[] _pendulums =
    [
        // 1
        new()
        {
            X = 348784,
            Y = 280031,
            Z = 12659,
            O = 2048,
        },
        // 2
        new()
        {
            X = 348664,
            Y = 280031,
            Z = 12659,
            O = 2048,
        },
        // 3
        new()
        {
            X = 348544,
            Y = 280031,
            Z = 12659,
            O = 2048,
        },
        // 4
        new()
        {
            X = 348424,
            Y = 280031,
            Z = 12659,
            O = 2048,
        },
        // 5
        new()
        {
            X = 348304,
            Y = 280031,
            Z = 12659,
            O = 2048,
        },
        // 6
        new()
        {
            X = 348184,
            Y = 280031,
            Z = 12659,
            O = 2048,
        },
    ];

    private static readonly (Position Position, uint DoorId)[] _doors =
    [
        (
            new()
            {
                X = 347415,
                Y = 280435,
                Z = 12656,
                O = 1986,
            },
            187787368
        ),
    ];

    public RightPendulumTrapController(GameObject gameObject)
        : base(gameObject, _levers, _pendulums, _exitLevers, _doors) { }
}

[GeneralScript(GameObjectEntry = 200202350)]
public class LeftPendulumTrapController : PendulumTrapController
{
    private static readonly Position[] _levers =
    [
        // Left 1
        new()
        {
            X = 347880,
            Y = 283073,
            Z = 12697,
            O = 2048,
        },
        // Left 2
        new()
        {
            X = 347652,
            Y = 283073,
            Z = 12697,
            O = 2048,
        },
        // Right 1
        new()
        {
            X = 347882,
            Y = 282667,
            Z = 12697,
            O = 4096,
        },
    ];

    private static readonly Position[] _exitLevers =
    [
        new()
        {
            X = 347169,
            Y = 282352,
            Z = 12634,
            O = 4096,
        },
    ];

    private static readonly Position[] _pendulums =
    [
        // 1
        new()
        {
            X = 348784,
            Y = 282876,
            Z = 12659,
            O = 2048,
        },
        // 2
        new()
        {
            X = 348664,
            Y = 282876,
            Z = 12659,
            O = 2048,
        },
        // 3
        new()
        {
            X = 348544,
            Y = 282876,
            Z = 12659,
            O = 2048,
        },
        // 4
        new()
        {
            X = 348424,
            Y = 282876,
            Z = 12659,
            O = 2048,
        },
        // 5
        new()
        {
            X = 348304,
            Y = 282876,
            Z = 12659,
            O = 2048,
        },
        // 6
        new()
        {
            X = 348184,
            Y = 282876,
            Z = 12659,
            O = 2048,
        },
    ];

    private static readonly (Position Position, uint DoorId)[] _doors =
    [
        (
            new()
            {
                X = 347410,
                Y = 282455,
                Z = 12656,
                O = 4055,
            },
            187787304
        ),
    ];

    public LeftPendulumTrapController(GameObject gameObject)
        : base(gameObject, _levers, _pendulums, _exitLevers, _doors) { }
}
