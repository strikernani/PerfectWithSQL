import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import MySQL
import Foundation



print("Hello, world!")

let server :HTTPServer = HTTPServer()
server.serverPort = 3307
server.documentRoot = "webroot"

//starting SQLServer
let testHost = "127.0.0.1"
let testUser = "root"
let testPassword = "newpassword"
let testDB = "perfect_schema"


func fetchUserData(username : String , password : String) -> [String : Any] {
    
    let mysql = MySQL() // Create an instance of MySQL to work with
    
    let connected = mysql.connect(host: testHost, user: testUser, password: testPassword, db: testDB)
    
    guard connected else {
        // verify we connected successfully
        print(mysql.errorMessage())
        return ["response" : mysql.errorMessage()]
    }
    
    defer {
        mysql.close() //This defer block makes sure we terminate the connection once finished, regardless of the result
    }
    
    // Run the Query (for example all rows in an options table)
    let querySuccess = mysql.query(statement: "SELECT * FROM perfect_schema.p_user1 WHERE username = '\(username)' AND password ='\(password)'")
    // make sure the query worked
    guard querySuccess else {
        return ["response" : "failure"]
    }
    
    // Save the results to use during this session
    let results = mysql.storeResults()! //We can implicitly unwrap because of the guard on the querySuccess. You’re welcome to use an if-let here if you like.
    
    
    var ary = [String:Any]()
    var response = Dictionary<String, Any>()
    response["status"] = "Success"
    response["message"] = "Successfully Logged in."
    
    results.forEachRow { (element) in
        debugPrint(element)
        ary[element.description] = element
        response["response"] = ["userid": element[0]!,
                                "username": element[1]!,
                                "email": element[3]!,
                                "mobilenumber": element[4]!
        ]

        
    }
    
   
    
    return ["response" : response]
    }



func insertUserData(userdetails : [String : Any]) -> [String : Any] {
    
    let mysql = MySQL() // Create an instance of MySQL to work with
    
    let connected = mysql.connect(host: testHost, user: testUser, password: testPassword, db: testDB)
    
    guard connected else {
        // verify we connected successfully
        print(mysql.errorMessage())
        return ["response" : mysql.errorMessage()]
    }
    
    defer {
        mysql.close() //This defer block makes sure we terminate the connection once finished, regardless of the result
    }
    
    // Run the Query (for example all rows in an options table)
    let querySuccess = mysql.query(statement: "INSERT INTO perfect_schema.p_user1(username,password,email,mobilenumber) VALUES('\(userdetails["username"]!)','\(userdetails["password"]!)','\(userdetails["email"]!)','\(userdetails["mobilenumber"]!)')")
    // make sure the query worked
       guard querySuccess else {
            return ["response" : "failure"]
        }
    
    // Save the results to use during this session
    let results = mysql.storeResults()
    //We can implicitly unwrap because of the guard on the querySuccess. You’re welcome to use an if-let here if you like.
    
    
    var response = Dictionary<String, Any>()
    response["status"] = "Success"
    response["message"] = "Success"
    response["response"] = ["description": "Succesfully user details are saved"]

    
    results?.forEachRow { (element) in
        
    }
    
    return ["response" : response]
}








//creating Routes
var routes = Routes()

routes.add(method: .get, uri: "/") { (request, response) in
    response.setBody(string: "My response success body")
    //without the below line response will not come to view
    response.completed()
}

//default json function

func returnJSONMessage(message : String,description : String, response : HTTPResponse)
{
    
    do {
        try response.setBody(json: ["message" : message])
        response.setHeader(.contentType , value :"application./json")
            response.completed()

        
    } catch{
        response.setBody(string: "My badrequest body")
        response.status = .badRequest
        response.completed()
    }
}
func convertToDictionary(text: String) -> [String: Any] {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return [:]
}


routes.add(method: .get, uri: "/jsonResponse") { (request , response) in
    
    returnJSONMessage(message :"Hello! This is the sample json response",description : "Success", response : response)
}

//MARK:- My SQL services
routes.add(method: .get, uri: "/getuser/") { (request , response) in
    
    var postParams = convertToDictionary(text: request.queryParams[0].0)
    debugPrint(postParams)

    var username : String!
    var password : String!
    if request.queryParams[0].0 == "username"
    {
        username = request.queryParams[0].1
    }
    if request.queryParams[1].0 == "password"
    {
        password = request.queryParams[1].1

    }
    if username == nil || password == nil
    {
        response.setBody(string: "Please enter correct fields")
        response.status = .badRequest
        response.completed()
        return
    }
    
    do {
        var resFiltered = fetchUserData(username: username ,password : password)
        
        try response.setBody(json: resFiltered["response"] as! [String : Any]) 
        //without the below line response will not come to view
        response.setHeader(.contentType , value :"application./json")
        response.completed()
        
        
    } catch{
        response.setBody(string: "Failure")
        response.status = .badRequest
        response.completed()
    }

    

}
routes.add(method: .post, uri: "/saveUser") { (request , response) in
    

    debugPrint(request.postParams)
    

    var postParams = convertToDictionary(text: request.postBodyString!)
    debugPrint(postParams)

    do {
        var resFiltered : [String : Any] = insertUserData(userdetails: postParams)
        
        try response.setBody(json: resFiltered["response"] as! [String : Any])
        //without the below line response will not come to view
        response.setHeader(.contentType , value :"application./json")
        response.completed()
        
        
    } catch{
        response.setBody(string: "Failure")
        response.status = .badRequest
        response.completed()
    }
    
    
}


routes.add(method: .get, uri: "/students/{num_student}") { (request , response) in
    
    
    guard let numStuString = request.urlVariables["num_student"],
        let numStudents = Int(numStuString) else{
        
            response.completed()
            return
    }
    
    returnJSONMessage(message :"The number of students given by you is \(numStudents)",description : "Success", response : response)
}



server.addRoutes(routes)


do {
    try server.start()
}catch PerfectError.networkError(let err, let msg){

print("network error thrown :\(err) \(msg)")
}
