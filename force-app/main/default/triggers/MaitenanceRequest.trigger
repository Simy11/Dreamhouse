trigger MaitenanceRequest on Case(after update) {
    MaintenanceRequestHelper.updateMaintenanceRequests(
        Trigger.New,
        Trigger.OldMap
    );

}
