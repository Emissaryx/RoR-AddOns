namespace Game.Scripts.Dungeons.HuntersVale;

using Game.Repositories.World;
using Game.World.Objects;
using WarEmu.Database.World.Database.Creatures;
using WarEmu.Database.World.Database.GameObjects;

[GeneralScript(GameObjectEntry = 500000)]
internal class RunestonePuzzle : GameObjectScript
{
    private readonly GameObjectRepository _gameObjectRepository;
    private readonly CreatureProtoRepository _creatureProtoRepository;

    private sealed class PuzzlePosition
    {
        public ushort ZoneId;
        public uint X;
        public uint Y;
        public ushort Z;
        public ushort O;
    }

    /*
     * These are the icons that appear on the floor once you have stepped on the correct one.
     * They are also used to detect if a player is stepping on them.
     */
    private static readonly uint[] _runestoneGameObjects = [500001, 500002, 500003, 500004, 500005, 500006];

    private static readonly PuzzlePosition[] _runestone =
    [
        new()
        {
            ZoneId = 50,
            X = 331525,
            Y = 529878,
            Z = 4593,
            O = 1806,
        },
        new()
        {
            ZoneId = 50,
            X = 331789,
            Y = 529652,
            Z = 4593,
            O = 1228,
        },
        new()
        {
            ZoneId = 50,
            X = 330922,
            Y = 529687,
            Z = 4593,
            O = 2548,
        },
        new()
        {
            ZoneId = 50,
            X = 331650,
            Y = 529035,
            Z = 4593,
            O = 557,
        },
        new()
        {
            ZoneId = 50,
            X = 331321,
            Y = 528928,
            Z = 4593,
            O = 3900,
        },
        new()
        {
            ZoneId = 50,
            X = 330854,
            Y = 529357,
            Z = 4593,
            O = 3234,
        },
    ];

    /*
     * These are the different icons that will appear on the pillars.
     * The positions are below.
     */
    private static readonly uint[] _pillarstoneGameObjects = [500007, 500008, 500009, 500010, 500011, 500012];

    private static readonly PuzzlePosition[] _pillarstone =
    [
        new()
        {
            ZoneId = 50,
            X = 331138,
            Y = 529969,
            Z = 4795,
            O = 2230,
        },
        new()
        {
            ZoneId = 50,
            X = 330966,
            Y = 529004,
            Z = 4775,
            O = 3629,
        },
        new()
        {
            ZoneId = 50,
            X = 331897,
            Y = 529311,
            Z = 4786,
            O = 864,
        },
    ];

    private static readonly PuzzlePosition[] _pillarstoneMarkersPositions =
    [
        new()
        {
            ZoneId = 50,
            X = 331193,
            Y = 529889,
            Z = 4587,
            O = 0,
        },
        new()
        {
            ZoneId = 50,
            X = 331020,
            Y = 529061,
            Z = 4588,
            O = 0,
        },
        new()
        {
            ZoneId = 50,
            X = 331824,
            Y = 529319,
            Z = 4587,
            O = 0,
        },
    ];

    /*
     * Positions to spawn the birds once game is complete
     */
    private static readonly PuzzlePosition[] _birds =
    [
        new()
        {
            ZoneId = 50,
            X = 331673,
            Y = 529352,
            Z = 4586,
            O = 921,
        },
        new()
        {
            ZoneId = 50,
            X = 331253,
            Y = 529738,
            Z = 4586,
            O = 2264,
        },
        new()
        {
            ZoneId = 50,
            X = 331403,
            Y = 529074,
            Z = 4586,
            O = 79,
        },
        new()
        {
            ZoneId = 50,
            X = 331015,
            Y = 529531,
            Z = 4584,
            O = 2889,
        },
        new()
        {
            ZoneId = 50,
            X = 331574,
            Y = 529637,
            Z = 4586,
            O = 1513,
        },
        new()
        {
            ZoneId = 50,
            X = 331125,
            Y = 529181,
            Z = 4586,
            O = 3618,
        },
    ];

    private readonly bool[] _activatedPillarMarkers = new bool[3];
    private readonly bool[] _activatedRunestoneMarkers = new bool[6];

    private readonly int[] _chosenIcons = new int[3];

    private readonly Dictionary<uint, GameObject> _runestoneMarkers = new();
    private readonly Dictionary<uint, GameObject> _pillarstoneMarkers = new();
    private bool _gameComplete;

    public RunestonePuzzle(
        GameObject gameObject,
        GameObjectRepository gameObjectRepository,
        CreatureProtoRepository creatureProtoRepository
    )
        : base(gameObject)
    {
        _gameObjectRepository = gameObjectRepository;
        _creatureProtoRepository = creatureProtoRepository;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        ChoseRandomIcons();
        SpawnRunestoneMarkers();
        SpawnPillatstoneMarkers();
    }

