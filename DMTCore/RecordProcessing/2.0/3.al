// Neues Process Single Buffer 
while source.moveNext() do begin

    processRecord.setSourceRecord(source.getRecordRef());
    
    case runMode of
      runMode::MigrateOnlyNewRecordsFromSourceToTarget: begin
        ProcessKeyFields(processRecord);
        if not processRecord.HasErrors then
          if not processRecord.findExistingRecord() then begin
             ProcessNonKeyFields(processRecord);
             if not processRecord.HasErrors then
               InsertRecord(processRecord);
           end;
      end;

      runMode::MigrateRecordFromSourceToTarget: begin
         ProcessKeyFields(processRecord);
         if not processRecord.HasErrors() then
           ProcessNonKeyFields(processRecord);
         if not processRecord.HasErrors() then
           InsertOrOverwriteRecord(processRecord);
      end;

      runMode::MigrateFieldFromSourceToTarget: begin
        ProcessKeyFields(processRecord);
        if processRecord.findExistingRecord() then begin
           ProcessNonKeyFields(processRecord);
            if not processRecord.HasErrors() then
                UpdateRecord(processRecord);
        end;
      end;

      runMode::ApplyFixValuesToTarget: begin
        ProcessNonKeyFields(processRecord);
        if not processRecord.HasErrors() then
            UpdateRecord(processRecord);
      end;
    end;

    processRecord.GetResult();
end;