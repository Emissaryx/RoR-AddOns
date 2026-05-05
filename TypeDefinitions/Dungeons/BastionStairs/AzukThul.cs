namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums;
using Common.Enums.SystemData;
using Game.NetWork.Handler;
using Game.Repositories.World;
using Game.Services;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 47390)]
internal class AzukThul : BasicCreatureScript
{
    private readonly long _timer = 0;

    public AzukThul(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public void ClearStuff()
    {
        _creature.Tasks.RemoveTask(ApplyCurseOfKhorne);
        _creature.Tasks.RemoveTask(ApplyCurseOfKhorne);

        if (_creature.Region is null)
        {
            return;
        }

        foreach (Player plr in _creature.Region.Players)
        {
            plr.Abilities.EndTargetAbilities(13546);
        }
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        DestroyWall();

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        if (_creature.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _creature.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 2000975)
            {
                go.Destroy();
            }
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _adds.SpawnGameObject(2000660, new(989718, 992155, 7200), 3640);
        _adds.SpawnGameObject(2000660, new(989751, 996310, 7200), 2582);
        _adds.SpawnGameObject(2000659, new(995389, 1000542, 7859), 1330);
        _adds.SpawnGameObject(2000659, new(985558, 997806, 7859), 2354);
        _adds.SpawnGameObject(2000659, new(995554, 987912, 7875), 650);

        _creature.Tasks.AddTask(ApplyCurseOfKhorne, 100, 1);
        _creature.Tasks.AddTask(ApplyCurseOfKhorne, 90 * 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public void ApplyCurseOfKhorne()
    {
        SendOnscreenMessageToAllPlayers("Khorne himself cursed you!");
        foreach (Player plr in PlayersInRange())
        {
            _unit.Abilities.AddAbility(13546, plr, _unit.EffectiveLevel);
        }
    }

    public void RespawnGo1()
    {
        if (_timer != 0 && WorldService.RegionTimestampMS > _timer + 60 * 1000) { }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }
}

[GeneralScript(GameObjectEntry = 2000660)]
internal class KhorneAltarAzukThul : GameObjectScript
{
    public KhorneAltarAzukThul(GameObject gameObject)
        : base(gameObject) { }

    public override bool OnInteract(WorldObject obj, Player interactor, InteractMenu menu)
    {
        if (obj is GameObject go)
        {
            if (interactor.Abilities.HasAbilityById((ushort)GameBuffs.MurderBall))
            {
                ScriptHelpers.SendOnscreenMessageToAllPlayers(
                    _gameObject.Region,
                    $"{interactor.Name} lifted the Curse of Khorne from you!"
                );
                ScriptHelpers.RemoveBuffFromAllPlayersInRegion(_gameObject.Region, (ushort)GameBuffs.CurseOfKhorne);
                ScriptHelpers.RemoveBuffFromAllPlayersInRegion(_gameObject.Region, (ushort)GameBuffs.MurderBall);
            }
            else
            {
                interactor.SendClientMessage(
                    $"You can't interact with {go.Name} becase you are not affected by Murder Ball!",
                    ChatLogFilter.CSRTellReceive
                );
            }
        }

        return true;
    }
}

[GeneralScript(GameObjectEntry = 2000659)]
internal class KhorneShrineAzukThul : BasicScript
{
    public KhorneShrineAzukThul(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SayStuff, 30 * 1000, 1);
    }

    public void RemoveStuff()
    {
        _unit.Tasks.RemoveTask(SayStuff);
    }

    public override void SayStuff()
    {
        // SendOnscreenMessageToAllPlayers("Bozhar in his rage charges at new victim for the glory of the Blood God!");
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        RemoveStuff();

        base.OnDie(obj);
    }

    public override bool OnInteract(WorldObject obj, Player interactor, InteractMenu menu)
    {
        if (obj is not GameObject go)
        {
            return true;
        }

        if (interactor.Abilities.HasBuffById((ushort)GameBuffs.CurseOfKhorne))
        {
            interactor.SendClientMessage(
                "Hurry! You must reach Khorne's Altar as fast as possible!",
                ChatLogFilter.CWhite1
            );
            Creature? c = GetCreatureFromRegion(47390);
            c?.Abilities.AddAbility((ushort)GameBuffs.CurseOfKhorne, interactor, c.EffectiveLevel);
        }
        else
        {
            interactor.SendClientMessage(
                $"You can't interact with {go.Name} because you are not affected by Curse of Khorne!",
                ChatLogFilter.CSRTellReceive
            );
        }

        return true;
    }
}