    private void ChoseRandomIcons()
    {
        // Chose 3 random icons from 0-5
        List<int> randomList = [];

        for (int i = 0; i < 3; ++i)
        {
            bool validNumber = false;
            int myNumber = 0;

            while (!validNumber)
            {
                myNumber = Random.Shared.Next(0, 6);
                if (!randomList.Contains(myNumber))
                {
                    randomList.Add(myNumber);
                    validNumber = true;
                }
            }

            _chosenIcons[i] = myNumber;
        }
    }

    private void SpawnRunestoneMarkers()
    {
        GameObjectProto? proto = _gameObjectRepository.GetGameObjectProto(500013);

        if (proto is null)
        {
            return;
        }

        for (uint i = 0; i < _runestone.Length; ++i)
        {
            GameObject? marker = _gameObject.Region?.CreateGameObject(
                proto,
                new(_runestone[i].X, _runestone[i].Y, _runestone[i].Z),
                _runestone[i].O
            );

            if (marker is null)
            {
                return;
            }

            marker.Scripts.Scripts.Add(new RunestonePuzzleRunestoneMarker(marker, this, i));
        }
    }

    private void SpawnPillatstoneMarkers()
    {
        GameObjectProto? proto = _gameObjectRepository.GetGameObjectProto(500013);

        if (proto is null)
        {
            return;
        }

        for (uint i = 0; i < _pillarstone.Length; ++i)
        {
            GameObject? marker = _gameObject.Region?.CreateGameObject(
                proto,
                new(
                    _pillarstoneMarkersPositions[i].X,
                    _pillarstoneMarkersPositions[i].Y,
                    _pillarstoneMarkersPositions[i].Z
                ),
                _pillarstoneMarkersPositions[i].O
            );

            if (marker is null)
            {
                return;
            }

            marker.Scripts.Scripts.Add(new RunestonePuzzlePillarstoneMarker(marker, this, i));
        }
    }

    private void SpawnBirds()
    {
        CreatureProto? proto = _creatureProtoRepository.GetCreatureProto(50004);

        if (proto is null)
        {
            return;
        }

        for (uint i = 0; i < _birds.Length; ++i)
        {
            _gameObject.Region?.CreateCreature(proto, new(_birds[i].X, _birds[i].Y, _birds[i].Z), _birds[i].O);
        }
    }

    public void ActivateRunestoneMarker(uint id)
    {
        if (_gameComplete)
        {
            return;
        }

        if (_activatedRunestoneMarkers[id])
        {
            return;
        }

        // GameObject.Say("Activated Runestone: " + id);
        _activatedRunestoneMarkers[id] = true;

        GameObjectProto? proto = _gameObjectRepository.GetGameObjectProto(_runestoneGameObjects[id]);
        if (proto is null)
        {
            return;
        }

        GameObject? marker = _gameObject.Region?.CreateGameObject(
            proto,
            new(_runestone[id].X, _runestone[id].Y, _runestone[id].Z),
            _runestone[id].O
        );
        if (marker is null)
        {
            return;
        }

        _runestoneMarkers.Add(id, marker);

        EvaluateState();
    }

    public void DeactivateRunestoneMarker(uint id)
    {
        if (_gameComplete)
        {
            return;
        }

        if (!_activatedRunestoneMarkers[id])
        {
            return;
        }

        // GameObject.Say("Deactivated Runestone: " + id);
        _activatedRunestoneMarkers[id] = false;
        if (_runestoneMarkers.ContainsKey(id))
        {
            _runestoneMarkers[id].Dispose();
            _runestoneMarkers.Remove(id);
        }

        EvaluateState();
    }

    public void ActivatePillarstoneMarker(uint id)
    {
        if (_gameComplete)
        {
            return;
        }

        if (_activatedPillarMarkers[id])
        {
            return;
        }

        // GameObject.Say("Activated Pillar: " + id);
        _activatedPillarMarkers[id] = true;

        GameObjectProto? proto = _gameObjectRepository.GetGameObjectProto(_pillarstoneGameObjects[_chosenIcons[id]]);
        if (proto is null)
        {
            return;
        }

        GameObject? marker = _gameObject.Region?.CreateGameObject(
            proto,
            new(_pillarstone[id].X, _pillarstone[id].Y, _pillarstone[id].Z),
            _pillarstone[id].O
        );

        if (marker is null)
        {
            return;
        }

        _pillarstoneMarkers.Add(id, marker);

        EvaluateState();
    }

