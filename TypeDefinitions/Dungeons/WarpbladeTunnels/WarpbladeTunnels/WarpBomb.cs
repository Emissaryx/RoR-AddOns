namespace WorldServer.World.Scripting.Dungeons.WarpbladeTunnels;

using Common.Enums.GameData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001381)]
internal class WarpBomb : BasicCreatureScript
{
    public WarpBomb(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _creature.AddCrowdControlImmunity(CrowdControlTypes.All);

        _creature.Aggro.SendAggroUpdate = false;

        _creature.SpeedInterface.Speed = 0;
        _creature.Movement.SetBaseSpeed(_creature.SpeedInterface.Speed);

        obj.Tasks.AddTask(CheckDetonate, 500, 0);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(CheckDetonate);
        obj.Tasks.AddTask(_creature.RequestResurrect, 20 * 1000, 1);

        base.OnDie(obj);
    }

    public void CheckDetonate()
    {
        if (_unit is Creature c && !c.IsDead)
        {
            foreach (Player plr in c.PlayersInRange)
            {
                if (plr is not null && !plr.IsDead && plr.Stealth.StealthLevel < 2 &&
                    !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted) &&
                    !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked) && plr.Abilities.HasBuffById(13712) &&
                    _unit.IsWithin3DRadiusUnits(plr, 360))
                {
                    c.Tasks.AddTask(Detonate, 500, 1);
                    c.Tasks.RemoveTask(CheckDetonate);
                    break;
                }
            }
        }
    }

    public void Detonate()
    {
        _creature.AbilityCast.StartCast(13937, 0);
    }
}
