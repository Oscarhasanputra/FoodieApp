import 'package:http/http.dart' as http;
class ApiRequest{
    static const apiKey="b9d70ead2c334d4eba6bf7fb009a4658";
    // static const apiKey="390d94877f454fe3ae067e771ef4b8fe";
    static const url="https://api.spoonacular.com/recipes/";
    static Future<http.Response> getReq(urlParam){
        return http.Client().get(url+urlParam+"&apiKey=$apiKey");
    }
}