namespace Game.Scripts.Dungeons.BilerotBurrow;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2000724)]
internal class BilelordSlimehound : BasicScript
{
    public BilelordSlimehound(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }
}
