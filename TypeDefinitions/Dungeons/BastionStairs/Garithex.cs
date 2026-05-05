namespace Game.Scripts.Dungeons.BastionStairs;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 7597)]
internal class Garithex : BasicCreatureScript
{
    public const ushort AbilityBloodArmor = 5816;
    public const ushort AbilityDispelBloodArmor = 5817;
    public const ushort AbilityBloodArmorCounter = 5818;

    public Garithex(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnDie(Unit obj)
    {
        RemoveStuff();

        DespawnBastionStairsWalls();

        DestroyWall();

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000970)
            {
                go.Destroy();
            }
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        // GO
        // Helm
        _adds.SpawnGameObject(100544, new(1036126, 998171, 14371), 11);

        // Pauldron
        _adds.SpawnGameObject(100543, new(1035691, 998617, 14351), 3072);

        // Gauntlet
        _adds.SpawnGameObject(100545, new(1035691, 997700, 14351), 2048);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnBastionStairsWalls();

        RemoveStuff();

        base.OnLeaveCombat(owner);
    }

    public void RemoveStuff()
    {
        if (_unit.Region is null)
        {
            return;
        }

        _unit.Abilities.EndTargetAbilities(AbilityBloodArmor);

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && (go.Entry == 100544 || go.Entry == 100543 || go.Entry == 100545))
            {
                go.Destroy();
            }
        }
    }
}

internal class GarithexGo : BasicGameObjectScript
{
    private Creature? _boss;

    public GarithexGo(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(DelayedPlayEffect, 100, 1);
        _boss = GetCreatureFromRegion(7597);

        _go.NoRespawn = false;
        _go.RespawnTimeSeconds = 60;
    }

    private void DelayedPlayEffect()
    {
        SendOnscreenMessageToAllPlayers($"{_go.Name} fortifies Garithex defences!");
        if (_boss is not null)
        {
            _boss.Abilities.AddAbility(Garithex.AbilityBloodArmorCounter, _boss, _boss.EffectiveLevel);
        }
        _unit.PlayEffect(1322);
    }

    public override void OnDie(Unit obj)
    {
        _boss?.Abilities.AddAbility(Garithex.AbilityDispelBloodArmor, _boss, _boss.EffectiveLevel);
        SendOnscreenMessageToAllPlayers(
            $"After destroying {obj.Name} you see an opening in Garithex defences! Strike now!"
        );
    }
}

[GeneralScript(GameObjectEntry = 100544)]
internal class GarithexHelm : GarithexGo
{
    public GarithexHelm(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }
}

[GeneralScript(GameObjectEntry = 100543)]
internal class GarithexPauldron : GarithexGo
{
    public GarithexPauldron(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }
}

[GeneralScript(GameObjectEntry = 100545)]
internal class GarithexGauntlet : GarithexGo
{
    public GarithexGauntlet(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }
}
