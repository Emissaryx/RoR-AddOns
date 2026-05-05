namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Common.Positions;
using Game.Repositories.World;
using Game.World.Objects;

/*
 * Tree Kin Twins
 *
 * Both NPCS start in stage 0 and stay in sync.
 * Both are IsInvulnerable to start and DurthWood
 * Starts the interaction when a player comes close.
 * He will be targetable and start attacking a player.
 * Every 20% health drop they freeze and the other tree
 * activates.
 */

[GeneralScript(CreatureEntry = 97448)]
internal class DurthuWood : BasicCreatureScript
{
    public DurthuWood(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _adds.ClearOnDeath = false;
    }

    private Wildwood? _wildwood;

    private static readonly Point3D[] _critterWaypoints =
    [
        new(319115, 533862, 3057),
        new(319934, 533596, 3216),
        new(320525, 533267, 3375),
    ];

    private Wildwood? GetWildwood()
    {
        if (_wildwood is null)
        {
            _wildwood =
                _creature
                    .ObjectsInRange.FirstOrDefault(o => o is Creature c && c.Scripts.Scripts.Any(s => s is Wildwood))
                    ?.Scripts.Scripts.FirstOrDefault(s => s is Wildwood) as Wildwood;
        }

        return _wildwood;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.AggroResetDistance = 3600;
        _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
        _creature.Tasks.AddTask(CheckActivationRange, 1000, 0);
    }

    private void CheckActivationRange()
    {
        foreach (Player plr in _creature.PlayersInRange)
        {
            if (
                plr is { IsDead: false, Stealth.IsInGameMasterStealth: false }
                && _creature.WorldPosition.IsWithin3DRadiusUnits(plr.WorldPosition, 600)
            )
            {
                _creature.Tasks.RemoveTask(CheckActivationRange);
                _creature.DispatchPacket(
                    Player.BuildLocalizeString(
                        "All about you, the forest stirs angrily. You've awoken something terrible!",
                        ChatLogFilter.CWhite
                    ),
                    false
                );
                _creature.Tasks.AddTask(Start, 6000, 1);
            }
        }
    }

    private void Start()
    {
        _creature.DispatchPacket(
            Player.BuildLocalizeString(
                "The ground stirs beneath your feet! Durthu-Wood has arisen to wreak havoc on all interlopers!",
                ChatLogFilter.CWhite
            ),
            false
        );
        _creature.Tasks.AddTask(Start2, 2000, 1);
    }

    private void Start2()
    {
        _creature.PlayEffect(970); // CAMERASHAKE_Large

        foreach (
            Creature critter in _creature.GetInRangeUnits<Creature>(
                creature => creature.Entry == 97471 || creature.Entry == 97472,
                1200
            )
        )
        {
            critter.AiInterface.ResetWaypoints();
            foreach (var waypoint in _critterWaypoints)
            {
                critter.AiInterface.AddWaypoint(
                    new()
                    {
                        X = (uint)(waypoint.X + (Random.Shared.Next(0, 100) * ((Random.Shared.Next(0, 2) * 2) - 1))),
                        Y = (uint)(waypoint.Y + (Random.Shared.Next(0, 100) * ((Random.Shared.Next(0, 2) * 2) - 1))),
                        Z = (ushort)(waypoint.Z + (Random.Shared.Next(0, 100) * ((Random.Shared.Next(0, 2) * 2) - 1))),
                        Speed = 200,
                    }
                );
            }
        }

        SetStage(ScriptStage.Stage1);
        if (_creature.PlayersInRange.FirstOrDefault() is Player plr)
        {
            _creature.AiInterface.ProcessCombatStart(plr);
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        switch (_stage)
        {
            case ScriptStage.Stage1:
            {
                if (_creature.Health.Pct < 80)
                {
                    GetWildwood()?.SetStage(ScriptStage.Stage2);
                    SetStage(ScriptStage.Stage2);
                    Knockback();
                }

                break;
            }

            case ScriptStage.Stage3:
            {
                if (_creature.Health.Pct < 60)
                {
                    GetWildwood()?.SetStage(ScriptStage.Stage4);
                    SetStage(ScriptStage.Stage4);
                    Knockback();
                }

                break;
            }

            case ScriptStage.Stage5:
            {
                if (_creature.Health.Pct < 40)
                {
                    GetWildwood()?.SetStage(ScriptStage.Stage6);
                    SetStage(ScriptStage.Stage6);
                    Knockback();
                }

                break;
            }

            case ScriptStage.Stage7:
            {
                if (_creature.Health.Pct < 20)
                {
                    GetWildwood()?.SetStage(ScriptStage.Stage8);
                    SetStage(ScriptStage.Stage8);
                    Knockback();
                }

                break;
            }
        }
    }

    private void Knockback()
    {
        foreach (Player plr in _creature.PlayersInRange)
        {
            if (_creature.IsWithin3DRadiusUnits(plr, 2400))
            {
                plr.ApplyKnockback(_creature, 50, 600, 0, 2);
            }
        }
    }

    public override void OnDie(Unit obj)
    {
        GetWildwood()?.SetStage(ScriptStage.Stage10);
        SetStage(ScriptStage.Stage10);
        Knockback();
    }

    public new void SetStage(ScriptStage stage)
    {
        // Creature.Say("SetStage: " + stage);
        if (stage is ScriptStage.Stage2 or ScriptStage.Stage4 or ScriptStage.Stage6 or ScriptStage.Stage8)
        {
            FreezeNpc();
            _creature.SendAnimation(121);

            // Cast 5539
            foreach (Player plr in _creature.PlayersInRange)
            {
                plr.AbilityCast.StartCast(5539, 0);
            }
        }
        else if (
            stage
            is ScriptStage.Stage1
                or ScriptStage.Stage3
                or ScriptStage.Stage5
                or ScriptStage.Stage7
                or ScriptStage.Stage9
        )
        {
            UnfreezeNpc();
        }

        _stage = stage;
    }
}

internal class Critter : CreatureScript
{
    public Critter(Creature creature)
        : base(creature) { }

