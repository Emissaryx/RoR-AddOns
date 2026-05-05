namespace Game.Scripts.Dungeons.SigmarsCrypt;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 3186)]
internal class SisterEudecia : BasicCreatureScript
{
    public SisterEudecia(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 820;
        _creature.Enrage.StartPosition = new(1494699, 219869, 8649);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        base.OnEnterCombat(owner, attacker);

        SpawnSigmarsCryptWalls();
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        DespawnCityDungeonWalls();

        foreach (WorldObject? o in obj.Region.Objects.ToList())
        {
            if (o is not null && o is Creature crea && crea.Entry == 2001448)
            {
                crea.Destroy();
                break;
            }
        }

        base.OnDie(obj);
    }
}
