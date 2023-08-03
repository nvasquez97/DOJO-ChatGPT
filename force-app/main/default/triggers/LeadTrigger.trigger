trigger LeadTrigger on Lead(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  LeadTriggerHandler.handleAll(
    Trigger.new,
    Trigger.old,
    Trigger.newMap,
    Trigger.oldMap,
    Trigger.operationType
  );
}
