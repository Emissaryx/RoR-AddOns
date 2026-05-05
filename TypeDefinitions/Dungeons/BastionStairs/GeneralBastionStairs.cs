namespace Game.Scripts.Dungeons.BastionStairs;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 46329)]
internal class BrassBarbarian : BasicScript
{
    public BrassBarbarian(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        ChangeAppearance(1, 90, 229, 408);
        _unit.PlayEffect(1322);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ChangeAppearance(0, 90, 1322);

        base.OnLeaveCombat(owner);
    }
}
