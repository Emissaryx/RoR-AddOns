-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------

-- Always ensure addon table exists
NoOverheal = NoOverheal or {}

-- Only apply German strings when language is German (with safe guards)
if CoreLanguageDirectories
and SystemData
and SystemData.Settings
and SystemData.Settings.Language
and CoreLanguageDirectories[SystemData.Settings.Language.active] == "german"
then

NoOverheal.ADDONNAME        = L"NoOverheal"
NoOverheal.NOTARGET         = L"Kein Ziel."
NoOverheal.TOOLTIPTEXT = L"Linksklick: Zauber abbrechen\nRechtsklick: NoOverheal ein oder aus\nMittelklick: Fenster sperren oder entsperren"
NoOverheal.GREETINGS        = L"NoOverheal geladen. Befehl: /noo"
NoOverheal.MOVEABLE         = L"Fenster ist verschiebbar."
NoOverheal.LOCKED           = L"Fenster ist gesperrt."
NoOverheal.PREVENT          = L"Überheilung verhindert auf "
NoOverheal.ON               = L"NoOverheal aktiviert. Überheilung wird verhindert."
NoOverheal.OFF              = L"NoOverheal deaktiviert. Überheilung ist erlaubt."
NoOverheal.TEXT             = L"Chatbenachrichtigung bei Abbruch aktiviert"
NoOverheal.NOTEXT           = L"Chatbenachrichtigung bei Abbruch deaktiviert"
NoOverheal.HELPHEADLINE     = L"NoOverheal Befehle:"
NoOverheal.HELPON           = L"/noo on  Aktiviert NoOverheal"
NoOverheal.HELPOFF          = L"/noo off  Deaktiviert NoOverheal"
NoOverheal.HELPLOCK         = L"/noo lock  Sperrt das Fenster"
NoOverheal.HELPUNLOCK       = L"/noo unlock  Entsperrt das Fenster"
NoOverheal.HELPTEXT         = L"/noo text  Chatmeldung bei Abbruch aktivieren"
NoOverheal.HELPNOTEXT       = L"/noo notext  Chatmeldung bei Abbruch deaktivieren"

end
