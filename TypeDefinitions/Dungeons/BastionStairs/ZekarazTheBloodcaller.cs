namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;
using WarEmu.Database.World.Database.Items;

[GeneralScript(CreatureEntry = 46325)]
internal class ZekarazTheBloodcaller : BasicCreatureScript
{
    public const ushort Bloodrage = 2500;
    public const ushort BloodShield = 2501;

    public ZekarazTheBloodcaller(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _adds.SpawnGameObject(2000904, new(1015830, 1013983, 17924), 1024);
        _adds.SpawnGameObject(100538, new(1016980, 1014539, 17917), 2048);
        _adds.SpawnGameObject(100538, new(1016212, 1014538, 17917), 2048);
        _adds.SpawnGameObject(100538, new(1015445, 1014537, 17917), 2048);
        _adds.SpawnGameObject(100538, new(1014679, 1014539, 17917), 2048);
        _adds.SpawnGameObject(100538, new(1014679, 1013381, 17917), 0);
        _adds.SpawnGameObject(100538, new(1015445, 1013381, 17917), 0);
        _adds.SpawnGameObject(100538, new(1016212, 1013382, 17917), 0);
        _adds.SpawnGameObject(100538, new(1016981, 1013381, 17917), 0);

        SendOnscreenMessageToAllPlayers($"Unstoppable rage overtakes {_unit.Name}!");
        _unit.Tasks.AddTask(CastBuff, 4 * 1000, 0);

        RemoveItems();

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(CastBuff);

        _unit.Abilities.EndTargetAbilities(Bloodrage);
        _unit.Abilities.EndTargetAbilities(BloodShield);

        DestroyWall();

        base.OnDie(obj);
    }

    public void RemoveItems()
    {
        foreach (Player plr in _unit.Region.Players)
        {
            plr.Items.RemoveQuestItems(36920);
        }
    }

    public void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000978)
            {
                go.Destroy();
            }
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(CastBuff);

        base.OnLeaveCombat(owner);

        _unit.Abilities.EndTargetAbilities(Bloodrage);
        _unit.Abilities.EndTargetAbilities(BloodShield);
    }

    public void CastBuff()
    {
        _unit.Abilities.AddAbility(Bloodrage, _unit, _unit.EffectiveLevel);
    }
}

[GeneralScript(GameObjectEntry = 100538)]
internal class ZekarazGo1 : BasicGameObjectScript
{
    public ZekarazGo1(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.CaptureDuration = TimeSpan.FromSeconds(2);

        _go.Tasks.AddTask(PlayEffect, 100, 1);

        base.OnObjectLoad(obj);
    }

    public void PlayEffect()
    {
        _go.PlayEffect(437);
    }

    public override void NotifyInteractionComplete(WorldObject obj, Player target)
    {
        target.Items.CreateItemNotify(36920, 1);

        _go.Destroy();
    }
}

[GeneralScript(GameObjectEntry = 2000904)]
internal class ZekarazGo2 : BasicGameObjectScript
{
    private readonly ItemRepository _itemRepository;

    public ZekarazGo2(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository,
        ItemRepository itemRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _itemRepository = itemRepository;
    }

    private int _counter;

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.CaptureDuration = TimeSpan.FromSeconds(2);
    }

    public override void NotifyInteractionComplete(WorldObject obj, Player target)
    {
        ItemInfo? itm = _itemRepository.GetItemInfo(36920);

        if (target.Region is null || target.IsDead || itm is null)
        {
            return;
        }

        ushort itmCount = target.Items.GetItemCount(36920);
        if (itmCount > 0)
        {
            if (_counter > 2)
            {
                target.SendClientMessage(
                    "You can't place more than 3 skulls on the altar!",
                    ChatLogFilter.CSRTellReceive
                );
                return;
            }

            _counter++;

            target.Items.RemoveQuestItems(36920);

            target.SendClientMessage(
                $"You placed all of your {itm.Name} in the {_go.Name}!",
                ChatLogFilter.CSRTellReceive
            );

            Creature? c = GetCreatureFromRegion(46325);

            if (c is not null && !c.IsDead)
            {
                c.Abilities.AddAbility(ZekarazTheBloodcaller.BloodShield, c, c.EffectiveLevel);
                c.Abilities.EndTargetAbilities(ZekarazTheBloodcaller.Bloodrage);
            }
        }
        else
        {
            target.SendClientMessage(
                $"You can't interact with {_go.Name} because you don't have any {itm.Name} in your possession!",
                ChatLogFilter.CAbilityError
            );
        }
    }
}
