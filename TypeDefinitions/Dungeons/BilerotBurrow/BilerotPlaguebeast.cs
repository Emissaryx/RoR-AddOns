namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 48126)]
internal class BilerotPlaguebeast : BasicScript
{
    public BilerotPlaguebeast(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnDie(Unit obj)
    {
        obj.Say("Instability claims remains of this beast!", ChatLogFilter.MonsterEmote);
        obj.Tasks.AddTask(obj.Destroy, 100, 1);

        base.OnDie(obj);
    }
}
