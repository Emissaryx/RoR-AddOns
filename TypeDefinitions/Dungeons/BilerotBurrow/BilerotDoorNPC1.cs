namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2001403)]
internal class BilerotDoorNpc1 : BasicScript
{
    public BilerotDoorNpc1(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(() => _adds.SpawnGameObject(2000790, new(1503982, 1045963, 11967), 3072), 5000, 1); // Door

        _unit.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
    }
}
