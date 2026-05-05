namespace Game.Scripts.Dungeons.Gunbad;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 38624)]
internal class Kurga : BasicScript
{
    public Kurga(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }
}
