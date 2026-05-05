namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2000893)]
internal class Logazor : BasicScript
{
    public Logazor(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);

        obj.Tasks.AddTask(CheckDespawn, 30 * 1000, 0);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        _unit.Say(
            "It may have been these creatures that awoken us, but it is all those who live who shall be made to serve the Mourkain! We shall arise once more!",
            ChatLogFilter.MonsterSay
        );
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(37964); // Checking for Herald
    }

    public void CheckDespawn()
    {
        bool despawn = true;
        foreach (WorldObject o in _unit.ObjectsInRange)
        {
            if (o is Creature c && c.Entry == 37964 && !c.IsDead)
            {
                despawn = false;
                break;
            }
        }

        if (despawn)
        {
            _unit.Tasks.RemoveTask(CheckDespawn);
            _unit.Tasks.AddTask(_unit.Destroy, 100, 1);
        }
    }
}
