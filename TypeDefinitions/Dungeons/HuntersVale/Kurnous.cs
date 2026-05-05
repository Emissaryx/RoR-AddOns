namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums;
using Common.Enums.GameData;
using Common.Enums.MythicAbilities;
using Common.Enums.SystemData;
using Common.Positions;
using Game.NetWork.Handler;
using Game.Repositories.World;
using Game.World.Events;
using Game.World.Objects;
using WarEmu.Database.World.Database.Creatures;
using WarEmu.Database.World.Database.GameObjects;

[GeneralScript(CreatureEntry = 97430)]
internal class Kurnous : BasicCreatureScript, IEventListener
{
    private readonly ILogger<Kurnous> _logger;
    private readonly GameObjectRepository _gameObjectRepository;
    private readonly CreatureProtoRepository _creatureProtoRepository;

    public bool Completed;

    public enum Aspects
    {
        /// <summary>
        /// Wolf
        /// </summary>
        Wolf,

        /// <summary>
        /// Lion
        /// </summary>
        Lion,

        /// <summary>
        /// Hound
        /// </summary>
        Hound,
    }

    private string AspectName(Aspects aspect)
    {
        return aspect switch
        {
            Aspects.Wolf => "Lupine",
            Aspects.Lion => "Leonine",
            Aspects.Hound => "Canine",
            _ => "Unknown",
        };
    }

    /// <summary>
    /// Aspect Transformation Abilities
    /// </summary>
    private readonly ushort[] _aspectTransforms = [13163, 13164, 13165];

    public static readonly Point3D[] AspectSpawn =
    [
        new(327380, 524567, 7885),
        new(327510, 522916, 7894),
        new(326273, 523313, 7919),
    ];

#pragma warning disable IDE0052 // Remove unread private members
    private readonly IDisposable _subscription;
#pragma warning restore IDE0052 // Remove unread private members

    public Kurnous(
        Creature creature,
        ILogger<Kurnous> logger,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository,
        CreatureProtoRepository creatureProtoRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _logger = logger;
        _gameObjectRepository = gameObjectRepository;
        _creatureProtoRepository = creatureProtoRepository;
        _subscription = creature.Events.Subscribe(this);
    }

    private sealed class Position
    {
        public ushort ZoneId;
        public uint X;
        public uint Y;
        public ushort Z;
        public ushort O;
    }

    private static readonly Position[] _gateGameObjectPositions =
    [
        new()
        {
            ZoneId = 50,
            X = 326191,
            Y = 524635,
            Z = 7885,
            O = 2559,
        }, // 1
        new()
        {
            ZoneId = 50,
            X = 325938,
            Y = 523756,
            Z = 7885,
            O = 3060,
        }, // 2
        new()
        {
            ZoneId = 50,
            X = 326249,
            Y = 522923,
            Z = 7885,
            O = 3561,
        }, // 3
        new()
        {
            ZoneId = 50,
            X = 327100,
            Y = 522565,
            Z = 7885,
            O = 4084,
        }, // 4
        new()
        {
            ZoneId = 50,
            X = 327932,
            Y = 522906,
            Z = 7886,
            O = 500,
        }, // 5
        new()
        {
            ZoneId = 50,
            X = 328261,
            Y = 523741,
            Z = 7885,
            O = 1035,
        }, // 6
        new()
        {
            ZoneId = 50,
            X = 327939,
            Y = 524624,
            Z = 7885,
            O = 1524,
        }, // 7
        new()
        {
            ZoneId = 50,
            X = 327130,
            Y = 525005,
            Z = 7886,
            O = 2059,
        }, // 8
    ];

