namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2001405)]
internal class BilerotDoorNpc3 : BasicScript
{
    public BilerotDoorNpc3(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(() => _adds.SpawnGameObject(2000792, new(1503237, 1046695, 11967), 22), 5000, 1); // Door

        _unit.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
    }
}