    public override void OnFinishedWaypoints()
    {
        _creature.Destroy();
    }
}

[GeneralScript(CreatureEntry = 97471)]
internal class Critter1 : Critter
{
    public Critter1(Creature creature)
        : base(creature) { }
}

[GeneralScript(CreatureEntry = 97472)]
internal class Critter2 : Critter
{
    public Critter2(Creature creature)
        : base(creature) { }
}

[GeneralScript(CreatureEntry = 97432)]
internal class Wildwood : BasicCreatureScript
{
    public Wildwood(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _stage = ScriptStage.Stage1;
        _adds.ClearOnDeath = false;
    }

    private DurthuWood? _durthWood;
    private bool _spawningAdds;

    private DurthuWood? GetDurthuWood()
    {
        if (_durthWood is null)
        {
            _durthWood =
                _creature
                    .ObjectsInRange.FirstOrDefault(o => o is Creature c && c.Scripts.Scripts.Any(s => s is DurthuWood))
                    ?.Scripts.Scripts.FirstOrDefault(s => s is DurthuWood) as DurthuWood;
        }

        return _durthWood;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.AggroResetDistance = 3600;
        _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
        _creature.Tasks.AddTask(SpawnAdds, 10000, 0);
    }

    public new void SetStage(ScriptStage stage)
    {
        // Creature.Say("SetStage: " + stage);
        switch (stage)
        {
            case ScriptStage.Stage2:
            case ScriptStage.Stage4:
            case ScriptStage.Stage6:
            case ScriptStage.Stage8:
            case ScriptStage.Stage10:
                _spawningAdds = true;
                UnfreezeNpc();
                _creature.SendAnimation(0);
                break;
            case ScriptStage.Stage3:
            case ScriptStage.Stage5:
            case ScriptStage.Stage7:
            case ScriptStage.Stage9:
                _spawningAdds = false;
                FreezeNpc();
                _creature.SendAnimation(121);
                break;
        }

        if (stage == ScriptStage.Stage2 && _creature.PlayersInRange.FirstOrDefault() is Player plr)
        {
            _creature.AiInterface.ProcessCombatStart(plr);
        }

        _stage = stage;
    }

    private void SpawnAdds()
    {
        if (!_spawningAdds)
        {
            return;
        }

        for (uint i = 0; i < 3; ++i)
        {
            _adds.SpawnCreature(
                97451,
                new(_creature.WorldPosition.X, _creature.WorldPosition.Y, _creature.WorldPosition.Z),
                _creature.Heading
            );
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        switch (_stage)
        {
            case ScriptStage.Stage2:
            {
                if (_creature.Health.Pct < 80)
                {
                    GetDurthuWood()?.SetStage(ScriptStage.Stage3);
                    SetStage(ScriptStage.Stage3);
                    Knockback();
                }

                break;
            }

            case ScriptStage.Stage4:
            {
                if (_creature.Health.Pct < 60)
                {
                    GetDurthuWood()?.SetStage(ScriptStage.Stage5);
                    SetStage(ScriptStage.Stage5);
                    Knockback();
                }

                break;
            }

            case ScriptStage.Stage6:
            {
                if (_creature.Health.Pct < 40)
                {
                    GetDurthuWood()?.SetStage(ScriptStage.Stage7);
                    SetStage(ScriptStage.Stage7);
                    Knockback();
                }

                break;
            }

            case ScriptStage.Stage8:
            {
                if (_creature.Health.Pct < 20)
                {
                    GetDurthuWood()?.SetStage(ScriptStage.Stage9);
                    SetStage(ScriptStage.Stage9);
                    Knockback();
                }

                break;
            }
        }
    }

    private void Knockback()
    {
        foreach (Player plr in _creature.PlayersInRange)
        {
            if (_creature.IsWithin3DRadiusUnits(plr, 2400))
            {
                plr.ApplyKnockback(_creature, 50, 800, 0, 2);
            }
        }
    }

    public override void OnDie(Unit obj)
    {
        _spawningAdds = false;
    }
}

[GeneralScript(CreatureEntry = 97451)]
internal class HalfHewnSpite : CreatureScript
{
    public HalfHewnSpite(Creature c)
        : base(c) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Tasks.AddTask(Attack, 1000, 1);
    }

    private void Attack()
    {
        if (_creature.PlayersInRange.FirstOrDefault() is Player plr)
        {
            _creature.AiInterface.ProcessCombatStart(plr);
        }
    }
}
