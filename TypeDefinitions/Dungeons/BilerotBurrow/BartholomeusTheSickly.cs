namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

/*[GeneralScript(CreatureEntry =  20756)]
class MaggotfiendUrhil : BasicScript
{
    public override void OnObjectLoad(Object Obj)
    {
        base.OnObjectLoad(Obj);

        this.Obj = Obj;


        Obj.EvtInterface.AddEventNotify(EventName.OnEnterCombat, OnEnterCombat);
        Obj.EvtInterface.AddEventNotify(EventName.OnLeaveCombat, OnLeaveCombat);
        Obj.ScdInterface.AddTask(ClearImmunities, 900, 0);
        Obj.ScdInterface.AddTask(RageIfFarAway, 1000, 0);

        Unit.AddCrowdControlImmunity(GameData.CrowdControlTypes.All);
    }

    public override void OnRemoveFromWorld(Object Obj)
    {
        OnDie(Obj);
        base.OnRemoveFromWorld(Obj);
    }


    public override void OnEnterCombat(Unit Owner, Unit? attacker)
    {
        Creature c = Obj as Creature;

        SpawnBilerotWalls();

        base.OnEnterCombat(Owner, attacker);
    }

    public override void OnLeaveCombat(Unit Owner)
    {
        DespawnCityDungeonWalls();

        base.OnLeaveCombat(Owner);


        return false;
    }

    public override void OnDie(Unit Obj)
    {
        Obj.ScdInterface.RemoveTask(RageIfFarAway);

        DestroyGameObjectInRegion(2000790);

        DespawnCityDungeonWalls();

        base.OnDie(Obj);
    }
}*/

[GeneralScript(CreatureEntry = 48128)]
internal class BartholomeusTheSickly : BasicCreatureScript
{
    public BartholomeusTheSickly(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        SpawnBilerotWalls();

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        DestroyGameObjectInRegion(2000792);

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }
}
