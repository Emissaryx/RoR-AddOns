namespace Game.Scripts.Dungeons.BastionStairs;

using Game.Repositories.World;
using Game.Services;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 9227)]
internal class BorzharRageborn : BasicCreatureScript
{
    public long Timer;
    public long Timer2;

    public BorzharRageborn(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
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

        // AddInfluenceToAllPlayersInRegion(200, 1000);
        // AddInfluenceToAllPlayersInRegion(201, 1000);
        DespawnBastionStairsWalls();

        DestroyWall();

        base.OnDie(obj);
    }

    private void DestroyWall()
    {
        foreach (WorldObject? o in _creature.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000973)
            {
                go.Destroy();
            }
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _adds.SpawnGameObject(100528, new(1002162, 996393, 7379), 2858);
        _adds.SpawnGameObject(100527, new(1002157, 997002, 7371), 2858);

        Timer = WorldService.RegionTimestampMS;
        Timer2 = Timer;

        // if (Timer + 4999 < now)
        base.OnEnterCombat(owner, attacker);
    }

    public void RespawnGo1()
    {
        if (Timer != 0 && WorldService.RegionTimestampMS > Timer + 60 * 1000) { }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnBastionStairsWalls();

        base.OnLeaveCombat(owner);
    }
}

[GeneralScript(GameObjectEntry = 100528)]
internal class BorzharBanner1 : BasicGameObjectScript
{
    public BorzharBanner1(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterWorld(WorldObject obj)
    {
        base.OnEnterWorld(obj);

        _go.NoRespawn = false;
        _go.RespawnTimeSeconds = 60;

        PlayVfx();
        _go.Tasks.AddTask(PlayVfx, 2000, 0);

        SpawnBeastmen();
        _go.Tasks.AddTask(SpawnBeastmen, 20 * 1000, 0);
        _go.Tasks.AddTask(SayStuff, 20 * 1000, 0);
    }

    private void PlayVfx()
    {
        _go.PlayEffect(1829);
    }

    private void SpawnBeastmen()
    {
        _adds.SpawnCreaturesAroundPos(2000673, _unit.WorldSpawnPoint, 360, 2);
    }

    private void RemoveStuff()
    {
        _unit.Tasks.RemoveTask(PlayVfx);
        _unit.Tasks.RemoveTask(SpawnBeastmen);
        _unit.Tasks.RemoveTask(SayStuff);
    }

    public override void SayStuff()
    {
        SendOnscreenMessageToAllPlayers("More slaves of the Blood God joins the slaughter!");
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        RemoveStuff();
    }
}

[GeneralScript(GameObjectEntry = 100527)]
internal class BorzharBanner2 : BasicGameObjectScript
{
    public BorzharBanner2(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.NoRespawn = false;
        _go.RespawnTimeSeconds = 60;
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        PlayVfx();
        obj.Tasks.AddTask(PlayVfx, 2000, 0);

        SetRandomTarget();
        obj.Tasks.AddTask(SayStuff, 30 * 1000, 1);

        Creature? c = GetCreatureFromRegion(9227);

        if (c is not null)
        {
            DelayedBuff(c, 4388); // Taunt Immunity
        }
    }

    private void PlayVfx()
    {
        _unit.PlayEffect(1829);
    }

    private void RemoveStuff()
    {
        _unit.Tasks.RemoveTask(PlayVfx);
        _unit.Tasks.RemoveTask(SetRandomTarget);
        _unit.Tasks.RemoveTask(SayStuff);
    }

    public override void SayStuff()
    {
        SendOnscreenMessageToAllPlayers("Bozhar in his rage charges at new victim for the glory of the Blood God!");
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        RemoveStuff();

        Creature? boss = GetCreatureFromRegion(9227);
        if (boss is not null && !boss.IsDead && boss.CombatFlag.IsInCombat)
        {
            boss.Abilities.EndTargetAbilities(4388);
            boss.Aggro.Reset();
        }
    }
}
