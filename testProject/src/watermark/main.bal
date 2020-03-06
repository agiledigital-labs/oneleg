import ballerinax/java.jdbc;
import ballerina/runtime;
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
  time:Time|error curWatermark = time:parse("0001-06-26T09:46:22.444-0500",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ");

  while (true) {
    runtime:sleep(2000);
    var selectRet = testDB->select("SELECT * FROM student order by insertedTime", Student);
    
    if (selectRet is table<Student>) {
      json jsonConversionRet = jsonutils:fromTable(selectRet);
      foreach var item in selectRet {
        if (curWatermark is time:Time){
          if (item.insertedTime.time > curWatermark.time){
            curWatermark = item.insertedTime;
            io:println("New data from id: "+item.id.toString());
          }
        }
      }
    } else {
        io:println("Select data from student table failed: ",
        <string>selectRet.detail()?.message);
    }
  }
}