    private static readonly Position[] _gateCreaturePositions =
    [
        new()
        {
            ZoneId = 50,
            X = 326310,
            Y = 524518,
            Z = 7886,
            O = 2559,
        }, // 1
        new()
        {
            ZoneId = 50,
            X = 326132,
            Y = 523790,
            Z = 7885,
            O = 3060,
        }, // 2
        new()
        {
            ZoneId = 50,
            X = 326372,
            Y = 523068,
            Z = 7885,
            O = 3561,
        }, // 3
        new()
        {
            ZoneId = 50,
            X = 327091,
            Y = 522732,
            Z = 7885,
            O = 4084,
        }, // 4
        new()
        {
            ZoneId = 50,
            X = 327795,
            Y = 523017,
            Z = 7885,
            O = 500,
        }, // 5
        new()
        {
            ZoneId = 50,
            X = 328103,
            Y = 523718,
            Z = 7885,
            O = 1035,
        }, // 6
        new()
        {
            ZoneId = 50,
            X = 327814,
            Y = 524489,
            Z = 7885,
            O = 1524,
        }, // 7
        new()
        {
            ZoneId = 50,
            X = 327129,
            Y = 524842,
            Z = 7885,
            O = 2059,
        }, // 8
    ];

    private readonly GameObject[] _gateGameObjects = new GameObject[_gateGameObjectPositions.Length];
    private readonly Creature[] _gateCreatures = new Creature[_gateCreaturePositions.Length];

    private bool _shockOfNatureEnabled;

    private readonly List<Player> _javelinDelugeTargets = [];

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Roam = 0;
        _creature.Aggro.AggroResetDistance = 3600;
        _creature.CombatFlag.CantLeaveCombat = true;

        SpawnGateGameObjects();
        SpawnGateCreatures();

