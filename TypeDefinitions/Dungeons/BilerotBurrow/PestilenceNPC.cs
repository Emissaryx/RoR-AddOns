namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2001453)]
internal class PestilenceNpc : BasicScript
{
    public PestilenceNpc(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);

        _unit.Speed.SetBaseSpeed(0);
    }
}
