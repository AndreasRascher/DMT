# DMT Backup
## Anforderungen
- Elemente wie Verarbeitungsbuch.-Blatt oder Import Konfigurationen sollen sich zwischen Datenbanken übertragen lassen
## Probleme
- Import Konfiguration und Quelldateien sind ID basierte Tabellen. Bei einem Import in bestehende Strukturen passt der ID Bezug der Quelldateien nicht mehr
- Wenn eine Quelldateien ID bereits vorhanden ist, aber der Quelldateienname abweicht
- Wenn die Import Konfiguration bereits existiert, aber auf eine andere Datei verweist
## Lösungsansatz
Import Worksheet
 - Typen:
   - Quelldateien (Dateiname)
   - Import Konfiguration (Dateiname)
   - Ersetzungen (Dateiname in Zeilen)
   - Tabellen kopieren
   - Verarbeitungsplanzeile (ToDo: Dateiname in Zeile)