        base.OnObjectLoad(obj);
    }

    private void IfNoPlayersInRangeReset()
    {
        if (!PlayersInRange().Any())
        {
            Reset();
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _creature.Say("Watch now as I humble these mortal hunters!", ChatLogFilter.MonsterSay);
        _creature.PlaySound(1453); // s_Kurnous_VO_PQ_09

        _unit.Tasks.AddTask(CastDebuffOnRandomPlayer, 10 * 1000, 0);
        _unit.Tasks.AddTask(IfNoPlayersInRangeReset, 1000, 0);
        _creature.RemoveCrowdControlImmunity((byte)CrowdControlTypes.All);
        _creature.AddCrowdControlImmunity(CrowdControlTypes.All);
        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        Reset();
        base.OnLeaveCombat(owner);
    }

    private void Reset()
    {
        Appear();

        // This is here as unfreeze removes the CantLeaveCombatFlag
        UnfreezeNpc();
        _unit.CombatFlag.CantLeaveCombat = true;

        _creature.AiInterface.ProcessCombatEnd();
        _creature.CombatFlag.LeaveCombat();

        _unit.Tasks.RemoveTask(IfNoPlayersInRangeReset);

        _unit.Tasks.RemoveTask(CastDebuffOnRandomPlayer);

        _unit.Tasks.RemoveTask(RunToCurrentGate);
        _unit.Tasks.RemoveTask(TeleportToNextGate);
        _unit.Tasks.RemoveTask(GateSolo);

        SetStage(ScriptStage.Stage0);

        if (!_creature.IsDead)
        {
            ResetGates();
        }

        foreach (var ability in _unit.Abilities.GetAbilities())
        {
            if (ability.Ability.HasFlag(AbilityFlags.Passive))
            {
                continue;
            }

            _unit.Abilities.EndTargetAbilities(ability.AbilityId);
        }
    }

    private void CastDebuffOnRandomPlayer() // Spirit of Nature
    {
        if (!_shockOfNatureEnabled)
        {
            return;
        }

        Player? player = PlayersInRange().RandomElement();

        if (player == null)
        {
            return;
        }

        _creature.Abilities.AddAbility(13160, player, _creature.EffectiveLevel);
        SendOnscreenMessageToAllPlayers($"Shock of nature affects {player.Name}!");
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stage == ScriptStage.Stage0)
        {
            if (_creature.Health.Pct < 100)
            {
                SetStage(ScriptStage.Stage1);
            }
        }
        else if (_stage == ScriptStage.Stage1)
        {
            if (_creature.Health.Pct < 80)
            {
                SetStage(ScriptStage.Stage2);
            }
        }
        else if (_stage == ScriptStage.Stage3)
        {
            if (_creature.Health.Pct < 60)
            {
                SetStage(ScriptStage.Stage4);
            }
        }
        else if (_stage == ScriptStage.Stage5)
        {
            SetStage(ScriptStage.Stage6);
        }
        else if (_stage == ScriptStage.Stage6)
        {
            if (_creature.Health.Pct < 40)
            {
                SetStage(ScriptStage.Stage7);
            }
        }
        else if (_stage == ScriptStage.Stage7)
        {
            if (_creature.Health.Pct < 30)
            {
                SetStage(ScriptStage.Stage8);
            }
        }
        else if (_stage == ScriptStage.Stage8 && _creature.Health.Pct < 20)
        {
            SetStage(ScriptStage.Stage9);
        }
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(CastDebuffOnRandomPlayer);
        obj.Tasks.RemoveTask(IfNoPlayersInRangeReset);

        obj.Tasks.RemoveTask(TeleportToNextGate);
        obj.Tasks.RemoveTask(GateSolo);
        obj.Tasks.RemoveTask(RunToCurrentGate);

        SetStage(ScriptStage.Stage0);
        OpenAllPortals();

        _creature.PlaySound(1460); // s_Kurnous_VO_PQ_16
        _creature.Say("At last! A mortal worthy of the title: Master Hunter!", ChatLogFilter.MonsterSay);

        Completed = true;

        foreach (
            Player plr in _unit.PlayersInRange.Where(p =>
                !p.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                && !p.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                && !p.Stealth.IsInGameMasterStealth
            )
        )
        {
            plr.ActionCounters.Increment(ActionCounterEnum.KurnousDefeated);
        }

        base.OnDie(obj);
    }

    public override void SetStage(ScriptStage stage)
    {
        // if (stage != ScriptStage.Stage0)
        // {
        //     stage = ScriptStage.Stage9;
        // }

        _stage = stage;

        switch (stage)
        {
            case ScriptStage.Stage1:
                _shockOfNatureEnabled = true;
                break;
            case ScriptStage.Stage2:
            case ScriptStage.Stage4:
                _shockOfNatureEnabled = false;
                ResetGates();
                StartGateWalk();
                break;
            case ScriptStage.Stage3:
                _shockOfNatureEnabled = true;
                break;
            case ScriptStage.Stage5:
                _shockOfNatureEnabled = true;
                DestroyGates();
                break;
            case ScriptStage.Stage7:
            case ScriptStage.Stage8:
            case ScriptStage.Stage9:
                {
                    _creature.RemoveCrowdControlImmunity((byte)CrowdControlTypes.All);
                    SpawnAspects();
                    SendOnscreenMessageToAllPlayers(
                        $"KURNOUS IS TAKING ON A {AspectName(_currentAspect).ToUpper()} ASPECT"
                    );
                    SendOnscreenMessageToAllPlayers("CHOOSE THE CORRECT SPIRIT ANIMAL TO AID YOU!");
                    _creature.PlaySound(1468); // s_Kurnous_VO_PQ_24 - "The hunters become the hunted!"
                    _creature.Say("The hunters become the hunted!", ChatLogFilter.MonsterSay);
                }

                break;
        }
    }

    #region Gates

    private int _currentGate = -1;
    private int _currentGateOpenCount;

    private void SpawnGateGameObjects()
    {
        for (uint i = 0; i < _gateGameObjectPositions.Length; ++i)
        {
            GameObjectProto? proto = _gameObjectRepository.GetGameObjectProto(100552);
            if (proto is null)
            {
                return;
            }

            GameObject? gate = _creature.Region?.CreateGameObject(
                proto,
                new(_gateGameObjectPositions[i].X, _gateGameObjectPositions[i].Y, _gateGameObjectPositions[i].Z),
                _gateGameObjectPositions[i].O
            );

            if (gate is not null)
            {
                gate.Scripts.AddScript(new KurnousExitPortal(gate, this));
                _gateGameObjects[i] = gate;
            }
        }
    }

    private void SpawnGateCreatures()
    {
        for (uint i = 0; i < _gateCreaturePositions.Length; ++i)
        {
            _gateCreatures[i]?.Destroy();

            Creature? gate = _creature.Region?.CreateCreature(
                97437,
                new(_gateCreaturePositions[i].X, _gateCreaturePositions[i].Y, _gateCreaturePositions[i].Z),
                _gateCreaturePositions[i].O
            );

            if (gate is not null)
            {
                _gateCreatures[i] = gate;
            }
        }
    }

    private void ResetGates()
    {
        foreach (GameObject gateGameObject in _gateGameObjects)
        {
            gateGameObject.VfxState = 0;
        }

        foreach (Creature gateCreature in _gateCreatures)
        {
            gateCreature.Health.Value = gateCreature.Health.Total;
        }

        // Just respawn gate creatures
        SpawnGateCreatures();

        _currentGateOpenCount = 0;
        _currentGate = -1;
    }

    private int GetRandomGate(int excluding = -1)
    {
        return Enumerable
            .Range(0, _gateGameObjectPositions.Length)
            .Where(i => i != excluding)
            .OrderBy(x => Guid.NewGuid())
            .FirstOrDefault();
    }

    private void DestroyGates()
    {
        IEnumerable<int> gates = Enumerable.Range(0, _gateGameObjects.Length).OrderBy(x => Guid.NewGuid());
        int time = 2000;

        foreach (int gate in gates)
        {
            _creature.Tasks.AddTask(
                () =>
                {
                    _gateGameObjects[gate].PlayEffect(3140); // SPEC_WHUNT_PortalExplosion
                    _gateGameObjects[gate].VfxState = 8;
                },
                time,
                1
            );
            time += 2000;
        }
    }

    private void OpenAllPortals()
    {
        foreach (GameObject gate in _gateGameObjects)
        {
            gate.VfxState = 6;
            gate.Interactable = true;
        }
    }

    private void StartGateWalk()
    {
        _creature.PlaySound(1454); // s_Kurnous_VO_PQ_10
        _creature.Say("Well played, mortal... but you will need to do much, much better!", ChatLogFilter.MonsterSay);

        _currentGate = GetRandomGate();
        RunToCurrentGate(); // This is where magic happens
    }

    private void RunToCurrentGate()
    {
        if (_currentGate == -1)
        {
            _logger.LogInformation("Missing currentGate");
            return;
        }

        // Mark Gate as opened
        _gateGameObjects[_currentGate].VfxState = 6; // OPEN
        _gateCreatures[_currentGate].DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _gateCreatures[_currentGate].AiInterface.CurrentBrain.NoAttack = false;

        // Creature.Say("Going to gate " + _currentGate);

        // Pause combat
        FreezeNpc();
        _unit.CombatFlag.CantLeaveCombat = true;

        // Tell creature to move and return time
        float time = _creature.Movement.Move(_gateGameObjects[_currentGate]);

        // When creature i gate make him disappear and move gate
        _creature.Tasks.AddTask(
            () =>
            {
                if (_currentGate == -1)
                {
                    return;
                }

                // Creature.Say("Arrived at gate " + _currentGate);
                _creature.Stealth.Cloak(StealthType.Invisible);
                _gateGameObjects[_currentGate].VfxState = 4; // CLOSED
                _gateCreatures[_currentGate].DormantInfo |=
                    DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
                _gateCreatures[_currentGate].AiInterface.CurrentBrain.NoAttack = true;
                _creature.Tasks.AddTask(_stage == ScriptStage.Stage4 ? GateSolo : TeleportToNextGate, 3000, 1);
            },
            (int)time,
            1
        );
    }

    private void GateSolo()
    {
        var gates = Enumerable
            .Range(0, _gateGameObjectPositions.Length)
            .OrderBy(x => Guid.NewGuid())
            .Take(++_currentGateOpenCount % _gateGameObjectPositions.Length)
            .ToList();

        foreach (var gate in gates)
        {
            _gateGameObjects[gate].VfxState = 2; // PARTIALLY OPEN
            _gateCreatures[gate].AiInterface.CurrentBrain.NoAttack = false;
            int spriteCount = Random.Shared.Next(2, 8);
            for (int i = 0; i < spriteCount; ++i)
            {
                _adds.SpawnCreature(
                    97452,
                    new(
                        (uint)(
                            _gateCreaturePositions[gate].X
                            + Random.Shared.Next(20, 100) * ((Random.Shared.Next(0, 2) * 2) - 1)
                        ),
                        (uint)(
                            _gateCreaturePositions[gate].Y
                            + Random.Shared.Next(20, 100) * ((Random.Shared.Next(0, 2) * 2) - 1)
                        ),
                        _gateCreaturePositions[gate].Z
                    ),
                    _gateCreaturePositions[gate].O
                );
            }
        }

        _creature.Tasks.AddTask(
            () =>
            {
                foreach (var gate in gates)
                {
                    _gateGameObjects[gate].VfxState = 4; // CLOSED
                    _gateCreatures[gate].AiInterface.CurrentBrain.NoAttack = true;
                }

                _creature.Tasks.AddTask(TeleportToNextGate, 3000, 1);
            },
            10000,
            1
        );
    }

    private void TeleportToNextGate()
    {
        // New gate
        _currentGate = GetRandomGate(_currentGate);

        if (_currentGate == -1)
        {
            _logger.LogInformation("Missing currentGate");
            return;
        }

        // Creature.Say("exiting at gate " + _currentGate);
        // Open new gate, uncloak and run to middle
        _gateGameObjects[_currentGate].VfxState = 6; // OPEN
        _gateCreatures[_currentGate].DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _gateCreatures[_currentGate].AiInterface.CurrentBrain.NoAttack = false;
        _creature.Movement.Teleport(_gateGameObjects[_currentGate].WorldPosition);
        _creature.Stealth.Cloak(0);

        float time = _creature.Movement.Move(_creature.Spawn.WorldX, _creature.Spawn.WorldY, _creature.Spawn.WorldZ);

        _creature.Tasks.AddTask(
            () =>
            {
                if (_currentGate == -1)
                {
                    return;
                }

                if (_gateCreatures[_currentGate].IsDead)
                {
                    _creature.Say("You will suffer for this impudence!", ChatLogFilter.MonsterSay);
                    _creature.PlaySound(1461); // s_Kurnous_VO_PQ_17
                    SetStage(_stage + 1);

                    // This is here as unfreeze removes the CantLeaveCombatFlag
                    UnfreezeNpc();
                    _unit.CombatFlag.CantLeaveCombat = true;

                    Player? target = PlayersInRange().RandomElement();
                    if (target is not null)
                    {
                        _creature.CombatFlag.RefreshCombatTimer(target);
                        _creature.Aggro.AddHatred(target, 1000);
                        _creature.Targets.Set(TargetTypes.TARGETTYPES_TARGET_ENEMY, target.Oid);
                    }
                }
                else
                {
                    _creature.Say("We have only just begun to play, you and I!", ChatLogFilter.MonsterSay);
                    _creature.PlaySound(1458); // s_Kurnous_VO_PQ_14

                    // This just does an animation of throwing things up

                    _javelinDelugeTargets.Clear();
                    _javelinDelugeTargets.AddRange(PlayersInRange());
                    _creature.Tasks.AddTask(() => CastAbility(13159), 1000, 1);
                    _creature.Tasks.AddTask(RunToCurrentGate, 10000, 1);
                }
            },
            (int)time,
            1
        );
    }

    public void OnAbilityServerCommandStartEvent(ref AbilityServerCommandStartEvent eventValue)
    {
        // Winter's Breath
        if (eventValue.AbilityComponent.Values[0] == 251 && eventValue.AbilityComponent.Values[1] == 86208)
        {
            var player = PlayersInRange().FirstOrDefault();

            if (player is null)
            {
                return;
            }

            _unit.Abilities.AddAbility(13180, player, _unit.EffectiveLevel);
        }

        // Feral Blitz
        if (eventValue.AbilityComponent.Values[0] == 32 && eventValue.AbilityComponent.Values[1] == 41881)
        {
            _creature.Abilities.EndTargetAbilities(13172);
        }

        // Feral Blitz
        if (eventValue.AbilityComponent.Values[0] == 32 && eventValue.AbilityComponent.Values[1] == 41880)
        {
            _creature.Abilities.EndTargetAbilities(13172);
            _creature.Abilities.EndTargetAbilities(abilityGroup: 1020);

            foreach (var player in PlayersInRange())
            {
                player.Abilities.EndTargetAbilities(13171);
            }
        }

        // Feral Blitz
        if (eventValue.AbilityComponent.Values[0] == 266 && eventValue.AbilityComponent.Values[1] == 41807)
        {
            Player? target = PlayersInRange().RandomElement();
            if (target is not null)
            {
                _unit.Abilities.AddAbility(13171, target, _creature.EffectiveLevel);
            }
        }

        // Javelin Deluge casts
        if (eventValue.AbilityComponent.Values[0] == 266 && eventValue.AbilityComponent.Values[1] == 41826)
        {
            // Block intentionally left empty.
        }
    }

    public void OnAbilityServerCommandTickEvent(ref AbilityServerCommandTickEvent eventValue)
    {
        // Javelin Deluge tick
        if (eventValue.AbilityComponent.Values[0] == 266 && eventValue.AbilityComponent.Values[1] == 41826)
        {
            if (_javelinDelugeTargets.Count == 0)
            {
                return;
            }

            Player? target = _javelinDelugeTargets.RandomElement();
            if (target is not null)
            {
                _javelinDelugeTargets.Remove(target);
                _creature.Abilities.AddAbility(13193, target, _creature.EffectiveLevel);
            }
        }
    }
    #endregion

    #region Aspects

    private Aspects _currentAspect;

    private void SpawnAspects()
    {
        // Select new random aspect which is different
        _currentAspect = (Aspects)
            Enumerable
                .Range(0, Enum.GetNames(typeof(Aspects)).Length)
                .Where(i => i != (int)_currentAspect)
                .OrderBy(x => Guid.NewGuid())
                .FirstOrDefault();

        // Transform
        _creature.AbilityCast.StartCast(_aspectTransforms[(int)_currentAspect], 0, allowNonAbilitySet: true);

        var aspectSpawns = AspectSpawn.OrderBy(x => Guid.NewGuid()).ToList();

        byte i = 0;

        foreach (Point3D asp in aspectSpawns)
        {
            uint entry = 0;
            switch (i)
            {
                case 0:
                    entry = 97468;
                    break;
                case 1:
                    entry = 97470;
                    break;
                case 2:
                    entry = 97475;
                    break;
            }

            i++;

            CreatureProto? proto = _creatureProtoRepository.GetCreatureProto(entry);

            if (proto is null)
            {
                continue;
            }

            Creature c = Creature.Create(Global.ServiceProvider, proto);
            c.NoRespawn = true;
            c.Roam = 250;

            _adds.Add(c, asp, (ushort)Random.Shared.Next(0, 3601));

            for (int j = 0; j < 3; j++)
            {
                var waypoint = aspectSpawns[(i + j) % 3];

                c.AiInterface.Waypoints.Add(
                    new()
                    {
                        X = waypoint.X,
                        Y = waypoint.Y,
                        Z = waypoint.Z,
                    }
                );
            }
        }
    }

    public void AspectResult(Aspects chosen, ushort abilityId)
    {
        if (_currentAspect == chosen)
        {
            _creature.Abilities.AddAbility(abilityId, _creature, _creature.EffectiveLevel);
            AspectCleanup();
            return;
        }

        AspectFail();
    }

    private void AspectFail()
    {
        var player = PlayersInRange().FirstOrDefault();

        if (player is null)
        {
            return;
        }

        player.Abilities.AddAbility(24619, player, player.EffectiveLevel);

        AspectCleanup();
    }

    private void AspectCleanup()
    {
        _creature.Tasks.RemoveTask(AspectFail);
        GetCreatureFromRegion(97468)?.Destroy();
        GetCreatureFromRegion(97470)?.Destroy();
        GetCreatureFromRegion(97475)?.Destroy();
    }

    #endregion
}

