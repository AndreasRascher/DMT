# DMT Backup
## Anforderungen
- Elemente wie Verarbeitungsbuch.-Blatt oder Import Konfigurationen sollen sich zwischen Datenbanken übertragen lassen
Import Konfiguration
  * Kombination von Quelldateiname und Zieltabelle bereits vorhanden
    * Ersetzen anbieten 
  * ID bereits vorhanden
    * Nächste freie ID verwenden 
  * Problem gleicher Dateiname und gleiches Ziel aber unterschiedliche Zeilen
    * Lösungsmöglichkeiten - Fehlermeldung bei Anlage der Import Konf. 
  * Felder in Zielsystem nicht vorhanden
    * anbieten, die Felder zu löschen
    * Status der Felder aus ignorieren 
   
## Lösungsansatz
Import Worksheet
 - Typen:
   - Quelldateien (Dateiname)
   - Import Konfiguration (Dateiname)
   - Ersetzungen (Dateiname in Zeilen)
   - Tabellen kopieren
   - Verarbeitungsplanzeile (ToDo: Dateiname in Zeile)
