namespace WorldServer.Scripting.MoonSharp.Proxies;

using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using Services.World;
using World.Objects;

[PublicAPI]
public class CreatureProxy : UnitProxy
{
    private readonly Creature _creature;
    private readonly CreatureGroupService _creatureGroupService;

    [MoonSharpHidden]
    public CreatureProxy(CreatureGroupService creatureGroupService, Creature creature)
        : base(creature)
    {
        _creatureGroupService = creatureGroupService;
        _creature = creature;
    }


    [PublicAPI]
    public uint Entry => _creature.Entry;

    [PublicAPI]
    public void SetState(string stateName, int state) => _creature.ScriptState.SetState(stateName, state);

    [PublicAPI]
    public int? GetState(string stateName) => _creature.ScriptState.GetState(stateName);

    [PublicAPI]
    public void SetAbilitySet(int? abilitySetId) => _creature.AbilitySet.SetAbilitySet(abilitySetId);

    [PublicAPI]
    public void EquipItem(ushort slotId, ushort modelId) => _creature.Items.AddCreatureItem(slotId, modelId);

    [PublicAPI]
    public void UnEquipItem(ushort slotId) => _creature.Items.RemoveCreatureItem(slotId);

    [PublicAPI]
    public int EnableRangeUnits => _creature.Enrage.EnableRangeUnits;

    [PublicAPI]
    public bool NoRespawn { get => _creature.NoRespawn; set => _creature.NoRespawn = value; }

    [PublicAPI]
    public void Say(String message) => _creature.Say(message, Common.Enums.SystemData.ChatLogFilter.MonsterSay);

    [PublicAPI]
    public void Emote(String message) => _creature.Say(message, Common.Enums.SystemData.ChatLogFilter.MonsterEmote);

    [PublicAPI]
    public void AttackStart(Unit target) => _creature.AiInterface.ProcessCombatStart(target);

    [PublicAPI]
    public bool IsInCreatureGroup(int groupId) => _creatureGroupService.IsMemberOf(groupId, _creature.SubType, _creature.Entry);
}
