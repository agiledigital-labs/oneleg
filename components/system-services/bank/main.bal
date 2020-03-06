import ballerinax/java.jdbc;
//import ballerina/runtime;
import ballerina/io;
import ballerina/jsonutils;
import ballerina/time;

jdbc:Client testDB = new({
    url: "jdbc:postgresql://localhost/bank_records",
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
    bigdecimal balance;
    string type;
    int customer_id;
    time:Time created_at;
    time:Time updated_at;
};

type Transaction record {
    int id;
    string description;
    bigdecimal delta;
    acccount_id id;
    time:Time created_at;
    time:Time updated_at;
};


public function main() {

}

function handleUpdate(jdbc:UpdateResult|jdbc:Error returned, string message) {
    if (returned is jdbc:UpdateResult) {
        io:println(message, " status: ", returned.updatedRowCount);
    } else {
        io:println(message, " failed: ", <string>returned.detail()?.message);
    }
}