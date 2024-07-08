public with sharing class WarehouseCalloutService implements Queueable {
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public static void execute(QueueableContext context) {
        runWarehouseEquipmentSync();
    }

    @future(callout=true)
    public static void runWarehouseEquipmentSync() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Object[] deserializedResponse = (Object[]) JSON.deserializeUntyped(
                response.getBody()
            );

            Product2[] equipmentList = new List<Product2>();

            for (Object individualResponse : deserializedResponse) {
                Map<String, Object> responseMap = (Map<String, Object>) individualResponse;
                Product2 equipment = new Product2();

                equipment.Name = (String) responseMap.get('name');
                equipment.Cost__c = (Decimal) responseMap.get('cost');
                equipment.ProductCode = (String) responseMap.get('_id');
                equipment.Current_Inventory__c = (Integer) responseMap.get(
                    'quantity'
                );
                equipment.Maintenance_Cycle__c = (Integer) responseMap.get(
                    'maintenanceperiod'
                );
                equipment.Replacement_Part__c = (Boolean) responseMap.get(
                    'replacement'
                );
                equipment.Lifespan_Months__c = (Integer) responseMap.get(
                    'lifespan'
                );
                equipment.Warehouse_SKU__c = (String) responseMap.get('sku');

                equipmentList.add(equipment);
            }

            if (equipmentList.size() > 0) {
                upsert equipmentList;
            }
        }
    }
}
