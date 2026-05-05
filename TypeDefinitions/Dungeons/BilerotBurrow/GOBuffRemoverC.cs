namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.SystemData;
using Game.NetWork.Handler;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(GameObjectEntry = 2000803)]
internal class GoBuffRemoverC : BasicScript
{
    public GoBuffRemoverC(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override bool OnInteract(WorldObject obj, Player target, InteractMenu menu)
    {
        if (target.Abilities.HasBuffById(21209))
        {
            target.SendClientMessage("The brew from cauldron healed Diseased Attack!", ChatLogFilter.CWhite1);
            target.Abilities.EndTargetAbilities(21209);
        }

        return true;
    }
}
