import ballerinax/java.jdbc;
import ballerina/runtime;
import ballerina/io;
import ballerina/jsonutils;
import ballerina/time;
import ballerina/rabbitmq;

jdbc:Client testDB = new({
    url: "jdbc:postgresql://localhost:5433/bank_records",
    username: "insecure_user",
    password: "password123",
    poolOptions: { maximumPoolSize: 5 }
});

rabbitmq:Connection newConnection = new({ host: "localhost", 
                                        port: 5673, 
                                        username: "insecure_user", 
                                        password: "password123" });

rabbitmq:Channel newChannel1 = new(newConnection);
var queueResult1 = newChannel1->queueDeclare({ queueName: "MyQueue1" });

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

public function main() {
  time:Time|error curWatermark = time:parse("0001-06-26T09:46:22.444-0500",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
  int curWatermarkId = 0;

  while (true) {
    runtime:sleep(5000);
    io:println("Current watermark "+curWatermark.toString());
    var isNew = 1;

    if (curWatermark is time:Time){

      jdbc:Parameter curJwatermark = {
        sqlType: jdbc:TYPE_TIMESTAMP,
        value: curWatermark
      };

      io:println("current time: "+curJwatermark.toString());

      io:println("Watermarked id: " + curWatermarkId.toString());

      var selectRet = testDB->select("SELECT * FROM customers where updated_at > ? order by updated_at, id", Customer, curJwatermark);
    
      if (selectRet is table<Customer>) {
        json jsonConversionRet = jsonutils:fromTable(selectRet);

        foreach var item in selectRet {
          curWatermark = item.updated_at;
          curWatermarkId = item.id;
          var data = <@untainted> ("New data from id: "+curWatermarkId.toString());
          io:println(data);
          io:println("Current watermark "+curWatermark.toString());
        }
      
      isNew = 0;
      } else {
        io:println("Select data from customer table failed: ",
        <string>selectRet.detail()?.message);
    }
  }
}
}