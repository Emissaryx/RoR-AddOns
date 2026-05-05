namespace WorldServer.World.Scripting.Dungeons.LostVale;

using Common.Enums.GameData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 6860)]
internal class WhitefireBroodmother : BasicScript
{
    public WhitefireBroodmother(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);

        _unit.ObjectState.AddEffect(ObjectEffectState.OBJECTEFFECTSTATE_BERSERK);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(SpawnRandomGo);
        obj.Tasks.RemoveTask(SpawnRandomGo);

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        _unit.Tasks.RemoveTask(SpawnRandomGo);
        _unit.Tasks.RemoveTask(SpawnRandomGo);

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature crea && crea.Entry == 6824)
            {
                crea.Destroy();
            }
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        SpawnRandomGo();

        _unit.Tasks.AddTask(SpawnRandomGo, 15 * 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public void SpawnRandomGo()
    {
        // Spider spawns
        _adds.SpawnCreaturesAroundPos(100479, _unit.WorldPosition, 180, 2);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }
}

[GeneralScript(GameObjectEntry = 100479)]
internal class WhitefireEgg : BasicGameObjectScript
{
    public WhitefireEgg(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.NoRespawn = true;
    }

    public override void OnDie(Unit obj)
    {
        obj.PlayEffect(2185);
        obj.Tasks.AddTask(obj.Destroy, 1000, 1);
    }
}
