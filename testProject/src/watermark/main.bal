import ballerinax/java.jdbc;
//import ballerina/runtime;
import ballerina/io;
import ballerina/jsonutils;
import ballerina/time;

jdbc:Client testDB = new({
    url: "jdbc:postgresql://localhost/test",
    username: "postgres",
    password: "password",
    poolOptions: { maximumPoolSize: 5 }
});

type Student record {
    int id;
    int age;
    string name;
    time:Time insertedTime;
};

public function main() {
      time:Time|error curWatermark = time:parse("2017-06-26T09:46:22.444-0500",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
  while (true) {
    io:println("\nThe select operation - Select data from a table");
    var selectRet = testDB->select("SELECT * FROM student", Student);
    
    if (selectRet is table<Student>) {
      json jsonConversionRet = jsonutils:fromTable(selectRet);
      foreach var item in selectRet {
        io:println("Time: ", item.insertedTime);
        if (item.insertedTime.time > time:currentTime().time){
          io:println("New data from id: "+item.id.toString());
        }
      }
    } else {
        io:println("Select data from student table failed: ",
        <string>selectRet.detail()?.message);
    }
  }
}

function handleUpdate(jdbc:UpdateResult|jdbc:Error returned, string message) {
    if (returned is jdbc:UpdateResult) {
        io:println(message, " status: ", returned.updatedRowCount);
    } else {
        io:println(message, " failed: ", <string>returned.detail()?.message);
    }
}