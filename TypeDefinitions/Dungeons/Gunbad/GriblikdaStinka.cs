namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 36549)]
internal class GriblikdaStinka : BasicScript
{
    public GriblikdaStinka(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        if (_unit is Creature c)
        {
            c.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
            _stageNum = -1;

            SetRandomTargetToNpc(2000900); // Greenwingz join fight
        }
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2000900);
    }

    public override void OnDie(Unit obj)
    {
        DestroyWall();
        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(512);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100003)
            {
                go.Destroy();
            }
        }
    }
}

[GeneralScript(CreatureEntry = 2000900)]
internal class OlGreenwingz : BasicScript
{
    public OlGreenwingz(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        if (_unit is not Creature c)
        {
            return;
        }

        c.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        SetRandomTargetToNpc(2000900); // Griblik da Stinka join fight

        _unit.Tasks.AddTask(SpawnRandomGo, 1000, 1);

        _unit.Tasks.AddTask(SpawnRandomGo, 30 * 1000, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        foreach (WorldObject obj in owner.ObjectsInRange)
        {
            if (obj is GameObject go && go.Entry == 2000576)
            {
                go.Destroy();
            }
        }

        _unit.Tasks.RemoveTask(SpawnRandomGo);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        obj.Tasks.RemoveTask(SpawnRandomGo);
    }

    public void SpawnRandomGo()
    {
        if (_unit is not Creature c)
        {
            return;
        }

        c.Say("*** Ol' Greenwingz shots rotten eggs in every direction! ***", ChatLogFilter.MonsterEmote);

        if (
            c.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY) is not null
            && (
                c.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY) is Player
                || c.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY) is Pet
            )
        )
        {
            foreach (Player player in c.PlayersInRange)
            {
                if (
                    !player.IsDead
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                )
                {
                    _adds.SpawnGameObjectsAroundPos(2000576, player.WorldPosition, 180); // Rotten eggs
                }
            }
        }
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(36549);
    }
}

[GeneralScript(GameObjectEntry = 2000576)]
internal class RottenEggOlGreenwingz : BasicScript
{
    public RottenEggOlGreenwingz(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(BreakEgg, (5 + Random.Shared.Next(1, 6)) * 1000, 1);
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        obj.PlayEffect(2185);
    }

    public override void OnDie(Unit obj)
    {
        // Obj.PlayEffect(2185);
        // BreakEgg();
        obj.Tasks.RemoveTask(BreakEgg);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        BreakEgg();
    }

    public void BreakEgg()
    {
        if (_unit is not GameObject go)
        {
            return;
        }

        go.PlayEffect(2185);

        go.Say("*** Terrible stench of rotten wyvern eggs fills the cave... ***", ChatLogFilter.MonsterEmote);

        Creature? olGreenwingz = null;

        foreach (WorldObject o in _unit.ObjectsInRange)
        {
            if (o is Creature c && c.Entry == 2000900)
            {
                olGreenwingz = c;
            }
        }

        if (olGreenwingz is not null)
        {
            foreach (Player player in _unit.PlayersInRange)
            {
                if (
                    player is not null
                    && !player.IsDead
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                    && go.IsWithin3DRadiusUnits(player, 360)
                )
                {
                    olGreenwingz.Abilities.AddAbility(20356, player, olGreenwingz.EffectiveLevel); // Bad Gaz

                    // Disabled as was player ability
                    //olGreenwingz.MythicAbtInterface.AddAbility(1927, player, olGreenwingz.EffectiveLevel); // Sticky Feetz
                }
            }
        }

        go.AbilityCast.StartCast(1927, 1);

        _unit.Tasks.AddTask(_unit.Destroy, 1000, 1);
    }
}