[GeneralScript(CreatureEntry = 97452)]
internal class HalfHewnSpiteKurnous : BasicCreatureScript
{
    public HalfHewnSpiteKurnous(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Tasks.AddTask(Attack, 500, 1);
    }

    private void Attack()
    {
        var randomTarget = PlayersInRange().FirstOrDefault();

        if (randomTarget is not null)
        {
            _creature.AiInterface.ProcessCombatStart(randomTarget);
        }
    }

    public override void OnDie(Unit obj)
    {
        _creature.Destroy();
    }
}

[GeneralScript(CreatureEntry = 97437)]
internal class GateOfNature : BasicCreatureScript
{
    public GateOfNature(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Health.NoRegen = true;
        _creature.AaSpeed = 0;
        _creature.Aggro.SendAggroUpdate = false;
        _creature.CombatFlag.CantLeaveCombat = true;
        _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
        _creature.AiInterface.CurrentBrain.NoAttack = true;

        _creature.Tasks.AddTask(ThrowJavelin, 5000, 0);

        base.OnObjectLoad(obj);
    }

    private void ThrowJavelin()
    {
        if (
            _creature.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
            || _creature.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
        )
        {
            return;
        }

        CastAbility(24620);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        foreach (Creature creature in GetListOfCreaturesFromRegion(97437))
        {
            if (_creature != creature)
            {
                creature.Health.Value = _creature.Health.Value;
            }
        }
    }

