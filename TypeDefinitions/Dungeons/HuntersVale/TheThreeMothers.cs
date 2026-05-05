namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Positions;
using Game.World.Events;
using Game.World.Objects;

/*
 * The Three Mothers Script
 *
 * Once a player activates (by going near) the object
 * the first mother is spawned, and every 10 seconds,
 * 3 of its babies will spawn and run to the start,
 * once the mother is killed, the next mother will spawn,
 * and its babies will start spawning etc.
 */

[GeneralScript(CreatureEntry = 97460)]
internal class TheThreeMothers : CreatureScript, IEventListener
{
    private readonly ILogger<TheThreeMothers> _logger;

    #region Static Data

    private static readonly uint[] _mothers = [97449, 97444, 97435];

    private static readonly uint[][] _mothersSpawns =
    [
        [324911, 524141, 3712, 614],
        [321908, 518063, 4866, 170],
        [330457, 524350, 4408, 3060],
    ];

    private static readonly uint[] _babies = [97445, 6822, 2000740];

    private static readonly Point3D[] _babiesSpawns =
    [
        new(324795, 524331, 3688),
        new(321698, 517729, 4812),
        new(329903, 524469, 4397),
    ];

    private static readonly Point3D[][] _waypoints =
    [
        [
            new(324581, 524802, 3688),
            new(324948, 525605, 3688),
            new(325653, 526357, 3720),
            new(326832, 526508, 3717),
            new(327901, 526488, 3675),
            new(328607, 526391, 3590),
            new(328986, 527151, 3390),
        ],
        [
            new(322149, 518640, 4797),
            new(321402, 519470, 4746),
            new(321329, 520095, 4705),
            new(321776, 522042, 4497),
            new(322846, 522866, 4155),
            new(324020, 524214, 3688),
        ],
        [
            new(331108, 524222, 4307),
            new(330886, 522985, 4304),
            new(330863, 522163, 4192),
            new(330510, 521135, 4217),
            new(330442, 520282, 4179),
            new(329950, 519471, 4202),
            new(329432, 518421, 4288),
            new(327955, 518541, 4227),
            new(326664, 518560, 4200),
            new(325209, 518094, 4434),
            new(324326, 518191, 4729),
            new(323254, 518427, 4779),
        ],
    ];

    #endregion

    private byte _stage;
    private AddsTracker _adds;
    private IDisposable? _subscription;
    private Creature? _mother;

    public TheThreeMothers(ILogger<TheThreeMothers> logger, Creature creature)
        : base(creature)
    {
        _logger = logger;
        _adds = new(creature);
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Tasks.AddTask(CheckActivationRange, 5000, 0);
    }

    private void CheckActivationRange()
    {
        foreach (Player plr in _creature.PlayersInRange)
        {
            if (
                plr is not null
                && !plr.IsDead
                && !plr.Stealth.IsInGameMasterStealth
                && _creature.IsWithin3DRadiusUnits(plr, 1200)
            )
            {
                _creature.Tasks.RemoveTask(CheckActivationRange);
                StartStage(0);
                break;
            }
        }
    }

    private long _startTime;

    private void StartStage(byte stage)
    {
        if (stage == 0)
        {
            _startTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        }

        // Remove previous stages adds in 20s
        _creature.Tasks.AddTask(() => _adds.Clear(), 20000, 1);

        // If we finished all stages kill the controller
        // as it is technically the boss
        if (stage >= _mothers.Length)
        {
            _unit.Region?.Instance?.CompletedEncounter(4);

            long endTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            long timeTaken = endTime - _startTime;

            _logger.LogInformation(
                "Three Mothers Completed in {Duration}, Start: {Start}, End: {End}",
                timeTaken,
                _startTime,
                endTime
            );

            if (timeTaken < 300)
            {
                if (_creature.Region is null)
                {
                    return;
                }

                foreach (Player plr in _creature.Region.Players)
                {
                    plr.TomeOfKnowledge.AddTok(10926);
                }
            }

            return;
        }

        // New adds tracker for this stage
        _adds = new(_creature);

        // Creature.Say("Starting Stage " + stage);
        _stage = stage;

        _mother = _creature.Region?.CreateCreature(
            _mothers[stage],
            new(_mothersSpawns[stage][0], _mothersSpawns[stage][1], (ushort)_mothersSpawns[stage][2]),
            (ushort)_mothersSpawns[stage][3]
        );

        if (_mother is null)
        {
            return;
        }

        _subscription = _mother.Events.Subscribe(this);

        SpawnAds();
        _creature.Tasks.AddTask(SpawnAds, 30000, 0);
    }

    // When a mother dies
    public void OnDieEvent(ref DieEvent eventValue)
    {
        if (eventValue.Victim == _mother)
        {
            _subscription?.Dispose();
            _subscription = null;
            _mother = null;
            Progress();
        }
    }

    private void Progress()
    {
        _creature.Tasks.RemoveTask(SpawnAds);
        StartStage(++_stage);
    }

    private void SpawnAds()
    {
        // Creature.Say("Spawn Ads Stage " + _stage);
        if (_adds.Count() >= 30)
        {
            return;
        }

        _adds.SpawnCreaturesAroundPos(
            _babies[_stage],
            _babiesSpawns[_stage],
            180,
            3,
            cre =>
            {
                cre.Tasks.AddTask(
                    () =>
                    {
                        AdsMove(cre);
                    },
                    1000,
                    1
                );
            }
        );
    }

    private void AdsMove(Creature cre)
    {
        if (_stage > 2)
        {
            return;
        }

        for (int j = _stage; j >= 0; --j)
        {
            for (int k = 0; k < _waypoints[j].Length; k++)
            {
                cre.AiInterface.AddWaypoint(
                    new()
                    {
                        X = (uint)(
                            _waypoints[j][k].X + (Random.Shared.Next(0, 100) * ((Random.Shared.Next(0, 2) * 2) - 1))
                        ),
                        Y = (uint)(
                            _waypoints[j][k].Y + (Random.Shared.Next(0, 100) * ((Random.Shared.Next(0, 2) * 2) - 1))
                        ),
                        Z = (ushort)(
                            _waypoints[j][k].Z + (Random.Shared.Next(0, 100) * ((Random.Shared.Next(0, 2) * 2) - 1))
                        ),
                        Speed = 200,
                    }
                );
            }
        }
    }
}
