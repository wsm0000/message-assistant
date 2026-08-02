// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KeywordRuleImpl _$$KeywordRuleImplFromJson(Map<String, dynamic> json) =>
    _$KeywordRuleImpl(
      id: json['id'] as String,
      keyword: json['keyword'] as String,
      type:
          $enumDecodeNullable(_$MatchTypeEnumMap, json['type']) ??
          MatchType.contains,
      priority: (json['priority'] as num?)?.toInt() ?? 50,
      scopeGroupIds:
          (json['scopeGroupIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      excludeWords:
          (json['excludeWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      enabled: json['enabled'] as bool? ?? true,
      groupName: json['groupName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$KeywordRuleImplToJson(_$KeywordRuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyword': instance.keyword,
      'type': _$MatchTypeEnumMap[instance.type]!,
      'priority': instance.priority,
      'scopeGroupIds': instance.scopeGroupIds,
      'excludeWords': instance.excludeWords,
      'enabled': instance.enabled,
      'groupName': instance.groupName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MatchTypeEnumMap = {
  MatchType.exact: 'exact',
  MatchType.contains: 'contains',
};
