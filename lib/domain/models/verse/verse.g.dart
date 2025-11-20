// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerseModelImpl _$$VerseModelImplFromJson(Map<String, dynamic> json) =>
    _$VerseModelImpl(
      id: json['id'] as String?,
      bibleVerse: json['bible_verse'] as String? ?? '',
      relatedVerses: json['related_verses'] as List<dynamic>? ?? const [],
      passage: json['passage'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      like: json['like'] as bool? ?? false,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
    );

Map<String, dynamic> _$$VerseModelImplToJson(_$VerseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bible_verse': instance.bibleVerse,
      'related_verses': instance.relatedVerses,
      'passage': instance.passage,
      'explanation': instance.explanation,
      'like': instance.like,
      'date_created': instance.dateCreated?.toIso8601String(),
    };
