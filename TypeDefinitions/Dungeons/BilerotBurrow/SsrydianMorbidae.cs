namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums;
using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 52462)]
internal class SsrydianMorbidae : BasicCreatureScript
{
    public SsrydianMorbidae(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(ZCheck);
        obj.Tasks.RemoveTask(StartZCheck);

        obj.Tasks.RemoveTask(CastBuffA);
        obj.Tasks.RemoveTask(CastBuffB);
        obj.Tasks.RemoveTask(CastBuffC);

        DestroyGameObjectInRegion(2000791);

        RemoveBuffFromAllPlayersInRegion(13924);
        RemoveBuffFromAllPlayersInRegion(13961);
        RemoveBuffFromAllPlayersInRegion(3057);
        RemoveBuffFromAllPlayersInRegion(21210);
        RemoveBuffFromAllPlayersInRegion(21209);

        foreach (WorldObject? o in obj.Region.Objects.ToList())
        {
            if (o is Creature crea && crea.Entry == 2001453)
            {
                crea.Destroy();
            }
        }

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(ZCheck, 1000, 0);

        _adds.SpawnGameObject(2000802, new(1506693, 1043074, 11959), 0);

        _adds.SpawnGameObject(2000803, new(1507590, 1042081, 11957), 0);

        _adds.SpawnGameObject(2000804, new(1508606, 1043003, 11958), 0);

        // Debuffs
        _unit.Tasks.AddTask(CastBuffA, TimeSpan.FromSeconds(15), 0);
        _unit.Tasks.AddTask(CastBuffB, TimeSpan.FromSeconds(22), 0);
        _unit.Tasks.AddTask(CastBuffC, TimeSpan.FromSeconds(30), 0);

        // NPC stuff casters
        _adds.SpawnCreature(2001453, new(1507627, 1042487, 11962), 2721);
        _unit.Tasks.AddTask(
            () => _adds.SpawnCreature(2001453, new(1508217, 1043047, 11960), 2721),
            "SpawnAdds",
            3 * 1000,
            1
        );
        _unit.Tasks.AddTask(
            () => _adds.SpawnCreature(2001453, new(1507035, 1043062, 11960), 2721),
            "SpawnAdds",
            6 * 1000,
            1
        );

        SpawnBilerotWalls();

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(ZCheck);
        _unit.Tasks.RemoveTask(StartZCheck);

        _unit.Tasks.RemoveTask(CastBuffA);
        _unit.Tasks.RemoveTask(CastBuffB);
        _unit.Tasks.RemoveTask(CastBuffC);

        RemoveBuffFromAllPlayersInRegion(13924);
        RemoveBuffFromAllPlayersInRegion(13961);
        RemoveBuffFromAllPlayersInRegion(3057);
        RemoveBuffFromAllPlayersInRegion(21210);
        RemoveBuffFromAllPlayersInRegion(21209);

        foreach (WorldObject? o in _unit.Region.Objects.ToList())
        {
            if (o is Creature crea && crea.Entry == 2001453)
            {
                crea.Destroy();
            }
        }

        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public void ZCheck()
    {
        if (_unit.WorldPosition.Z > 11950)
        {
            _unit.Tasks.RemoveTask(ZCheck);
            _unit.Tasks.AddTask(StartZCheck, 10 * 1000, 1);

            CastAbility(4164);
        }
    }

    public void StartZCheck()
    {
        if (_unit.CombatFlag.IsInCombat && !_unit.IsDead)
        {
            _unit.Tasks.AddTask(ZCheck, 1000, 0);
        }
    }

    public void CastBuffA()
    {
        for (int i = 0; i < 200; i++)
        {
            Player? plr = GetRandomPlayerInRange();
            if (plr is not null && plr.Career.GetTrueArchetype() == Archetype.Healer)
            {
                _unit.Abilities.AddAbility(3057, plr, _unit.EffectiveLevel);

                SendOnscreenMessageToAllPlayers(
                    $"{plr.Name} contracted Soul Killer! Maybe the brew from the cauldron can help..."
                );

                break;
            }
        }
    }

    public void CastBuffB()
    {
        for (int i = 0; i < 200; i++)
        {
            Player? plr = GetRandomPlayerInRange();
            if (plr is not null && _unit.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY) != plr)
            {
                _unit.Abilities.AddAbility(21210, plr, _unit.EffectiveLevel);

                SendOnscreenMessageToAllPlayers(
                    $"{plr.Name} contracted Pestilent Infection! Maybe the brew from the cauldron can help..."
                );

                break;
            }
        }
    }

    public void CastBuffC()
    {
        for (int i = 0; i < 200; i++)
        {
            Player? plr = GetRandomPlayerInRange();
            if (plr is not null && plr.WorldPosition.Z > 11950)
            {
                _unit.Abilities.AddAbility(21209, plr, _unit.EffectiveLevel);

                SendOnscreenMessageToAllPlayers(
                    $"{plr.Name} has been hit by Diseased Attack! Maybe the brew from the cauldron can help..."
                );

                break;
            }
        }
    }
}