    private Kurnous? _kurnous;

    public Kurnous? GetKurnous()
    {
        if (_kurnous is null)
        {
            _kurnous =
                _creature
                    .ObjectsInRange.FirstOrDefault(o => o is Creature c && c.Scripts.Scripts.Any(s => s is Kurnous))
                    ?.Scripts.Scripts.FirstOrDefault(s => s is Kurnous) as Kurnous;
        }

        return _kurnous;
    }

    public override void OnDie(Unit obj)
    {
        foreach (Creature creature in GetListOfCreaturesFromRegion(97437))
        {
            if (_creature != creature)
            {
                creature.Destroy();
            }
        }

        base.OnDie(obj);

        _creature.Destroy();
    }
}

internal class KurnousSpirit : BasicCreatureScript
{
    private readonly Kurnous.Aspects _aspect;
    private readonly ushort _abilityId;

    private Kurnous? _kurnous;

    public KurnousSpirit(
        Creature creature,
        Kurnous.Aspects aspect,
        ushort abilityId,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _aspect = aspect;
        _abilityId = abilityId;
    }

    private Kurnous? GetKurnous()
    {
        return _kurnous ??=
            _creature
                .ObjectsInRange.FirstOrDefault(o => o is Creature c && c.Scripts.Scripts.Any(s => s is Kurnous))
                ?.Scripts.Scripts.FirstOrDefault(s => s is Kurnous) as Kurnous;
    }

