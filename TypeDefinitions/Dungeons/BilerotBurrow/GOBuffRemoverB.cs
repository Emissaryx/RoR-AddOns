namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.SystemData;
using Game.NetWork.Handler;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(GameObjectEntry = 2000804)]
internal class GoBuffRemoverB : BasicScript
{
    public GoBuffRemoverB(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override bool OnInteract(WorldObject obj, Player target, InteractMenu menu)
    {
        if (target.Abilities.HasBuffById(21210))
        {
            target.SendClientMessage("The brew from cauldron cured Pestilent Infection!", ChatLogFilter.CWhite1);
            target.Abilities.EndTargetAbilities(21210);
        }

        return true;
    }
}
