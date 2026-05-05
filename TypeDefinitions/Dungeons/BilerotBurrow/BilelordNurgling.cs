namespace Game.Scripts.Dungeons.BilerotBurrow;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2001378)]
internal class BilelordNurgling : BasicScript
{
    public BilelordNurgling(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }
}
