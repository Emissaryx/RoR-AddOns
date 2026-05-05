namespace WorldServer.World.Scripting.Dungeons.BloodwroughtEnclave;

using Common.Enums.GameData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001401)]
internal class YozigTheBlooded : BasicCreatureScript
{
    public YozigTheBlooded(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        SetInvisible("Invisible Creature");

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        SetVisible(_unit.Name, 1656);

        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        SendOnscreenMessageToAllPlayers("You hear terrible wail and after a moment you hear many voices in the distance that answers this call!");

        SpawnGorgers();

        _unit.Tasks.AddTask(SpawnGorgers, "SpawnAdd", 30 * 1000, 0); // adds

        SpawnBloodwroughtWalls();
    }

    private void SpawnGorgers()
    {
        _adds.SpawnCreaturesAroundPos(2001400, _unit.WorldPosition, 240, 3);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        if (!_unit.IsDead)
        {
            SetInvisible("Invisible Creature");
        }

        base.OnLeaveCombat(owner);
        DespawnCityDungeonWalls();
    }

    public override void OnDie(Unit obj)
    {
        DespawnCityDungeonWalls();

        DestroyGameObjectInRegion(652);

        base.OnDie(obj);
    }
}
