import ballerinax/java.jdbc;
import ballerina/io;
import ballerina/jsonutils;
import ballerina/time;
import ballerina/http;
import ballerina/log;

jdbc:Client testDB = new({
    url: "jdbc:postgresql://localhost:5433/bank_records",
    username: "insecure_user",
    password: "password123",
    poolOptions: { maximumPoolSize: 5 }
});

type Customer record {
    int id;
    string first_name;
    string last_name;
    string phone;
    string email;
    time:Time created_at;
    time:Time updated_at;
};

type Account record {
    int id;
    string name;
    decimal balance;
    string 'type;
    int customer_id;
    time:Time created_at;
    time:Time updated_at;
};

type Transaction record {
    int id;
    string description;
    decimal delta;
    int account_id;
    time:Time created_at;
    time:Time updated_at;
};



@http:ServiceConfig {
    basePath: "/"
}
service api on new http:Listener(8081) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/customers"
    }
    resource function getCustomers(http:Caller caller, http:Request req) {

        var selectRet = testDB->select("SELECT * FROM customers", Customer);

        if (selectRet is table<Customer>) {
            var result = caller->respond(jsonutils:fromTable(selectRet));

            if (result is error) {
                log:printError("Error sending response", result);
            }
        } else {
        error err = selectRet;
        io:println("Select data from customer table failed: ",
                <string> err.detail()["message"]);
        }
    }

     @http:ResourceConfig {
        methods: ["POST"],
        path: "/customers"
    }
    resource function getCustomersBulk(http:Caller caller, http:Request req) {

        var body = req.getJsonPayload();
        if (body is json) {
            int[]|error params = int[].constructFrom(body);
            if (params is int[]) {
                jdbc:Parameter wrappedParam = { sqlType: jdbc:TYPE_ARRAY, value: params, direction: jdbc:DIRECTION_IN };
                var selectRet = testDB->select("SELECT * FROM customers WHERE id = ANY(?)", Customer, wrappedParam);

                if (selectRet is table<Customer>) {
                    var result = caller->respond(jsonutils:fromTable(selectRet));

                    if (result is error) {
                        log:printError("Error sending response", result);
                    }
                } else {
                    error err = selectRet;
                    io:println("Select data from customer table failed: ",
                            <string> err.detail()["message"]);
                    http:Response res = new;
                    res.statusCode = 500;
                    var result = caller->respond(res);

                    if (result is error) {
                        log:printError("Error sending response", result);
                    }
                }
            } else {
                io:println("Invalid body");
                error err = error("Invalid body");
                http:Response res = new;
                res.statusCode = 400;
                var result = caller->respond(res);

                if (result is error) {
                    log:printError("Error sending response", result);
                }
            }
        } else {
            io:println("Invalid body");
            error err = error("Invalid body");
            http:Response res = new;
            res.statusCode = 400;
            var result = caller->respond(res);

            if (result is error) {
                log:printError("Error sending response", result);
            }
        }
    }
}
