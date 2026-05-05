namespace WorldServer.World.Scripting.Dungeons.BloodwroughtEnclave;

using Common.Enums.GameData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2000763)]
internal class Cilius : BasicCreatureScript
{
    public Cilius(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnDie(Unit obj)
    {
        DespawnCityDungeonWalls();

        DestroyGameObjectInRegion(650);

        base.OnDie(obj);
    }
}
