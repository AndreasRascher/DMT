Ziele:
 2:2 - Anlagenzeilen (Type/No) durch Sachkontozeilen ersetzen
 1:2 - Buchungsgruppennr durch Produktbuchungsgruppe und MwSt Buchungsgruppe ersetzen

 Workflow:
Wenn 1:1: Aus Feldermapping auswählen
1:2 / 2:2 
- 1.) Import Konfiguration aus Übersicht auswählen, Spalte "Hat Felder mit Ziel Relation" anbieten
  2.) In Zeile anlegen, Feld "Von Feld 1", Feld "Zu Feld 1", "Zu Feld 2" auswählen
  - Felder mandatory kennzeichnen, Status Spalte "unvollständig(rot)", "vollständig(grün)":

Enitäten
- Ersetzungen
  - Name, Anz. Felder Von, Anz. Felder Zu
  - "Zu Feld 1 Tabellenrelation", "Zu Feld 2 Tabellenrelation", "Zu Feld 3 Tabellenrelation"
  - Von Wert Captions,Zu Wert Captions
- Regeln
  - Von Wert 1, Von Wert 2, Zu wert 1, Zu Wert 2
- Zuordnung
  - Importconfiguration, Zieltabelle,  Von Feld 1, Von Feld 2,  Zu Feld 1, Zu Feld 2,

LoadToTemp_Replacement(Header,Rule,Assignment)
SetLookUpFilters
GetAssignmentStatus : option "inconmplete","complete"

TODO:
- Fehlerbehandlung bei Typkonflikten (z.B. Neuer Wert ist Text in Boolean)
- ShowMandatory in allen benötigten Spalten anzeigen (Source1-2, Target 1-2)
- Status / Kennzeichen wenn noch ungültiges Assignment