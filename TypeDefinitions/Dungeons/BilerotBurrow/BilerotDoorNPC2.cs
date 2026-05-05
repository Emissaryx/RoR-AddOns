namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2001404)]
internal class BilerotDoorNpc2 : BasicScript
{
    public BilerotDoorNpc2(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(() => _adds.SpawnGameObject(2000791, new(1502499, 1045964, 11967), 1024), 5000, 1); // Door

        _unit.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
    }
}
