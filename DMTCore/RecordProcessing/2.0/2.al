Funktionen
==========
- Feld Update existierender Records
- Neue Records anlegen
- Fehler bei Update/Insert protokollieren
- Werte Ersetzen vor dem Zuweisen
- Felder in Ziel mit Fixwerten belegen


Feld Update existierender Records
===============================
bufferLoop
    processRecord
        keyFieldLoop
        logError
        findExistingRecord
    processRecord    
        processNonKeyFields
        logError
    processRecord
        updateRecord
        logError

Neue Records anlegen
====================
bufferLoop
    processRecord
        keyFieldLoop
        logError
        findExistingRecord -> exit if insertNewOnlyOption
    processRecord    
        processNonKeyFields
        logError
    processRecord
        InsertOrOverwriteRecord
        logError

Felder in Ziel mit Fixwerten belegen
====================================
targetLoop
    processRecord
        processNonKeyFields
        logError
    processRecord
        UpdateRecord
        logError

Kombiniert über eine RunMode Variable
====================================
RunModes: FieldTransfer, Modify, Insert
bufferLoop    
    
    processRecord
        keyFieldLoop
        logError
        findExistingRecord
    case RunMode of
        FieldTransferToNewRecord:
            processRecord    
                processNonKeyFields
                logError
            processRecord
                updateRecord
                logError
        FieldTransferToExistingRecord:
            processRecord    
                processNonKeyFields
                logError
            processRecord
                InsertOrOverwriteRecord
                logError
        Modify:
                UpdateRecord
                logError
        Insert:
                InsertOrOverwriteRecord
                logError 

    end;

    processRecord    
        processNonKeyFields
        logError
    processRecord
        InsertOrOverwriteRecord
        logError
