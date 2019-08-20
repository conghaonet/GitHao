import 'package:dio/dio.dart';

import 'package:githao/network/entity/authorization_entity.dart';
import 'package:githao/network/entity/authorization_post.dart';
import 'codehub_client.dart';
import 'entity/commit_entity.dart';
import 'entity/event_entity.dart';
import 'entity/repo_content_entity.dart';
import 'entity/repo_entity.dart';
import 'entity/user_entity.dart';
import 'dio_client.dart';

class ApiService {
  static Future<AuthorizationEntity> login(String credentialsBasic) async {
    Options options = Options(headers: {"Authorization": credentialsBasic});
    Response<Map<String, dynamic>> response = await dioClient.dio.post("/authorizations", data: AuthorizationPost().toJson(), options: options);
    return AuthorizationEntity.fromJson(response.data);
  }

  static Future<UserEntity> getUser(String username) async {
    Response<Map<String, dynamic>> response = await dioClient.dio.get("/users/$username");
    return UserEntity.fromJson(response.data);
  }

  static Future<UserEntity> getAuthenticatedUser() async {
    Response<Map<String, dynamic>> response = await dioClient.dio.get("/user");
    return UserEntity.fromJson(response.data);
  }

/*
  static Future<List<RepoEntity>> getRepos({int page=1, String type='all', String sort='full_name', String direction='asc'}) async {
    Map<String, dynamic> parameters = {'page': page, 'type': type, 'sort': sort, 'direction': direction};
    Response<List<dynamic>> response = await dioClient.dio.get("/user/repos", queryParameters: parameters);
    return response.data.map((item) => RepoEntity.fromJson(item)).toList();
  }
*/

  /// [login] GitHub显示的用户名
  /// [page] 取值从1开始，表示请求第几页，每页返回30笔数据
  /// [type] Can be one of: all, owner, public, private, member
  /// [sort] Can be one of: created, updated, pushed, full_name
  /// [direction] Can be one of: asc or desc
  static Future<List<RepoEntity>> getUserRepos(String login, {int page=1, String type='all', String sort='full_name', String direction='asc'}) async {
    Map<String, dynamic> parameters = {'page': page, 'type': type, 'sort': sort, 'direction': direction};
    Response<List<dynamic>> response = await dioClient.dio.get("/users/$login/repos", queryParameters: parameters);
    return response.data.map((item) => RepoEntity.fromJson(item)).toList();
  }

  static Future<List<RepoEntity>> getOrgRepos(String org, {int page=1, String type='all', String sort='full_name', String direction='asc'}) async {
    Map<String, dynamic> parameters = {'page': page, 'type': type, 'sort': sort, 'direction': direction};
    Response<List<dynamic>> response = await dioClient.dio.get("/orgs/$org/repos", queryParameters: parameters);
    return response.data.map((item) => RepoEntity.fromJson(item)).toList();
  }


/*
  static Future<List<RepoEntity>> getStarredRepos({int page=1, String sort='created', String direction='desc'}) async {
    Map<String, dynamic> parameters = {'page': page, 'sort': sort, 'direction': direction};
    Response<List<dynamic>> response = await dioClient.dio.get("/user/starred", queryParameters: parameters);
    return response.data.map((item) => RepoEntity.fromJson(item)).toList();
  }
*/

  /// [login] GitHub显示的用户名
  /// [sort] One of created (when the repository was starred) or updated (when it was last pushed to). Default: created
  /// [direction] Can be one of: asc or desc
  static Future<List<RepoEntity>> getUserStarredRepos(String login, {int page=1, String sort='created', String direction='desc'}) async {
    Map<String, dynamic> parameters = {'page': page, 'sort': sort, 'direction': direction};
    Response<List<dynamic>> response = await dioClient.dio.get("/users/$login/starred", queryParameters: parameters);
    return response.data.map((item) => RepoEntity.fromJson(item)).toList();
  }

  static Future<List<EventEntity>> getEvents(String login, {String repoName, int page=1}) async {
    Response<List<dynamic>> response;
    if(repoName == null || repoName.isEmpty) {
      response = await dioClient.dio.get("/users/$login/events?page=$page");
    } else {
      response = await dioClient.dio.get("/repos/$login/$repoName/events?page=$page");
    }
    return response.data.map((item) => EventEntity.fromJson(item)).toList();
  }

  static Future<String> getRepoReadme(String owner, String repo) async {
    Options options = Options(headers: {"Accept": "application/vnd.github.VERSION.html"});
    Response<String> response = await dioClient.dio.get("/repos/$owner/$repo/readme", options: options);
    return response.data;
  }

  static Future<List<RepoContentEntity>> getRepoContents(String owner, String repo, String branch, {String path = ''}) async {
    Map<String, dynamic> parameters = {'ref': branch};
    Response<List<dynamic>> response = await dioClient.dio.get("/repos/$owner/$repo/contents/$path", queryParameters: parameters);
    return response.data.map((item) => RepoContentEntity.fromJson(item)).toList();
  }

  static Future<String> getRepoContentRaw(String owner, String repo, String branch, String path) async {
    Options options = Options(headers: {"Accept": "application/vnd.github.VERSION.raw"});
    Map<String, dynamic> parameters = {'ref': branch};
    Response<String> response = await dioClient.dio.get("/repos/$owner/$repo/contents/$path", queryParameters: parameters, options: options);
    return response.data;
  }

  static Future<String> getRepoContentHtml(String owner, String repo, String branch, String path) async {
    Options options = Options(headers: {"Accept": "application/vnd.github.VERSION.html"});
    Map<String, dynamic> parameters = {'ref': branch};
    Response<String> response = await dioClient.dio.get("/repos/$owner/$repo/contents/$path", queryParameters: parameters, options: options);
    return response.data;
  }

  static Future<List<CommitEntity>> getRepoCommits(String owner, String repo, String branch) async {
    Map<String, dynamic> parameters = {'sha': branch};
    Response<List<dynamic>> response = await dioClient.dio.get("/repos/$owner/$repo/commits", queryParameters: parameters);
    return response.data.map((item) => CommitEntity.fromJson(item)).toList();
  }

  static Future<List<RepoEntity>> getTrending({String since='daily', String language=''}) async {
    Map<String, dynamic> parameters = {'since': since, 'language': language};
    Response<List<dynamic>> response = await codehubClient.dio.get("/trending", queryParameters: parameters);
    return response.data.map((item) => RepoEntity.fromJson(item)).toList();
  }
}