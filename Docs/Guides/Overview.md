# Data Migration Tool (DMT)

## Überblick
Das Data Migration Tool ist eine Sammlung von Funktionalitäten zur Unterstützung von Datenmigrationen nach Microsoft Business Central.
Die Apps richten sich an Berater, Entwickler oder techn. versierte Kunden mit einem Verständnis für das NAV/BC Datenmodell. Um eine bessere Performance zu erreichen (z.B. gegenüber Rapid Start) werden Daten als CSV Dateien verwendet.

## Allgemeine Funktionsweise
Daten aus einem anderen ERP System werden als CSV oder Excel-Datei exportiert. Die Dateien werden in Business Central importiert. Je Datei wird eine **Import Konfiguration** angelegt und eine Zieltabelle definiert. Die Spaltenüberschriften aus der CSV-Datei werden den Spaltennamen der BC Zieltabelle zugeordnet. Beim Import in die Zieltabelle werden alle Felder entsprechend der Einrichtung validiert. Datensätze mit Fehlern werden nicht übernommen. Alle Fehler werden in einem Protokoll gesammelt. Die einzelnen Arbeitsschritte werden in einem Verarbeitungsplan erfasst und organisiert. Nach der Simulationsphase kann die vollständige Einrichtung exportiert und in der zukünftigen Produktivumgebung importiert werden.

### Voraussetzungen
- genügend freie Objekte in der Business Central Lizenz 
    - Alternativ: Service Tier mit Entwicklerlizenz
- für Exporte aus Altsystem NAV: Eine freie/verfügbare Dataport(bis NAV2009) bzw. XMLPort (Ab NAV2013) Objekt ID in der Kundenlizenz