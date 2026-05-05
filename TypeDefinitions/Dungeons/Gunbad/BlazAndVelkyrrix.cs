namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 38909)]
internal class BlazDaTaminMasta : BasicCreatureScript
{
    public BlazDaTaminMasta(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        foreach (WorldObject o in _creature.ObjectsInRange)
        {
            if (o is Creature creature && creature.Entry == 38907 && !creature.IsDead)
            {
                creature.Abilities.EndTargetAbilities(14897);

                break;
            }
        }

        DestroyWall();

        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(511);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);
    }

    private void DestroyWall()
    {
        if (_creature.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _creature.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100010)
            {
                go.Destroy();
            }
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        bool spiderAlive = false;

        foreach (WorldObject o in _creature.ObjectsInRange)
        {
            if (o is Creature creature && !creature.IsDead && creature.Entry == 38907)
            {
                spiderAlive = true;
                break;
            }
        }

        if (!spiderAlive)
        {
            DelayedBuff(_creature, 13155, "No, it cannot be... Yu 'll pay for dis! Die!"); // Rage
        }

        SetRandomTargetToNpc(38907); // Velkyrrix join fight

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        _creature.Abilities.EndTargetAbilities(13155);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(38907); // Checking for Velkyrrix
    }
}

[GeneralScript(CreatureEntry = 38907)]
internal class Velkyrrix : BasicCreatureScript
{
    public Velkyrrix(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        // Players need to kill both
        _creature.Aggro.AggroResetDistance = 12000;

        _creature.ObjectState.AddEffect(ObjectEffectState.OBJECTEFFECTSTATE_BERSERK);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        foreach (WorldObject o in obj.ObjectsInRange)
        {
            if (o is Creature creature && !creature.IsDead && creature.Entry == 38909)
            {
                DelayedBuff(creature, 13155, "No, it cannot be... Yu 'll pay for dis! Die!"); // Rage
                break;
            }
        }

        obj.Tasks.RemoveTask(SpawnRandomGo);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        SpawnRandomGo();

        SetRandomTargetToNpc(38907); // Blaz join fight

        DelayedBuff(_creature, 14897); // Iron Body

        _creature.Tasks.AddTask(SpawnRandomGo, 15 * 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public void SpawnRandomGo()
    {
        // Spider spawns
        _adds.SpawnGameObjectsAroundPos(2000569, _unit.WorldPosition, 180, 2);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        foreach (WorldObject obj in _creature.ObjectsInRange)
        {
            if (obj is GameObject go && go.Entry == 2000569)
            {
                go.Destroy();
            }

            if (obj is Creature creature && creature.Entry == 38720)
            {
                creature.Destroy();
            }
        }

        _unit.Tasks.RemoveTask(SpawnRandomGo);

        _unit.Abilities.EndTargetAbilities(14897); // Removing Iron Body
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(38909); // Checking for Blaz
    }
}

[GeneralScript(CreatureEntry = 38720)]
internal class VelkyrrixSpawn : BasicScript
{
    public VelkyrrixSpawn(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }
}

[GeneralScript(GameObjectEntry = 2000569)]
internal class VelkyrrixEgg : GameObjectScript
{
    public VelkyrrixEgg(GameObject go)
        : base(go)
    {
        go.NoRespawn = true;
    }

    public override void OnDie(Unit obj)
    {
        obj.PlayEffect(2185);
        obj.Tasks.AddTask(() => obj.IsActive = false, 1000, 1);
    }
}
