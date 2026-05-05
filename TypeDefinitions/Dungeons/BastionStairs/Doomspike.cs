namespace Game.Scripts.Dungeons.BastionStairs;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 46324)]
internal class Doomspike : BasicCreatureScript
{
    public const ushort AuxiliaryEmpathy = 13818;
    public const ushort BloodRage = 13814;
    public const ushort Enrage = 5567;

    public Doomspike(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);
        obj.Tasks.AddTask(SpecialRage, 1000, 0);
    }

    public void SpecialRage()
    {
        Creature? c = GetCreatureFromRegion(46327);
        if (c is not null)
        {
            CheckDistanceAndHandleBuff(c, BloodRage, 480, "Blood Rage");
        }
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        DestroyGameObjectInRegion(2000791); // This destroy walls

        // AddInfluenceToAllPlayersInRegion(200, 1000);
        // AddInfluenceToAllPlayersInRegion(201, 1000);
        DespawnBastionStairsWalls();

        DestroyWall();

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000976)
            {
                go.Destroy();
            }
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        // Pet
        _adds.SpawnCreaturesAroundPos(46327, _unit.WorldSpawnPoint, 120);

        _unit.Tasks.AddTask(CheckHealthAndCast, 5 * 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnBastionStairsWalls();

        base.OnLeaveCombat(owner);
    }

    public void CheckHealthAndCast()
    {
        CheckFriendHealthAndHandleBuff(AuxiliaryEmpathy, 46327, 10, true, "Blood for the blood god!", true);
    }

    public void RemoveStuff()
    {
        _unit.Abilities.EndTargetAbilities(BloodRage);
        _unit.Abilities.EndTargetAbilities(AuxiliaryEmpathy);

        _unit.Tasks.RemoveTask(CheckHealthAndCast);
    }
}

[GeneralScript(CreatureEntry = 46327)]
internal class Clawfang : BasicCreatureScript
{
    public Clawfang(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        DelayedBuff(_unit, 4388); // Taunt Immunity
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        RemoveStuff();

        base.OnDie(obj);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        DelayedBuff(_unit, 4388); // Taunt Immunity

        _unit.Tasks.AddTask(CheckHealthAndCast, 5 * 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnBastionStairsWalls();

        _unit.Abilities.EndTargetAbilities(Doomspike.Enrage);

        RemoveStuff();

        base.OnLeaveCombat(owner);
    }

    public void CheckHealthAndCast()
    {
        CheckFriendHealthAndHandleBuff(Doomspike.AuxiliaryEmpathy, 46324, 10, true, "Blood for the blood god!");
    }

    public void RemoveStuff()
    {
        _unit.Abilities.EndTargetAbilities(Doomspike.BloodRage);
        _unit.Abilities.EndTargetAbilities(Doomspike.AuxiliaryEmpathy);

        _unit.Tasks.RemoveTask(CheckHealthAndCast);
    }
}
