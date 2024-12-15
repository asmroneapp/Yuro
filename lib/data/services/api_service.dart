import 'package:asmrapp/core/cache/recommendation_cache_manager.dart';
import 'package:asmrapp/data/models/mark_status.dart';
import 'package:asmrapp/data/models/playlists_with_exist_statu/playlists_with_exist_statu.dart';
import 'package:dio/dio.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/works/pagination.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:asmrapp/data/services/interceptors/auth_interceptor.dart';


class WorksResponse {
  final List<Work> works;
  final Pagination pagination;

  WorksResponse({required this.works, required this.pagination});
}

class ApiService {
  final Dio _dio;
  final _recommendationCache = RecommendationCacheManager();

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.asmr.one/api',
        )) {
    _dio.interceptors.add(AuthInterceptor());
  }

  /// 获取作品文件列表
  Future<Files> getWorkFiles(String workId) async {
    try {
      final response = await _dio.get('/tracks/$workId', queryParameters: {
        'v': '1',
      });

      if (response.statusCode == 200) {
        final filesData = {
          'type': 'root',
          'title': 'Root',
          'children': response.data,
        };

        return Files.fromJson(filesData);
      }

      throw Exception('获取文件列表失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 获取作品列表
  Future<WorksResponse> getWorks({int page = 1}) async {
    try {
      final response = await _dio.get('/works', queryParameters: {
        'page': page,
      });

      if (response.statusCode == 200) {
        final List<dynamic> works = response.data['works'] ?? [];
        final pagination = Pagination.fromJson(response.data['pagination']);

        return WorksResponse(
          works: works.map((work) => Work.fromJson(work)).toList(),
          pagination: pagination,
        );
      }

      throw Exception('获取作品列表失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 搜索作品
  Future<WorksResponse> searchWorks({
    required String keyword,
    int page = 1,
    String order = 'create_date',
    String sort = 'desc',
    int subtitle = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/search/${Uri.encodeComponent(keyword)}',
        queryParameters: {
          'page': page,
          'order': order,
          'sort': sort,
          'subtitle': subtitle,
          'includeTranslationWorks': true,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.debug('搜索返回数据: ${response.data}');

        final works = (response.data['works'] as List)
            .map((work) => Work.fromJson(work))
            .toList();

        final pagination = Pagination.fromJson(response.data['pagination']);

        return WorksResponse(
          works: works,
          pagination: pagination,
        );
      }

      throw Exception('搜索失败: ${response.statusCode}');
    } catch (e) {
      throw Exception('搜索请求失败: $e');
    }
  }

  /// 获取收藏列表
  Future<WorksResponse> getFavorites({int page = 1}) async {
    try {
      final response = await _dio.get('/review', queryParameters: {
        'page': page,
        'order': 'updated_at',
        'sort': 'desc',
      });

      if (response.statusCode == 200) {
        final List<dynamic> works = response.data['works'] ?? [];
        final pagination = Pagination.fromJson(response.data['pagination']);

        return WorksResponse(
          works: works.map((work) => Work.fromJson(work)).toList(),
          pagination: pagination,
        );
      }

      throw Exception('获取收藏列表失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 获取推荐作品
  Future<WorksResponse> getRecommendations({
    required String uuid,
    int page = 1,
    int subtitle = 0,
  }) async {
    try {
      final response = await _dio.post(
        '/recommender/recommend-for-user',
        data: {
          'keyword': ' ',
          'userId': uuid,
          'page': page,
          'subtitle': subtitle,
          'localSubtitledWorks': [],
          'withPlaylistStatus': [],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> works = response.data['works'] ?? [];
        final pagination = Pagination.fromJson(response.data['pagination']);

        return WorksResponse(
          works: works.map((work) => Work.fromJson(work)).toList(),
          pagination: pagination,
        );
      }

      throw Exception('获取推荐列表失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 获取热门作品
  Future<WorksResponse> getPopular({
    int page = 1,
    int subtitle = 0,
  }) async {
    try {
      final response = await _dio.post(
        '/recommender/popular',
        data: {
          'keyword': ' ',
          'page': page,
          'subtitle': subtitle,
          'localSubtitledWorks': [],
          'withPlaylistStatus': [],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> works = response.data['works'] ?? [];
        final pagination = Pagination.fromJson(response.data['pagination']);

        return WorksResponse(
          works: works.map((work) => Work.fromJson(work)).toList(),
          pagination: pagination,
        );
      }

      throw Exception('获取热门列表失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 获取相关推荐作品
  Future<WorksResponse> getItemNeighbors({
    required String itemId,
    int page = 1,
    int subtitle = 0,
  }) async {
    try {
      // 先尝试从缓存获取
      final cachedData = _recommendationCache.get(itemId, page, subtitle);
      if (cachedData != null) {
        return cachedData;
      }

      // 缓存未命中，从网络获取
      final response = await _dio.post(
        '/recommender/item-neighbors',
        data: {
          'keyword': '',
          'itemId': itemId,
          'page': page,
          'subtitle': subtitle,
          'localSubtitledWorks': [],
          'withPlaylistStatus': [],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> works = response.data['works'] ?? [];
        final pagination = Pagination.fromJson(response.data['pagination']);

        final worksResponse = WorksResponse(
          works: works.map((work) => Work.fromJson(work)).toList(),
          pagination: pagination,
        );

        // 存入缓存
        _recommendationCache.set(itemId, page, subtitle, worksResponse);

        return worksResponse;
      }

      throw Exception('获取相关推荐失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 获取作品在收藏夹中的状态
  Future<PlaylistsWithExistStatu> getWorkExistStatusInPlaylists({
    required String workId,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/playlist/get-work-exist-status-in-my-playlists',
        queryParameters: {
          'workID': workId,
          'page': page,
          'version': 2,
        },
      );

      if (response.statusCode == 200) {
        return PlaylistsWithExistStatu.fromJson(response.data);
      }

      throw Exception('获取收藏夹列表失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 添加作品到收藏夹
  Future<void> addWorkToPlaylist({
    required String playlistId,
    required String workId,
  }) async {
    try {
      await _dio.post(
        '/playlist/add-works-to-playlist',
        data: {
          'id': playlistId,
          'works': [int.parse(workId)],
        },
      );
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('添加到收藏夹失败', e, stackTrace);
      throw Exception('添加到收藏夹失败: $e');
    }
  }

  /// 从收藏夹移除作品
  Future<void> removeWorkFromPlaylist({
    required String playlistId,
    required String workId,
  }) async {
    try {
      await _dio.post(
        '/playlist/remove-works-from-playlist',
        data: {
          'id': playlistId,
          'works': [int.parse(workId)],
        },
      );
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('从收藏夹移除失败', e, stackTrace);
      throw Exception('从收藏夹移除失败: $e');
    }
  }

  /// 更新作品的标记状态
  Future<void> updateWorkMarkStatus(String workId, String status) async {
    try {
      final response = await _dio.put(
        '/review',
        data: {
          'work_id': int.parse(workId),
          'progress': status,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('标记失败: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('更新标记状态失败', e);
      rethrow;
    }
  }

  /// 将 MarkStatus 枚举转换为 API 参数
  String convertMarkStatusToApi(MarkStatus status) {
    switch (status) {
      case MarkStatus.wantToListen:
        return 'marked';
      case MarkStatus.listening:
        return 'listening';
      case MarkStatus.listened:
        return 'listened';
      case MarkStatus.relistening:
        return 'replay';
      case MarkStatus.onHold:
        return 'postponed';
    }
  }
}
