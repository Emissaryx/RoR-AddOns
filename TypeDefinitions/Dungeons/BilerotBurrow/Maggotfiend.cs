namespace Game.Scripts.Dungeons.BilerotBurrow;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 20756)]
internal class Maggotfiend : BasicScript
{
    public Maggotfiend(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnDie(Unit obj)
    {
        DestroyGameObjectInRegion(2000790);

        base.OnDie(obj);
    }
}
