namespace Game.Scripts.Dungeons.BastionStairs;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 45224)]
internal class GahlvotDarkrage : BasicCreatureScript
{
    public GahlvotDarkrage(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 720;
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        DestroyWall();

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000974)
            {
                go.Destroy();
            }
        }
    }

    public void ClearStuff()
    {
        foreach (WorldObject? obj in _unit.Region.Objects)
        {
            if (obj is Creature creature && creature.Entry == 2001145)
            {
                creature.Destroy();
            }
        }

        _unit.Abilities.EndTargetAbilities(5567);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        // Pet
        _adds.SpawnCreaturesAroundPos(16081, _unit.WorldPosition, 240);

        _unit.Abilities.EndTargetAbilities(5567);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }
}

[GeneralScript(CreatureEntry = 16081)]
internal class Beastrip : BasicCreatureScript
{
    public Beastrip(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        Creature? c = GetCreatureFromRegion(45224);
        if (c is not null && !c.IsDead && c.CombatFlag.IsInCombat)
        {
            DelayedBuff(c, 5567); // Rage
        }

        base.OnDie(obj);
    }
}
