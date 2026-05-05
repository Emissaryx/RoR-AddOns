namespace Game.Scripts.Dungeons.SigmarsCrypt;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 52379)]
internal class CryptwebQueen : BasicCreatureScript
{
    public CryptwebQueen(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
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
        SetVisible(_unit.Name, 1101);

        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        SpawnSigmarsCryptWalls();

        /*var prms = new List<object>() { 2000904, 844260, 857649, 28536, Obj.Heading }; //Spider adds
        c.ScdInterface.AddTask(SpawnAdds, 30 * 1000, 0, prms);
        prms = new List<object>() { 2000904, 843486, 857279, 28447, Obj.Heading }; //Spider adds
        c.ScdInterface.AddTask(SpawnAdds, 30 * 1000, 0, prms);
        prms = new List<object>() { 2000904, 843982, 856909, 28558, Obj.Heading }; //Spider adds
        c.ScdInterface.AddTask(SpawnAdds, 30 * 1000, 0, prms);*/
    }

    public override void OnLeaveCombat(Unit owner)
    {
        if (!_unit.IsDead)
        {
            SetInvisible("Invisible Creature");
        }

        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }
}
