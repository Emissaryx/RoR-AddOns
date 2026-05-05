namespace Game.Scripts.Dungeons.BilerotBurrow;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2000716)]
internal class BilerotNurgling : BasicScript
{
    public BilerotNurgling(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.11 && _stageNum < 1 && !_unit.IsDead)
        {
            foreach (WorldObject o in _unit.ObjectsInRange)
            {
                if (o is Creature crea && !crea.IsDead && crea.Entry == 2000718 && _unit.IsInCastRangeUnits(crea, 600))
                {
                    crea.Abilities.AddAbility(13928, crea, crea.EffectiveLevel); // Rage
                }
            }

            _stageNum = 1;
        }
    }
}
