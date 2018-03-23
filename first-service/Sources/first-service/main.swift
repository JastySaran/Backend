//.............................******.......................******..................******.........................
                                            //Mark : Import Frameworks
//.............................******.......................******..................******.........................
import Kitura
import HeliumLogger
import CouchDB
import SwiftyJSON
import Cocoa
HeliumLogger.use()
//.............................******.......................******..................******.........................
                                               //Mark : Struct Movies
//.............................******.......................******..................******.........................
struct Movies {
    var title : String
    var type : String
    var actors : Array<Any>
    var duration : Float
    var rating : Float
    var rev : String
    var id : String
    
    func seriliazable () -> [String:Any]{
        return ["title":self.title,"type":self.type,"actors":self.actors,"duration":self.duration,"rating":self.rating,"rev":self.rev,"id":self.id]
    }
}
//.............................******.......................******..................******.........................
//.............................******.......................******..................******.........................
                                //Mark: Converting text or string Into Dictionary
//.............................******.......................******..................******.........................
func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
//.............................******.......................******..................******.........................
//.............................******.......................******..................******.........................
                                     //Mark : Configuration Of CouchDB
//.............................******.......................******..................******.........................
let connectionProperties = ConnectionProperties(host: "localhost", port: 5984, secured: false)
let client = CouchDBClient(connectionProperties: connectionProperties)
let dataBase = client.database("movies")
let router = Router()
//.............................******.......................******..................******.........................

//.............................******.......................******..................******.........................
                                       //Mark: PostMoviesAPI (CouchDB)
//.............................******.......................******..................******.........................
router.post("movies"){ request, responce, next in
    defer {next()}
    router.post("*",middleware: BodyParser())
    
    let rawData = try! request.readString()
    let dict = convertToDictionary(text: rawData!)
    let name = dict!["title"]
    let type = dict!["type"]
    let actors = dict!["actors"]
    let duration = dict!["duration"]
    let rating = dict!["rating"]
    responce.send(name! as! String)
    dataBase.create(JSON(["title":name!,"type":type,"actors":[actors],"duration":duration,"rating":rating])){id, revision, doc, error in
        if let id  = id {
            responce.status(.OK).send(json :["id":id,"actors":[actors]])
            }else{
            responce.status(.internalServerError).send(json :["Message : Inserting Document"])
        }
    }
}
//.............................******.......................******..................******.........................
//.............................******.......................******..................******.........................
                                         //Mark: GetMoviesAPI (CouchDB)
//.............................******.......................******..................******.........................
router.get("getMovies"){ request, responce, next in
    defer {next()}
    dataBase.retrieveAll(includeDocuments: true){ docs, error in
        var movies = [Movies]()
        if error != nil {
            responce.status(.internalServerError).send(json:["error":"Error in retrieving data please try again later"])
        }else{
            if let docs = docs{
            for document in docs ["rows"].arrayValue {
            let title = document["doc"]["title"].stringValue
            let type = document["doc"]["type"].stringValue
            let actors = document["doc"]["actors"].arrayObject
            let duration = document["doc"]["duration"].floatValue
            let rating = document["doc"]["rating"].floatValue
            let rev = document["doc"]["_rev"].stringValue
            let id = document["doc"]["_id"].stringValue
                let movie = Movies(title: title, type: type, actors:actors!, duration: duration, rating: rating, rev: rev, id: id)
                    movies.append(movie)}
            responce.send(json :["Movies":movies.map{ $0.seriliazable()}])}}}
}
//.............................******.......................******..................******.........................
                                 //Mark: DeleteMoviesAPI (CouchDB)
//.............................******.......................******..................******.........................
router.delete("deleteMovie"){ request, responce, next in
     defer{next()}
     router.delete("*",middleware: BodyParser())
     let rawData = try! request.readString()
     let dict = convertToDictionary(text: rawData!)
     let id = dict!["id"]
     let rev = dict!["rev"]
    dataBase.delete(id as! String, rev: rev as! String){ error in
        if error != nil{
            responce.status(.internalServerError).send(json:["error":"Unable to delete record"])
        }else{
            responce.status(.OK).send(json:["sucsess":true])
        }
    }
}
//.............................******.......................******..................******.........................
//.............................******.......................******..................******.........................
                                 // Mark: UpdateMoviesAPI (CouchDB)
//.............................******.......................******..................******.........................
router.put("updateMovie"){ request, responce, next in
    defer {next ()}
    router.put("*",middleware:BodyParser())
    let rawData = try! request.readString()
    let dict = convertToDictionary(text: rawData!)
    let id = dict!["id"]
    let rev = dict!["rev"]
    let name = dict!["title"]
    let actors = dict!["actors"]
    let duration = dict!["duration"]
    let rating = dict!["rating"]
    let type = dict!["type"]
    dataBase.update(id as! String, rev: rev as! String, document: JSON(["type":type,"title":name,"actors":actors,"duration":duration,"rating":rating])){ rev, doc, error in
        if error != nil {
           responce.status(.internalServerError).send(json:["error":"Unable to update record"])
        }else{
           responce.status(.OK).send(json:["sucsess":true])
        }
    }
}
//.............................******.......................******..................******.........................
Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
//.............................******.......................******..................******.........................
