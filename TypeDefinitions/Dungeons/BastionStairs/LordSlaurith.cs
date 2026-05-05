namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 48112)]
internal class LordSlaurith : BasicCreatureScript
{
    private const ushort Bloodpulse = 5066;
    private const ushort BloodscentAura = 5551;
    private const ushort ScentOfBlood = 5809;
    private const ushort BleedingShout = 5811;

    private readonly ILogger<LordSlaurith> _logger;

    public LordSlaurith(
        Creature creature,
        ILogger<LordSlaurith> logger,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _logger = logger;
        _creature.Enrage.EnableRangeUnits = 3600;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);
        _creature.Aggro.AggroResetDistance = 2760;
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(CastBloodpulse, 20000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        RemoveStuff();

        base.OnLeaveCombat(owner);
    }

    private void RemoveStuff()
    {
        _unit.Tasks.RemoveTask(CastBloodpulse);
    }

    public override void OnDie(Unit obj)
    {
        RemoveStuff();

        //AddInfluenceToAllPlayersInRegion(128, 2000);
        //AddInfluenceToAllPlayersInRegion(129, 2000);

        base.OnDie(obj);
    }

    private void CastBloodpulse()
    {
        _logger.LogDebug("Running buff check");

        if (_unit.IsDead)
        {
            return;
        }

        _logger.LogDebug("Running buff check");

        var randomPlayer = GetRandomPlayerInRange();

        if (randomPlayer is null)
        {
            return;
        }

        _logger.LogDebug("Casting bloodpulse");
        _creature.AbilityCast.StartCast(
            Bloodpulse,
            0,
            true,
            true,
            false,
            true,
            targetPosition: randomPlayer.WorldPosition
        );
        _unit.Tasks.AddTask(CastBloodscentAura, 12000, 1);
    }

    private void CastBloodscentAura()
    {
        var playerWithBloodScent = _unit.PlayersInRange.FirstOrDefault(plr =>
            !plr.IsDead
            && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
            && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
            && !plr.Stealth.IsInGameMasterStealth
            && plr.Abilities.HasBuffById(BloodscentAura)
        );
        if (playerWithBloodScent is not null)
        {
            _logger.LogInformation("Found player with bloodscent aura");
            double plrHate = _creature.Aggro.GetAggro(playerWithBloodScent.Oid)?.Hatred ?? 0;
            double maxHate = _creature.Aggro.GetMaxHatred()?.Hatred ?? 0;
            _creature.Aggro.AddHatred(playerWithBloodScent, maxHate - plrHate + 10000);
            _creature.Abilities.AddAbility(ScentOfBlood, _creature, _creature.EffectiveLevel);
        }
        else
        {
            _logger.LogInformation("No player with bloodscent aura, doing bleeding shout");
            _creature.Abilities.AddAbility(BleedingShout, _creature, _creature.EffectiveLevel);
        }
    }
}
