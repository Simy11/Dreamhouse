@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    global static HttpResponse respond(HttpRequest request) {
        Assert.areEqual(
            'https://th-superbadge-apex.herokuapp.com/equipment',
            request.getEndpoint(),
            'Wrong endpoint called'
        );
        Assert.areEqual(
            'GET',
            request.getMethod(),
            'Wrong request method called'
        );

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(
            '[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"}]'
        );
        response.setStatusCode(200);
        return response;
    }
}
