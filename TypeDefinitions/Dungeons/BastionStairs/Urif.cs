namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 7622)]
internal class Urif : BasicCreatureScript
{
    public Urif(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        DestroyGameObjectInRegion(2000791); // This destroy walls

        foreach (WorldObject? o in obj.Region.Objects)
        {
            if (o is Creature crea && crea.Entry == 2001395)
            {
                crea.Destroy();
                continue;
            }

            if (o is GameObject go && go.Entry == 100541)
            {
                go.Destroy();
            }
        }

        DespawnBastionStairsWalls();

        DestroyWall();

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000972)
            {
                go.Destroy();
            }
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        // Skull
        _adds.SpawnGameObject(100541, new(1042962, 995811, 13784), 2025);
        _adds.SpawnGameObject(100541, new(1042349, 995807, 13784), 11);

        _unit.Abilities.EndTargetAbilities(5567);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnBastionStairsWalls();

        _unit.Abilities.EndTargetAbilities(5567);

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature crea && crea.Entry == 2001395)
            {
                crea.Destroy();
                continue;
            }

            if (o is GameObject go && go.Entry == 100541)
            {
                go.Destroy();
            }
        }

        base.OnLeaveCombat(owner);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2001395);
    }
}

[GeneralScript(GameObjectEntry = 100541)]
internal class SteamingSkull : BasicGameObjectScript
{
    public SteamingSkull(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(CastAbility, 100, 1);
        obj.Tasks.AddTask(CastAbility, 5 * 1000, 0);

        _go.NoRespawn = false;
        _go.RespawnTimeSeconds = 45;
    }

    public void CastAbility()
    {
        if (_unit.IsDead)
        {
            return;
        }

        foreach (Player plr in _unit.PlayersInRange)
        {
            if (
                plr is not null
                && !plr.IsDead
                && !plr.Stealth.IsInGameMasterStealth
                && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
            )
            {
                _unit.Abilities.AddAbility(5662, plr, _unit.EffectiveLevel);
            }
        }

        _unit.PlayEffect(775);
        _unit.AbilityCast.StartCast(13811, 0);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(CastAbility);
        _unit.Abilities.EndTargetAbilities(13811);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        obj.Tasks.RemoveTask(CastAbility);
        _unit.Abilities.EndTargetAbilities(13811);
    }
}

[GeneralScript(CreatureEntry = 2001395)]
internal class UrifEffectNpc : BasicCreatureScript
{
    public UrifEffectNpc(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _creature.Speed.SetBaseSpeed(0);

        _creature.Aggro.SendAggroUpdate = false;
    }
}
