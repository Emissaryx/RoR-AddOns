namespace Game.Scripts.Dungeons.SigmarsCrypt;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 52870)]
internal class TobiasTheFallen : BasicCreatureScript
{
    public TobiasTheFallen(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1080;
        _creature.Enrage.StartPosition = new(1496898, 217664, 8649);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        base.OnEnterCombat(owner, attacker);

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);

        SpawnSigmarsCryptWalls();
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 300, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }
}