    public void DeactivatePillarstoneMarker(uint id)
    {
        if (_gameComplete)
        {
            return;
        }

        if (!_activatedPillarMarkers[id])
        {
            return;
        }

        // GameObject.Say("Deactivated Pillar: " + id);
        _activatedPillarMarkers[id] = false;

        if (_pillarstoneMarkers.ContainsKey(id))
        {
            _pillarstoneMarkers[id].Dispose();
            _pillarstoneMarkers.Remove(id);
        }

        EvaluateState();
    }

    private void EvaluateState()
    {
        if (_gameComplete)
        {
            return;
        }

        // Puzzle.Say("================================");
        bool badMarker = false;
        bool completed = true;
        int pillarsActive = 0;
        int runestonesActive = 0;

        for (int i = 0; i < 6; ++i)
        {
            bool validRunestone = false;
            bool activatedRunestone = _activatedRunestoneMarkers[i];
            bool activatedPillar = false;

            for (int j = 0; j < 3; ++j)
            {
                if (_chosenIcons[j] == i)
                {
                    validRunestone = true;
                    activatedPillar = _activatedPillarMarkers[j];
                    break;
                }
            }

            // If pillar active
            if (activatedPillar)
            {
                pillarsActive++;
            }

            // if runestone active
            if (activatedRunestone)
            {
                runestonesActive++;
            }

            // If bad runestone, but activated the marker = fail
            if (!validRunestone && activatedRunestone)
            {
                // Puzzle.Say("Incorrect marker activated " + i);
                badMarker = true;
                break;
            }

            // If good runestone, but not yet activated = continue
            if (validRunestone && !activatedRunestone)
            {
                // Puzzle.Say("Not yet activated " + i);
                completed = false;
                continue;
            }

            // If good runestone, activated the marker, but the pillar wasnt active = fail
            if (validRunestone && activatedRunestone && !activatedPillar)
            {
                // Puzzle.Say("valid runestone activated without pillar " + i);
                badMarker = true;
            }
        }

        // If we steppted on a bad marker OR we activated an extra pillar without the previous runestone
        if (badMarker || pillarsActive > runestonesActive + 1)
        {
            // Kill players /w Lightning Strike
            // kill how many players already on puzzle at random
            Punish();
            _gameObject.Tasks.AddTask(Punish, 1000, 0);

            // Reset puzzle
            ChoseRandomIcons();
            return;
        }

        _gameObject.Tasks.RemoveTask(Punish);

        if (completed)
        {
            // Spawn birds
            _gameComplete = true;
            SpawnBirds();

            // GameObject.Say("Success ");
        }

        // GameObject.Say("Pending");
    }

    private void Punish()
    {
        var player = _gameObject.PlayersInRange.FirstOrDefault();

        if (player is null)
        {
            return;
        }

        player.Abilities.AddAbility(24617, player, player.EffectiveLevel);
    }
}

internal sealed class RunestonePuzzleRunestoneMarker : GameObjectScript
{
    private readonly RunestonePuzzle _puzzle;
    private readonly uint _markerId;

    public RunestonePuzzleRunestoneMarker(GameObject gameObject, RunestonePuzzle puzzle, uint markerId)
        : base(gameObject)
    {
        _puzzle = puzzle;
        _markerId = markerId;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        obj.Tasks.AddTask(CheckPlayers, 2000, 0);
    }

    private void CheckPlayers()
    {
        foreach (Player p in _gameObject.PlayersInRange)
        {
            if (_gameObject.IsWithin3DRadiusUnits(p, 84) && !p.IsDead)
            {
                _puzzle.ActivateRunestoneMarker(_markerId);
                return;
            }
        }

        _puzzle.DeactivateRunestoneMarker(_markerId);
    }
}

internal sealed class RunestonePuzzlePillarstoneMarker : GameObjectScript
{
    private readonly RunestonePuzzle _puzzle;
    private readonly uint _markerId;

    public RunestonePuzzlePillarstoneMarker(GameObject gameObject, RunestonePuzzle puzzle, uint markerId)
        : base(gameObject)
    {
        _puzzle = puzzle;
        _markerId = markerId;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        obj.Tasks.AddTask(CheckPlayers, 2000, 0);
    }

    private void CheckPlayers()
    {
        foreach (Player p in _gameObject.PlayersInRange)
        {
            if (_gameObject.IsWithin3DRadiusUnits(p, 84) && !p.IsDead)
            {
                _puzzle.ActivatePillarstoneMarker(_markerId);
                return;
            }
        }

        _puzzle.DeactivatePillarstoneMarker(_markerId);
    }
}
