# Empfohlene Vorgehensweise
        
## Export
Exportieren Sie die Tabellendaten mithilfe aus NAV mit Hilfer der  bereitgestellten [Export Objekte](#Export-Objekte)
## Simulation in einem eigenen Mandant
- Zur Ausarbeitung des Verarbeitungsplans empfiehlt sich ein eigener Mandant in dem die Einrichtung und Migrationsschritte erprobt werden können. 
## Import der Dateien
            i. Excel Dateien: Datenlayout definieren
            ii. Excel Dateien: Performance Tipp: Als MSDos CSV Speichern
            iii. Import als Zip
            iv. Download
            v. Update/erneutes hochladen
        d. Erstellen der Import Konfigurationen
            i. Dateien aus der Übersicht hinzufügen
            ii. Import in Puffertabelle
            iii. Feldzuordnung Vorschlagen
            iv. Feldzuordnung durchführen (siehe Schema.csv)
            v. Ersetzungen definieren und den einzelnen Fieldmappings zuordnen
        e. Übernahme in Ziel Tabelle
            i. Nur neue
            ii. Eigene Puffer Objekte
        f. Fehlerprotokoll auswerten
        g. Reihenfolge der Aktionen auf Basis der Import Konfigurationen in einem Verarbeitungplan erfassen.
        Mit c weitermachen bis alle benötigten Tabellen übernommen wurden. (?) 
        h. Wenn bei der Simulation alles übernommen wurde, die Einrichtung exportieren und für den Go-Live oder weitere Demo Mandanten verwenden
    3. Typische Fehlerquellen
        a. Fehlende Basis Einrichtungen
            i. Tabellen wie Nummernserie, Herkunftscodes, Währung, Dimensionstabellen, Länder, Sprachen werden in vielen anderen Tabellen verwendet. Diese sollten zuerst eingelesen werden. 
        b. Import Reihenfolge (Relationen innerhalb einer Tabelle) 
            i. Unternehmenskontakte vor Personenkontakten mit Unternehmensbezug, Debitoren ohne Rechnungsdebitor vor Debitoren mit. 
            ii. Feld Unternehmenskontaktnr. (?) nicht validieren, in einem zusätzlichen Feldupdate validiert einfügen
        c. Reihenfolge zwischen Tabellen
            i. Kontakt - Debitoren / Kreditor (Autom. Anlage von Kontakten - > Insert (false)
        d. Reihenfolge der Feldvalidierung
            i. Beim Validieren werden mitunter andere Felder mit Inhalten gefüllt. So können Werte die übernommen wurden je nach Reihenfolge der Validierung wieder verloren gehen. Um diese Probleme zu ermitteln werden im Fehlerprotokoll diese Überschreibungen notiert
        e. Dimensionen aus NAV vor Version NAV2013
            i. Stand: 8.8.24 : Eigene Verarbeitungscodeunit erforderlich
        f. Dimensionen ab NAV2013
            i. Die Dimensionstabellen  können direkt übernommenen werden. Wenn in dem Mandanten bereits neue Buchungen mit Dimensionen hinzugefügt wurden darf die Übernahme nicht noch einmal erfolgen
        g. Tabellen mit Status Feldern, z.B. Stücklisten
            i. Import der Tabelle mit einem Fixiert für das Statusfeld, bei dem die Felder validieren können (im Beispiel "Entwurf"). Übernahme des Status Feldes in einem 2. Lauf (Feldupdate) 
            
    4. Einrichtungen
        a. DMT Einrichtung
            i. Profil: NAV spezifische Prüfungen aktivieren [Liste der Funktionen(z.B. Standard) CSV Format) ]
            ii. Backup aus anderen Mandanten importieren
            iii. Schema.CSV importieren
        b. DMT Quelldateien & Datenlayouts
        c. Import Konfiguration
            i. Page Actions
        d. Fehlerprotokoll
            i. Typen
            ii. Trigger Changes
            iii. Excel Export ignorierter Fehler

# Export Objekte
[Export für NAV Versionen bis 2009 R2]([../images/DMT_ExportObjects_NAVClassic.png](https://github.com/AndreasRascher/DMT/blob/NAV-Upgrade-Helper/Docs/images/DMT_ExportObjects_NAVClassic.png))