    public override bool OnInteract(WorldObject obj, Player target, InteractMenu menu)
    {
        GetKurnous()?.AspectResult(_aspect, _abilityId);

        return true;
    }
}

[GeneralScript(CreatureEntry = 97470)]
internal class KurnousWolfSpirit : KurnousSpirit
{
    public KurnousWolfSpirit(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, Kurnous.Aspects.Hound, 13179, pQuestRepository, gameObjectRepository) { }
}

[GeneralScript(CreatureEntry = 97468)]
internal class KurnousHoundSpirit : KurnousSpirit
{
    public KurnousHoundSpirit(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, Kurnous.Aspects.Lion, 13178, pQuestRepository, gameObjectRepository) { }
}

[GeneralScript(CreatureEntry = 97475)]
internal class KurnousLionSpirit : KurnousSpirit
{
    public KurnousLionSpirit(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, Kurnous.Aspects.Wolf, 13177, pQuestRepository, gameObjectRepository) { }
}

internal sealed class KurnousExitPortal : GameObjectScript
{
    private readonly Kurnous _kurnous;

    public KurnousExitPortal(GameObject gameObject, Kurnous kurnous)
        : base(gameObject)
    {
        _kurnous = kurnous;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _gameObject.Tasks.AddTask(CheckActivationRange, 1000, 0);
    }

    private void CheckActivationRange()
    {
        if (!_kurnous.Completed)
        {
            return;
        }

        foreach (Player plr in _gameObject.PlayersInRange)
        {
            if (plr.IsDead || plr.Stealth.IsInGameMasterStealth || !_gameObject.IsWithin3DRadiusUnits(plr, 120))
            {
                continue;
            }

            if (plr.Realm == Realms.Order)
            {
                plr.Teleport(207, 876156, 1331992, 8291, 3121);
            }
            else
            {
                plr.Teleport(207, 845562, 1311278, 8341, 2865);
            }
        }
    }
}
