namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.SystemData;
using Game.NetWork.Handler;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(GameObjectEntry = 2000802)]
internal class GoBuffRemoverA : BasicScript
{
    public GoBuffRemoverA(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override bool OnInteract(WorldObject obj, Player target, InteractMenu menu)
    {
        if (target.Abilities.HasBuffById(3057))
        {
            target.SendClientMessage("The brew from cauldron cured Soul Killer!", ChatLogFilter.CWhite1);
            target.Abilities.EndTargetAbilities(3057);
        }

        return true;
    }
}
